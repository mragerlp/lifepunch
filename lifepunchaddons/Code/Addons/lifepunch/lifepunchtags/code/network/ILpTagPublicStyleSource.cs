using System;

namespace LifePunch.DXRP.Addons.Tags;

public interface ILpTagPublicStyleSource
{
    bool IsAvailable { get; }
    bool TryGet( ulong steamId, out LpEffectiveTagStyleV1 style );
    event Action<ulong, LpEffectiveTagStyleV1>? Changed;
}
