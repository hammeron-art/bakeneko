package bakeneko.entity;

import bakeneko.core.Log.*;
import bakeneko.utils.Utils;

class Entity {

	public var id:String;

	public var transform:Transform;
	public var scene:Scene;
	public var parent:Entity;
	public var children:Array<Entity>;

	var components:Array<Component>;

	var appActive:Bool = false;
	var appForegrounded:Bool = false;

	public function new(?id:String) {
		transform = new Transform();
		components = [];
		scene = null;
		parent = null;
		children = [];

		if (id != null)
			this.id = id;
		else
			this.id = Utils.uniqueID();
	}

	public function addComponent(component:Component) {
		assert(component != null, "Can't add null component");

		components.push(component);
		component.entity = this;
	}

	public function addEntity(child:Entity) {
		assert(child != null, "Can't add null entity");
		assert(child.scene == null, "Can't add entity ${entity.id} with existing scene");

		children.push(child);
		transform.addChildTransform(child.transform);
		child.parent = this;

		if (scene != null) {
			scene.add(child);
		}
	}

	@:generic public function getComponent<T:(Component)>(c:Class<T>):T {
		for (component in components) {
			if (Std.is(component, c)) {
				return cast component;
			}
		}
		return null;
	}

	public function addedToScene() {
		for (component in components) {
			component.onAddedToScene();
		}

		for (child in children) {
			scene.add(child);
		}
	}

	public function update(delta:Float) {
		for (component in components) {
			component.onUpdate(delta);
		}
	}

	public function fixedUpdate(delta:Float) {
		for (component in components) {
			component.onFixedUpdate(delta);
		}
	}

	public function resume() {
		assert(appActive == false, 'Entity $id received resume event while already actived');

		appActive = true;

		for (component in components) {
			component.onResume();
		}
	}

	public function foreground() {
		assert(appForegrounded == false, 'Entity $id received foreground event while already actived');

		appForegrounded = true;

		for (component in components) {
			component.onForeground();
		}
	}

	public function removedFromScene() {
		for (child in children) {
			scene.remove(child);
		}

		for (component in components) {
			component.onRemovedFromScene();
		}
	}

	public function background() {
		assert(appForegrounded == true, "Entity received background while already backgrounded");

		appForegrounded = false;

		for (component in components) {
			component.onBackground();
		}
	}

	public function suspend() {
		assert(appActive == true, "Entity received suspend while already suspended");

		appActive = false;

		for (component in components) {
			component.onSuspend();
		}
	}

	public function toString():String {
		return id;
	}

}