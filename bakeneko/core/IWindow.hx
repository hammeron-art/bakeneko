package bakeneko.core;

import bakeneko.render.Surface;
import bakeneko.render.Renderer;
import bakeneko.input.KeyCode;
import bakeneko.input.KeyModifier;

interface IWindow {
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
	
	public var onActivate:Event<Void->Void>;
	public var onClose:Event<Void->Void>;
	public var onCreate:Event<Void->Void>;
	public var onDeactivate:Event<Void->Void>;
	public var onDropFile:Event<String->Void>;
	public var onEnter:Event<Void->Void>;
	public var onFocusIn:Event<Void->Void>;
	public var onFocusOut:Event<Void->Void>;
	public var onFullscreen:Event<Void->Void>;
	public var onKeyDown:Event<KeyCode->KeyModifier->Void>;
	public var onKeyUp:Event<KeyCode->KeyModifier->Void>;
	public var onLeave:Event<Void->Void>;
	public var onMinimize:Event<Void->Void>;
	public var onMouseDown:Event<Float->Float->Int->Void>;
	public var onMouseMove:Event<Float->Float->Void>;
	public var onMouseMoveRelative:Event<Float->Float->Void>;
	public var onMouseUp:Event<Float->Float->Int->Void>;
	public var onMouseWheel:Event<Float->Float->Void>;
	public var onMove:Event<Float->Float->Void>;
	public var onResize:Event<Int->Int->Void>;
	public var onRestore:Event<Void->Void>;
	public var onTextEdit:Event<String->Int->Int->Void>;
	public var onTextInput:Event<String->Void>;
}