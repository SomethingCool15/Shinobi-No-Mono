/*
Option widgets handle checkbox and radio button behavior.

Options widgets respect all base control widget behaviors, plus:

	Toggled() //called when this element's toggle state is changed.

Options can be assigned a group, which allows multiple checkboxes or radio buttons to cooperate.
	the containing hud will store the cooperative value of all grouped options in hud.outputs[group].
	the active option for a radio group is stored in hud.outputs["[group]:active"]

Options can be set to toggled in their boilerplate, and they will start out toggled, syncing all their other output states correctly.

The assets for options use a 6-direction widget format.

NORTH: Unhovered Untoggled
NORTHWEST: Disabled Untoggled
NORTHEAST: Hovered Untoggled

SOUTH: Unhovered Toggled
SOUTHWEST: Disabled Toggled
SOUTHEAST: Hovered Toggled

*/

//option modes
var/const/OPTION_CHECKBOX = 0	//Checkbox options can have multiple controls active per group
var/const/OPTION_RADIO = 1		//Radio options can only have one active control per group

hud
	var/tmp
		//stores the status of any grouped option widgets
		alist/outputs = alist()

	proc
		//called by grouped options belonging to this hud
		ToggleOption(hud/widget/option/option)
			var/group = option.group
			switch(option.mode)
				//for checkboxes, if the checkbox is part of a group, update the group value
				if(OPTION_CHECKBOX)
					if(group)
						if(option.toggled)
							outputs[group] &= ~option.value
						else
							outputs[group] |= option.value

					return 1

				//for radios, allow the change and mark the active radio element
				if(OPTION_RADIO)
					if(group)
						var/id = "[group]:active", hud/widget/option/old
						//if the old active element refuses to allow the new one to take over, refuse the toggle
						if((old = outputs[id]) && (old = locate(old)) && (old==option || !old.GroupToggled(option)))
							return 0

						//mark the current option as active and update the group value
						outputs[id] = "\ref[option]"
						outputs[group] = option.value

					return 1

			return 1

		//called by grouped options belonging to this hud when they are first created while toggled
		InitOption(hud/widget/option/option)
			var/group = option.group
			switch(option.mode)
				//for checkboxes, turn on the option's value in the group list
				if(OPTION_CHECKBOX)
					outputs[group] |= option.value

				//for radios, mark the active element, and untoggle the previously active element
				if(OPTION_RADIO)
					//check for an old option
					var/id = "[group]:active", hud/widget/option/old, hovered
					if((old = outputs[id]) && (old = locate(old)))
						//if the old option cannot be untoggled
						if(!old.GroupToggled(option))
							//untoggle this option instead
							option.state = NORTH
							option.dir = option.state + (option.enabled && WEST)
							option.toggled = 0
							return

					//mark this option as active and update the group
					outputs[id] = "\ref[option]"
					outputs[group] = option.value

					//display this option as toggled
					hovered = option.state & EAST
					option.state = SOUTH
					option.dir = SOUTH + (option.enabled ? hovered : WEST)
					option.toggled = 1

hud/widget/option
	parent_type = /hud/widget/control

	var/tmp
		mode = OPTION_CHECKBOX	//the mode of this option control; OPTION_CHECKBOX or OPTION_RADIO

		group		//the name of the output group this control belongs to.

		value = 1	//the value of this option when toggled.
					//for checkboxes, use bit flags within a group for each checkbox
					//for radio buttons, any value is fine. Numbers, text, etc.

	//OVERRIDES
	//make sure all the component variables are up to date and the hud group tracker is up to date.
	New(loc,hud/root)
		dir = (state = (toggled ? SOUTH : NORTH)) | (!enabled && WEST)
		if(group && toggled)
			root.InitOption(src)
		..()

	//allow this component to be toggled; check if the owning hud permits the action
	canToggle()
		return !(hud()?:ToggleOption(src)==0)

	proc
		//called when another option in this group becomes active (for radio options)
		GroupToggled(hud/widget/option/toggling)
			if(toggled)
				toggled = 0
				state = (state & 4) | NORTH
				dir = (enabled ? state : SOUTHWEST)
				Toggled()
			return 1