package bakeneko.core;

import bakeneko.core.Event;
import bakeneko.core.WindowEvent;
import bakeneko.core.WindowConfig;
import bakeneko.render.Renderer;
import bakeneko.render.Surface;
import bakeneko.input.KeyCode;
import bakeneko.input.KeyModifier;

class Window implements bakeneko.core.IWindow {
	
	public var id (get, null):Int;
	
	public var x (get, set):Int;
	public var y (get, set):Int;
	public var width(get, never):Int;
	public var height(get, never):Int;
	
	public var resizable (get, set):Bool;
	public var scale (get, null):Float;
	public var title (get, set):String;
	public var borderless (get, set):Bool;
	
	public var surface:Surface;
	public var renderer:Renderer;
	
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
	
	function get_id() {
		return limeWindow.id;
	}
	
	function get_width() {
		return limeWindow.width;
	}
	function set_width(value) {
		return limeWindow.width = value;
	}
	
	function get_height() {
		return limeWindow.height;
	}
	function set_height(value) {
		return limeWindow.height = value;
	}
	
	function get_x() {
		return limeWindow.x;
	}
	function set_x(value) {
		return limeWindow.x = value;
	}
	
	function get_y() {
		return limeWindow.y;
	}
	function set_y(value) {
		return limeWindow.y = value;
	}
	
	function get_resizable() {
		return limeWindow.resizable;
	}
	function set_resizable(value) {
		return limeWindow.resizable = value;
	}
	
	function get_scale() {
		return limeWindow.scale;
	}
	
	function get_title() {
		return limeWindow.title;
	}
	function set_title(value) {
		return limeWindow.title = value;
	}
	
	function get_borderless() {
		return limeWindow.borderless;
	}
	function set_borderless(value) {
		return limeWindow.borderless = value;
	}
	
}