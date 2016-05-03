package bakeneko.render;

#if !flash
typedef Renderer = GLRenderer;
#else
typedef Renderer = FlashRenderer;
#end