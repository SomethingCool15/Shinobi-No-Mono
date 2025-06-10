#ifndef NEXT_SERVER_TICK
	#define NEXT_SERVER_TICK world.time
#endif

client
	var/tmp
		ui/ui

		mouse_primary = "left"			//stores the client's mouse handedness preferences
		mouse_secondary = "right"

	proc
		//make sure you call this somewhere in your code. Otherwise you won't have a ui.
		#ifndef HUDLIB_INFO
			#warn call client.InitializeUI() to set up the ui manager, or HudLib won't work. #define HUDLIB_INFO to suppress this warning
		#endif

		InitializeUI()
			ui = new/ui(src)

		//returns the size of the viewport as a vector
		ScreenSize()
			return vector(view) * world.icon_size

		//converts a screen_loc string (from mouse params) to a vector in pixels from the bottom-left corner
		ScreenVector(sloc)
			if(!sloc) return null
			var/list/l = splittext(sloc,","), list/c = splittext(l[1],":"), len = length(c)
			return vector((text2num(c[len-1]) - 1) * world.icon_size + text2num(c[len]) - 1,(text2num((c = splittext(l[2],":"))[1]) - 1) * world.icon_size + text2num(c[2]) - 1)

		//converts a screen_loc string (from mouse params) to a pixloc on the map
		ScreenPixloc(sloc)
			var/z = bounds?[5]
			if(!z) return null
			var/list/l = splittext(sloc,","), list/c = splittext(l[1],":"), len = length(c)
			return pixloc(locate(1,1,z), bounds[1] - 1 + (text2num(c[len-1]) - 1) * world.icon_size + text2num(c[len]) - 1, bounds[2] - 1 + (text2num((c = splittext(l[2],":"))[1]) - 1) * world.icon_size + text2num(c[2]) - 1)

	//clean up the UI when we disconnect.
	Del()
		ui?.client = null
		ui = null
		..()

ui
	var/tmp
		client/client

		alist/hud = alist()
		list/active_huds = list()

		alist/transitions = alist()

	New(client/client)
		src.client = client
		..()

	proc
		//allow adding /hud elements to the ui via the += operator.
		operator+=(B)
			if(!islist(B))
				B = list(B)

			var/id
			for(var/hud/adding in B)
				//active huds MUST have a vis_id; if none is provided, make one up
				if(!(id = adding.vis_id))
					id = (adding.vis_id = "\ref[adding]")

				//don't allow to huds with the same id to be active.
				var/hud/old = hud[id]
				if(old)
					src -= old

				hud[id] = adding

		//allow removing /hud elements from the ui via the -= operator.
		operator-=(B)
			if(!islist(B))
				B = list(B)

			for(var/hud/removing in B)
				if(active_huds[removing])
					//hide the hud before removal if it's showing
					Hide(removing)
				hud -= removing.vis_id

		//allow looking up /hud elements by vis_id string.
		operator[](idx)
			return hud[idx]

		//allow replacing /hud elements by vis_id string.
		operator[]=(idx,B)
			if(!istext(idx))
				throw EXCEPTION("Invalid index: [idx]")

			var/hud/adding = astype(B,/hud)
			if(!adding && B)
				throw EXCEPTION("Invalid value for list: [B]")

			var/hud/old = hud[idx]
			if(old)
				if(old==adding) return
				src -= old

			adding.vis_id = idx
			hud[idx] = adding

		//show a hud on the UI.
		Show(hud/showing)
			set waitfor = 0
			usr = client.mob

			var/id
			if(istext(showing))
				showing = hud[showing]
			else if(ispath(showing))
				showing = hud[initial(showing:vis_id)] || new showing()
			else if(!showing || active_huds[showing]) return

			if(!(id = showing.vis_id) || hud[id]!=showing)
				src += showing

			if(showing.screen_loc)
				client.screen += showing
			else
				showing.vis_flags &= ~VIS_HIDE

			active_huds[showing] = 1

			//if the hud has ticking behavior, set up the next tick time
			if(showing.tick_lag<1#INF && showing.next_tick==1#INF)
				showing.next_tick = NEXT_SERVER_TICK

			showing.Show()

		//hide a hud from the UI.
		Hide(hud/hiding)
			set waitfor = 0
			usr = client.mob

			if(istext(hiding))
				hiding = hud[hiding]
			else if(ispath(hiding))
				hiding = hud[initial(hiding:vis_id)]

			if(hiding && active_huds[hiding])
				hiding.Hide()
				if(hiding.screen_loc)
					client.screen -= hiding
				else
					hiding.vis_flags |= VIS_HIDE

				active_huds -= hiding
				hiding.next_tick = 1#INF

		//toggle the show/hide state of a hud.
		ToggleShow(hud/toggle)
			set waitfor = 0
			usr = client.mob

			if(ispath(toggle))
				var/id = initial(toggle:vis_id)
				toggle = hud[id] || toggle
			if(istext(toggle))
				toggle = hud[toggle]

			if(istype(toggle))
				if(active_huds[toggle])
					Hide(toggle)
				else
					Show(toggle)

		//call toward the end of every world tick to allow huds to receive ticks
		#ifndef HUDLIB_INFO
			#warn call client.ui.Tick() at the end of world.Tick() or HudLib won't work. #define HUDLIB_INFO to suppress this warning
		#endif

		Tick()
			var/time = world.time
			for(var/hud/hud in active_huds)
				if(time >= hud.next_tick)
					hud.next_tick = world.time + hud.tick_lag
					hud.Tick()

			if(length(src.transitions))
				var/alist/transitions = src.transitions
				src.transitions = alist()
				for(var/hud_obj/elem, transition  in transitions)
					elem.onTransition(transition)

	Del()
		client?.screen -= active_huds
		..()


hud_obj
	var
		transition_state = null
	proc
		onTransition(transition)
			set waitfor = 0
			transition_state = transition

hud
	var/tmp
		next_tick = 1#INF	//the next time this hud will tick
		tick_lag = 1#INF	//set to 0 to tick every tick, or a time in deciseconds to tick every n deciseconds
	proc
		//called when a ui element is shown
		Show()

		//called when a ui element is hidden
		Hide()

		//called when the ui ticks every [tick_lag] ticks
		Tick()
			set waitfor = 0