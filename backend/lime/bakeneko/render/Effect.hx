package bakeneko.render;

import bakeneko.hxsl.RuntimeShader;

#if !flash

import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;

class Effect {

	public var runtimeShader:RuntimeShader;
	var vertexShader:GLShader;
	var fragmentShader:GLShader;
	var program:GLProgram;
	
	var vertexLocation:GLUniformLocation;
	var fragmentLocation:GLUniformLocation;
	var vertGlobalLocation:GLUniformLocation;
	var fragGlobalLocation:GLUniformLocation;
	var vertTexLocations:Array<GLUniformLocation>;
	var fragTexLocations:Array<GLUniformLocation>;
	
	public function new(runtimeShader, vertexShader, fragmentShader, program, vertexLocation, fragmentLocation, vertGlobalLocation, fragGlobalLocation, vertTexLocations, fragTexLocations) {
		this.runtimeShader = runtimeShader;
		this.vertexShader = vertexShader;
		this.fragmentShader = fragmentShader;
		this.program = program;
		
		this.vertexLocation = vertexLocation;
		this.fragmentLocation = fragmentLocation;
		this.vertGlobalLocation = vertGlobalLocation;
		this.fragGlobalLocation = fragGlobalLocation;
		this.vertTexLocations = vertTexLocations;
		this.fragTexLocations = fragTexLocations;
	}
	
}

#else

class Effect {
	
	public var runtimeShader:RuntimeShader;
	var program:flash.display3D.Program3D;
	
	public function new(runtimeShader, program) {
		this.program = program;
		this.runtimeShader = runtimeShader;
	}
	
}

#end