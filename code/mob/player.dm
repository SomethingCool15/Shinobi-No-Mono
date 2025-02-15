player
	parent_type = /mob
	icon = 'icons/base/Base_Pale.dmi'

	Login()
		..()	
		playerList += src
		admin_check(src.key)

	Logout()
		playerList -= src
		..()