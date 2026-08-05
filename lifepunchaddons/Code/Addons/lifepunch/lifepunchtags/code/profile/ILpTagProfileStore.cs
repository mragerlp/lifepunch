using System.Threading.Tasks;

namespace LifePunch.DXRP.Addons.Tags;

public enum LpTagProfileLoadStatus : byte
{
    Found,
    NotFound,
    Unreadable,
    Unavailable
}

public enum LpTagProfileWriteStatus : byte
{
    Success,
    Conflict,
    Unavailable
}

public readonly record struct LpTagProfileLoadResult(
    LpTagProfileLoadStatus Status,
    LpStoredTagPreferencesV1 Record,
    string FilteredError );

public readonly record struct LpTagProfileWriteResult(
    LpTagProfileWriteStatus Status,
    LpStoredTagPreferencesV1 CanonicalRecord,
    string FilteredError );

public interface ILpTagProfileStore
{
    Task<LpTagProfileLoadResult> LoadAsync( ulong steamId );

    Task<LpTagProfileWriteResult> CompareExchangeAsync(
        ulong steamId,
        ulong expectedRevision,
        string requestIdentifier,
        LpTagProfileWritePayloadV1 normalizedPayload );
}
