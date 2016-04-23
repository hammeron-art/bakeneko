package bakeneko.asset;

import bakeneko.task.Task;

interface IResource {
	public var id:String;
	public var refCount:Int;
	public function reload():Task<Dynamic>;
	public function clear():Void;
	public function memoryUsage():Int;
}