using System;

namespace LifePunch.DXRP.Addons.Tags;

public interface ILpTagProfileClient : IDisposable
{
    LpTagClientMode Mode { get; }
    event Action<LpTagProfileReadResult>? ReadCompleted;
    event Action<LpTagMutationResult>? MutationCompleted;
    void ReadOwnProfile( LpTagProfileReadRequest request, ulong menuGeneration );
    void MutateOwnProfile( LpTagMutationRequest request, ulong menuGeneration );
}
