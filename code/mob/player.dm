player
	parent_type = /mob
	icon = 'icons/base/Base_Pale.dmi'

	Login()
		..()
		playerList += src
		if(src.ckey in admin5)
			src.verbs += typesof(/admin5/verb)

	Logout()
		playerList -= src
		..()