# Classes

s&box comes with a good amount of helper classes that simplifies working with various renderer features, such as lighting, decals, depth, envmaps, g-buffer, and many others. 

* 🌥️ [Ambient Light](/dev/doc/rendering/shaders/classes/ambientlight)
* * How to sample ambient light, DDGI/envprobe/lightmap probe/sky light priority
* 🔗 [Bindless API](/dev/doc/rendering/shaders/classes/bindless-api)
* * How bindless API works, how to assign a bindless texture or sampler from C# and read it from the shader
* 🎇 [Decals](/dev/doc/rendering/shaders/classes/decals)
* * Applying decals in your custom shaders, understanding the structure of decals structured buffer, and extra data byte address buffer, reading packed buffer data, helper functions
* 👀 [Depth](/dev/doc/rendering/shaders/classes/depth)
* * How to sample depth and get various data from it
* 🪩 [Dynamic Reflections](/dev/doc/rendering/shaders/classes/dynamic-reflections)
* * Adding support for dynamic reflections to your custom shader
* 🎨 [EnvMap](/dev/doc/rendering/shaders/classes/envmap)
* * How to sample environment map probe for your custom shader
* 🌁 [Fog](/dev/doc/rendering/shaders/classes/fog)
* * Applying fog and its separate effects, such as gradient fog, cubemap fog, and volumetric fog
* 🌍 [G-Buffer](/dev/doc/rendering/shaders/classes/g-buffer)
* * Everything you need to know about reading its contents, and writing to G-Buffer
* 💡 [Light](/dev/doc/rendering/shaders/classes/light)
* * Iterating all light sources in your custom shader, understanding light data, sampling shadows, light contribution types, and separatae directional light data   
* 🚝 [Motion](/dev/doc/rendering/shaders/classes/motion)
* 📉 [Procedural Effects](/dev/doc/rendering/shaders/classes/procedural-fx)
* * Optional library with procedural noises and patterns
* 🥢 [Screen Space Tracing](/dev/doc/rendering/shaders/classes/screen-space-tracing)
* 🕳️ [Screen Space Ambient Occlusion](/dev/doc/rendering/shaders/classes/ssao)
* ✂️ [Texture Sheets](/dev/doc/rendering/shaders/classes/texture-sheets)