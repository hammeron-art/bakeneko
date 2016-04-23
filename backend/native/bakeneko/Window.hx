package bakeneko;

import bakeneko.core.Event;
import bakeneko.core.WindowEvent;
import bakeneko.core.WindowConfig;

class Window implements bakeneko.core.Window {

	public var onWindowEvent = new Event<WindowEvent->Void>();

	public var limeWindow:lime.ui.Window;
	
	public function new(config:WindowConfig) {
		limeWindow = new lime.ui.Window(config);
	}
	
}