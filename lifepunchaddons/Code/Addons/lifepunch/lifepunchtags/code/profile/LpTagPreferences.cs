namespace LifePunch.DXRP.Addons.Tags;

public readonly record struct LpTagSurfacePreference(
    bool Enabled,
    string SelectedEffectKey );

public readonly record struct LpStoredTagPreferencesV1(
    int SchemaVersion,
    ulong Revision,
    LpTagSurfacePreference Chat,
    LpTagSurfacePreference Scoreboard,
    LpTagSurfacePreference Nameplate );

public readonly record struct LpTagProfileWritePayloadV1(
    int SchemaVersion,
    LpTagSurfacePreference Chat,
    LpTagSurfacePreference Scoreboard,
    LpTagSurfacePreference Nameplate );

public readonly record struct LpEffectiveTagStyleV1(
    LpTagEffectId ChatEffectId,
    LpTagEffectId ScoreboardEffectId,
    LpTagEffectId NameplateEffectId,
    ulong Revision );
