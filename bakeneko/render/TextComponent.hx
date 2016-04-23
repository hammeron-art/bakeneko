package bakeneko.render;
import bakeneko.asset.Font;

/**
 * A component to hold and draw text
 */
class TextComponent extends StaticMeshComponent{
	
	public var text(default, set):String;
	
	var font:Font;
	var baseQuad:Mesh;
	
	public function new(font:Font, ?material:Material, ?text:String = "") {

		baseQuad = MeshUtils.createQuad();
		super(baseQuad, material);
				
		this.font = font;
		this.text = text;
	}
	
	/**
	 * Update vertex information for the current text
	 */
	function updateText() {
		// number of vertices for all the characters
		var vertexNumber = text.length * baseQuad.getVertexCount();
		
		if (vertexNumber > mesh.getVertexCount()) {
			for (i in 0...(vertexNumber - mesh.getVertexCount())) {
				
				for (i in mesh.getVertex(i))
					mesh.vertexList.push(i);
			}
		}
		
		trace(mesh.vertexList.length);
	}
	
	public function set_text(text:String) {
		this.text = text;
		
		updateText();
		
		return text;
	}
	
}