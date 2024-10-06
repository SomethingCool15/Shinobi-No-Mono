mob
	step_size = 8
	var
		canMove = TRUE
		strength = 1
		endurance = 1
		agility = 1
		speed = 1
		control = 1
		stamina = 1
		stamina_bar = null
		health_bar = null
		chakra_bar = null
		chakra = 1
		clan = ""
		rank = ""
		division = ""
		totalPP = 0
		unspentPP = 0
		profession = ""
		grade = "E"
		village = ""
		age = ""
		list/squad = list()
		list/inventory = list()
		list/shinobi_kit = list()
		list/perks = list()
		list/jutsu = list()
		
	Move()
		if(canMove)
			..() //Allow parent proc to execute