/*
Grid widgets create a fixed-size grid of controls that can be updated with cell information.
The grid maintains a list of values, which can be anything, which can be passed to cells.

You can set the rows, cols, row_size, and col_size in your boilerplate when defining a grid. These determine the layout of the grid.

You can pass a list of values to a grid by calling Update() with that list. The argument is optional.
	If the argument is not provided, the current stored values list will be used.

You can change the page of the values that the grid is presenting prior to a call to Update().
	If a grid has more values than cells, changing the page will allow you to step through the values content one page at a time.

Cells will automatically be created or destroyed on Update() if you change the rows/cols.

You should override UpdateCell() to handle laying out cells. Cells do not need to be visually laid out in any particular order. It is arbitrary.

You can provide any child of component to the grid by changing cell_component to a different type_path in your boilerplate.
	Cells can be whatever you want. You can supply a grid widget as a cell type, and pass a list of lists as values if you want. It's all arbitrary.

The default cell subwidget calls hooks on the grid itself that you may override and respond to.
	Hovered(cell,location,control,params)
	Unhovered(cell,location,control,params)
	Pressed(cell,value,location,control,params)
	Released(cell,value,location,control,params)
	Dropped(cell,value,drop_object,drag_location,drop_location,drag_control,drop_control,params)

Grids can be expensive; Having grids that are very large will result in performance degradation.
Try to avoid updating grids many times per tick. This is expensive.
*/

//grids store additional data on cell components
hud/component
	var/tmp
		cell_index
		cell_pos

		cell_x
		cell_y

		cell_value


hud/widget/grid
	var
		rows = 1		//how many rows this grid has
		cols = 1		//how many cells this grid has

		row_size = 32	//how many pixels are between each row of cells
		col_size = 32	//how many pixels are between each column of cells

		cell_component = /hud/widget/grid/cell	//the component type for each cell that will be created to fill the grid

		list/cells		//stores all the cells in a grid in sequential order
		list/values		//stores the current set of values that get fed to cells

		page = 1		//stores what page to start the cell data at when updating the grid
		pages = 1		//stores how many pages of cell data are in the values list

	proc
		//convenience function for changing the size of a grid on the fly; Won't change the number of cells until the next Update() call
		Resize(cols=src.cols,rows=src.rows)
			src.rows = rows
			src.cols = cols

		//causes the cells to be repopulated with data. It will create any cells that it needs to fit the new size, and destroy any unneeded cells.
		Update(list/values = src.values)
			//update the cell data list
			src.values = values

			//resize the cells list if needed
			var/len = rows * cols
			if(!cells)
				cells = list()
			else
				//temporarily remove the cells from vis_contents
				vis_contents -= cells

			cells.len = len

			var/hud/component/item, pos = 0, count = length(values), value

			//clamp the current page offset
			pages = len ? ceil(count / len) : 1
			page = clamp(page,1,pages)

			//calculate the current index of the values list to write from
			var/index = (page - 1) * len

			//loop over the grid, creating new cells where needed, and populating them with grid data
			for(var/y in 1 to rows)
				for(var/x in 1 to cols)
					//grab the old cell at this pos (page index), or create a new cell if needed
					item = (cells[++pos] ||= new cell_component())

					//grab the value from this value index (page independent), or null if we're past the end of the values list
					if(count >= ++index)
						value = values[index]
					else
						value = null

					//update the cell
					UpdateCell(item,x,y,pos,index,value)

			//if the cells list isn't empty, add it back to the vis_contents list
			if(len)
				vis_contents += cells

		//called for each cell in an Update() sequence.
		//	item: the cell being updated (cells[pos])
		//  x: the column position (1-based) of the cell
		//  y: the row position (1-based) of the cell
		//  pos: The index of the cell in-page (1-based)
		//  index: The index of the cell page-independent (1-based)
		//  value: The value of values[index]
		UpdateCell(hud/component/item,x,y,pos,index,value)
			//by default, update the grid variables of the cell component
			item.cell_x = x
			item.cell_y = y
			item.cell_pos = pos
			item.cell_index = index
			item.cell_value = value

	//HOOKS:
		//called when a cell is hovered
		Hovered(hud/component/item,atom/location,control,params)
			set waitfor = 0

		//called when a cell is unhovered
		Unhovered(hud/component/item,atom/location,control,params)
			set waitfor = 0

		//called when a cell is pressed
		Pressed(hud/component/item,value,atom/location,control,params)
			set waitfor = 0

		//called when a cell is released while hovering over itself
		Released(hud/component/item,value,atom/location,control,params)
			set waitfor = 0

		//called when a cell is dropped over something else
		Dropped(hud/component/item,value,atom/drop_object,atom/drag_location,atom/drop_location,drag_control,drop_control,params)
			set waitfor = 0


//grid cells can be any kind of component. They don't need to be grid cell subwidgets. You could have a grid of grids, or a grid of sliders. It doesn't matter.
hud/widget/grid/cell
	parent_type = /hud/widget

	dir = NORTH

	var
		state = NORTH		//cells behave very similarly to controls, tracking mouse activity.

	MouseEntered(atom/location,control,params)
		//look up the containing grid
		var/hud/widget/grid = length(vis_locs) ? vis_locs[1] : null

		//maintain the visual/logical state
		state = EAST
		dir = EAST

		//notify the grid that this cell has been hovered
		grid?:Hovered(src,location,control,params)

		//update the client's mouse tracking variables
		var/client/client = usr.client
		client.__mouse_mode = MOUSE_MODE_NONE
		client.__mouse_over = src
		client.__mouse_params = params

	MouseExited(atom/location,control,params)
		//look up the containing grid
		var/hud/widget/grid = length(vis_locs) ? vis_locs[1] : null

		//maintain the visual/logical state
		state = NORTH
		dir = NORTH

		//notify the grid that this cell has been unhovered
		grid?:Unhovered(src,location,control,params)

		//update the client's mouse tracking variables
		var/client/client = usr.client
		client.__mouse_mode = MOUSE_MODE_NONE
		client.__mouse_over = src
		client.__mouse_params = params

	MouseDown(atom/location,control,params)
		var/list/p = params2list(params)
		//ignore any mouse actions that are part of a drag sequence
		if(!p["drag"])
			var/client/client = usr.client

			//look up the containing grid
			var/hud/widget/grid = length(vis_locs) ? vis_locs[1] : null

			//if the event is primary
			if(p["button"]==client.mouse_primary)
				//update the client's mouse tracking variables
				client.__mouse_mode = MOUSE_MODE_PRESS
				client.__mouse_src = cell_value
				client.__mouse_params = params

				//maintain visual/logical state
				state = SOUTH
				dir = SOUTH

				//notify the grid that this cell has been unhovered and pressed
				grid?:Unhovered(src,location,control,params)
				grid?:Pressed(src,client.__mouse_src,location,control,params)
			else
				//maintain visual/logical state
				state = NORTH
				dir = NORTH

				//notify the grid that this cell has been unhovered
				grid?:Unhovered(src,location,control,params)

	MouseUp(atom/location,control,params)
		var/client/client = usr.client
		var/list/p = params2list(params)
		//ignore any mouse actions that are part of a drag sequence
		if(!p["drag"])
			//look up the containing grid
			var/hud/widget/grid = length(vis_locs) ? vis_locs[1] : null

			//update the client's mouse tracking variables
			state = EAST
			dir = EAST
			//if the event is primary
			if(p["button"]==client.mouse_primary)
				//notify the grid that this cell has been released
				grid?:Released(src,client.__mouse_src,location,control,params)

			//notify the grid that this cell has been hovered
			grid?:Hovered(src,location,control,params)

			//maintain the client's mouse tracking variables
			client.__mouse_params = params
			client.__mouse_mode = MOUSE_MODE_NONE
			client.__mouse_src = null

	MouseDrag(atom/over_object,atom/src_location,atom/over_location,src_control,over_control,params)
		var/client/client = usr.client
		//convert this action to a drag if it's still a press
		if(client.__mouse_mode==MOUSE_MODE_PRESS && over_object!=src)
			client.__mouse_mode = MOUSE_MODE_DRAG

		//maintain the client's mouse tracking variables
		client.__mouse_over = over_object
		client.__mouse_params = params

	MouseDrop(atom/over_object,atom/src_location,atom/over_location,src_control,over_control,params)
		var/list/p = params2list(params)
		var/client/client = usr.client

		//in a primary action
		if(p["button"]==client.mouse_primary)
			//look up the owning grid
			var/hud/widget/grid = length(vis_locs) ? vis_locs[1] : null

			if(over_object==src)
				//update the visual/logical state for the release branch
				state = EAST
				dir = EAST

				//notify of release and hovering
				grid?:Released(src,over_location,over_control,params)
				grid?:Hovered(src,over_location,over_control,params)

				client.__mouse_over = src
			else
				//update the visual/logical state for the drop branch
				state = NORTH
				dir = NORTH

				//notify the grid that this cell has been dropped
				grid?:Dropped(src,client.__mouse_src,over_object,src_location,over_location,src_control,over_control,params)

			client.__mouse_over = null

		//update the client's mouse tracking variables
		client.__mouse_mode = MOUSE_MODE_NONE
		client.__mouse_src = null
		client.__mouse_params = params