/*
	hud navigation:

	all hud_objs have a vis_registry. You can navigate the vis_registry of a hud object by using the [] operator on that hud element.

	call parent() to step one level up from a component in its vis_hierarchy. This will be the hud component that contains this component, or null if we are already at top level.
	call root() to step to the top level hud component that contains this one, or null if we're already at the top level.

	string navigation:
		Each node in the navigation string is the vis_id of a child, "parent", or "root".
		Each node is separated by a "."

		component["child"] will navigate to a child component.
		component["child.grandchild"] will navigate to a child of a child
		component["parent"] will navigate to the parent component
		component["parent.parent"] will navigate to the parent-of-parent.
		component["parent.child"] will navigate to a sibling component
		component["root"] will navigate to the root component
		component["hud"] will navigate to the first /hud container from the current node

	setting components:
		navigation strings can be used to replace components or add components:

		component["newchild"] = new/hud/whatever/new_child()

		The new component will be given the vis_id of "newchild".

	adding/subtracting components:
		components can be added or removed from their direct parent with the += and -= operator.
*/

hud_obj
	var/tmp
		vis_id
		alist/vis_registry

	proc
		//get the parent element if it's a hud_obj
		parent() as /hud_obj
			return length(vis_locs) ? astype(vis_locs[1],/hud_obj) : null

		//get the root element if it's a hud_obj
		root() as /hud_obj
			var/hud_obj/seek = src, hud_obj/parent, list/locs

			while(seek)
				parent = seek
				seek = length((locs = seek.vis_locs)) ? locs[1] : null

			if(parent==src || !istype(parent))
				return null

			return parent

		//get the first /hud in the parent hierarchy
		hud() as /hud
			var/hud_obj/seek = src, hud_obj/parent, list/locs

			while(seek)
				parent = seek
				seek = length((locs = seek.vis_locs)) ? locs[1] : null
				if(istype(seek,/hud))
					return seek

			if(parent==src || !istype(parent))
				return null

			return parent

		//allow indexing of components by vis_id
		// parent and root are valid navigators
		// sub-children can be navigated with "." eg child.grandchild or parent.sibling

		operator[](idx)
			if(!vis_registry) return null

			var/hud_obj/seek = src, alist/registry
			for(var/id in splittext(idx,"."))
				registry = seek.vis_registry

				switch(id)
					if("parent")
						seek = seek.parent()
					if("root")
						seek = seek.root()
					if("hud")
						seek = seek.hud()
					else
						seek = registry?[id]

				if(!seek)
					return null

			return seek

		//allow assigning of components by vis_id
		// parent and root are valid navigators
		// sub-children can be navigated with "." eg child.grandchild or parent.sibling

		operator[]=(idx,hud/component/child)
			if(!isnull(child) && !istype(child))
				throw EXCEPTION("Invalid type for list")

			var/hud_obj/seek = src, alist/registry, list/splits = splittext(idx,"."), len = length(splits)-1
			for(var/split in 1 to len)
				var/id = splits[split]

				switch(id)
					if("parent")
						seek = seek.parent()
					if("root")
						seek = seek.root()
					if("hud")
						seek = seek.hud()
					else
						registry = seek.vis_registry
						seek = registry?[id]

				if(!seek)
					throw EXCEPTION("Unknown hud object: [idx]")

			child.vis_id = splits[len+1]
			seek += child

		//allow adding components and widgets
		// lists of components and widgets are also allowed

		operator+=(hud/component/child)
			var/list/adding = islist(child) ? child : list(child), alist/registry = (vis_registry ||= alist())

			for(child in adding)
				if(!istype(child))
					throw EXCEPTION("Invalid type for list")

				var/id = child.vis_id
				if(id)
					var/hud/component/old_component = registry[id]

					if(old_component && old_component != child)
						src -= id

					vis_registry[id] = child

				vis_contents += child

		//allow removing components and widgets
		// lists of components and widgets are also allowed

		operator-=(hud/component/child)
			var/list/removing = islist(child) ? child : list(child), list/registry = vis_registry

			for(child in removing)
				if(!istype(child))
					continue

				var/id = child.vis_id
				if(id)
					var/hud/component/old_component = vis_registry?[id]

					if(old_component==child)
						registry -= id

				vis_contents -= child

	Del()
		if(length(vis_locs))
			var/hud_obj/parent = parent()
			if(parent)
				parent -= src
			vis_locs.len = 0
		..()