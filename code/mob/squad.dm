/datum/squad
    var
        mob/leader
        list/members = list()
        name
        squad_composition
        mission/mission
        max_members = 3
        datum/village/village  // Add village reference

    proc/disbandSquad()
        for(var/mob/M in members)
            M.squad = null
            M << "The squad has been disbanded."
            members = list()
            leader = null
            squad_composition = null
            
            // Remove from global squad manager
            if(GLOBAL_SQUAD_MANAGER)
                GLOBAL_SQUAD_MANAGER.removeSquad(src)
            
            // Remove from village's squad list if associated with a village
            if(village)
                village.squads -= src

    proc/AddMember(mob/M)
        var/temp_members = members.Copy()
        temp_members += M
        
        var/genin_count = 0
        var/jonin_count = 0
        var/tokubetsu_jonin_count = 0
        
        for(var/mob/N in temp_members)
            if(N.rank.rank_name == "Genin")
                genin_count++
            else if(N.rank.rank_name == "Jonin")
                jonin_count++
            else if(N.rank.rank_name == "Tokubetsu Jonin")
                tokubetsu_jonin_count++
        
        var/is_valid_four = (jonin_count == 1 && genin_count == 3) || (tokubetsu_jonin_count == 1 && genin_count == 3) || (M.rank.rank_name == "Jonin" && genin_count == 3) || (M.rank.rank_name == "Tokubetsu Jonin" && genin_count == 3)
        
        // Now check max members, allowing the special 4-member cases
        if(members.len >= max_members && !is_valid_four)
            usr << "The squad has reached its maximum capacity of [max_members] members."
            return

        if(!canAddMember(M))
            usr << "[M] cannot be added to the squad due to composition rules."
            return
            
        // Actually add the member to the squad
        members += M
        M.squad = src
        
        // Update max_members if we've formed a valid 4-member composition
        if((jonin_count == 1 && genin_count == 3) || (tokubetsu_jonin_count == 1 && genin_count == 3))
            max_members = 4
            
        squad_composition = getSquadComposition()
        
        // Notify the user
        usr << "[M] has been added to your squad."
        M << "You have been added to [usr]'s squad."

    proc/RemoveMember(mob/M)
        members -= M
        M.squad = null
        
        if(members.len)
            squad_composition = getSquadComposition()
            
            // If leader was removed, assign a new leader
            if(M == leader && members.len)
                leader = members[1]
        else
            squad_composition = null
            
            // Remove from global squad manager if squad is empty
            if(GLOBAL_SQUAD_MANAGER)
                GLOBAL_SQUAD_MANAGER.removeSquad(src)
            
            // Remove from village's squad list if associated with a village
            if(village)
                village.squads -= src

    proc/getSquadComposition()
        var/genin_count = 0
        var/chunin_count = 0
        var/tokubetsu_jonin_count = 0
        var/jonin_count = 0

        for(var/mob/M in members)
            if(M.rank.rank_name == "Genin")
                genin_count++
            else if(M.rank.rank_name == "Chunin")
                chunin_count++
            else if(M.rank.rank_name == "Tokubetsu Jonin")
                tokubetsu_jonin_count++
            else if(M.rank.rank_name == "Jonin")
                jonin_count++

        if(jonin_count >= 1)
            return "Jonin Squad"
            
        if(tokubetsu_jonin_count >= 1)
            return "Tokubetsu Jonin Squad"
            
        if(chunin_count >= 1)
            return "Chunin Squad"
            
        if(genin_count >= 1)
            return "Genin Squad"
        
        return "Unknown Squad"

    proc/canAddMember(mob/M)
        if(!members.len)
            return 1
            
        if(members.len >= max_members)
            var/temp_members = members.Copy()
            temp_members += M
            
            var/genin_count = 0
            var/jonin_count = 0
            var/tokubetsu_jonin_count = 0
            
            for(var/mob/N in temp_members)
                if(N.rank.rank_name == "Genin")
                    genin_count++
                else if(N.rank.rank_name == "Jonin")
                    jonin_count++
                else if(N.rank.rank_name == "Tokubetsu Jonin")
                    tokubetsu_jonin_count++
            
            if(!((jonin_count == 1 && genin_count == 3) || (tokubetsu_jonin_count == 1 && genin_count == 3)))
                return 0

        var/temp_members = members.Copy()
        temp_members += M

        var/genin_count = 0
        var/chunin_count = 0
        var/tokubetsu_jonin_count = 0
        var/jonin_count = 0

        for(var/mob/N in temp_members)
            if(N.rank.rank_name == "Genin")
                genin_count++
            else if(N.rank.rank_name == "Chunin")
                chunin_count++
            else if(N.rank.rank_name == "Tokubetsu Jonin")
                tokubetsu_jonin_count++
            else if(N.rank.rank_name == "Jonin")
                jonin_count++

        // Genin squad compositions
        if(genin_count == 3 && chunin_count == 0 && tokubetsu_jonin_count == 0 && jonin_count == 0)
            return 1
        if(genin_count == 1 && chunin_count == 1 && tokubetsu_jonin_count == 0 && jonin_count == 0)
            return 1
        if(genin_count == 2 && chunin_count == 1 && tokubetsu_jonin_count == 0 && jonin_count == 0)
            return 1
            
        // Chunin squad compositions
        if(genin_count == 0 && chunin_count == 3 && tokubetsu_jonin_count == 0 && jonin_count == 0)
            return 1
        if(genin_count == 0 && chunin_count == 1 && tokubetsu_jonin_count == 1 && jonin_count == 0)
            return 1
        if(genin_count == 2 && chunin_count == 1 && tokubetsu_jonin_count == 1 && jonin_count == 0)
            return 1
            
        // Tokubetsu Jonin squad compositions
        if(genin_count == 0 && chunin_count == 0 && tokubetsu_jonin_count == 2 && jonin_count == 0)
            return 1
        if(genin_count == 0 && chunin_count == 2 && tokubetsu_jonin_count == 1 && jonin_count == 0)
            return 1
        if(genin_count == 3 && chunin_count == 0 && tokubetsu_jonin_count == 1 && jonin_count == 0)
            return 1
            
        // Jonin squad compositions
        if(genin_count == 0 && chunin_count == 0 && tokubetsu_jonin_count == 0 && jonin_count == 1)
            return 1
        if(genin_count == 3 && chunin_count == 0 && tokubetsu_jonin_count == 0 && jonin_count == 1)
            return 1
        if(genin_count == 0 && chunin_count == 0 && tokubetsu_jonin_count == 2 && jonin_count == 1)
            return 1
        if(genin_count == 0 && chunin_count == 2 && tokubetsu_jonin_count == 1 && jonin_count == 1)
            return 1

        // Single member squads
        if(members.len <= 1 && (genin_count == 1 || chunin_count == 1 || tokubetsu_jonin_count == 1 || jonin_count == 1))
            return 1
            
        // Two member squads
        if(members.len <= 2)
            // Two Genin
            if(genin_count == 2 && chunin_count == 0 && tokubetsu_jonin_count == 0 && jonin_count == 0)
                return 1
                
            // Two chunin
            if(genin_count == 0 && chunin_count == 2 && tokubetsu_jonin_count == 0 && jonin_count == 0)
                return 1
                
            
            // Jonin + Genin (could become Jonin + 3 Genin)
            if(genin_count == 1 && chunin_count == 0 && tokubetsu_jonin_count == 0 && jonin_count == 1)
                return 1
                
            // Jonin + Tokubetsu (could become Jonin + 2 Tokubetsu)
            if(genin_count == 0 && chunin_count == 0 && tokubetsu_jonin_count == 1 && jonin_count == 1)
                return 1
                
            // Jonin + chunin (could become Jonin + Tokubetsu + 2 chunin)
            if(genin_count == 0 && chunin_count == 1 && tokubetsu_jonin_count == 0 && jonin_count == 1)
                return 1
                
            // Tokubetsu + Genin (could become Tokubetsu + 3 Genin)
            if(genin_count == 1 && chunin_count == 0 && tokubetsu_jonin_count == 1 && jonin_count == 0)
                return 1
                
            // Tokubetsu + chunin (could become Tokubetsu + 2 chunin)
            if(genin_count == 0 && chunin_count == 1 && tokubetsu_jonin_count == 1 && jonin_count == 0)
                return 1
            
            // chunin + Genin (could become chunin + 3 Genin or chunin + 2 Genin)
            if(genin_count == 1 && chunin_count == 1 && tokubetsu_jonin_count == 0 && jonin_count == 0)
                return 1
        
        if(members.len <= 3)
            // Jonin + 2 Genin (could become Jonin + 3 Genin)
            if(genin_count == 2 && chunin_count == 0 && tokubetsu_jonin_count == 0 && jonin_count == 1)
                return 1
                
            // Tokubetsu + 2 Genin (could become Tokubetsu + 3 Genin)
            if(genin_count == 2 && chunin_count == 0 && tokubetsu_jonin_count == 1 && jonin_count == 0)
                return 1

        // If none of the valid compositions match, return 0
        return 0

mob/verb/invite_to_squad()
    set name = "Invite to Squad"
    set category = "Squad"
    
    if(!src.squad)
        src << "You are not in a squad."
        return
    
    if(src != src.squad.leader)
        src << "Only the squad leader can invite new members."
        return
    
    var/is_war_squad = istype(src.squad, /datum/squad/war_squad)
    var/datum/squad/S = src.squad
    
    // Special case for Missing-nin squads - limit to 2 members
    var/is_missing_nin_squad = (src.village.name == "Missing")
    var/max_squad_size = is_missing_nin_squad ? 2 : S.max_members
    
    var/temp_members = S.members.Copy()
    var/genin_count = 0
    var/jonin_count = 0
    var/tokubetsu_jonin_count = 0
    
    for(var/mob/N in temp_members)
        if(N.rank.rank_name == "Genin")
            genin_count++
        else if(N.rank.rank_name == "Jonin")
            jonin_count++
        else if(N.rank.rank_name == "Tokubetsu Jonin")
            tokubetsu_jonin_count++

    // Check if we already have a full valid composition
    if((jonin_count == 1 && genin_count == 3) || (tokubetsu_jonin_count == 1 && genin_count == 3))
        src << "Your squad is already at maximum capacity ([S.max_members] members)."
        return
    
    var/list/possible_members = list()
    for(var/mob/M in view(7))
        if(M != src && !M.squad)
            // For war squads, check village and rank restrictions
            if(is_war_squad)
                if(M.village == src.village && M.rank.rank_name != "Civilian" && M.rank.rank_name != "Academy Student")
                    possible_members += M
            // For regular squads, check appropriate restrictions
            else
                // For Missing-nin (rogue shinobi), check stat grade difference and village
                if(src.village.name == "Missing" && M.village.name == "Missing")
                    if(src.grade_difference(M) > 2)
                        continue // Skip this player if grade difference is too large
                    possible_members += M
                // For regular village squads, check that they're from the same village
                else if(M.village == src.village && M.rank.rank_name != "Civilian" && M.rank.rank_name != "Academy Student")
                    possible_members += M
            
    if(!possible_members.len)
        src << "There are no eligible players nearby to invite."
        return
        
    var/mob/selected = input("Who would you like to invite to your squad?") as null|anything in possible_members
    if(!selected)
        return

    // Now do the capacity check after we have selected a member
    if(S.members.len >= max_squad_size && !((jonin_count == 1 && genin_count == 2) || (tokubetsu_jonin_count == 1 && genin_count == 2) || (genin_count == 3 && selected.rank.rank_name in list("Jonin", "Tokubetsu Jonin"))))
        if(is_missing_nin_squad)
            src << "Rogue shinobi squads can only have 2 members."
        else
            src << "Your squad is already at maximum capacity ([S.max_members] members)."
        return
    
    // For Missing-nin, double check the grade difference
    if(src.village.name == "Missing" && selected.village.name == "Missing")
        if(src.grade_difference(selected) > 2)
            src << "You cannot invite [selected] to your squad. Their power level is too different from yours."
            return
    
    // For war squads, add directly
    if(is_war_squad)
        var/datum/squad/war_squad/WS = src.squad
        
        // Bypass confirmation for testing
        WS.members += selected
        selected.squad = WS
        src << "[selected] has been added to your war squad."
        selected << "You have been added to [src]'s war squad."
    // For regular squads, check composition rules
    else
        if(!src.squad.canAddMember(selected))
            src << "[selected] cannot be added to the squad due to composition rules."
            return
        
        // Bypass confirmation for testing
        // Use the fixed AddMember proc
        src.squad.AddMember(selected)

mob/verb/leave_squad()
    set name = "Leave Squad"
    set category = "Squad"
    
    if(!src.squad)
        src << "You are not in a squad."
        return
        
    if(src == src.squad.leader && src.squad.members.len > 1)
        src.squad.disbandSquad()
        return
        
    src.squad.RemoveMember(src)
    src << "You have left the squad."
    
mob/verb/transfer_leadership()
    set name = "Transfer Leadership"
    set category = "Squad"
    
    if(!src.squad)
        src << "You are not in a squad."
        return
        
    if(src != src.squad.leader)
        src << "Only the squad leader can transfer leadership."
        return
        
    if(src.squad.members.len <= 1)
        src << "There are no other members to transfer leadership to."
        return
        
    var/list/possible_leaders = src.squad.members.Copy()
    possible_leaders -= src
    
    var/mob/new_leader = input("Who would you like to make the new squad leader?") as null|anything in possible_leaders
    if(!new_leader)
        return
        
    src.squad.leader = new_leader
    src << "You have transferred squad leadership to [new_leader]."
    new_leader << "You are now the leader of the squad."

mob/verb/view_squad_info()
    set name = "View Squad Info"
    set category = "Squad"
    
    if(!src.squad)
        src << "You are not in a squad."
        return
    
    var/info = "Squad Information:\n"
    info += "Squad Type: [src.squad.squad_composition]\n"
    info += "Leader: [src.squad.leader]\n"
    info += "Members ([src.squad.members.len]/[src.squad.max_members]):\n"
    for(var/mob/M in src.squad.members)
        info += "- [M] ([M.rank.rank_name])\n"
    src << info

mob/verb/create_squad()
    set name = "Create Squad"
    set category = "Squad"
    
    if(src.rank.rank_name == "Civilian")
        src << "You cannot create a squad."
        return
        
    if(src.squad)
        src << "You're already in a squad!"
        return
        
    var/datum/squad/S = new()
    S.members += src
    S.leader = src
    src.squad = S
    S.name = "Squad [rand(1,100)]"
    S.squad_composition = S.getSquadComposition()
    
    // Set the squad's village to the creator's village
    S.village = src.village
    
    // Register with global manager
    if(!GLOBAL_SQUAD_MANAGER)
        GLOBAL_SQUAD_MANAGER = new()
    GLOBAL_SQUAD_MANAGER.addSquad(S)
    
    src << "You have created a new squad. Type: [S.squad_composition]"

mob/verb/kick_from_squad()
    set name = "Kick from Squad"
    set category = "Squad"
    
    if(!src.squad)
        src << "You are not in a squad."
        return
        
    if(src != src.squad.leader)
        src << "Only the squad leader can kick members from the squad."
        return
        
    if(src.squad.members.len <= 1)
        src << "There are no other members to kick from the squad."
        return
    
    var/is_war_squad = istype(src.squad, /datum/squad/war_squad)
    var/squad_type = is_war_squad ? "war squad" : "squad"
        
    var/list/possible_kicks = src.squad.members.Copy()
    possible_kicks -= src
    
    var/mob/selected = input("Who would you like to kick from your [squad_type]?") as null|anything in possible_kicks
    if(!selected)
        return
        
    src.squad.RemoveMember(selected)
    src << "You have kicked [selected] from your [squad_type]."
    selected << "You have been kicked from [src]'s [squad_type]."

/datum/squad/war_squad
    // Don't redefine max_members here, override it in New()
    
    New()
        ..()
        max_members = 4  // Override the default max_members
    
    // Override the canAddMember proc without redefining it
    canAddMember(mob/M)
        // Check if adding this member would exceed max members
        if(members.len >= max_members)
            return 0
            
        // Check if the member is from another village
        if(M.village != leader.village)
            return 0
            
        // Check if the member is an academy student
        if(M.rank.rank_name == "Academy Student")
            return 0
            
        // Check if the member is a civilian
        if(M.rank.rank_name == "Civilian")
            return 0
            
        // All other ranks are allowed
        return 1

mob/verb/create_war_squad()
    set name = "Create War Squad"
    set category = "Squad"
    
    if(src.rank.rank_name == "Civilian" || src.rank.rank_name == "Academy Student")
        src << "You cannot create a war squad."
        return
        
    if(src.squad)
        src << "You're already in a squad!"
        return
        
    var/datum/squad/war_squad/S = new()
    S.members += src
    S.leader = src
    src.squad = S
    S.name = "War Squad [rand(1,100)]"
    S.squad_composition = "War Squad"
    
    // Set the squad's village to the creator's village
    S.village = src.village
    
    // Register with global manager
    if(!GLOBAL_SQUAD_MANAGER)
        GLOBAL_SQUAD_MANAGER = new()
    GLOBAL_SQUAD_MANAGER.addSquad(S)
    
    src << "You have created a new war squad. This squad can have up to 4 members with no composition restrictions."

// Add this helper proc to the mob type to compare stat grades
mob/proc/grade_difference(mob/other)
    var/list/grades = list("E", "E+", "D-", "D", "D+", "C-", "C", "C+", "B-", "B", "B+", "A-", "A", "A+", "S-", "S", "S+")
    var/my_grade = getOverallGrade()
    var/other_grade = other.getOverallGrade()
    
    var/my_index = grades.Find(my_grade)
    var/other_index = grades.Find(other_grade)
    
    if(!my_index || !other_index)
        return 999 // If grade not found, return a large number
        
    return abs(my_index - other_index)