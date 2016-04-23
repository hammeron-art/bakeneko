attribute vec3 position;
attribute vec4 color;

varying vec4 Color;

uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

void main()
{
	Color = color;

    gl_Position = projectionMatrix * viewMatrix * vec4(position, 1.0);
}