# Custom Snapshot Data

In some circumstances you may want to add additional data to the network snapshot that gets sent to clients when they join a server. One example of this might be serializing and deserializing voxel world data.


[Components](/dev/doc/scene/components) in the [Scene](/dev/doc/scene/scenes) can write and read their own data during the snapshot sending and receiving process by implementing `Component.INetworkSnapshot`.


# Writing Snapshot Data

To write snapshot data for a Component you can simply implement the `WriteSnapshot` method on a component.


```csharp
  	private byte[] MyVoxelData { get; set; }
    
	void INetworkSnapshot.WriteSnapshot( ref ByteStream writer )
	{
		writer.WriteArray( MyVoxelData );
	}
```


# Reading Snapshot Data

Reading snapshot data can be done by implementing `ReadSnapshot` on a component. If you have expensive loading work to do with this data, override `OnLoad` and return a `Task` so the loading screen waits for it to finish before continuing.


```csharp
	void INetworkSnapshot.ReadSnapshot( ref ByteStream reader )
	{
        MyVoxelData = reader.ReadArray<byte>();
	}
 
    protected override async Task OnLoad()
    {
        await LoadVoxelWorld( MyVoxelData );
    }

	private Task LoadVoxelWorld( byte[] data )
	{
		// ...
		return Task.CompletedTask;
	}
```
