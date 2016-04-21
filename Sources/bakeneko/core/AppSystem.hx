package bakeneko.core;

/**
 * An appsystem is create when the app start and exists
 * through the entire life of the app
 */

class AppSystem {

	var app:Application;

	public function new() {
		app = Application.get();
	}

	public function onInit():Void {};
    public function onResume():Void {};
    public function onForeground():Void {};
    public function onUpdate(delta:Float):Void {};
    public function onFixedUpdate(delta:Float):Void {};
    public function onBackground():Void {};
    public function onSuspend():Void {};
    public function onDestroy():Void {};
}