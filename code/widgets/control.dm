/*
controls are the base class from which most hud widgets derive.

These are meant to be inherited from to build other widgets, rather than used directly in most cases.

The control widget provides handling for mouse interaction and state tracking.

Mouse tracking functions:
	Hovered()
	Unhovered()
	Pressed()
	Released()
	Dropped()
	Toggled()

	//called from MouseTick() when hover_lag, hold_lag, hover_delay, and hold_delay are set
	Hover()
	Hold()

Altering the state:
	Disable()
	Enable()
	Toggle()

checking the state:
	isEnabled()
	isDisabled()
	isPressed()
	isHovered()
	canToggle()

control widgets can use 4 or 6 directional icon_states to represent their interaction state.

4 dir:
NORTH: Inactive (unpressed & untoggled)
SOUTH: Active (pressed or toggled)
EAST: Hovered
WEST: Disabled

6 dir:
NORTH: Unhovered Untoggled
NORTHWEST: Disabled Untoggled
NORTHEAST: Hovered Untoggled

SOUTH: Unhovered Toggled
SOUTHWEST: Disabled Toggled
SOUTHEAST: Hovered Toggled

*/

client
	var/tmp
		//temporary data storage for interaction with controls
		__mouse_mode
		atom/__mouse_over
		atom/__mouse_src
		__mouse_params

		vector/__mouse_drag_handle
		vector/__mouse_drag_screen

		__mouse_drag_tick = 1#INF
		__mouse_next_tick = 1#INF

	proc
		#ifndef HUDLIB_CONTROL_INFO
			#warn MouseTick() needs to be integrated into your tick scheduler. Click here for notes or define HUDLIB_CONTROL_INFO to dismiss this warning.
		#endif
		//Because controls might instigate player actions, you want to call this before the client's inputs are processed in your tick scheduler.
		//this function allows MouseTick() updates to be fired on frames where mouse hover, hold, or drag events are expected.
		MouseUpdate()
			set waitfor = 0
			if(__mouse_next_tick<=world.time)
				__mouse_next_tick = 1#INF
				MouseTick(__mouse_src,__mouse_mode,__mouse_over,__mouse_params)

			if(__mouse_drag_tick<=world.time)
				__mouse_drag_tick = 1#INF
				MouseTick(__mouse_src,MOUSE_MODE_DRAGGING,__mouse_over,__mouse_params)

		//This should be called each tick while the mouse is actively involved with a control
		MouseTick(atom/src_object,mode,atom/over_object,params)
			set waitfor = 0
			__mouse_drag_tick = 1#INF
			src_object?.MouseTick(mode,over_object,params)

atom
	proc
		//called from client.MouseTick() when the mouse is actively involved with a control
		MouseTick(mode,over_object,params)
			set waitfor = 0


//hold_mode values for control.hold_mode
var/const/MOUSE_HOLDING_FREE = 0	//Hold() is called regardless of what the mouse is over
var/const/MOUSE_HOLDING_OVER = 1	//Hold() is only called when  when the mouse is held over the control
var/const/MOUSE_HOLDING_DRAG = 2	//Adds additional tracking for screen positions during a drag and drop sequence

//mouse modes are stored in client.__mouse_mode when in use over a control
var/const/MOUSE_MODE_NONE = null
var/const/MOUSE_MODE_PRESS = "press"
var/const/MOUSE_MODE_RELEASE = "release"
var/const/MOUSE_MODE_DRAG = "drag"
var/const/MOUSE_MODE_DRAGGING = "dragging"
var/const/MOUSE_MODE_DROP = "drop"


hud/widget/control
	dir = NORTH

	var/tmp
		enabled = 1						//controls won't do anything when disabled
		state = NORTH					//keeps track of the hover, press, and toggle state of the control
		toggled = 0						//keeps track of whether this control is toggled (1 = toggled, 0 = untoggled)

		hover_lag = 1#INF				//how long after the last Hover() call to wait before calling Hover() again
		hover_delay = 1#INF				//how long after beginning to hover the first Hover() is called from MouseTick()

		hold_lag = 1#INF				//how long after the last Hold() call to wait before calling Hold() again
		hold_delay = 1#INF				//how long after beginning to hold the control Hold() is called from MouseTick()

		hold_mode = MOUSE_HOLDING_OVER	//determines behavior during a mouse holding or dragging sequence.
										// MOUSE_HOLDING_FREE or MOUSE_HOLDING_OVER: OVER will call Hold() only when the mouse is held over this control. FREE doesn't care what the mouse is held over
										// MOUSE_HOLDING_DRAG: If this flag is on, additional data regarding mouse positioning will be kept for use in MouseTick()

		transitions = 0					//transitions will only fire once per frame. If this is on, onTransition() will be called at the end of ui.Tick()

	proc
	//HOOKS

		//called when the mouse begins hovering over this control
		Hovered()
			set waitfor = 0
			if(transitions) usr.client?.ui.transitions[src] = "hover"

		//called periodically while hovering over this control; controlled by hover_delay and hover_lag
		Hover()
			set waitfor = 0

		Unhovered()
			set waitfor = 0
			if(transitions) usr.client?.ui.transitions[src] = "unhover"

		Pressed()
			set waitfor = 0
			if(transitions) usr.client?.ui.transitions[src] = "press"

		Hold()
			set waitfor = 0
			if(transitions) usr.client?.ui.transitions[src] = "held"

		Released()
			set waitfor = 0

		Dropped()
			set waitfor = 0
			if(transitions) usr.client?.ui.transitions[src] = "drop"

		//called after the toggle state of the control has been changed
		Toggled()
			set waitfor = 0

	//MUTATORS

		//disables this control
		Disable()
			dir = WEST | (toggled ? SOUTH : NORTH)
			enabled = 0

		//enables this control
		Enable()
			dir = state
			enabled = 1

		//call to swap the toggle state of this control
		//	returns 0 if no change
		//	returns 1 if changed
		Toggle()
			if(!canToggle()) return 0

			toggled = !toggled
			state = (state & EAST) | (toggled ? SOUTH : NORTH)
			dir = (enabled ? state : WEST | (toggled ? SOUTH : NORTH))
			Toggled()

			return 1

	//ACCESSORS

		//returns 1 if enabled, 0 if disabled
		isEnabled()
			return enabled

		//returns 0 if enabled, 1 if disabled
		isDisabled()
			return !enabled

		//returns true if currently pressed
		isPressed()
			return state & SOUTH

		//returns true if currently hovered
		isHovered()
			return state & EAST

		//returns 0 by default. return 1 if you want to allow this control to be toggled; checked by Toggle() and mouse release actions
		canToggle()
			set waitfor = 0
			return 0

	//OVERRIDES

	MouseDown(atom/location,control,params)
		var/list/p = params2list(params)
		//ignore mouse presses during a drag event
		if(!p["drag"])
			var/client/client = usr.client

			//when the mouse primary button is being pressed
			if(p["button"]==client.mouse_primary)

				//store the mouse action data
				client.__mouse_mode = MOUSE_MODE_PRESS
				client.__mouse_src = src
				client.__mouse_over = src
				client.__mouse_params = params
				client.__mouse_next_tick = world.time + max(hold_delay,0)

				//if this object needs to preserve drag data, store a drag handle and initial screen position
				if(hold_mode & MOUSE_HOLDING_DRAG)
					client.__mouse_drag_handle = vector(text2num(p["icon-x"])-1,text2num(p["icon-y"])-1)
					client.__mouse_drag_screen = client.ScreenVector(p["screen-loc"])
					//mark the mouse dragging tick time
					if(enabled)
						client.__mouse_drag_tick = world.time

				//exit the hover state
				state = SOUTH
				Unhovered()

				//if this object is enabled, update the direction and call Pressed()
				if(enabled)
					dir = state
					Pressed()
			else
				//if an alternate button is pressed, we're no longer hovering.
				state &= ~EAST
				dir = state & (!enabled&&WEST)
				Unhovered()

	MouseUp(atom/location,control,params)
		var/list/p = params2list(params)
		//ignore mouse releases during a drag event
		if(!p["drag"])
			var/client/client = usr.client

			//if we're just holding the mouse
			if(client.__mouse_mode==MOUSE_MODE_PRESS)
				//if the mouse button is primary
				if(p["button"]==client.mouse_primary)
					//if enabled
					if(enabled)
						//trigger toggling if allowed
						var/changed = 1
						if(canToggle())
							toggled = !toggled
						else
							changed = 0

						//update state and graphics
						state = EAST | (toggled ? SOUTH : NORTH)
						dir = state

						//call release, toggle, and hover hooks
						Released()
						if(changed)
							Toggled()
						Hovered()
					else
						//when disabled, update the state
						state = EAST | (toggled ? SOUTH : NORTH)
				else
					//if the button is non-primary, update the state and call the hovered hook if enabled
					state = EAST
					if(enabled)
						dir = state
						Hovered()

				//update the mouse params and invoke MouseTick() for the end of a drag action if the hold mode includes dragging notifications
				client.__mouse_params = params

				if(enabled && (hold_mode & MOUSE_HOLDING_DRAG))
					client.__mouse_drag_tick = world.time
					client.MouseTick(src,MOUSE_MODE_RELEASE,src,params)
				else
					client.__mouse_drag_tick = 1#INF

				//clean up the mouse tracking data
				client.__mouse_mode = MOUSE_MODE_NONE
				client.__mouse_src = null
				client.__mouse_drag_handle = null
				client.__mouse_drag_screen = null

			else if(client.__mouse_mode==MOUSE_MODE_NONE)
				//when in any other state, just clean up the state and call out to hovered if necessary (shores up a missing MouseDrop call)
				if(!(state&EAST))
					state = EAST | (toggled ? SOUTH : NORTH)
					if(enabled)
						dir = state
						Hovered()

	MouseDrop(over_object,src_location,over_location,src_control,over_control,params)
		var/list/p = params2list(params)
		var/client/client = usr.client

		//handle primary mouse drops
		if(p["button"]==client.mouse_primary)
			if(over_object==src)
				//when over self (dropping on self after initiating a drag event)
				if(enabled)
					//update the toggle state
					var/changed = 1
					if(canToggle())
						toggled = !toggled
					else
						changed = 0

					//update the visual and logical state
					state = EAST | (toggled ? SOUTH : NORTH)
					dir = state

					//call the released hooks like this is just a MouseUp event
					Released()
					if(changed)
						Toggled()
					Hovered()
				else
					//otherwise, just update the logical state
					state = EAST | (toggled ? SOUTH : NORTH)

				client.__mouse_over = src
			else
				//when dropping onto another object, update the visual and logical state when enabled and fire the Dropped() hook
				state = (toggled ? SOUTH : NORTH)
				if(enabled)
					dir = state
					Dropped()

				client.__mouse_over = null

			//if this object is tracking drag actions, we need to fire a MouseTick() for the drop action
			if(enabled && (hold_mode & MOUSE_HOLDING_DRAG))
				client.__mouse_drag_tick = world.time
				client.MouseTick(src,MOUSE_MODE_DROP,over_object,params)
			else
				client.__mouse_drag_tick = 1#INF

		//clean up the mouse data tracking
		client.__mouse_mode = MOUSE_MODE_NONE
		client.__mouse_src = null
		client.__mouse_params = params
		client.__mouse_drag_handle = null
		client.__mouse_drag_screen = null

	MouseDrag(over_object,src_location,over_location,src_control,over_control,params)
		var/client/client = usr.client
		//if we're just beginning a drag action, swap the action to a drag
		if(client.__mouse_mode==MOUSE_MODE_PRESS && over_object!=src)
			client.__mouse_mode = MOUSE_MODE_DRAG

		//if we're tracking drag actions, enabled, and tracking a primary action, mark the next drag tick for this frame
		if(enabled && client.__mouse_mode && (hold_mode & MOUSE_HOLDING_DRAG))
			client.__mouse_drag_tick = world.time

		//update the mouse data tracking
		client.__mouse_over = over_object
		client.__mouse_params = params

	MouseTick(mode,over_object,params)
		switch(mode)
			if(MOUSE_MODE_NONE)
				//when hovering, call the hover tick
				usr.client.__mouse_next_tick = world.time + max(hover_lag,0)
				if(enabled && over_object==src)
					Hover()

			if(MOUSE_MODE_PRESS, MOUSE_MODE_DRAG)
				//when pressing or dragging, call the hold tick
				usr.client.__mouse_next_tick = world.time + max(hold_lag,0)
				//obey the hold mode settings
				if(enabled && (!(hold_mode&MOUSE_HOLDING_OVER) || over_object==src))
					Hold()

			if(MOUSE_MODE_DRAGGING, MOUSE_MODE_DROP, MOUSE_MODE_RELEASE)
				//if tracking mouse drags, we need to lock out mouse drag ticks until the next drag action resets it
				usr.client.__mouse_drag_tick = 1#INF

	MouseEntered(atom/location,control,params)
		//trigger the hovered action if not already hovering
		if(!(state&EAST))
			state = EAST | (toggled ? SOUTH : NORTH)
			if(enabled)
				dir = state
				Hovered()

		//set up the mouse tracking data
		var/client/client = usr.client
		client.__mouse_mode = MOUSE_MODE_NONE
		client.__mouse_over = src
		client.__mouse_params = params
		client.__mouse_next_tick = world.time + max(hold_delay,0)

	MouseExited(atom/location,control,params)
		//trigger the unhovered action if enabled
		state = (toggled ? SOUTH : NORTH)
		if(enabled)
			dir = state
			Unhovered()

		//tear down the mouse tracking data
		var/client/client = usr.client
		client.__mouse_mode = MOUSE_MODE_NONE
		client.__mouse_over = null
		client.__mouse_params = params
		client.__mouse_next_tick = 1#INF