# Screen-Space Reflections

SSR is done in three steps

* Intersection
  * Uses the [G-Buffer](/dev/doc/rendering/shaders/classes/g-buffer) and [Screen Space Tracing](/dev/doc/rendering/shaders/classes/screen-space-tracing) right after we do the Depth Pre-Pass, uses the result from last frame reprojected with [Motion](/dev/doc/rendering/shaders/classes/motion)
  * ![](https://cdn.sbox.game/doc/rendering/shaders/reference/images/screen-space-reflections-1.png)
* Denoising
  * Accumulates the result and makes it pretty taking off the rough edges
  * ![](https://cdn.sbox.game/doc/rendering/shaders/reference/images/screen-space-reflections.png)
* Compositing
  * Sets the texture to be composited with [Dynamic Reflections](/dev/doc/rendering/shaders/classes/dynamic-reflections)
  * ![](https://cdn.sbox.game/doc/rendering/shaders/reference/images/screen-space-reflections-2.png)
