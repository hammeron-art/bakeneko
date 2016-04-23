package bakeneko.render;

import bakeneko.asset.Resource;
import bakeneko.asset.Shader;
import bakeneko.asset.Texture;
import bakeneko.backend.RenderDriver;
import bakeneko.render.pass.Types.Primitive;
import bakeneko.core.Application;
import bakeneko.core.Log;
import bakeneko.core.Log.*;

/**
 * A material describes the render state of a mesh.
 * Properties such as textures, shaders, blending mode and culling.
 * Meshes are batched by material.
 */
class Material {

	public var visible:Bool = true;
	public var wireframe:Bool = false;
	public var wireColor:Color;
	public var wireWidth:Int = 1;
	public var fill:Bool = true;
	
	// slot and texture
	var textureList:Map<Int, Texture>;
	
	public var shader(default, null):Shader;
	
	var isCacheValid:Bool = false;
	static var currentlyBound(default, null):Material = null;
	static var currentSet(default, null):Material = null;
	var set = false;

	public var id(default, null):String;
	
	public var vertexFormat:VertexFormat;
	
	var driver:RenderDriver;

	public function new(id:String, vertexFormat:VertexFormat) {
		textureList = new Map();
		
		this.id = id;
		this.vertexFormat = vertexFormat;
		
		wireColor = new Color(0.0, 1.0, 0.0, 1.0);
		
		driver = Application.get().renderSystem.driver;
	}

	public function setTexture(slot:Int, texture:Texture) {
		assert(texture != null, "Can't add null texture");

		textureList.set(slot, texture);
		onMaterialChanged();
	}
	
	public function getTexture(slot:Int) {
		return textureList[slot];
	}

	public function removeTexture(slot:Int) {
		textureList.remove(slot);
		onMaterialChanged();
	}

	public function setShader(shader:Shader) {
		assert(shader != null, "Can't add null shader");

		this.shader = shader;
		onMaterialChanged();
	}
	
	/**
	 * The material is ready for use?
	 */
	public function isReady() {
		return shader != null && shader.state == ResourceState.loaded;
	}

	/**
	 * Apply the properties of this material to affect the drawing
	 */
	public function apply() {
		if (currentlyBound != this)
		{
			if (isReady()) {
				shader.bind();

				for (slot in textureList.keys()) {
					var tex = textureList.get(slot);

					tex.bind(slot);
					shader.setUniform('tex$slot', slot);
				}
			}

			currentlyBound = this;
		}
	}

	function onMaterialChanged() {
		isCacheValid = false;
	}

	public function setAttributes() {
		Log.assert(shader.program != null, 'Shader program of $this can\'t be null');
		
		if (currentSet == this)
			return;
		
		var stride = 0;

		for (element in vertexFormat.elements) {
			stride += element.size();
		}

		var offset = 0;
		
		for (element in vertexFormat.elements) {
			var verticeAttribute = driver.getAttribLocation(shader.program, element.attributeName());

			Log.assert(verticeAttribute >= 0, 'Vertex attribute (${element.attributeName()}) not found for shader (${this.shader}). Check the vertexFormat or not used variables in the shader.');
			driver.enableVertexAttribArray(verticeAttribute);
			driver.vertexAttribPointer(verticeAttribute, element.numData(), element.glType(), false, stride, offset);

			offset += element.size();
		}
		
		currentSet = this;
	}
	
	public function toString() {
		return 'Material: $id';
	}
}