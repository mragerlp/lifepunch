# ITemporaryEffect

The interface Component.ITemporaryEffect is used on a component that comes to an end.


```csharp
	public interface ITemporaryEffect
	{
		// Should return true if the effect is active in a visible way
		bool IsActive { get; }

		// Indicates to the target object that we want it to die. If it's looping then
		// it should stop now and put itself in a state where it will eventually die.
		void DisableLooping() { }
	}
```


This is implemented on ParticleEffect and ParticleEmitter,  and returns true while they're emitting and have particles that are still alive.  It is also implemented on SoundPoint and returns true while the sound is playing.


The intended usage of this interface is to allow you to check a temporary GameObject to see if it's finished being useful - in a generic way. This is how the TemporaryEffect component works.
