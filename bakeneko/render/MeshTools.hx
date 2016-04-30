package bakeneko.render;

import bakeneko.core.Application;
import bakeneko.core.Log;
import bakeneko.render.VertexStructure;
import bakeneko.render.MeshData;
import lime.utils.Float32Array;

class MeshTools {

	public static function createQuad():MeshData {
		/*var vertices = [
		//	 X	   Y	 Z	  R	   G	B	 A    U	   V
			-0.5,  0.5,  0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0,	// top-left
			 0.5,  0.5,  0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, // top-right
			-0.5, -0.5,  0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, // bottom-left
			 0.5, -0.5,  0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, // bottom-right
		];*/

		var elements = [
			0, 1, 2,
			2, 1, 3
		];
		
		var data:MeshData = {
			vertexCount: 3 * 4,
			positions: [[-0.5, 0.5, 0.0], [0.5, 0.5, 0.0], [-0.5, -0.5, 0.0], [0.5, -0.5, 0.0]],
			colors: [[1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 1.0]],
			uvs: [[0.0, 1.0], [1.0, 1.0], [0.0, 0.0], [1.0, 0.0]],
			indices: elements,
		}

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
	public static function buildVertexData(data:MeshData, ?format:VertexStructure):Float32Array {
		format = format != null ? format : data.structure;
		Log.assert(format != null, "Can't build vertex data without a vertex format");

		var vertexData = new Float32Array(format.totalNumValues * data.vertexCount);
		
		// Validate mesh data
		Log.check({
			for (element in format.elements) {
				
				inline function check(array:Array<Dynamic>) {
					Log.assert(array != null || array.length != 0 || array.length % element.numData() == 0);
				}

				switch (element.semantic) {
					case SPosition:
						check(data.positions);
					case STexcoord:
						check(data.uvs);
					case SNormal:
						check(data.normals);
					case SColor:
						check(data.colors);
					case SJointIndex | SWeight:
						Log.api("Not implemented!");
				}
			}
		});
		
		// Build vertex data
		var pos = 0;
		for (i in 0...data.vertexCount) {
			for (element in format.elements) {
				var n = element.numData();
				
				inline function addData(array:Vector) {
					for (ii in 0...n) {
						vertexData[pos++] = array[ii];
					}
				}

				switch (element.semantic) {
					case SPosition:
						addData(data.positions[i]);
					case STexcoord:
						addData(data.uvs[i]);
					case SNormal:
						Log.api("Not implemented!");
					case SColor:
						addData(data.colors[i]);
					case SJointIndex | SWeight:
						Log.api("Not implemented!");
				}
			}
		}
		
		return vertexData;
	}
	
}