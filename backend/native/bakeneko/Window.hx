package bakeneko;

import bakeneko.core.Event;
import bakeneko.core.WindowEvent;
import bakeneko.core.WindowConfig;
import bakeneko.input.KeyCode;
import bakeneko.input.KeyModifier;

class Window implements bakeneko.core.Window {

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
	
}