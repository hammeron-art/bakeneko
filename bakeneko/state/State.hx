package bakeneko.state;

import bakeneko.core.Application;
import bakeneko.core.Log.*;
//import bakeneko.entity.Scene;

@:allow(bakeneko.state.StateManager)
class State
{
	var app:Application;

	var systems:Array<StateSystem>;
	var canAddSystens:Bool = true;

	//public var scene(default, null):Scene;

	public function new()
	{
		app = Application.get();

		systems = [];
		//scene = new Scene();
	}

	/**
	 * Create app systems
	 */
	public function createSystems():Void {}

	/**
	 * Called after all systems have been set up
	 */
	public function onInit():Void { }

	/**
	 * Called once after OnInit and called subsequently after returning from a suspended state (i.e. the app has been resumed after being minimised). This is also called when the state moves back to the top of the stack.
	 */
	public function onResumed():Void { }

	/**
	 * Called once after OnResume and called subsequently after returning from a background state (i.e. the app has been foregrounded after a dialog pop-up).
	 */
	public function onForeground():Void { }

	/**
	 * Called once per game loop with the time since last update in seconds.
	 *
	 * @param	delta
	 */
	public function onUpdate(delta:Float):Void { }

	/**
	 * Can be called multiple times per game loop in order to maintain a fixed time between updates. This is useful for physics calculations.
	 */
	public function onFixedUpdate(delta:Float):Void { }
	
	/**
	 * Called when mouse moves
	 */
	//public function onMouseMove(event:MouseEvent):Void { }

	/**
	 * Called when the app is no longer at the front of the view stack (i.e. during a pop-up dialogue or prior to suspending) or when the state is no longer top of the state stack.
	 */
	public function onBackground():Void { }

	/**
	 * Called when the state is no longer active
	 */
	public function onSuspend():Void { }

	/**
	 * Called when the state is removed from the state stack.
	 */
	public function onDestroy():Void { }

	/**
	 * StateSystems are created with this method
	 */
	public function createSystem<T>(stateSystem:T):T
	{
		assert(canAddSystens == true, "Can't create state systems");

		systems.push(cast stateSystem);
		return stateSystem;
	}

	function init() {
		canAddSystens = true;

		//createSystem(scene);
		// user defined systems
		createSystems();

		canAddSystens = false;

		for (system in systems) {
			system.onInit();
		}

		onInit();
		//verbose('State ${Type.getClassName(Type.getClass(this))} initialized', 2);
	}

	function resume() {
		for (system in systems) {
			system.onResume();
		}

		onResumed();
		//verbose('State ${Type.getClassName(Type.getClass(this))} resumed', 2);
	}

	function foreground() {
		for (system in systems) {
			system.onForeground();
		}

		onForeground();
		//verbose('State ${Type.getClassName(Type.getClass(this))} foregrounded', 2);
	}

	function update(delta:Float) {
		for (system in systems) {
			system.onUpdate(delta);
		}

		onUpdate(delta);
	}

	function fixedUpdate(delta:Float) {
		for (system in systems) {
			system.onFixedUpdate(delta);
		}

		onFixedUpdate(delta);
	}
	
	/*function mouseMove(event:MouseEvent) {
		onMouseMove(event);
	}*/

	function background() {
		onBackground();
		//verbose('State ${Type.getClassName(Type.getClass(this))} backgrounded', 2);

		for (system in systems) {
			system.onBackground();
		}
	}

	function suspend() {
		onSuspend();
		//verbose('State ${Type.getClassName(Type.getClass(this))} suspended', 2);

		for (system in systems) {
			system.onSuspend();
		}
	}

	function destroy() {
		onDestroy();
		//verbose('State ${Type.getClassName(Type.getClass(this))} destroyed', 2);

		for (system in systems) {
			system.onDestroy();
		}
	}

}