package bakeneko.render;

import bakeneko.hxsl.Cache;
import bakeneko.hxsl.Globals;
import bakeneko.hxsl.ShaderList;

class ShaderManager {
	
	public var globals:Globals;
	var shaderCache:Cache;
	var output:Int;
	
	public function new(output:Array<String>) {
		shaderCache = Cache.get();
		#if flash
		shaderCache.constsToGlobal = true;
		#end
		globals = new Globals();
		this.output = shaderCache.allocOutputVars(output);
	}
	
	public function compileShaders(shaders:ShaderList) {
		for( shader in shaders ) shader.updateConstants(globals);
		return shaderCache.link(shaders, output);
	}
	
}