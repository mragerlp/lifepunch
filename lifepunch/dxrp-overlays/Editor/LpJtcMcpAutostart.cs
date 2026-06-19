// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH DXRP workspace overlay" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// is the sole-owned intellectual property of lifepunch.co. It is NOT licensed for resale,
// redistribution, sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Reflection;
using Editor;
using Sandbox;

namespace Dxura.RP.Game;

/// <summary>
/// jtc.mcp-server only binds HTTP when its "MCP Server" dock opens. Cursor <c>sbox-jtc</c>
/// needs <c>:29015/mcp</c> without that manual step — mirror chomnr autostart behavior here.
/// Uses reflection (no compile-time ref to <c>package.jtc.mcp-server.editor</c>) so editor boot
/// does not spam <c>tool.frame</c> when jtc is not mounted yet.
/// Swap point: remove when jtc adds editor-load autostart upstream.
/// </summary>
public static class LpJtcMcpAutostart
{
	const int DefaultPort = 29015;
	static bool _done;

	[EditorEvent.Frame]
	public static void OnFrame()
	{
		if ( _done )
			return;

		_done = true;
		TryAutostartOnce();
	}

	static void TryAutostartOnce()
	{
		try
		{
			var serverType = ResolveJtcServerType();
			if ( serverType is null )
			{
				Log.Info( "[LifePunch] jtc MCP not loaded — add jtc/mcp-server in Library Manager." );
				return;
			}

			// HTTP listener alone is insufficient — EditorBridge wires in McpServerDock ctor.
			EditorWindow.DockManager.SetDockState( "MCP Server", true );

			var dockType = ResolveJtcDockType();
			var current = dockType?.GetProperty( "Current", BindingFlags.Public | BindingFlags.Static )?.GetValue( null );
			if ( current is null )
			{
				Log.Warning( "[LifePunch] jtc MCP dock failed to open — Editor menu -> MCP Server (smart_toy)." );
				return;
			}

			var getOrStart = serverType.GetMethod(
				"GetOrStart",
				BindingFlags.Public | BindingFlags.Static,
				binder: null,
				types: new[] { typeof( int ) },
				modifiers: null );

			if ( getOrStart is null )
			{
				Log.Warning( "[LifePunch] jtc MCP autostart: McpHttpServer.GetOrStart missing." );
				return;
			}

			var server = getOrStart.Invoke( null, new object[] { DefaultPort } );
			if ( server is null )
			{
				Log.Warning( "[LifePunch] jtc MCP autostart: GetOrStart returned null." );
				return;
			}

			var isListening = serverType.GetProperty( "IsListening" )?.GetValue( server ) as bool? ?? false;
			var port = serverType.GetProperty( "Port" )?.GetValue( server ) as int? ?? DefaultPort;

			if ( isListening )
				Log.Info( $"[LifePunch] jtc MCP ready — http://localhost:{port}/mcp (dock + bridge)" );
			else
				Log.Warning( "[LifePunch] jtc MCP autostart: server not listening — open MCP Server dock." );
		}
		catch ( Exception ex )
		{
			var message = ex.InnerException?.Message ?? ex.Message;
			if ( message.Contains( "conflicts with an existing registration", StringComparison.OrdinalIgnoreCase ) )
				Log.Info( "[LifePunch] jtc MCP already listening on :29015 (MCP Server dock)." );
			else
				Log.Warning( $"[LifePunch] jtc MCP autostart skipped: {message}" );
		}
	}

	static global::System.Type ResolveJtcDockType()
	{
		foreach ( var asm in AppDomain.CurrentDomain.GetAssemblies() )
		{
			var asmName = asm.GetName().Name;
			if ( asmName is null || !asmName.Contains( "jtc.mcp-server", StringComparison.OrdinalIgnoreCase ) )
				continue;

			var t = asm.GetType( "SboxMcp.McpServerDock" );
			if ( t is not null )
				return t;
		}

		return null;
	}

	static global::System.Type ResolveJtcServerType()
	{
		foreach ( var asm in AppDomain.CurrentDomain.GetAssemblies() )
		{
			var asmName = asm.GetName().Name;
			if ( asmName is null || !asmName.Contains( "jtc.mcp-server", StringComparison.OrdinalIgnoreCase ) )
				continue;

			var t = asm.GetType( "SboxMcp.Mcp.McpHttpServer" );
			if ( t is not null )
				return t;
		}

		return null;
	}
}
