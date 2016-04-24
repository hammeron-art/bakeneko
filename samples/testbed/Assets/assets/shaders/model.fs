varying vec2 Texcoord;

uniform sampler2D tex0;

void main()
{
	gl_FragColor = texture2D(tex0, Texcoord) * vec4(1.0);
}