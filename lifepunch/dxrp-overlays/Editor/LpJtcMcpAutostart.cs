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
using Editor;
using Sandbox;
using SboxMcp.Mcp;

namespace Dxura.RP.Game;

/// <summary>
/// jtc.mcp-server only binds HTTP when its "MCP Server" dock opens. Cursor <c>sbox-jtc</c>
/// needs <c>:29015/mcp</c> without that manual step — mirror chomnr autostart behavior here.
/// Swap point: remove when jtc adds editor-load autostart upstream.
/// </summary>
public static class LpJtcMcpAutostart
{
	static bool _started;

	[EditorEvent.Frame]
	public static void OnFrame()
	{
		if ( _started )
			return;

		try
		{
			var server = McpHttpServer.GetOrStart( McpHttpServer.DefaultPort );
			_started = server.IsListening;

			if ( _started )
				Log.Info( $"[LifePunch] jtc MCP autostart — http://localhost:{server.Port}/mcp" );
			else
				Log.Warning( "[LifePunch] jtc MCP autostart: server not listening — open MCP Server dock." );
		}
		catch ( Exception ex )
		{
			Log.Warning( $"[LifePunch] jtc MCP autostart failed: {ex.Message}" );
		}
	}
}
