attribute vec3 position;
attribute vec4 color;
attribute vec2 texcoord;

varying vec4 Color;
varying vec2 Texcoord;

uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

void main()
{
	Color = color;
	Texcoord = texcoord;

    gl_Position = projectionMatrix * viewMatrix * vec4(position, 1.0);
}