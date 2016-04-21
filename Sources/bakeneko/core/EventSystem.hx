package bakeneko.core;
import bakeneko.utils.Utils;

/**
 * An event system that handles queued, immediate or
 * scheduled event id's to be fired and listened for.
 * Multiple listeners can be connected to a single event id,
 * and when fired all listeners are informed. Events are not
 * retroactive, only listeners that are attached at the time
 * will recieve the event notifications. Don't forget to disconnect events.
 */
class EventSystem extends AppSystem {

    @:noCompletion public var eventQueue : Map< String, EventObject>;
	// event id, connect
    @:noCompletion public var eventConnections : Map< String, EventConnection>;
	// event name, array of connections
    @:noCompletion public var eventSlots : Map< String, Array<EventConnection> >;
	// event name, array of connections
    @:noCompletion public var eventFilters : Map< String, Array<EventConnection> >;
	// event id, timer
    @:noCompletion public var eventSchedules : Map< String, bakeneko.core.Timer >;

    // Create a new instance for sending/receiving events.
    public function new( ) {
		super();

		//create the queue, lists and map
        eventConnections = new Map();
        eventSlots = new Map();
        eventFilters = new Map();
        eventQueue = new Map();
        eventSchedules = new Map();

    }

    // Destroy this `Events` instance
    public function destroy() {
        clear();
    }

    // Clear any scheduled or bound events. Called on destroy.
    public function clear() {

        for(schedule in eventSchedules) {
            schedule.stop();
            schedule = null;
        }

        for(connection in eventConnections.keys()) {
            eventConnections.remove(connection);
        }

        for(filter in eventFilters.keys()) {
            eventFilters.remove(filter);
        }

        for(slot in eventSlots.keys()) {
            eventSlots.remove(slot);
        }

        for(event in eventQueue.keys()) {
            eventQueue.remove(event);
        }

    }

    // Convenience. Exposed for learning/testing the filtering API.
    public function does_filter_event( filter:String, event:String ) {

        var replace_stars : EReg = ~/\*/gi;
        var final_filter : String = replace_stars.replace( filter, '.*?' );
        var final_search : EReg = new EReg(final_filter, 'gi');

        return final_search.match( event );

    }

    /**
	 * Bind a signal (listener) to a slot (eventName)
	 * eventName : The event id
	 * listener : A function handler that should get called on event firing
	 */
    public function listen<T>( eventName : String, listener : T -> Void ):String {

		//we need an ID and a connection to store
        var id : String = Utils.uniqueID();
        var connection : EventConnection = new EventConnection( id, eventName, listener );

		// now we store it in the map
        eventConnections.set( id, connection );

        // first check if the event name in question has a * wildcard,
		// if it does we have to store it as a filtered event so it's more optimal
		// to search through when events are fired
        var hasStars : EReg = ~/\*/gi;
        if(hasStars.match(eventName)) {

			//also store the listener inside the slots
            if(!eventFilters.exists(eventName)) {
				//no slot exists yet? make one!
                eventFilters.set(eventName, [] );
            }
			// it should exist by now, lets store the connection by event name
            eventFilters.get(eventName).push( connection );

        } else {

			// also store the listener inside the slots
            if(!eventSlots.exists(eventName)) {
				// no slot exists yet? make one!
                eventSlots.set(eventName, [] );
            }
			// it should exist by now, lets store the connection by event name
            eventSlots.get(eventName).push( connection );

        }

		// return the id for unlistening
        return id;

    }

    /**
	 * Disconnect a bound signal
     * The event connection id is returned from listen()
     * and returns true if the event existed and was removed.
	 */
    public function unlisten( eventID : String ) : Bool {

        if(eventConnections.exists(eventID)) {

            var connection = eventConnections.get(eventID);
            var eventSlot = eventSlots.get(connection.eventName);

            if(eventSlot != null) {
                eventSlot.remove(connection);
                return true;
            } else {
                var event_filter = eventFilters.get(connection.eventName);
                if(event_filter != null) {
                    event_filter.remove(connection);
                    return true;
                } else {
                    return false;
                }
            }

            return true;

        } else {
            return false;
        }

    }

	/*
	 * Queue an event in the next update loop
     * eventName : The event (register listeners with listen())
	 * properties : A dynamic pass-through value to hand off data
	 * returns : a String, the unique ID of the event
	 */
    public function queue<T>( eventName : String, ?properties : T ) : String {

        var id : String = Utils.uniqueID();

			//store it in case we want to manipulate it
            var event:EventObject = new EventObject(id, eventName, properties);

			//stash it away
            eventQueue.set(id, event);

		//return the user the id
        return id;

    }

	// Remove an event from the queue by id returned from queue.
    public function dequeue( eventID: String ) {

        if(eventQueue.exists(eventID)) {
            var event = eventQueue.get(eventID);
                event = null;

            eventQueue.remove( eventID );

            return true;
        }

        return false;

    }

	/*
	 * Process/update the events, firing any events in the queue.
     * if you create a custom instance, call this when you want to process.
	 */
	override public function onUpdate(delta:Float):Void {

		//fire each event in the queue
        for(event in eventQueue) {
            fire( event.name, event.properties );
        }

		//if we actually have any events, clear the queue
        if(eventQueue.keys().hasNext()) {
			//clear out the queue
            eventQueue = null;
            eventQueue = new Map();
        }

    }

	/**
	 * Fire an event immediately, calling all listeners.
	 * properties : An optional pass-through value to hand to the listener.
	 * Returns true if event existed, false otherwise.
	 * If the optional tag flag is set (default:false), the properties object will be modified
	 * with some debug information, like _eventName_ and _event_connection_count_
	 */
    public function fire<T>( eventName : String, ?properties : T, ?tag:Bool=false ) : Bool {

        var fired = false;

        //we have to check against our filters if this event matches anything
        for(filter in eventFilters) {

            if(filter.length > 0) {

                var _filter_name = filter[0].eventName;
                if(does_filter_event(_filter_name, eventName)) {
                    if(tag) {
                        properties = tag_properties(properties, eventName, filter.length);
                    }

                    for(_connection in filter) {
                        _connection.listener( cast properties );
                    }

                    fired = true;
                }
            }

        }

        if (eventSlots.exists( eventName )) {
			//we have an event by this name
            var connections:Array<EventConnection> = eventSlots.get(eventName);

            if (tag) {
                properties = tag_properties(properties, eventName, connections.length);
            }

			//call each listener
            for (connection in connections) {
                connection.listener( cast properties );
            }

            fired = true;
        }

        return fired;

    }

	/**
	 * Schedule and event in the future
	 * eventName : The event (register listeners with listen())
	 * properties : An optional pass-through value to hand to the listeners
	 * Returns the ID of the schedule (for unschedule)
	 */
    public function schedule<T>( time:Int, eventName : String, ?properties : T ) : String {

        var id : String = Utils.uniqueID();

            var timer = Application.get().timer.schedule(time, fire.bind(eventName, properties));

            eventSchedules.set( id, timer );

        return id;

    }

	/**
	 * Unschedule a previously scheduled event
	 * schedule_id : The id of the schedule (returned from schedule)
	 * Returns false if fails, or event doesn't exist
	 */
    public function unschedule( scheduleID : String ) : Bool {

        if(eventSchedules.exists(scheduleID)) {
			// find the timer
            var timer = eventSchedules.get(scheduleID);
			// kill it
            timer.stop();
			// remove it from the list
            eventSchedules.remove(scheduleID);
			// done
            return true;
        }

        return false;

    }

	// Internal

    function tag_properties(properties:Dynamic, name:String, count:Int) {

		if (properties == null)
			properties = {};

		//tag these information slots, with _ so they don't clobber other stuff
        Reflect.setField(properties,'_eventName_', name);
		//tag a listener count
        Reflect.setField(properties,'_eventConnectionCount_', count);

        return properties;

    }

}

private class EventConnection {

    public var listener : Dynamic -> Void;
    public var id : String;
    public var eventName : String;

    public function new( id:String, eventName:String, listener : Dynamic -> Void ) {
        this.id = id;
        this.listener = listener;
        this.eventName = eventName;
    }

}

private class EventObject {

    public var id : String;
    public var name:String;
    public var properties : Dynamic;

    public function new(id:String, eventName:String, eventProperties:Dynamic ) {
        this.id = id;
        name = eventName;
        properties = eventProperties;
    }

}