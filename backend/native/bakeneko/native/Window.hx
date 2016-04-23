package bakeneko.native;

import bakeneko.core.Event;
import bakeneko.core.WindowEvent;
import bakeneko.core.WindowConfig;
import bakeneko.input.KeyCode;
import bakeneko.input.KeyModifier;

class Window implements bakeneko.core.Window {

	public var x (get, set):Int;
	public var y (get, set):Int;
	public var width(get, never):Int;
	public var height(get, never):Int;
	
	public var resizable (get, set):Bool;
	public var scale (get, null):Float;
	public var title (get, set):String;
	public var borderless (get, set):Bool;
	
	public var onActivate = new Event<Void->Void> ();
	public var onClose = new Event<Void->Void> ();
	public var onCreate = new Event<Void->Void> ();
	public var onDeactivate = new Event<Void->Void> ();
	public var onDropFile = new Event<String->Void> ();
	public var onEnter = new Event<Void->Void> ();
	public var onFocusIn = new Event<Void->Void> ();
	public var onFocusOut = new Event<Void->Void> ();
	public var onFullscreen = new Event<Void->Void> ();
	public var onKeyDown = new Event<KeyCode->KeyModifier->Void> ();
	public var onKeyUp = new Event<KeyCode->KeyModifier->Void> ();
	public var onLeave = new Event<Void->Void> ();
	public var onMinimize = new Event<Void->Void> ();
	public var onMouseDown = new Event<Float->Float->Int->Void> ();
	public var onMouseMove = new Event<Float->Float->Void> ();
	public var onMouseMoveRelative = new Event<Float->Float->Void> ();
	public var onMouseUp = new Event<Float->Float->Int->Void> ();
	public var onMouseWheel = new Event<Float->Float->Void> ();
	public var onMove = new Event<Float->Float->Void> ();
	public var onResize = new Event<Int->Int->Void> ();
	public var onRestore = new Event<Void->Void> ();
	public var onTextEdit = new Event<String->Int->Int->Void> ();
	public var onTextInput = new Event<String->Void> ();
	
	var limeWindow:lime.ui.Window;
	
	public function new(config:WindowConfig) {
		limeWindow = new lime.ui.Window(config);
	}
	
	inline function get_width() {
		return limeWindow.width;
	}
	inline function set_width(value) {
		return limeWindow.width = value;
	}
	
	inline function get_height() {
		return limeWindow.height;
	}
	inline function set_height(value) {
		return limeWindow.height = value;
	}
	
	inline function get_x() {
		return limeWindow.x;
	}
	inline function set_x(value) {
		return limeWindow.x = value;
	}
	
	inline function get_y() {
		return limeWindow.y;
	}
	inline function set_y(value) {
		return limeWindow.y = value;
	}
	
	inline function get_resizable() {
		return limeWindow.resizable;
	}
	inline function set_resizable(value) {
		return limeWindow.resizable = value;
	}
	
	inline function get_scale() {
		return limeWindow.scale;
	}
	
	inline function get_title() {
		return limeWindow.title;
	}
	inline function set_title(value) {
		return limeWindow.title = value;
	}
	
	inline function get_borderless() {
		return limeWindow.borderless;
	}
	inline function set_borderless(value) {
		return limeWindow.borderless = value;
	}
	
}