package;

import bakeneko.asset.Shader;
import bakeneko.asset.Texture;
import bakeneko.core.Application;
import bakeneko.core.Promise;
import bakeneko.utils.Utils;
import bakeneko.entity.Entity;
import bakeneko.entity.Scene;
import bakeneko.input.InputSystem;
import bakeneko.math.MathUtil;
import bakeneko.math.Matrix4x4;
import bakeneko.math.Vector3;
import bakeneko.math.Vector4;
import bakeneko.render.CameraComponent;
import bakeneko.render.Color;
import bakeneko.render.Material;
import bakeneko.render.Mesh;
import bakeneko.render.MeshBatcher;
import bakeneko.render.StaticMeshComponent;
import bakeneko.render.Vertex;
import bakeneko.render.VertexFormat;
import bakeneko.state.State;
import haxe.io.Path;
import snow.api.buffers.*;
import snow.modules.opengl.GL;
import snow.system.io.IO;
import snow.system.window.Window;

import bakeneko.core.EventSystem;

class ShaderTest extends State
{
	public var vertices:Array<Float>;
	public var verticeArray:Float32Array;

	var meshBatcher:MeshBatcher;
	var mesh:Mesh;

	var entity:Entity;
	var entity2:Entity;
	var entity3:Entity;
	var camera:Entity;

	public function new() {
		super();
	}

	override public function onInit():Void {
		//Application.events.listen('eventTest', function(e) { trace('45456'); } );
		//Application.events.fire('eventTest', { }, true);

		vertices = [
		//	 X	   Y	 Z	  R	   G	B	 A    U	   V
			-0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0,
			 0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0,
			 0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
			 0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
			-0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0,
			-0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0,

			-0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0,
			 0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0,
			 0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
			 0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
			-0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0,
			-0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0,

			-0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0,
			-0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
			-0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0,
			-0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0,
			-0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0,
			-0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0,

			 0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0,
			 0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
			 0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0,
			 0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0,
			 0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0,
			 0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0,

			-0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0,
			 0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
			 0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0,
			 0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0,
			-0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0,
			-0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0,

			-0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0,
			 0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
			 0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0,
			 0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0,
			-0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0,
			-0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0
		];

		// elements
		var elements = [
			0, 1, 2,
			2, 3, 0
		];

		var desc = new VertexFormat();
		desc.push(new VertexElement(TFloat(3), SPosition));
		desc.push(new VertexElement(TFloat(4), SColor));
		desc.push(new VertexElement(TFloat(2), STexcoord));

		mesh = new Mesh(desc);

		mesh.setVertexFromArray(vertices);
		//mesh.setIndexFromArray(elements);

		var material1:Material = new Material("custom1");
		var material2:Material = new Material("custom2");

		var shaderPromise = app.resourceManager.loadShader('assets/shaders/custom');
		shaderPromise.then(function(shader:Shader) {
			material1.setShader(shader);
			material2.setShader(shader);
		});

		var texture0Promise = app.resourceManager.loadTexture('assets/image1.png');
		texture0Promise.then(function(texture:Texture) {
			material1.setTexture(0, texture);
		});

		var texture1Promise = app.resourceManager.loadTexture('assets/image2.png');
		texture1Promise.then(function(texture:Texture) {
			material2.setTexture(0, texture);
		});

		var cameraComponent1 = new CameraComponent();
		cameraComponent1.setPerspective(MathUtil.degToRad(45.0), 1.0, 10000.0, 800 / 600);
		camera = new Entity("camera");
		camera.addComponent(cameraComponent1);
		//projectionMatrix = Matrix4x4.CreateOrthographic(8, 6, 1.0, 100.0);
		camera.transform.lookAt( new Vector3(0.5, 0, -3.2), new Vector3(0.0, 0.0, 0.0), new Vector3(0.0, 1.0, 0.0));
		cameraComponent1.setLayers([0, 1, 2]);
		cameraComponent1.depth = 0;

		//material2.setTexture(0, cameraComponent.renderTarget.colorTexture);

		var cameraComponent2 = new CameraComponent();
		cameraComponent2.setOrthographic(8, 6, 1.0, 100.0);
		var camera2 = new Entity("camera2");
		camera2.addComponent(cameraComponent2);
		camera2.transform.lookAt( new Vector3(1.2, 1.2, 1.2), new Vector3(0.0, 0.0, 0.0), new Vector3(0.0, 0.0, 1.0));
		camera2.getComponent(CameraComponent).setLayers([1, 2, 0]);
		cameraComponent2.depth = 1;

		var meshComponent1 = new StaticMeshComponent(mesh, material2);
		entity = new Entity("TestEntity1");
		entity.addComponent(meshComponent1);
		entity.transform.position.set( 0.0, 0.0, 0.0);
		meshComponent1.layer = 1;

		var meshComponent2 = new StaticMeshComponent(mesh, material1);
		entity2 = new Entity("TestEntity2");
		entity2.addComponent(meshComponent2);
		entity2.transform.position.set( -2.0, 0.0, 0.0);
		entity2.transform.scale.set(1.25, 0.25, 1.5);
		meshComponent2.layer = 2;

		var meshComponent3 = new StaticMeshComponent(mesh, material1);
		entity3 = new Entity("TestEntity3");
		entity3.addComponent(meshComponent3);
		entity3.transform.position.set(0.1, 1.0, 0.0);
		entity3.transform.scale.set(0.15, 0.10, 0.25);
		meshComponent3.layer = 0;

		entity2.addEntity(entity3);
		scene.add(entity2);
		//entity.addEntity(camera);
		//entity.addEntity(entity2);
		scene.add(entity);
		scene.add(camera);
		scene.add(camera2);

		app.input.bindInput('left', Key.left);
		app.input.bindInput('right', Key.right);
		app.input.bindInput('up', Key.up);
		app.input.bindInput('down', Key.down);
	}

	override public function onUpdate(delta:Float):Void {
		var h:Int  = Utils.int(app.input.inputDown('right')) - Utils.int(app.input.inputDown('left'));
		var v:Int  = Utils.int(app.input.inputDown('up')) - Utils.int(app.input.inputDown('down'));

		var s = Math.sin(Application.core.current_time);
		var c = Math.cos(Application.core.current_time);

		entity.transform.scaleTo(new Vector3(1 + 0.2*s, 1 + 0.2*s, 1 + 0.2*s));
		entity2.transform.scaleTo(new Vector3(-c, c/2, c/2));

		entity.transform.position = entity.transform.position + (new Vector3(h, -v)) * delta;

		entity.transform.rotateZBy(Math.PI * (delta * 0.05));
		entity2.transform.rotateZBy(Math.PI * (delta * 0.75));
	}

}
