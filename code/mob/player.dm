player
	parent_type = /mob
	icon = 'icons/base/Base_Pale.dmi'

	Login()
		..()	
		playerList += src
		var/datum/rank/R = new /datum/rank/mizukage()
		R.apply_rank(src)
		var/datum/village/V = GLOBAL_VILLAGE_MANAGER.villages[2]
		V.add_player(src)
		admin_check(src.ckey)
		
		// Add test players if this is the first login
		if(playerList.len == 1)
			spawn_test_players()

	Logout()
		playerList -= src
		..()

	proc/spawn_test_players()
		var/list/test_players = list(
			"TestCivilian" = /datum/rank/civilian,
			"TestAcademyStudent" = /datum/rank/academy_student,
			"TestGenin" = /datum/rank/genin,
			"TestChunin" = /datum/rank/chunin,
			"TestJonin" = /datum/rank/jonin,
			"TestAnbu" = /datum/rank/jonin,
			"TestSecretary" = /datum/rank/jonin
		)
		
		var/x = 1
		for(var/name in test_players)
			var/player/P = new()
			P.name = name
			var/rank_type = test_players[name]
			P.rank = new rank_type
			var/datum/village/V = GLOBAL_VILLAGE_MANAGER.villages[2]
			V.add_player(P)
			x += 1
			P.loc = locate(x,1,1)
			
			if(name == "TestAnbu")
				var/datum/sub_rank/hunter_nin/HN = new()
				HN.apply_rank(P)
			else if(name == "TestSecretary")
				var/datum/sub_rank/mizukage_secretary/S = new()
				S.apply_rank(P)
			
			P.strength = 10
			P.endurance = 10
			P.agility = 10
			P.speed = 10
			P.control = 10
			P.stamina = 10
			P.chakra = 10
			P.age = 19
			P.b_rank_missions_completed = 4
			P.passed_anbu = TRUE
			
			playerList += P