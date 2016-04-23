package bakeneko.entity;

import bakeneko.core.Log.*;
import bakeneko.state.StateSystem;
import haxe.macro.Expr;

class Scene extends StateSystem {

	public var entityList(default, null):Array<Entity>;

	var entitiesActive:Bool = false;
	var entitiesForegrounded:Bool = false;

	public function new() {
		entityList = [];
	}

	public function add(entity:Entity) {
		assert(entity != null, "Can't add a null entity");
		assert(entity.scene == null, 'Entity ${entity.id} is already attached in a scene');
		assert(entity.parent == null || entity.parent.scene == this, 'Cannot add entity ${entity.id} to a different scene than its parent');

		entityList.push(entity);

		entity.scene = this;
		entity.addedToScene();

		if (entitiesActive == true) {
			entity.resume();

			if (entitiesForegrounded == true) {
				entity.foreground();
			}
		}
	}

	public function remove(entity:Entity) {
		assert(entity != null, "Can't remove a null entity");
		assert(entity.scene == this, 'Entity ${entity.id} is not from this scene');

		if (entityList.remove(entity)) {

			if (entitiesActive == true) {
				if (entitiesForegrounded == true) {
					entity.background();
				}

				entity.suspend();
			}

			entity.removedFromScene();
			entity.scene = null;

		}
	}

	public function removeAllEntities() {
		for (entity in entityList) {

			if (entity.parent == null) {
				if (entitiesActive == true) {
					if (entitiesForegrounded == true) {
						entity.background();
					}
					entity.suspend();
				}

				entity.removedFromScene();
				entity.scene = null;
			}
		}
	}

	/**
	 * Returns an array of components of the given class
	 */
	@:generic public function queryComponents<T:(Component)>(c:Class<T>):Array<T> {
		var componentList:Array<T> = [];

		for (entity in entityList) {
			var comp:T = entity.getComponent(c);

			if (comp != null)
				componentList.push(comp);
		}

		return componentList;
	}

}