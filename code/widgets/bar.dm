/*
Bar widgets represent a fill state.

The fill level of a bar is stored in bar.value
Value() can be called to change the fill state of the bar.

bar.range determines the divisor of the bar; It is 1 by default, so 0 is 0%, and 1 is 100%.
Changing bar.range allows you to pass different numbers meaningfully to Value(). Setting it to 100 would make the range of values 0 to 100 instead.

bar.fill can be set to a type to change the look and behavior of the fill component.

A bar's icon should have a blank state for the bar's background, and a state named "fill" for the fill.

The bar should use an alpha gradient in the assets so that the fill shader can make the bar disappear and appear gradually.
	bars are not limited to a linear bar or any specific direction.
	The shape of your asset and gradient determines the shape of the bar.

*/

//color matrix used to display a full bar
var/list/HUD_BAR_FULL_MATRIX = list(1,0,0,0,
									0,1,0,0,
									0,0,1,0,
									0,0,0,255,
									0,0,0,0)

//color matrix used to display an empty bar
var/list/HUD_BAR_EMPTY_MATRIX = list(1,0,0,0,
									 0,1,0,0,
									 0,0,1,0,
									 0,0,0,255,
									 0,0,0,-254)

//return a color matrix at a specific percentage within range of 0 (empty) to 1 (full)
proc/bar_fill_matrix(v)
	var/static/HUD_BAR_FILL_MATRIX = list(1,0,0,0,
										  0,1,0,0,
										  0,0,1,0,
										  0,0,0,255,
										  0,0,0,0)

	HUD_BAR_FILL_MATRIX[20] = -ceil( clamp(1 - v,0,1) * 254)

	return HUD_BAR_FILL_MATRIX


hud/widget/bar
	parent_type = /hud/widget/control

	icon_state = ""

	var/tmp
		hud/component/fill = /hud/widget/bar/fill	//this will store the type of fill component to be created on New()

		value = 1		//the current value being shown by the bar
		range = 1		//the maximum range of the value shown by the bar

	proc
	//MUTATORS
		//change the value of the bar and update the visual state
		Value(value=src.value,time=0)
			src.value = value
			var/mtx = bar_fill_matrix(range ? (value / range) : 0)
			animate(fill,color=mtx,time=0)

	//OVERRIDES
	//create the fill subwidget and add it to the bar; update the current value
	New(loc,hud/root)
		fill = new fill()
		vis_contents += fill

		if(value!=range)
			Value(value,0)

		..()

	//the fill subwidget is created as part of the bar widget. These can be extended and modified
	fill
		parent_type = /hud/widget

		icon_state = "fill"

		vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID

		New()
			color = HUD_BAR_FULL_MATRIX
			..()