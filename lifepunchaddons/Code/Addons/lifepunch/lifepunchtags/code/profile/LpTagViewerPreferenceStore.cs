using System;
using System.Collections.Generic;
using Sandbox;

namespace LifePunch.DXRP.Addons.Tags;

public sealed class LpTagViewerPreferenceStore : ILpTagViewerPreferenceEditor
{
    public const string ReduceMotionCookieKey = "lifepunchtags.viewer.reduce_motion";
    public const string DisableAnimationsCookieKey = "lifepunchtags.viewer.disable_animations";
    public const string HideDotPlusCookieKey = "lifepunchtags.viewer.hide_dot_plus";

    private static readonly object SharedGate = new();
    private static LpTagViewerPreferenceStore _shared;

    private readonly Queue<LpViewerTagPreferencesV1> _pendingNotifications = new();
    private bool _isPublishingChanges;

    private LpTagViewerPreferenceStore()
    {
        Current = new LpViewerTagPreferencesV1(
            Game.Cookies.Get<bool>( ReduceMotionCookieKey, false ),
            Game.Cookies.Get<bool>( DisableAnimationsCookieKey, false ),
            Game.Cookies.Get<bool>( HideDotPlusCookieKey, false ) );
    }

    public static LpTagViewerPreferenceStore Shared
    {
        get
        {
            lock ( SharedGate )
            {
                return _shared ??= new LpTagViewerPreferenceStore();
            }
        }
    }

    public LpViewerTagPreferencesV1 Current { get; private set; }

    public event Action<LpViewerTagPreferencesV1>? Changed;

    public void SetReduceMotion( bool value )
    {
        if ( value == Current.ReduceMotion )
            return;

        Game.Cookies.Set<bool>( ReduceMotionCookieKey, value );
        Publish( Current with { ReduceMotion = value } );
    }

    public void SetDisableAnimations( bool value )
    {
        if ( value == Current.DisableAnimations )
            return;

        Game.Cookies.Set<bool>( DisableAnimationsCookieKey, value );
        Publish( Current with { DisableAnimations = value } );
    }

    public void SetHideDotPlusDecorations( bool value )
    {
        if ( value == Current.HideDotPlusDecorations )
            return;

        Game.Cookies.Set<bool>( HideDotPlusCookieKey, value );
        Publish( Current with { HideDotPlusDecorations = value } );
    }

    private void Publish( LpViewerTagPreferencesV1 value )
    {
        Current = value;
        _pendingNotifications.Enqueue( value );
        if ( _isPublishingChanges )
            return;

        _isPublishingChanges = true;
        try
        {
            while ( _pendingNotifications.Count > 0 )
            {
                var notification = _pendingNotifications.Dequeue();
                Changed?.Invoke( notification );
            }
        }
        finally
        {
            _isPublishingChanges = false;
        }
    }

#if LIFEPUNCH_LOCAL
    internal static void ResetSharedForTests()
    {
        lock ( SharedGate )
        {
            if ( _shared is not null )
                _shared.Changed = null;

            _shared = null;
        }
    }
#endif
}
