package bakeneko.state;
import bakeneko.core.Log;

/**
 * ...
 * @author Hammer On Art
 */
class StateSystem {

	public function onInit():Void { Log.info('$this initialized'); };
    public function onResume():Void {};
    public function onForeground():Void {};
    public function onUpdate(delta:Float):Void {};
    public function onFixedUpdate(delta:Float):Void {};
    public function onBackground():Void {};
    public function onSuspend():Void {};
    public function onDestroy():Void { };
	
	public function toString() {
		return Type.getClassName(Type.getClass(this));
	}
	
}