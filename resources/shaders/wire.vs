attribute vec3 position;

varying vec4 Color;

uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform vec4 color;

void main()
{
	Color = color;
    gl_Position = projectionMatrix * viewMatrix * vec4(position, 1.0);
}