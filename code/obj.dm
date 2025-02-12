obj
	var
		weight = 0

	weapons
		var
			href = ""
			equipped = FALSE

		proc/equip(mob/user, obj/weapons/weapon)
			if(!equipped)
				equipped = TRUE
				user.overlays += weapon

		proc/unequip(mob/user, obj/weapons/weapon)
			if(equipped)
				equipped = FALSE
				user.overlays -= weapon

		Click(obj/weapons/weapon)
			if(equipped)
				unequip(usr, weapon)
			else
				equip(usr, weapon)

		DblClick(obj/weapons/weapon)
			usr << "Double clicked <a href='[weapon.href]'>[weapon.name]</a>"

		//Perk Tree Objects
	InterfaceIcons
		alpha = 0
		icon = 'icons/perktree/InterfaceIcons.dmi'

		BlankNode
			icon_state = "BlankNode"
			screen_loc = "TreeBackground"
			layer = OBJ_LAYER+2
			transform = matrix(0.8,0,0,0,0.8,0)

		BlankLine
			icon_state = "BlankLine"
			screen_loc = "TreeBackground"
			layer = OBJ_LAYER+2
			transform = matrix(0.8,0,0,0,0.8,0)

	TreeBackgrounds
		icon = 'icons/perktree/TreeBackgrounds.dmi'
		var/PerkAmount

		KatonTreeBG
			icon_state = "KatonTreeBG"
			screen_loc = "TreeBackground:CENTER"
			layer = OBJ_LAYER+1
			transform = matrix (1,0,0,0,1,0)
			vis_contents = list(new/obj/InterfaceIcons/BlankLine, new/obj/InterfaceIcons/BlankNode)
			PerkAmount = 14

		SuitonTreeBG
			icon_state = "SuitonTreeBG"
			screen_loc = "TreeBackground:CENTER"
			layer = OBJ_LAYER+1
			transform = matrix (1,0,0,0,1,0)
			vis_contents = list(new/obj/InterfaceIcons/BlankLine, new/obj/InterfaceIcons/BlankNode)
			PerkAmount = 14

		AburameTreeBG
			icon_state = "AburameTreeBG"
			screen_loc = "TreeBackground:CENTER"
			layer = OBJ_LAYER+1
			transform = matrix (1,0,0,0,1,0)
			vis_contents = list(new/obj/InterfaceIcons/BlankLine, new/obj/InterfaceIcons/BlankNode)
			PerkAmount = 14