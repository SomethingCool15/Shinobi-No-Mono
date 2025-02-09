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
        statPoints = 9
        stamina_bar = null
        health_bar = null
        chakra_bar = null
        chakra = 1
        clan = ""
        division = ""
        core_slots= 11
        totalPP = 0
        unspentPP = 0
        rank = "Academy Student"
        profession = ""
        grade = "E"
        village = ""
        age = ""
        list/squad = list()
        list/inventory = list()
        list/shinobi_kit = list()
        list/perk_list = list()
        list/jutsu_list = list()

    New()
        ..()
        perk_list += "Test Requirement"

    proc/getStatGrade(statValue)
        if(statValue <= 5)
            return "E"
        else if(statValue <= 10)
            return "E+"
        else if(statValue <= 15)
            return "D-"
        else if(statValue <= 20)
            return "D"
        else if(statValue <= 25)
            return "D+"
        else if(statValue <= 30)
            return "C-"
        else if(statValue <= 35)
            return "C"
        else if(statValue <= 40)
            return "C+"
        else if(statValue <= 45)
            return "B-"
        else if(statValue <= 50)
            return "B"
        else if(statValue <= 55)
            return "B+"
    
    proc/getChakraGrade(chakraValue)
        if(chakraValue <= 5)
            return "E"
    
    Stat()
        ..()
        statpanel("Stats")
        stat("Strength", "[strength] ([getStatGrade(strength)])")
        stat("Endurance", "[endurance] ([getStatGrade(endurance)])")
        stat("Agility", "[agility] ([getStatGrade(agility)])")
        stat("Speed", "[speed] ([getStatGrade(speed)])")
        stat("Control", "[control] ([getStatGrade(control)])")
        stat("Stamina", "[stamina] ([getStatGrade(stamina)])")
        stat("Chakra", "[chakra] ([getStatGrade(chakra)])")
        stat("----------------------------------------------")
        stat("Stat Points", "[statPoints]")
        stat("PP", "[unspentPP]/[totalPP]")
        stat("Rank", "[rank]")
        statpanel("Jutsu")
        for(var/obj/jutsu/j in jutsu_list)
            stat("", j)

    verb
        increaseStrength()
            if(unspentPP < 1)
                usr << "Not enough passive points to increase strength."
                return
            strength += 1
            unspentPP -= 1
            usr << "Strength increased by 1. New strength: [strength]."

        increaseEndurance()
            if(unspentPP < 1)
                usr << "Not enough passive points to increase endurance."
                return
            endurance += 1
            unspentPP -= 1
            usr << "Endurance increased by 1. New endurance: [endurance]."

        increaseAgility()
            if(unspentPP < 1)
                usr << "Not enough passive points to increase agility."
                return
            agility += 1
            unspentPP -= 1
            usr << "Agility increased by 1. New agility: [agility]."

        increaseSpeed()
            if(unspentPP < 1)
                usr << "Not enough passive points to increase speed."
                return
            speed += 1
            unspentPP -= 1
            usr << "Speed increased by 1. New speed: [speed]."

        increaseControl()
            if(unspentPP < 1)
                usr << "Not enough passive points to increase control."
                return
            control += 1
            unspentPP -= 1
            usr << "Control increased by 1. New control: [control]."

        increaseStamina()
            if(unspentPP < 1)
                usr << "Not enough passive points to increase stamina."
                return
            stamina += 1
            unspentPP -= 1
            usr << "Stamina increased by 1. New stamina: [stamina]."

        increaseChakra()
            if(unspentPP < 1)
                usr << "Not enough passive points to increase chakra."
                return
            chakra += 1
            unspentPP -= 1
            usr << "Chakra increased by 1. New chakra: [chakra]."

    Move()
        if(canMove)
            ..() //Allow parent proc to execute

    proc/has_perk(perk_name)
        if(!perk_name) return 1  // If no perk required, return true
        return (perk_name in perk_list)  // Check if perk exists in their list
