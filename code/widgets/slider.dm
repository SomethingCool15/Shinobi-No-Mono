/*
slider widgets have a track and a handle by default.
	The handle is a button that can be held and dragged along two axes.

	The track_size should match draggable width and height of the track, from the near side of the handle at 0%, to the far side of the handle at 100%.

	The handle_size should match the size on the track that the handle occupies.
		A vertical slider will have a handle_size with an X size matching the track's X size, but a Y size that is less than the track's Y size.
		A horizontal slider will have a handle_size with a Y size matching the track's Y size, but an X size that is less than the track's X size.
		A 2D slider will have both X and Y axis sizes smaller for the handle than for the track.

onValue() is called whenever the value of the slider is changed. This is represented between 0 and 1
The Value() function will update the position of the handle according to a vector with x/y values between 0 and 1
	Value() can also be called with 2 numeric arguments instead of a vector
The MoveHandle() function will update the position of the handle being fed pixel position data of the center of the handle
	MoveHandle() can be called with 2 numeric arguments instead of a vector

the handle variable stores the type of handle to be created for the slider, and the slider handle that was created after New()

The position of the handle will be synced on creation, also calling onValue()


slider widgets expect that their icon will have an icon_state named track, and one named handle. Your handle should be at the top/right position of the track in the asset.

*/

hud/widget/slider
	parent_type = /hud/widget/control

	icon_state = "track"

	hold_mode = MOUSE_HOLDING_DRAG		//this widget keeps track of additional mouse drag data

	var/tmp
		hud/widget/slider/handle/handle = /hud/widget/slider/handle		//stores the handle type that will be created with this widget, and the handle instance after New()

		vector/handle_size = vector(32,32)	//the size of the handle widget
		vector/track_size = vector(96,32)	//the size of the track's draggable area

		vector/value = vector(0,0)			//the current value of the slider (can be set via boilerplate)
		vector/handle_position = null		//the current pixel position of the slider (cannot be set via boilerplate)

	//override New() to create the handle and update the handle position to the default values
	New(loc,hud/hud)
		..()
		vis_contents += (handle = new handle())
		Value(value)

	proc
		//call to change the value of the slider on the track using values (0 to 1)
		Value(vector/pct)
			//convert the 2 arg format to a vector
			if(length(args)==2)
				pct = vector(args[1],args[2])

			//calculate the limits of handle position
			var/vector/limit = handle_size - track_size

			var/static/vector/full = vector(1,1)
			var/static/vector/empty = vector(0,0)

			//update the current value
			value = clamp(pct,empty,full)
			var/vector/pos = limit * (full - value)

			//update the current handle position
			handle_position = (pos = vector(clamp(pos.x,limit.x,0),clamp(pos.y,limit.y,0)))

			//move the handle
			handle.transform = matrix(pos.x,pos.y,MATRIX_TRANSLATE)

			//call the onValue hook
			onValue(value)

		//call to change the pixel position of the slider on the track
		MoveHandle(vector/pos)
			//convert the 2 arg format to a vector
			if(length(args)==2)
				pos = vector(args[1],args[2])

			//calculate the limits of the handle position
			var/static/vector/empty = vector(0,0)

			var/vector/limit = handle_size - track_size
			handle_position = (pos = clamp(limit + pos,limit,empty))

			//update the current value
			value = vector((limit.x ? 1 - pos.x / limit.x : 0), (limit.y ? 1 - pos.y / limit.y : 0))

			//move the handle
			handle.transform = matrix(pos.x,pos.y,MATRIX_TRANSLATE)

			//call the onValue hook
			onValue(value)

	//HOOKS
		//called when the position of the handle has been changed
		onValue(vector/value)
			set waitfor = 0

	//OVERRIDES

	//called while dragging the handle
	MouseTick(mode,over_object,params)
		..()
		switch(mode)
			if(MOUSE_MODE_DRAGGING, MOUSE_MODE_DROP, MOUSE_MODE_RELEASE)
				//calculate the new handle position from the last cached screen loc for this tick action
				var/client/client = usr.client

				var/list/p = params2list(params)

				var/vector/value = client.ScreenVector(p["screen-loc"]) + client.__mouse_drag_handle - handle_size / 2 - (client.__mouse_drag_screen || vector(0,0))

				//move the handle to the new position
				MoveHandle(value)

	//the default handle subwidget for sliders
	handle
		parent_type = /hud/widget

		icon_state = "handle"

		vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID