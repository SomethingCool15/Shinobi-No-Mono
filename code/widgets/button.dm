/*
Button widgets respond to the following behaviors:

	Hovered()   --when the button has begun being hovered
	Unhovered() --when the button has stopped being hovered
	Pressed()   --when the button has been pressed
	Released()  --when the button has been released while the mouse is still over the button
	Dropped()   --when the button has been release while the mouse is no longer over the button

if hover_lag and hover_delay are set:
	Hover()	  --periodically while being hovered

if hold_lag and hold_delay are set:
	Hold()	  --periodically while being held (HOLD_MODE_FREE calls Hold even while the button is dragged elsewhere; HOLD_MODE_OVER calls hold only while the button is held over itself)

if transitions is set:
	onTransition()


Button widgets can use 4-directional icon_states:
	EAST: Hovered
	SOUTH: Active
	NORTH: Inactive
	WEST: Disabled

*/

hud/widget/button
	parent_type = /hud/widget/control

	New()
		..()
	
	Hovered()
		..()
		world << "Hovered"
		filters = filter(type="outline", size=1,color="white",flags=OUTLINE_SHARP)
	
	Unhovered()	
		..()
		world << "Unhovered"
		filters = null

	Pressed()
		..()
		world << "Pressed"
	
	Released()
		..()
		world << "Released"

hud/widget/kunai_button
	parent_type = /hud/widget/button
	icon = 'icons/graphics/kunaibutton.dmi'

	Pressed()
		..()
		world << "Pressed kunai"

hud/widget/sharingan_button
	parent_type = /hud/widget/button
	icon = 'icons/graphics/sharinganbutton.dmi'
