package bakeneko.render;

class Material {

	var pass:Pass;
	
	public function new(?pass:Pass) {
		this.pass = pass;
		
		init();
	}
	
	function init() {
		if (pass == null)
			return;
			
		pass.init();
	}
	
	public function apply() {
		pass.apply();
	}
}