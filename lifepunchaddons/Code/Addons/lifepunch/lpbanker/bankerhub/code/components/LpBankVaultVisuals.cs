// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH™ Banker Job for DXRP" (s&box ident: lifepunch.banker · addon ident: bankerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.Banker;

/// <summary>
/// Vault state → world-readable visuals (Law 6: a spectator knows the state without a menu).
/// Baseline: a single status PointLight child — dark when OFF, amber blink while BOOTING,
/// steady green when RUNNING (blue-tinted while the door is open).
/// Dynamic light as a component, never emissive-texture-only, per digital-machine §6.
/// Box-before-bones: no door animation, no bone stacks in S2 (tracked BANKER-01 in TECH_DEBT.md).
/// </summary>
[Title( "LIFEPUNCH Bank Vault Visuals (S2 baseline)" )]
[Category( "LifePunch/Banker" )]
public sealed class LpBankVaultVisuals : Component
{
	private const string StatusLightName = "vault_status_glow";
	private const float BootBlinkHz = 2f;

	private static readonly Color RunningColor = new( 0.15f, 1f, 0.45f, 1f );
	private static readonly Color BootingColor = new( 1f, 0.65f, 0.1f, 1f );
	private static readonly Color DoorOpenColor = new( 0.25f, 0.55f, 1f, 1f );

	[Property] public LpBankVaultEntity Vault { get; set; }

	private GameObject _statusGo;
	private PointLight _statusLight;
	private TimeSince _sinceStart;

	protected override void OnStart()
	{
		if ( !Vault.IsValid() )
			Vault = Components.Get<LpBankVaultEntity>( FindMode.EverythingInSelf );

		EnsureStatusLight();
		_sinceStart = 0;
	}

	protected override void OnUpdate()
	{
		if ( !Vault.IsValid() || !_statusLight.IsValid() )
			return;

		switch ( Vault.State )
		{
			case LpBankVaultEntity.VaultState.Off:
				_statusLight.Enabled = false;
				break;

			case LpBankVaultEntity.VaultState.Booting:
				_statusLight.Enabled = ( (int)( _sinceStart * BootBlinkHz * 2f ) % 2 ) == 0;
				_statusLight.LightColor = BootingColor;
				break;

			case LpBankVaultEntity.VaultState.Running:
				_statusLight.Enabled = true;
				_statusLight.LightColor = Vault.DoorOpen ? DoorOpenColor : RunningColor;
				break;
		}
	}

	private void EnsureStatusLight()
	{
		_statusGo = GameObject.Children
			.FirstOrDefault( child => child.IsValid()
			                          && child.Name.Equals( StatusLightName, System.StringComparison.OrdinalIgnoreCase ) );

		if ( !_statusGo.IsValid() )
		{
			_statusGo = new GameObject( GameObject, false, StatusLightName );
			_statusLight = _statusGo.Components.Create<PointLight>();
			_statusLight.Radius = 120f;
			_statusLight.Attenuation = 0.75f;
			_statusLight.Shadows = false;
			_statusLight.Enabled = false;
			AlignStatusLightToBody();
		}
		else
		{
			_statusLight = _statusGo.Components.Get<PointLight>( FindMode.EverythingInSelf );
		}
	}

	private void AlignStatusLightToBody()
	{
		var renderer = GameObject.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		if ( !renderer.IsValid() || !_statusGo.IsValid() )
			return;

		var bounds = renderer.LocalBounds;
		if ( bounds.Size.Length < 0.01f )
			return;

		// Front-upper face — where the endgame ModelDoc pass will author a real led_status attachment.
		_statusGo.LocalPosition = new Vector3(
			bounds.Maxs.x * 0.6f,
			bounds.Center.y,
			bounds.Center.z + bounds.Size.z * 0.25f );
	}
}
