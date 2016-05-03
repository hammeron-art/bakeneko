package states.api;

import bakeneko.asset.Texture;
import bakeneko.core.Log;
import bakeneko.hxsl.GlslOut;
import bakeneko.hxsl.RuntimeShader;
import bakeneko.render.Color;
import bakeneko.render.MeshData;
import bakeneko.render.MeshTools;
import bakeneko.render.VertexStructure;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLUniformLocation;
import lime.utils.Float32Array;
import lime.utils.Int32Array;
import lime.utils.UInt16Array;
import lime.utils.UInt32Array;
import bakeneko.render.ProgramBuffer;


class GLGraphics implements IGraphics {
	
	var compiledShader:RuntimeShader;
	
	var program:GLProgram;
	var vertex:GLBuffer;
	var index:GLBuffer;
	var vertexLocation:GLUniformLocation;
	var fragmentLocation:GLUniformLocation;
	var vertGlobalLocation:GLUniformLocation;
	var fragGlobalLocation:GLUniformLocation;
	var vertTexLocations:Array<GLUniformLocation>;
	var fragTexLocations:Array<GLUniformLocation>;
	
	var backColor:Color;
	
	public function new(compiledShader:RuntimeShader, data:MeshData, backColor: Color) {
		this.compiledShader = compiledShader;
		this.backColor = backColor;
		
		var out = new GlslOut();
		var vertexSource = out.run(compiledShader.vertex.data);
		var fragmentSource = out.run(compiledShader.fragment.data);
		
		Log.info('$vertexSource\n\n$fragmentSource', 0);
		
		var vertexData = MeshTools.buildVertexData(data);
		var indexData = new UInt16Array(data.indices);
		
		vertex = GL.createBuffer();
		index = GL.createBuffer();
		
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, index);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indexData, GL.STATIC_DRAW);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, vertex);
		GL.bufferData(GL.ARRAY_BUFFER, vertexData, GL.STATIC_DRAW);
		
		var i = 0;
		var offset = 0;
		for (element in data.structure.elements) {
			var size = element.numData();
			
			GL.vertexAttribPointer(i, size, GL.FLOAT, false, data.structure.totalSize, offset * 4);
			GL.enableVertexAttribArray(i);
			
			offset += size;
			++i;
		}
		
		var vertexShader = GL.createShader(GL.VERTEX_SHADER);
		var fragmentShader = GL.createShader(GL.FRAGMENT_SHADER);
		GL.shaderSource(vertexShader, vertexSource);
		GL.shaderSource(fragmentShader, fragmentSource);
		GL.compileShader(vertexShader);
		GL.compileShader(fragmentShader);
		
		program = GL.createProgram();
		GL.attachShader(program, vertexShader);
		GL.attachShader(program, fragmentShader);

		GL.linkProgram(program);

		if (GL.getProgramParameter(program, GL.LINK_STATUS) == 0) {
			Log.error(GL.getProgramInfoLog(program));
			GL.deleteProgram(program);
		}
		
		GL.useProgram(program);
		
		vertexLocation = GL.getUniformLocation(program, 'vertexParams');
		fragmentLocation = GL.getUniformLocation(program, 'fragmentParams');
		vertGlobalLocation = GL.getUniformLocation(program, 'vertexGlobals');
		fragGlobalLocation = GL.getUniformLocation(program, 'fragmentGlobals');
		vertTexLocations = [
			for (i in 0...compiledShader.vertex.textures2DCount) {
				GL.getUniformLocation(program, 'vertexTextures[$i]');
			}
		];
		fragTexLocations = [
			for (i in 0...compiledShader.fragment.textures2DCount) {
				var v = GL.getUniformLocation(program, 'fragmentTextures[$i]');
				trace(v);
				v;
			}
		];
	}
	
	public function render(buffer:ProgramBuffer) {
		
		if (compiledShader.vertex.paramsSize > 0)
			GL.uniform4fv(vertexLocation, buffer.vertex.params);
		if (compiledShader.fragment.paramsSize > 0)
			GL.uniform4fv(fragmentLocation, buffer.fragment.params);
		if (compiledShader.vertex.globalsSize > 0)
			GL.uniform4fv(vertGlobalLocation, buffer.vertex.globals);
		if (compiledShader.fragment.globalsSize > 0)
			GL.uniform4fv(fragGlobalLocation, buffer.fragment.globals);
		//if (compiledShader.fragment.textures2DCount > 0)
			//GL.uniform1iv(GL.getUniformLocation(program, 'fragmentTextures'), new Int32Array([0, 1]));
			
		/*for (i in 0...compiledShader.vertex.textures2DCount) {
			GL.activeTexture(GL.TEXTURE0 + i);
			GL.uniform1i(vertTexLocations[i], i);
			@:privateAccess
			GL.bindTexture(GL.TEXTURE_2D, buffer.vertex.textures[i].nativeTexture.texture);
		}*/
		for (i in 0...compiledShader.fragment.textures2DCount) {
			@:privateAccess
			GL.bindTexture(GL.TEXTURE_2D, buffer.fragment.textures[i].nativeTexture.texture);
			GL.activeTexture(GL.TEXTURE0 + i);
			GL.uniform1i(fragTexLocations[i], i);
		}
		
		GL.clearColor(backColor.r, backColor.g, backColor.b, backColor.a);
		GL.clear(GL.COLOR_BUFFER_BIT);
		GL.drawElements(GL.TRIANGLES, 3, GL.UNSIGNED_SHORT, 0);
	}

}