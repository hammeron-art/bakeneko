package bakeneko.render;

import bakeneko.core.Application;
import bakeneko.hxsl.Shader;
import bakeneko.hxsl.ShaderList;
import states.hxsl.ProgramBuffer;

@:build(bakeneko.hxsl.Macros.buildGlobals())
class Pass {

	public var state:RenderState;
	var shaderList:ShaderList;
	var effect:Effect;
	var programBuffer:ProgramBuffer;
	var manager:ShaderManager;
	var render:Renderer;
	
	public function new() {
		manager = new ShaderManager(['output.position', 'output.color']);
		render = Application.get().getRenderer();
	}
	
	public function addShader(shader:Shader) {
		shaderList = new ShaderList(shader, shaderList);
	}
	
	public function removeShader(shader:Shader) {
		var shaders = shaderList;
		var previous = null;
		
		while (shaders != null) {
			if (shaders.shader == shader) {
				if (previous == null)
					shaderList = shaders.next;
				else
					previous.next = shaders.next;
				return true;
			}
			previous = shaders;
			shaders = shaders.next;
		}
		return false;
	}

	public function init() {
		effect = render.createEffect(compileShader(shaderList));
		programBuffer = new ProgramBuffer(effect.runtimeShader);
	}
	
	public function apply() {
		render.applyRenderState(state);
		render.applyEffect(effect, programBuffer);
		
		setGlobals();
		manager.setParams(programBuffer, effect.runtimeShader, shaderList);
		manager.setGlobalParams(programBuffer, effect.runtimeShader);
	}
	
	function compileShader(shaders:ShaderList):bakeneko.hxsl.RuntimeShader {
		return manager.compileShaders(shaders);
	}

	public function dispose() {
	}

	public function draw(passes:Pass) {
		return passes;
	}
	
}