#ifndef HUDLIB_INFO
	#ifndef HUD_LAYER
		#warn HUD_LAYER is undefined. Defaulting to TOPDOWN_LAYER. #define HUD_LAYER to suppress this warning
		#define HUD_LAYER TOPDOWN_LAYER
	#endif

	#ifndef HUD_PLANE
		#warn HUD_PLANE is undefined. Defaulting to plane 1. #define HUD_PLANE to suppress this warning
		#define HUD_PLANE 1
	#endif
#endif

//hud_obj is the root type for hudlib.
/*
	All hud objects inherit their default properties and behaviors from hud_obj.

	Huds are top-level components meant to be added to the client's screen. They contain components and widgets as children.
	Components are meant to be defined under /huds as one-off children of huds.
	Widgets are meant to be defined under /hud/widget so that they can be referenced by children of huds.

	Templates will be created for each /hud. See hud_template.dm for more information
*/

hud_obj
    parent_type = /atom/movable
    layer = HUD_LAYER
    plane = HUD_PLANE
    appearance_flags = TILE_BOUND

hud/component
    parent_type = /hud_obj
    vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE

hud/widget
    parent_type = /hud/component

hud
    parent_type = /hud_obj