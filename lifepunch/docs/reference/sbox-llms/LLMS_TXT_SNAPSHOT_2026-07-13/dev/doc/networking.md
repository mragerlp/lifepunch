# Networking & Multiplayer

Networking is built right into s&box, so turning a single-player scene into a shared multiplayer experience takes surprisingly little code. GameObjects can be easily replicated to other clients, RPCs can be sent to the server or peer-to-peer and there is full dedicated server support.

:::warning
The networking system in s&box is purposefully simple and easy. Our initial aim isn't to provide a bullet proof server-authoritative networking system. Our aim is to provide a system that is really easy to use and understand.
:::

## Ways to Use It

- **Lobbies** - peer-to-peer games where one player hosts a lobby and others join
- **Dedicated Servers** - run persistent, server-authoritative, headless servers for your game
- **Custom Networking** - talk to external services over HTTP and WebSockets

## How It Works

The quickest way to get going is the **Network Helper** component - drop it into your scene and you have a working multiplayer setup, with players spawning and connecting out of the box.

Under the hood, everything revolves around **networked GameObjects**. Any GameObject can be made networked by calling `NetworkSpawn()`, after which its `[Sync]` properties replicate to everyone and its RPCs can be invoked remotely. From there, **ownership**, **visibility**, and **permissions** give you fine-grained control over who can do what, while **network events** let your components react to players joining and leaving.

## Pages

### [Network Helper](/dev/doc/networking/network-helper)

The easiest way to get a multiplayer game running - a ready-made component that handles spawning, connecting, and common setup. Start here, then customise it or write your own.

### [Networked Objects](/dev/doc/networking/networked-objects)

Make any GameObject networked with `NetworkSpawn()` so it exists for every connected player.

### [Ownership](/dev/doc/networking/ownership)

Assign and check which connection owns a networked object.

### [Sync Properties](/dev/doc/networking/sync-properties)

Replicate a property's latest value to other players whenever it changes using the `[Sync]` attribute.

### [RPC Messages](/dev/doc/networking/rpc-messages)

Call component methods remotely across the network.

### [Network Events](/dev/doc/networking/network-events)

React to players joining, leaving, and objects spawning in the scene.

### [Network Visibility](/dev/doc/networking/network-visibility)

Control whether a networked object is sent to a specific player.

### [Custom Snapshot Data](/dev/doc/networking/custom-snapshot-data)

Attach extra data to the snapshot new players receive when they join a server.

### [Connection Permissions](/dev/doc/networking/connection-permissions)

Let the host adjust what an individual connection is allowed to do.

### [Testing Multiplayer](/dev/doc/networking/testing-multiplayer)

Tools and tricks for testing your game without a second player on hand.

### [Dedicated Servers](/networking/dedicated-servers/)

Install, configure, and run standalone s&box servers.

### [Platform Chat](/dev/doc/networking/chat)

Drop-in text chat that's routed through the host, validated, and filtered for you.

### [Http Requests](/dev/doc/networking/http-requests)

Make asynchronous GET/POST/DELETE requests with built-in JSON support.

### [WebSockets](/dev/doc/networking/websockets)

Connect to external servers for custom networking or persistent data.
