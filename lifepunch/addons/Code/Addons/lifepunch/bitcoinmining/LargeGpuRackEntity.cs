// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Miner" (s&box ident: lifepunch.bitcoinmining · addon ident: bitcoinmining) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// Large stacked GPU rack placeable — same behavior as <see cref="GpuRackEntity"/> with
/// <see cref="GpuRackEntity.AdvancedRack"/> enabled (2× yield). Prefab: <c>large-gpu-rack</c>.
/// </summary>
[Title( "Large GPU Rack" )]
[Category( "LifePunch/Bitcoin Miner" )]
public sealed class LargeGpuRackEntity : GpuRackEntity
{
}
