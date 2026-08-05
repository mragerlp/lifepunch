using System;

namespace LifePunch.DXRP.Addons.Tags;

public sealed class LpTagEffectFrame
{
    private LpTagPaletteRole[] _roles = Array.Empty<LpTagPaletteRole>();

    public int GraphemeCount { get; private set; }
    public ReadOnlySpan<LpTagPaletteRole> Roles => _roles.AsSpan( 0, GraphemeCount );
    public string Decoration { get; internal set; } = string.Empty;
    public int TranslateXPixels { get; internal set; }
    public int FrameKey { get; internal set; }
    public double NextChangeDelayMilliseconds { get; internal set; } = double.PositiveInfinity;
    public bool RequiresWholeNameFallback { get; internal set; }
    internal int RoleCapacity => _roles.Length;

    public int RedRoleCount
    {
        get
        {
            var count = 0;
            for ( var index = 0; index < GraphemeCount; index++ )
            {
                if ( _roles[index] == LpTagPaletteRole.Red )
                    count++;
            }

            return count;
        }
    }

    public void Reset( int graphemeCount )
    {
        if ( graphemeCount < 0 )
            throw new ArgumentOutOfRangeException( nameof( graphemeCount ) );

        if ( _roles.Length < graphemeCount )
            _roles = new LpTagPaletteRole[graphemeCount];
        else if ( graphemeCount > 0 )
            Array.Clear( _roles, 0, graphemeCount );

        GraphemeCount = graphemeCount;
        Decoration = string.Empty;
        TranslateXPixels = 0;
        FrameKey = 0;
        NextChangeDelayMilliseconds = double.PositiveInfinity;
        RequiresWholeNameFallback = false;
    }

    public LpTagPaletteRole GetRole( int index )
    {
        if ( index < 0 || index >= GraphemeCount )
            throw new ArgumentOutOfRangeException( nameof( index ) );

        return _roles[index];
    }

    internal void SetRole( int index, LpTagPaletteRole role )
    {
        if ( index < 0 || index >= GraphemeCount )
            throw new ArgumentOutOfRangeException( nameof( index ) );

        _roles[index] = role;
    }

    internal void SetAllRoles( LpTagPaletteRole role )
    {
        for ( var index = 0; index < GraphemeCount; index++ )
            _roles[index] = role;
    }
}
