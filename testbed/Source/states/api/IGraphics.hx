package states.api;

import bakeneko.render.ProgramBuffer;
import bakeneko.render.Renderer;

interface IGraphics {
	public function render(render:Renderer, buffer:ProgramBuffer):Void;
}