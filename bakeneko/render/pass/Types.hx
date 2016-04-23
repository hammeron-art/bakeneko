package bakeneko.render.pass;

import lime.graphics.opengl.GL;

@:enum abstract Primitive(Int) from Int to Int {
	var Points = 0;
	var Lines = 1;
	var LineLoop = 2;
	var lineStrip = 3;
	var Triangles = 4;
	var TriangleStrip = 5;
	var TriangleFan = 6;
}

@:enum abstract Buffer(Int) from Int to Int {
	var ColorBufferBit = GL.COLOR_BUFFER_BIT;
	var DepthBufferBit = GL.DEPTH_BUFFER_BIT;
	var StencilBufferBit = GL.STENCIL_BUFFER_BIT;
}

enum BlendMode {
	None;
	Alpha;
	Add;
	SoftAdd;
	Multiply;
	Erase;
	Screen;
}

enum Face {
	None;
	Back;
	Front;
	Both;
}

@:enum abstract Blend(Int) from Int to Int {
	var One = GL.ONE;
	var Zero = GL.ZERO;
	var SrcAlpha = GL.SRC_ALPHA;
	var SrcColor = GL.SRC_COLOR;
	var DstAlpha = GL.DST_ALPHA;
	var DstColor = GL.DST_COLOR;
	var OneMinusSrcAlpha = GL.ONE_MINUS_SRC_ALPHA;
	var OneMinusSrcColor = GL.ONE_MINUS_SRC_COLOR;
	var OneMinusDstAlpha = GL.ONE_MINUS_DST_ALPHA;
	var OneMinusDstColor = GL.ONE_MINUS_DST_COLOR;
	// only supported on opengl
	var ConstantColor = GL.CONSTANT_COLOR;
	var ConstantAlpha = GL.CONSTANT_ALPHA;
	var OneMinusConstantColor = GL.ONE_MINUS_CONSTANT_COLOR;
	var OneMinusConstantAlpha = GL.ONE_MINUS_CONSTANT_ALPHA;
	var SrcAlphaSaturate = GL.SRC_ALPHA_SATURATE;
}

@:enum abstract Compare(Int) from Int to Int {
	var Always = GL.ALWAYS;
	var Never = GL.NEVER;
	var Equal = GL.EQUAL;
	var NotEqual = GL.NOTEQUAL;
	var Greater = GL.GREATER;
	var GreaterEqual = GL.GEQUAL;
	var Less = GL.LESS;
	var LessEqual = GL.LEQUAL;
}

enum MipMap {
	None;
	Nearest;
	Linear;
}

@:enum abstract Target(Int) from Int to Int {
	var Framebuffer = GL.FRAMEBUFFER;
	var Renderbuffer = GL.RENDERBUFFER;
}

@:enum abstract Filter(Int) from Int to Int {
	var Nearest = GL.NEAREST;
	var Linear = GL.LINEAR;
}

@:enum abstract Wrap(Int) from Int to Int {
	var Clamp = GL.CLAMP_TO_EDGE;
	var Repeat = GL.REPEAT;
	//Mirrored;
}

enum Operation {
	Add;
	Sub;
	ReverseSub;
}

@:enum abstract Attachment(Int) from Int to Int {
	var Color0 = GL.COLOR_ATTACHMENT0;
	var Depth = GL.DEPTH_ATTACHMENT;
	var Stencil = GL.STENCIL_ATTACHMENT;
	var DepthStencil = GL.DEPTH_STENCIL;
}