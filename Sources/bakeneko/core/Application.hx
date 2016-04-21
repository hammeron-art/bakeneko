package bakeneko.core;

import bakeneko.core.Window;
import bakeneko.input.Input.KeyCode;
import bakeneko.input.InputSystem;
import bakeneko.render.RenderSystem;
import bakeneko.asset.ResourceManager;
import bakeneko.state.StateManager;
import bakeneko.core.TimerManager;
import bakeneko.core.Log;
import lime.graphics.Renderer;
import lime.ui.KeyModifier;

/**
 * Application entry point
 * Contains all global systems and controls to the application
 */
@:allow(bakeneko.core.Core)
@:access(bakeneko.input.InputSystem)
class Application {
	// The core framework
	public static var core(default, null):Core;
	// Reference to this instance
	static var application:Application;

	// List of application systems
	public var systems:Array<AppSystem>;
	// If systems can be created
	var canAddSystens:Bool;

	// Reference to default application systems
	public var resourceManager(default, null):ResourceManager;
	public var renderSystem(default, null):RenderSystem;
	public var stateManager(default, null):StateManager;
	public var input(default, null):InputSystem;
	/*#if packer
	public var packer(default, null):TexturePacker;
	#end*/
	public static var events(default, null):EventSystem;

	public var timer(default, null):TimerManager;

	// Update control
	var updateInterval:Float = 1.0 / 60.0;
	var updateIntervalRemainder:Float = 0.0;
	var isFirstFrame:Bool = true;

	// Frames per second
	var fpsTimer:Timer;
	var fpsCount:Int = 0;
	var fpsFixedCount:Int = 0;
	public var fpsRate:Int = 0;
	public var fpsFixedRate:Int = 0;

	public function new() {
		systems = [];
		timer = new TimerManager();
		application = this;
	}

	/**
	 * User defined
	 * Configure the application
	 * Called when app is initialized
	 *
	 * @param	config
	 * @return
	 */
	public function initConfig(config:AppConfig):AppConfig {
		config.windows[0].title = "Bakeneko App";
		return config;
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
	public function createSystem<T>(appSystem:T):T {
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
	 * Get application instance
	 */
	public static function get():Application {
		return application;
	}

	/**
	 * The follow are not mean to be used by the user and is called by the Core
	 */

	/**
	 * Inicialize application
	 *
	 * @param	bakenekoCore
	 */
	function init(bakenekoCore:Core):Void {
		core = bakenekoCore;
		application = this;

		canAddSystens = true;
		createDefaultSystems();
		createSystems();
		canAddSystens = false;
		
		for (appSystem in systems) {
			appSystem.onInit();
		}

		onInit();
		initialState();
		Log.assert(stateManager.operations.length > 0 && stateManager.operations.first().action == StateAction.Push, 'Can\'t start without a state');
		
		fpsTimer = timer.schedule(1000, function() {
			fpsRate = fpsCount;
			fpsCount = 0;

			fpsFixedRate = fpsFixedCount;
			fpsFixedCount = 0;
		}, true);
		
		core.inited = true;
	}

	/**
	 * Create core app systems
	 */
	function createDefaultSystems():Void {
		input = createSystem(new InputSystem());
		events = createSystem(new EventSystem());
		resourceManager = createSystem(new ResourceManager());
		stateManager = createSystem(new StateManager());
		renderSystem = createSystem(new RenderSystem());

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
		//updateIntervalRemainder = Math.min(updateIntervalRemainder + delta, 0.33);
		
		onUpdate(delta);
		
		/*while ((updateIntervalRemainder >= updateInterval) || isFirstFrame) {
			updateIntervalRemainder -= updateInterval;

			onFixedUpdate(updateInterval);
			
			for (appSystem in systems) {
				appSystem.onFixedUpdate(updateInterval);
			}

			stateManager.fixedUpdateStates(updateInterval);

			isFirstFrame = false;

			++fpsFixedCount;
		}*/

		for (appSystem in systems) {
			appSystem.onUpdate(delta);
		}

		stateManager.updateStates(delta);
		
		++fpsCount;
	}
	
	function render(renderer:Renderer) {
		if (core.inited && stateManager.getCurrentState() != null) {
			renderSystem.onRender(renderer);
		}
	}
	
	function windowEvent(event:WindowEvent) {
		
		switch(event.type) {
			case WindowEventType.focusIn:
				foreground();
			case WindowEventType.focusOut:
				background();
			default:
		}
		
		onWindowEvent(event);
	}
	
	inline function keyDown(window:Window, keyCode:KeyCode, modifier:KeyModifier) {
		input.onKeyDown(window, keyCode, modifier);
	}
	
	inline function keyUp(window:Window, keyCode:KeyCode, modifier:KeyModifier) {
		input.onKeyUp(window, keyCode, modifier);
	}
	
	function background():Void {
		stateManager.backgroundStates();

		for (appSystem in systems) {
			appSystem.onBackground();
		}
	}

	function foreground():Void {
		for (appSystem in systems) {
			appSystem.onForeground();
		}

		stateManager.foregroundStates();
	}
}

// Application configuration type
typedef AppConfig = lime.app.Config;