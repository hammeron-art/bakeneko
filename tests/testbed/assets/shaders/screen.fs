varying vec2 Texcoord;

uniform sampler2D screenTexture;

void main()
{
    gl_FragColor = texture2D(screenTexture, Texcoord) * vec4(1.0);
}