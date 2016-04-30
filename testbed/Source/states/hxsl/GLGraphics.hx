package states.hxsl;

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
import lime.utils.UInt16Array;


class GLGraphics implements IGraphics {
	
	var compiledShader:RuntimeShader;
	
	var program:GLProgram;
	var vertex:GLBuffer;
	var index:GLBuffer;
	var glTextures:Array<GLTexture>;
	var vertexLocation:GLUniformLocation;
	var fragmentLocation:GLUniformLocation;
	var vertTexLocations:Array<GLUniformLocation>;
	var fragTexLocations:Array<GLUniformLocation>;
	
	var backColor:Color;
	
	public function new(compiledShader:RuntimeShader, data:MeshData, backColor: Color, textures:Array<Texture>) {
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
		vertTexLocations = [
			for (i in 0...compiledShader.vertex.textures2DCount) {
				GL.getUniformLocation(program, 'vertexTextures[$i]');
			}
		];
		fragTexLocations = [
			for (i in 0...compiledShader.fragment.textures2DCount) {
				GL.getUniformLocation(program, 'fragmentTextures[$i]');
			}
		];
		
		glTextures = [
			for (i in 0...compiledShader.fragment.textures2DCount) {
				var texture = textures[i];
				var tex = GL.createTexture();
				GL.activeTexture(0);
				GL.bindTexture(GL.TEXTURE_2D, tex);
				GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, texture.image.width, texture.image.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, texture.image.buffer.data);
				
				tex;
			}
		];
	}
	
	public function render(buffer:ProgramBuffer) {
		
		if (compiledShader.vertex.paramsSize > 0)
			GL.uniform4fv(vertexLocation, buffer.vertex.params);
		if (compiledShader.fragment.paramsSize > 0)
			GL.uniform4fv(fragmentLocation, buffer.fragment.params);
		for (i in 0...compiledShader.vertex.textures2DCount) {
			
		}
		for (i in 0...compiledShader.fragment.textures2DCount) {
			GL.activeTexture(GL.TEXTURE0 + i);
			GL.uniform1i(fragTexLocations[i], i);
			GL.bindTexture(GL.TEXTURE_2D, glTextures[i]);
			
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);

			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		}
		
		GL.clearColor(backColor.r, backColor.g, backColor.b, backColor.a);
		GL.clear(GL.COLOR_BUFFER_BIT);
		GL.drawElements(GL.TRIANGLES, 3, GL.UNSIGNED_SHORT, 0);
	}

}