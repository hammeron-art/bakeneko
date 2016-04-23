package bakeneko.utils;
#if use_profiler

/**
 * Profiler using hxScout
 * https://github.com/jcward/hxScout
 */
class Profiler {

	var hxt:hxtelemetry.HxTelemetry;
	
	public function new(?title:String = "Profiler") {
		var config = new hxtelemetry.HxTelemetry.Config();
		config.allocations = true;
		config.app_name = title;
		
		hxt = new hxtelemetry.HxTelemetry(config);
	}
	
	inline public function update() {
		hxt.advance_frame();
	}
	
}

#end