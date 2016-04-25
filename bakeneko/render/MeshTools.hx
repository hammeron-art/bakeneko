package bakeneko.render;

import bakeneko.core.Application;
import bakeneko.core.Log;
import bakeneko.render.VertexStructure;
import bakeneko.render.MeshData;

class MeshTools {

	public static function createQuad():MeshData {
		var vertices = [
		//	 X	   Y	 Z	  R	   G	B	 A    U	   V
			-0.5,  0.5,  0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0,	// top-left
			 0.5,  0.5,  0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, // top-right
			-0.5, -0.5,  0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, // bottom-left
			 0.5, -0.5,  0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, // bottom-right
		];

		var elements = [
			0, 1, 2,
			2, 1, 3
		];
		
		var data:MeshData = {
			positions: [[-0.5, 0.5, 0.0], [0.5, 0.5, 0.0], [-0.5, -0.5, 0.0], [0.5, -0.5, 0.0]],
			colors: [[1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0]],
			uvs: [[0.0, 1.0], [1.0, 1.0], [0.0, 0.0], [1.0, 0.0]],
			indices: elements,
		}

		//var mesh = new Mesh(Application.get().getSystem(RenderSystem).defaultFormat, data);
		
		return data;
	}
	
	// Process quads and return proper indices for triangle rendering
	public static function triangulate(faces:Array<Face>):Array<Int> {
		Log.api("Not complete!");
		
		var indices:Array<Int> = [];
		
		for (face in faces) {
			switch (face.length) {
			case 3:
				for (indice in face) {
					indices.push(indice);
				}
			case 4:
				for (i in 0...3) {
					indices.push(face[i]);
				}
				indices.push(face[2]);
				indices.push(face[3]);
				indices.push(face[0]);
			default:
				Log.error('Unssuported face index count (${faces.length})');
			}
		}

		return indices;
	}
	
	/**
	 * Merge attribute data and return as a array ready to be used as VBO
	 * @param	mesh
	 * @param	customFormat use other format instead of the actual mesh format
	 * @return
	 */
	public static function buildVertexData(mesh:MeshData, format:VertexStructure):Array<Float> {
		Log.assert(format != null, "Can't build vertex data without a vertex format");

		var vertexData:Array<Float> = [];
		
		// Validate mesh data
		var count:Int = 0;
		
		for (element in format.elements) {
			
			inline function check(array:Array<Dynamic>) {
				Log.assert(array != null || array.length != 0 || array.length % element.numData() == 0);
			}

			switch (element.semantic) {
				case SPosition:
					check(mesh.positions);
				case STexcoord:
					check(mesh.uvs);
				case SNormal:
					check(mesh.normals);
				case SColor:
					check(mesh.colors);
				case SJointIndex | SWeight:
					Log.api("Not implemented!");
			}
		}
		
		// Build vertex data
		for (i in 0...count) {
			for (element in format.elements) {
				var n = element.numData();
				
				inline function addData(array:Vector) {
					for (ii in 0...n) {
						vertexData.push(array[ii]);
					}
				}

				switch (element.semantic) {
					case SPosition:
						addData(mesh.positions[i]);
					case STexcoord:
						addData(mesh.uvs[i]);
					case SNormal:
						Log.api("Not implemented!");
					case SColor:
						addData(mesh.colors[i]);
					case SJointIndex | SWeight:
						Log.api("Not implemented!");
				}
			}
		}
		
		return vertexData;
	}
	
}