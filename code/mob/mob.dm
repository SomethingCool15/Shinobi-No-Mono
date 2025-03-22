mob
    step_size = 8
    icon_state = ""
    var
        canMove = TRUE
        strength = 5
        endurance = 5
        agility = 5
        speed = 5
        control = 5
        stamina = 5
        moniker = ""
        chakra = 5
        ryo = 500
        jinchuuriki = FALSE
        clan = ""
        division = ""
        core_slots = 11
        total_pp = 0
        unspent_pp = 0
        stat_points = 9
        spent_sp = 0
        sp_cap
        datum/rank/rank
        sub_rank
        profession = ""
        grade = "E"
        age = 8
        passed_chunin = FALSE
        passed_tokubetsu_jonin = FALSE
        passed_jonin = FALSE
        jonin_mentored = FALSE
        passed_anbu = FALSE
        passed_hancho = FALSE
        datum/village/village
        datum/squad/squad
        of_squad = FALSE
        d_rank_missions_completed = 0
        c_rank_missions_completed = 0
        b_rank_missions_completed = 0
        a_rank_missions_completed = 0
        s_rank_missions_completed = 0
        mission_cooldown = 0
        list/sub_ranks = list()
        list/inventory = list()
        list/shinobi_kit = list()
        list/perk_list = list()
        list/jutsu_list = list()
        list/tasks = list()
        list/worn_items = list()

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
    
    proc/get_total_points_spent()
        return strength + endurance + agility + speed + control + stamina + chakra - 35

    proc/getOverallGrade()
        var/total_spent = get_total_points_spent()
        if(total_spent <= 15)
            return "E"
        else if(total_spent <= 30)
            return "E+"
        else if(total_spent <= 45)
            return "D-"
        else if(total_spent <= 60)
            return "D"
        else if(total_spent <= 75)
            return "D+"
        else if(total_spent <= 90)
            return "C-"
        else if(total_spent <= 105)
            return "C"
        else if(total_spent <= 120)
            return "C+"
        else if(total_spent <= 135)
            return "B-"
        else if(total_spent <= 150)
            return "B"
        else if(total_spent <= 165)
            return "B+"
        else if(total_spent <= 180)
            return "A-"
        else if(total_spent <= 195)
            return "A"
        else if(total_spent <= 210)
            return "A+"
        else if(total_spent <= 225)
            return "S-"
        else if(total_spent <= 240)
            return "S"
        else
            return "S+"

    proc/can_spend_points()
        if(village.name == "Missing")
            return get_total_points_spent() < sp_cap
        if(!rank) return FALSE
        return get_total_points_spent() < sp_cap

    proc/calc_elo()
        return src.c_rank_missions_completed * 10 + src.b_rank_missions_completed * 20 + src.a_rank_missions_completed * 30 + src.s_rank_missions_completed * 40

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
        stat("Elo", "[calc_elo()]")
        stat("----------------------------------------------")
        stat("Stat Points", "[stat_points]")
        stat("PP", "[unspent_pp]/[total_pp]")
        stat("SP", "[stat_points]/[sp_cap]")
        stat("total spent", "[get_total_points_spent()]")
        if(village.name == "Missing")
            stat("Rank", "[rank.criminal_grade]-Grade Criminal ([getOverallGrade()])")
        else if(rank.rank_name == "Hokage" || rank.rank_name == "Hokage Assistant" || rank.rank_name == "Mizukage" || rank.rank_name == "Mizukage Assistant")
            stat("Rank", "You are the [rank.rank_name] ([getOverallGrade()]) of [village.name]")
        else
            stat("Rank", "You are a [rank.rank_name] ([getOverallGrade()]) of [village.name]")
        var/list/sub_rank_names = list()
        for(var/datum/sub_rank/sub_rank in sub_ranks)
            sub_rank_names += sub_rank.rank_name
        if(sub_rank_names.len > 0)
            stat("Sub-Ranks", "[jointext(sub_rank_names, ", ")]")

        statpanel("Jutsu")
        stat("Jutsu", "[jutsu_list.len]")
        if(jutsu_list.len > 0)
            for(var/obj/jutsu/J in jutsu_list)
                stat(null, J)
            
        statpanel("Inventory")
        stat("Slots Used", "[inventory.len]/[inventory_max_slots]")
        if(inventory.len > 0)
            for(var/obj/item/I in inventory)
                stat(I)
        stat("----------------------------------------------")
        stat("Slots Used", "[shinobi_kit.len]/[shinobi_kit_max_slots]")
        if(shinobi_kit.len > 0)
            for(var/obj/item/I in shinobi_kit)
                stat(I)

        statpanel("Tasks")
        stat("Tasks", "[tasks.len]")
        if(tasks.len > 0)
            for(var/datum/task/mission_completions/T in tasks)
                stat(T.desc, "[c_rank_missions_completed]/[T.amount_needed]")
        
        statpanel("Squad")
        if(squad)
            stat("Squad: ", squad.name)
            
            // Find the leader in online members
            var/leader_found = FALSE
            for(var/mob/M in squad.members)
                if(M.name == squad.leader_name)
                    stat("Leader: ", M.name)
                    leader_found = TRUE
                    break
            
            // If leader not found in online members, they must be offline
            if(!leader_found)
                stat("Leader: ", "[squad.leader_name] (OFFLINE)")
            
            stat("Members", "[squad.GetTotalMemberCount()]/[squad.max_members]")
            
            // Display online members
            for(var/mob/M in squad.members)
                stat(M)
            
            // Display offline members
            for(var/player_name in squad.offline_members)
                stat("[player_name]", "OFFLINE")
            
            stat("Squad Type: ", squad.squad_composition)
        else
            stat("You are not currently in a squad.")
            
    verb
        output_squad_info()
            set name = "Output Squad Info"

            if(!squad)
                src << "You are not in a squad."
                return

            src << "Squad Name: [squad.name]"
            
            // Find the leader in online members
            var/leader_found = FALSE
            for(var/mob/M in squad.members)
                if(M.name == squad.leader_name)
                    src << "Leader: [M.name]"
                    leader_found = TRUE
                    break
            
            // If leader not found in online members, they must be offline
            if(!leader_found)
                src << "Leader: [squad.leader_name] (OFFLINE)"
            
            src << "Members: [squad.GetTotalMemberCount()]/[squad.max_members]"
            
            // Display online members
            for(var/mob/M in squad.members)
                src << "Member: [M.name]"
            
            // Display offline members
            for(var/player_name in squad.offline_members)
                src << "Member: [player_name] (OFFLINE)"
            
            src << "Squad Type: [squad.squad_composition]"
            if(squad.village)
                src << "Squad Village: [squad.village.name]"
            
        complete_c_rank()
            set name = "Complete C-Rank Mission"
            c_rank_missions_completed += 1
            for(var/datum/task/mission_completions/T in tasks)
                T.complete(usr)
            usr << "You have completed a C-Rank mission. You now have [c_rank_missions_completed] C-Rank missions completed."

        increaseStrength()
            if(stat_points < 1)
                usr << "Not enough passive points to increase strength."
                return
            if(!can_spend_points())
                usr << "You have reached your rank's stat point cap. You must rank up to invest more points."
                return
            strength += 1
            stat_points -= 1
            usr << "Strength increased by 1. New strength: [strength]."

        increaseEndurance()
            if(stat_points < 1)
                usr << "Not enough passive points to increase endurance."
                return
            if(!can_spend_points())
                usr << "You have reached your rank's stat point cap. You must rank up to invest more points."
                return
            endurance += 1
            stat_points -= 1
            usr << "Endurance increased by 1. New endurance: [endurance]."

        increaseAgility()
            if(stat_points < 1)
                usr << "Not enough passive points to increase agility."
                return
            if(!can_spend_points())
                usr << "You have reached your rank's stat point cap. You must rank up to invest more points."
                return
            agility += 1
            stat_points -= 1
            usr << "Agility increased by 1. New agility: [agility]."

        increaseSpeed()
            if(stat_points < 1)
                usr << "Not enough passive points to increase speed."
                return
            if(!can_spend_points())
                usr << "You have reached your rank's stat point cap. You must rank up to invest more points."
                return
            speed += 1
            stat_points -= 1
            usr << "Speed increased by 1. New speed: [speed]."

        increaseControl()
            if(stat_points < 1)
                usr << "Not enough passive points to increase control."
                return
            if(!can_spend_points())
                usr << "You have reached your rank's stat point cap. You must rank up to invest more points."
                return
            control += 1
            stat_points -= 1
            usr << "Control increased by 1. New control: [control]."

        increaseStamina()
            if(stat_points < 1)
                usr << "Not enough passive points to increase stamina."
                return
            if(!can_spend_points())
                usr << "You have reached your rank's stat point cap. You must rank up to invest more points."
                return
            stamina += 1
            stat_points -= 1
            usr << "Stamina increased by 1. New stamina: [stamina]."

        increaseChakra()
            if(stat_points < 1)
                usr << "Not enough passive points to increase chakra."
                return
            if(!can_spend_points())
                usr << "You have reached your rank's stat point cap. You must rank up to invest more points."
                return
            chakra += 1
            stat_points -= 1
            usr << "Chakra increased by 1. New chakra: [chakra]."
        
        say(message as text)
            world << "<span style='color: red;'>[usr.name]: [message]</span>"

    Move()
        if(canMove)
            ..() //Allow parent proc to execute

    proc/has_perk(perk_name)
        if(!perk_name) return 1  // If no perk required, return true
        return (perk_name in perk_list)  // Check if perk exists in their list

    proc/add_pp(amount)
        total_pp += amount
        unspent_pp += amount
    
    proc/mission_complete(rank)
        if(rank == "D")
            d_rank_missions_completed += 1
        else if(rank == "C")
            c_rank_missions_completed += 1
        else if(rank == "B")
            b_rank_missions_completed += 1
        else if(rank == "A")
            a_rank_missions_completed += 1
        else if(rank == "S")
            s_rank_missions_completed += 1