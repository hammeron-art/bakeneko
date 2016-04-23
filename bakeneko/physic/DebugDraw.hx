package bakeneko.physic;
import bakeneko.asset.Resource;
import bakeneko.asset.ResourceManager;
import bakeneko.asset.Shader;
import bakeneko.backend.opengl.GL;
import bakeneko.core.Application;
import bakeneko.core.Log;
import bakeneko.render.CameraComponent;
import bakeneko.render.Material;
import bakeneko.render.Mesh;
import bakeneko.render.RenderSystem;
import bakeneko.backend.Surface;
import bakeneko.render.VertexFormat;

class DebugDraw {
	
	var material:Material;
	var phySystem:PhysicsSystem;
	var render:RenderSystem;
	var mesh:Mesh;
	
	var target:Surface;
	
	public function new(phySystem:PhysicsSystem) {
		this.phySystem = phySystem;
		render = Application.get().renderSystem;
		
		var vertexColorShader = new Shader( {
			id: 'bakeneko/shaders/vertexColor',
			vertSource: ResourceManager.getEmbeddedString('shaders.vertexColor.vs'),
			fragSource: ResourceManager.getEmbeddedString('shaders.vertexColor.fs')
		});

		Log.assert(vertexColorShader.state == ResourceState.loaded, 'Failed to create material for Physics debug draw');
		
		var format = new VertexFormat();
		format.push(new VertexElement(TFloat(3), SPosition));
		format.push(new VertexElement(TFloat(4), SColor));
		
		material = new Material('phyDebug', format);
		material.setShader(vertexColorShader);
		material.primitiveType = PrimitiveType.lines;
		
		var vertices = [
		//	 X	   Y	 Z	  R	   G	B	 A    
			-0.5,  0.5,  0.0, 1.0, 0.2, 1.0, 1.0, 
			 0.5,  0.5,  0.0, 1.0, 0.2, 1.0, 1.0, 
			-0.5, -0.5,  0.0, 1.0, 0.2, 1.0, 1.0, 
			 0.5, -0.5,  0.0, 1.0, 0.2, 1.0, 1.0,
		];

		var elements = [
			0, 1, 2,
			2, 1, 3
		];

		mesh = new Mesh(format, vertices, elements);
		mesh.scale(128, 128, 1);
		mesh.build();
		
		trace(mesh);
		
		target = new Surface(Application.core.window.width, Application.core.window.height);
		render.renderEvent.add(draw);
		render.addRenderTarget(target);
	}
	
	public function draw() {
		buildMesh();
		
		var camera:CameraComponent = Application.get().stateManager.getCurrentState().scene.queryComponents(CameraComponent)[0];
		
		var viewMatrix = camera.entity.transform.getWorld().clone();
			if (camera.projection != null)
				render.applyCamera(camera.projection, viewMatrix.inverse());
		
		GL.activeTexture(GL.TEXTURE0);
		GL.bindTexture(GL.TEXTURE_2D, null);
		
		target.bind();

		GL.clearColor(0.0, 0.0, 0.0, 0.0);
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
		GL.enable(GL.DEPTH_TEST);
				
		mesh.bind();
		render.drawBuffer(mesh, material);
	}
	
	function buildMesh() {
		var vertex = [
			0.0, 0.0, 0.0, 1.0, 0.5, 1.0, 1.0
		];
		
		for (body in phySystem.space.bodies) {
			var x = body.position.x;
			var y = body.position.y;
			
			for (shape in body.shapes) {
				/*for (edge in shape.castPolygon.edges)
					trace(edge);*/
			}
		}
	}
	
}