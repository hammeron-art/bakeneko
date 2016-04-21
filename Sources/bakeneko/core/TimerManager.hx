package bakeneko.core;

import bakeneko.core.Timer;

/**
 * Create and manager timer
 * All times in seconds
 */
class TimerManager {

	var timers: Array<Timer>;
	
	public function new() {
		timers = [];
	}
	
	public function schedule(time:Float, onFinish:Void->Void, ?repeat:Bool = false):Timer {
		var timer = new Timer(Std.int(time * 1000));
		
		timer.run = function() {
			if (!repeat) {
				timer.stop();
				timers.remove(timer);
			}
			onFinish();
		}
		
		timers.push(timer);
		
		return timer;
	}
	
	public function reset() {
		for (t in timers) {
			t.stop();
			t = null;
		}
		
		timers = null;
		timers = [];
	}
	
}