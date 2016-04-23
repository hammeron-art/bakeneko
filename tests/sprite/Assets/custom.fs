varying vec4 Color;
varying vec2 Texcoord;

uniform vec3 triangleColor;
uniform sampler2D tex0;
uniform sampler2D tex1;

void main()
{
	gl_FragColor = texture2D(tex0, Texcoord) * Color;
}