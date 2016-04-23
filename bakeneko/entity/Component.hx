package bakeneko.entity;

class Component {

	public var entity(default, set):Entity;

	public function removeFromEntity() {
	}

	// User events

	/**
	 * When the component is attached to an entity.
	 */
	public function onAddedToEntity() { }

	/**
	 * When the component is attached to and entity
	 * and that entity is on a scene.
	 */
	public function onAddedToScene() { }

	/**
	 * When the application is resumed while the component's
	 * owning entity is in a scene. This will also be called
	 * when the owning entity is added to the scane if the
	 * application is currently active or when the component
	 * is added to the entity if the entity is already in the
	 * scene.
	 */
	public function onResume() { }

	/**
	 * When the application is foregrounded while
	 * the entity is in the scene. This will also be
	 * caleed when the entity is added to the scene if
	 * the application is currently foregrounded or when
	 * the component is added to the entity if the entity
	 * is alread in the scene.
	 */
	public function onForeground() { }

	/**
	 * When the application is foregrounded while the entity
	 * is in the scene. This will also be called when the entity
	 * is added to the scene if the application is currently
	 * foregrounded or when the component is added to the entity
	 * if the entity is already in the scene
	 *
	 * @param	delta
	 */
	public function onUpdate(delta:Float) { }

	/**
	 * At fixed time periods
	 * @param	delta
	 */
	public function onFixedUpdate(delta:Float) { }

	/**
	 * When the application is backgrounded while the owning
	 * entity is removed from the scene if the applicaiton is
	 * currently foregrounded or when the component is removed
	 * while the entity is in the scene
	 */
	public function onBackground() { }

	/**
	 * When the application is backgrounded while the owning
	 * entity is in the scene. This will also be called when
	 * the owning entity is removed from the scene if the
	 * application is currently active or when the component
	 * is removed while the entity is in the scene.
	 */
	public function onSuspend() { }

	/**
	 * When the component is removed from an entity or then the
	 * entity is removed from the scene.
	 */
	public function onRemovedFromScene() { }

	/**
	 * When the component is removed from an entity.
	 */
	public function onRemovedFromEntity() { }

	function set_entity(entity:Entity) {
		this.entity = entity;

		onAddedToEntity();

		return entity;
	}

	public function toString() {
		return Type.getClassName(Type.getClass(this)) + ' of $entity';
	}

}