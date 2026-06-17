// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// LifePunch shared physics setup for placeable props — collider + ground contact.
// Mirrors DXRP Prop.Modify (model.Bounds → BoxCollider) + printer feet-on-floor.
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;

namespace LifePunch.DXRP.Addons;

/// <summary>Collider + ground contact for world props (racks, terminals, hubs).</summary>
public static class LifePunchPropPhysics
{
	/// <summary>Fit <see cref="BoxCollider"/> to the mounted vmdl, then sit mesh feet on the surface (host only).</summary>
	public static void SetupPhysicalProp( GameObject go, bool alignGround = true )
	{
		if ( !go.IsValid() )
			return;

		SyncBoxColliderFromModel( go );

		if ( alignGround )
			LifePunchGroundContact.AlignMeshBottom( go );
	}

	/// <summary>DXRP Prop pattern — <c>model.Bounds</c> drives BoxCollider center + scale in model space (matches ModelDoc white wireframe).</summary>
	public static bool SyncBoxColliderFromModel( GameObject go )
	{
		if ( !go.IsValid() )
			return false;

		var renderer = go.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		var box = go.Components.Get<BoxCollider>( FindMode.EverythingInSelf );
		if ( !renderer.IsValid() || !box.IsValid() || renderer.Model is null )
			return false;

		var bounds = renderer.Model.Bounds;
		box.Center = bounds.Center;
		box.Scale = bounds.Size;
		box.IsTrigger = false;
		box.Static = false;
		box.OnPhysicsChanged();
		return true;
	}

	/// <summary>Logs <c>model.Bounds</c> center/size for prefab BoxCollider bake (copy into prefab JSON).</summary>
	public static bool TryGetModelColliderBake( GameObject go, out Vector3 center, out Vector3 size )
	{
		center = default;
		size = default;

		if ( !go.IsValid() )
			return false;

		var renderer = go.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		if ( !renderer.IsValid() || renderer.Model is null )
			return false;

		var bounds = renderer.Model.Bounds;
		center = bounds.Center;
		size = bounds.Size;
		return true;
	}

	/// <summary>Dev / scale-audit logging for ModelDoc + prefab tuning.</summary>
	public static void LogModelPhysics( GameObject go, string tag )
	{
		if ( !go.IsValid() )
			return;

		var renderer = go.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		var box = go.Components.Get<BoxCollider>( FindMode.EverythingInSelf );
		if ( renderer.IsValid() && renderer.Model is not null )
		{
			var bounds = renderer.Model.Bounds;
			Log.Info( $"LIFEPUNCH_PROP_PHYSICS {tag} modelBounds center={bounds.Center} size={bounds.Size} extents={bounds.Extents}" );
		}

		if ( renderer.IsValid() )
		{
			var mesh = renderer.Bounds;
			Log.Info( $"LIFEPUNCH_PROP_PHYSICS {tag} renderBounds size={mesh.Size} mins={mesh.Mins} maxs={mesh.Maxs}" );
		}

		if ( box.IsValid() )
			Log.Info( $"LIFEPUNCH_PROP_PHYSICS {tag} boxCollider center={box.Center} scale={box.Scale}" );
	}
}
