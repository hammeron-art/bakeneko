package bakeneko.core;

import bakeneko.core.WindowEvent;
import bakeneko.input.InputSystem;
import bakeneko.input.KeyCode;
import bakeneko.input.KeyModifier;

class Application {

	public var windows:Array<Window>;
	// List of application systems
	public var systems:Array<AppSystem>;
	public var input:InputSystem;
	public var frameCount:Int;
	
	var canAddSystens:Bool;
	
	static var application:Application;
	
	public function new () {
		frameCount = 0;
		
		systems = [];
		windows = [];
		application = this;
	}
	
	/**
	 * Get application instance
	 */
	public static function get():Application {
		return application;
	}
	
	/**
	 * User defined
	 * Create app systems
	 */
	public function createSystems():Void { }

	/**
	 * User defined
	 * Called after all systems have been set up
	 */
	public function onInit():Void { }
	
	/**
	 * User defined
	 * Push first stage
	 */
	public function initialState():Void { }
	
	/**
	 * User defined
	 * Fixed update method called before any other system or state fixed update
	 * @param	delta
	 */
	public function onFixedUpdate(delta:Float):Void { }
	
	/**
	 * User defined
	 * Update method called before any other system or state update
	 * @param	delta
	 */
	public function onUpdate(delta:Float):Void { }

	/**
	 * User defined
	 * Called when an window event occurs
	 * @param	event
	 */
	public function onWindowEvent(event:WindowEvent):Void {}
	
	/**
	 * AppSystems are created with this method
	 */
	public function createSystem<T:AppSystem>(appSystem:T):T {
		Log.assert(canAddSystens == true, "Can't create app systems");

		systems.push(cast appSystem);
		return appSystem;
	}
	
	/**
	 * Get a AppSystem by type
	 */
	@:generic public function getSystem<T:(AppSystem)>(c:Class<T>):T {
		for (system in systems) {
			if (Std.is(system, c)) {
				return cast system;
			}
		}
		return null;
	}
	
	/**
	 * Inicialize application
	 *
	 * @param	bakenekoCore
	 */
	function init():Void {
		canAddSystens = true;
		createDefaultSystems();
		createSystems();
		canAddSystens = false;
		
		for (appSystem in systems) {
			appSystem.onInit();
		}

		onInit();
		initialState();
		//Log.assert(stateManager.operations.length > 0 && stateManager.operations.first().action == StateAction.Push, 'Can\'t start without a state');
	}

	/**
	 * Create core app systems
	 */
	function createDefaultSystems():Void {
		input = createSystem(new InputSystem());
		/*#if packer
		packer = createSystem(new TexturePacker());
		#end*/
	}
	
	/**
	 * Update of application
	 *
	 * @param	delta time from last update
	 */
	function update(delta:Float):Void {
		++frameCount;
	}
	
	function keyDown(window:Window, keyCode:KeyCode, modifier:KeyModifier):Void {
		input.onKeyDown(window, keyCode, modifier);
	}
	
	function keyUp(window:Window, keyCode:KeyCode, modifier:KeyModifier):Void {
		input.onKeyUp(window, keyCode, modifier);
	}
}