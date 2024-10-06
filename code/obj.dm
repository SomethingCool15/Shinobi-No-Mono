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
