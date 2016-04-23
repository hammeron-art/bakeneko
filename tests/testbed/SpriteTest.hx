package;

import bakeneko.asset.Font;
import bakeneko.asset.Shader;
import bakeneko.asset.Texture;
import bakeneko.core.Application;
import bakeneko.utils.Utils;
import bakeneko.input.InputSystem;
import bakeneko.entity.Entity;
import bakeneko.math.MathUtil;
import bakeneko.math.Vector3;
import bakeneko.render.CameraComponent;
import bakeneko.render.Material;
import bakeneko.render.Mesh;
import bakeneko.render.MeshBatcher;
import bakeneko.render.SpriteComponent;
import bakeneko.render.TextComponent;
import bakeneko.state.State;

class SpriteTest extends State {
	public var vertices:Array<Float>;
	public var verticeArray:Float32Array;

	var meshBatcher:MeshBatcher;
	var mesh:Mesh;

	var entity:Entity;
	var camera:Entity;
	var text:Entity;
	
	static public var texture:Texture;

	public function new() {
		super();
	}

	override public function onInit():Void {
		
		//Application.events.listen('eventTest', function(e) { trace('45456'); } );
		//Application.events.fire('eventTest', { }, true);
		
		var material1:Material = new Material("custom1");
		var material2:Material = new Material("custom2");

		var shaderPromise = app.resourceManager.loadShader( {
			id: 'assets/shaders/custom',
			vertID: 'assets/shaders/custom.vs',
			fragID: 'assets/shaders/custom.fs'
		});
		shaderPromise.then(function(shader:Shader) {
			material1.setShader(shader);
			material2.setShader(shader);
		});

		var pixelData:Array<Int> = [
			255, 255, 255, 255,
			0, 0, 0, 255,
			255, 0, 0, 128,
			0, 0, 255, 100
		];
		
		texture = new Texture( {
			id: 'customImage',
			pixels: new Uint8Array(pixelData),
			width: 2,
			height: 2,
			props: {
				wrapS: GL.REPEAT,
				wrapT: GL.REPEAT,
				minFilter: GL.NEAREST,
				magFilter: GL.NEAREST,
			}
		});
		
		material1.setTexture(0, texture);
		/*var texture0Promise = app.resourceManager.loadTexture({id: 'assets/image2.png'});
		texture0Promise.then(function(texture:Texture) {
			material1.setTexture(0, texture);
		});*/
		
		var font = app.resourceManager.loadFont({id: 'assets/font/liberation.fnt'}).then(function(font:Font) {
			material2.setTexture(0, font.texturePages[0]);
			
			var textComponent = new TextComponent(font, material2, "testText");
			text.addComponent(textComponent);
		});
		
		text = new Entity("TextEntity");
		text.transform.position.z = -0.05;

		var cameraComponent = new CameraComponent();
		cameraComponent.setPerspective(MathUtil.degToRad(45.0), 1.0, 10000.0, 800 / 600);
		//cameraComponent.setOrthographic(8, 6, 1.0, 100.0);
		camera = new Entity("camera");
		camera.addComponent(cameraComponent);
		camera.transform.lookAt( new Vector3(0.0, 0.0, -3.2), new Vector3(0.0, 0.0, 0.0), new Vector3(0.0, 1.0, 0.0));
		cameraComponent.setLayers([0,1]);
		cameraComponent.depth = 0;

		var meshComponent = new SpriteComponent(null, material1);
		entity = new Entity("TestEntity1");
		entity.addComponent(meshComponent);
		entity.transform.position.set( -0.2, 0.0, 0.0);
		meshComponent.layer = 1;
		
		var meshComponent2 = new SpriteComponent(null, material1);
		var entity2 = new Entity("TestEntity2");
		entity2.addComponent(meshComponent2);
		entity2.transform.position.set( 1.0, 0.0, 0.0);
		meshComponent2.layer = 1;

		scene.add(entity2);
		scene.add(entity);
		scene.add(text);
		scene.add(camera);

		app.input.bindInput('left', Key.left);
		app.input.bindInput('right', Key.right);
		app.input.bindInput('up', Key.up);
		app.input.bindInput('down', Key.down);
		app.input.bindInput('a', Key.key_a);
		app.input.bindInput('z', Key.key_z);
		app.input.bindInput('c', Key.key_c);
	}

	override public function onUpdate(delta:Float):Void {

		var h:Int = Utils.int(app.input.inputDown('right')) - Utils.int(app.input.inputDown('left'));
		var v:Int = Utils.int(app.input.inputDown('up')) - Utils.int(app.input.inputDown('down'));
		var z:Int = Utils.int(app.input.inputDown('z')) - Utils.int(app.input.inputDown('a'));
		
		var s = Math.sin(Application.core.current_time);
		var c = Math.cos(Application.core.current_time);

		//entity.transform.scaleTo(new Vector3(1 + 0.2*s, 1 + 0.2*s, 1 + 0.2*s));
		entity.transform.position = entity.transform.position + (new Vector3(h, v, z)) * delta;
		entity.transform.rotateZBy(Math.PI * (delta * 0.25) * Utils.int(app.input.inputDown('c')));
	}

}
