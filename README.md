README
======

A CALayer subclass with an approximation of Lambert shading and specular highlighting. Provides the graphical glory of a very basic lighting model combined with the relatively heavy-weight Core Animation object model. This yields visual results that are hard to achieve in Core Animation, seamlessly integrated with the ease of animation that is so hard to achieve in OpenGL.

In short: a layer with shininess and shadowing.

There's a blog post with slightly more detail here: [http://www.ultrajoke.net/2012/03/smshadowedlayer/](http://www.ultrajoke.net/2012/03/smshadowedlayer/)

HOW IT WORKS
------------

When a transform is set on this layer, it does a little math to determine how close its normal is to the direction of incident light (which is assumed to be at the viewer's eye, at least for this release). It renders a shadow with linear falloff, and a specular highlight with exponential falloff. It also does a little internal jiggery-pokery to change color values on a per-frame basis, rather than depending on the provided implicit animations. This matters e.g. when the layer rotates from facing left to facing right, passing through facing forward.

HOW TO USE IT
-------------

Use as you would any other CALayer. Set background color, contents, and so on, and position in your scene. It comes with reasonable defaults (shadow on, highlight off, full shadow color black with 75% opacity), but is fully customizable, from colors to the exponential falloff rate of the specular highlight. When a transform is applied, it will do the right thing for you. If you know the animation from the current transform to the new one won't involve a non-linear change in the layer's orientation to the screen, using `[layer setTransform:transform animatePerFrame:NO]` will save some CPU cycles.

The shadow and specular properties can also be used to fake other effects, such as the layer being shadowed by something above it. Simply set the currentShadowOpacity or currentSpecularOpacity. Note that subsequently transforming the layer will reset these as per the animation.

The project includes an optional CATransformLayer subclass that's aware of the shadowed layer's unique properties. If you use SMTransformLayer to contain SMShadowedLayers, they will behave as expected. If you prefer to use CATransformLayer, you'll have to call `[layer setTransform:layer.transform animatePerFrame:YES]` in any transaction in which you change the transform layer's `transform` or `sublayerTransform` properties.

LICENSE
-------

Copyright (C) 2012 by Spaceman Labs

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
