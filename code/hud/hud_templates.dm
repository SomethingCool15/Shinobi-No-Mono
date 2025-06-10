/*
	hud templates loop over every /hud/component instance (including /hud/widgets!) that you have defined in your project at startup.
	A template data structure is stored in memory, attempting to base every component inside of its containing /hud root.
	If a root hud is found, it will join that /hud's template.

	When a hud template is initialized, the components will all be created in one big pile, and then one by one inserted into their vis_parent.

	This will create a nested container/component structure that will allow complex multi-object huds to function just like you designed them.

	This slims down the code you need to write to create these huds by quite a bit.

	See hud_registry.dm for the tools to navigate the hud hierarchy.
*/

//when the world starts up, build the templates for every hud
hud/component
	var/tmp
		vis_parent

//when a hud is created, call its Initialize() function. This will harness a template
hud
	New()
		Initialize()
		..()

	proc
		Initialize()
			src += hud_template(type,src)

var
	list/hud_templates = init_hud_templates()

proc
	//constructs a list of hud templates for each /hud descendant
	init_hud_templates()
		var/list/templates = list()

		//this regex helps us break apart the path of an object and step backward through it
		var/regex/regex = new/regex(@"^((?:\/[^\/\n]+)+)\/[^\/\n]+$")

		//loop over everything that polymorphically derives from /hud/component, except for the system types (/hud/component, /hud/widget)
		for(var/v in typesof(/hud/component) - list(/hud/component,/hud/widget))

			//if the type has a compile-time vis_id, that means it's part of a boilerplate template
			if(initial(v:vis_id))

				//step backward through the path until we find the /hud that contains this component descendant
				var/parent_path = v
				while(regex.Find("[parent_path]",1))
					parent_path = regex.group[1]
					if(parent_path)
						parent_path = text2path(parent_path)
						if(ispath(parent_path,/hud))
							break

				//if we found a parent /hud, store this child in the template for that /hud
				if(parent_path)
					(templates[parent_path] ||= list())[v] = initial(v:vis_parent)

		return templates

	//this function constructs all of the child components of a /hud and organizes them structurally
	hud_template(type, hud/owner)
		var/list/template = hud_templates[type], list/root = list(), list/parenting = list(), list/registry = alist()
		var/hud/component/component, hud/component/parent, vis_path

		//loop over all the children in the template to create new instances of each of them
		for(var/child_type, parent_id in template)
			component = new child_type(null,owner)

			//set up the structural link table
			vis_path = parent_id ? "[parent_id].[component.vis_id]" : "[component.vis_id]"
			if(parent_id)
				(parenting[parent_id]||=list()) += component
			else
				root += component

			//store each component within a single registry
			registry[vis_path] = component

		//loop over all the children that have children
		for(var/path,items in parenting)
			//use the registry to look up the child that will have children
			parent = registry[path]
			//if the parent element exists, add all the children we just created that belong to that parent to the parent
			if(parent)
				parent += items

		return root