//hud scenes are packages of /hud objects that can be added all at once to your ui.
//scenes are identified by a string name, and can be added, removed, shown, or hidden all at once.
var/alist/hud_scenes = init_hud_scenes()

proc/init_hud_scenes()
	var/alist/categories = alist()

	for(var/item in typesof(/hud))
		var/category = initial(item:scene), id = initial(item:vis_id)
		if(id && category)
			(categories[category] ||= list()) += item

	return categories

hud/var/tmp
	scene

ui
	proc
		//add all of the huds belonging to a scene to the ui, but don't show them.
		//using the rename arg allows you to add the scenes under a different name.
		AddScene(name,rename=name)
			var/list/adding = list()
			for(var/creating in global.hud_scenes[name])
				var/elem = new creating
				elem:scene = rename
				adding += elem
			src += adding
			return adding

		//remove all huds belonging to a scene to the ui, hiding them if they are showing
		RemoveScene(name)
			var/list/removing = list()
			for(var/id, elem in hud)
				if(elem:scene==name)
					removing += elem
					if(active_huds[elem])
						Hide(elem)
			src -= removing
			return removing

		//show all huds belonging to a scene. If none are found, add and show them.
		//the exclusive argument will cause all non-null scene huds not matching the passed scene name to be hidden.
		ShowScene(name,exclusive=0)
			var/list/showing = list()
			for(var/id, elem in hud)
				if(elem:scene==name)
					showing += elem
					Show(elem)
				else if(exclusive && elem:scene)
					Hide(elem)

			if(!length(showing))
				for(var/elem in (showing = AddScene(name)))
					Show(elem)

			return showing

		//hide all huds belonging to a scene
		HideScene(name)
			var/list/hiding = list()
			for(var/id, elem in hud)
				if(elem:scene==name)
					Hide(elem)
					hiding += elem
			return hiding

		//this removes every scene but the named one. If it creates a new scene that is not already present, it can also rename the scene on creation.
		SetScene(name,rename=name)
			var/list/removing = list(), list/showing = list()
			for(var/id, elem in hud)
				if(elem:scene==name)
					showing += elem
					Show(elem)
				else if(elem:scene)
					removing += elem

			if(!length(showing))
				for(var/elem in AddScene(name,rename))
					Show(elem)
			if(length(removing))
				src -= removing