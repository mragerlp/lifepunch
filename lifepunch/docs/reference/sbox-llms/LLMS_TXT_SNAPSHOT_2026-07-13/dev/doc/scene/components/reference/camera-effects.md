# Camera Effects

Shake, punch and tilt on any `CameraComponent`. Effects stack, run out on their own, and don't touch the player's aim, they only move what's rendered.

```csharp
// rumble the screen for a second
Scene.Camera.AddShake( amplitude: 5f, frequency: 40f, duration: 1f );

// kick the view up and let it bounce back, like recoil
Scene.Camera.AddPunch( new Angles( -2f, 0, 0 ) );
```

`AddShake` is a sustained rumble, a duration of zero shakes until you call `Stop()` on the returned effect. `AddPunch` is a single kick that springs back, either along a direction or in view angles, with an optional FOV punch for impact. `AddTilt` eases the camera to a lean and back, good for damage indication or peeking.

These are local. Call them on whichever client should feel them, from a damage callback for example.

## EnvShake

`EnvShake` is the map component version, for earthquakes and explosions. Place it in a scene or Hammer map and it shakes every player within `Radius`, falling off toward the edge, or everywhere with `GlobalShake`. It can also kick nearby physics objects with `ShakePhysics`, and `Rumble` game controllers.

`StartShake()` and `StopShake()` control it, and they broadcast so every player gets the shake.

## Custom effects

For a custom effect, implement `ICameraModifier` on a component and reshape the view in `ModifyCamera`. It runs once per camera per frame while the component is enabled, and `CameraOrder` decides who goes first. This is the same hook the player controller, vehicles and weapons use to drive the camera.

```csharp
public class DrunkCamera : Component, ICameraModifier
{
	public void ModifyCamera( CameraComponent camera, ref CameraView view )
	{
		var sway = MathF.Sin( Time.Now * 2f ) * 5f;

		view.Rotation *= Rotation.FromRoll( sway );
		view.FieldOfView += sway;
	}
}
```

The view has the position, rotation, field of view and clip planes. Change whatever you like, the next modifier gets your result.
