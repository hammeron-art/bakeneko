attribute vec3 position;
attribute vec2 texcoord;

varying vec2 Texcoord;

uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

void main()
{
	Texcoord = texcoord;
    gl_Position = projectionMatrix * viewMatrix * vec4(position, 1.0);
}