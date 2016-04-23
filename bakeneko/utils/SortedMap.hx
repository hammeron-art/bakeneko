package bakeneko.utils;

import bakeneko.input.InputSystem.Key;
import haxe.Constraints.IMap;
import haxe.ds.ArraySort;

/**
 * Ordened map
 * If a sort function is defined, this map auto sort when a new key entry is added
 */
class SortedMap<K, V> implements IMap<K, V> {

	var map:Map<K, V>;
	@:allow(bakeneko.utils.SortedMapIterator)
	var keyList:Array<K>;
	var index = 0;
	var sortFunction:K->K->Int;
	
	public function new(map, ?sortFunction: K->K->Int) {
		keyList = [];
		this.map = map;
		
		this.sortFunction = sortFunction;
	}
	
	/* INTERFACE haxe.Constraints.IMap<K,V> */
	
	public function get(key:K):Null<V> {
		return map.get(key);
	}
	
	public function set(key:K, value:V):Void {
		if (!map.exists(key))
			keyList.push(key);
		map[key] = value;

		if (sortFunction != null)
			ArraySort.sort(keyList, sortFunction);
	}
	
	public function exists(key:K):Bool {
		return map.exists(key);
	}
	
	public function remove(key:K):Bool {
		return map.remove(key) && keyList.remove(key);
	}
	
	public function keys():Iterator<K> {
		return keyList.iterator();
	}
	
	public function iterator():Iterator<V> {
		return new SortedMapIterator<K, V>(this);
	}
	
	public function toString() {
        var str = '';
		var count = 0;
		var length = keyList.length;
		
        for (key in keyList)
			str += '$key => ${map.get(key)}${(count++ < length-1 ? ", " : "")}';
		
        return '[$str]';
    }
	
}

class SortedMapIterator<K, V> {
	var map:SortedMap<K, V>;
	var index = 0;
	
	public function new(map:SortedMap<K, V>) {
		this.map = map;
	}
	
	public function hasNext() {
		return index < map.keyList.length;
	}
	
	public function next() {
		return map.get(map.keyList[index++]);
	}
}