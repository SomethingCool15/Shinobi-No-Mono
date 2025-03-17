/datum/squad
    var
        leader_name
        list/members = list()
        list/offline_members = list() // Map of player names to ckeys for offline members
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
        offline_members = list() // Clear offline members too
        leader_name = null
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
        
        offline_members -= M.name
        
        // If leader was removed, assign a new leader
        if(M.name == leader_name && members.len)
            leader_name = members[1].name
        
        if(members.len)
            squad_composition = getSquadComposition()
        else
            squad_composition = null
            
            if(GLOBAL_SQUAD_MANAGER)
                GLOBAL_SQUAD_MANAGER.removeSquad(src)
            
            if(village)
                village.squads -= src

    proc/MemberOffline(mob/M)
        if(M in members)
            members -= M
            // Adding player to offline list
            offline_members[M.name] = M.ckey
            
            return 1
        return 0
        
    proc/MemberOnline(mob/M)
        if(offline_members[M.name] == M.ckey)
            members += M
            // Removing player from offline list
            offline_members -= M.name
            M.squad = src
            return 1
        return 0
        
    // Get total member count (online + offline)
    proc/GetTotalMemberCount()
        return members.len + offline_members.len

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
        if(!members.len && !offline_members.len)
            return 1
        
        // Get total member count including offline members
        var/total_members = GetTotalMemberCount()
        
        if(total_members >= max_members)
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
    
    if(src.name != src.squad.leader_name)
        src << "Only the squad leader can invite new members."
        return
    
    var/is_war_squad = istype(src.squad, /datum/squad/war_squad)
    var/datum/squad/S = src.squad
    
    // Special case for Missing-nin squads - limit to 2 members
    var/is_missing_nin_squad = (src.village.name == "Missing")
    var/max_squad_size = is_missing_nin_squad ? 2 : S.max_members
    
    // Get total member count including offline members
    var/total_members = S.GetTotalMemberCount()
    
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
    
    // Check if we're at max capacity considering offline members
    if(total_members >= max_squad_size)
        if(is_missing_nin_squad)
            src << "Rogue shinobi squads can only have 2 members."
        else
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
        if(src.grade_difference(selected) > 2 || src.grade_difference(selected) < 2)
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
        
        src.squad.AddMember(selected)

mob/verb/leave_squad()
    set name = "Leave Squad"
    set category = "Squad"
    
    if(!src.squad)
        src << "You are not in a squad."
        return
        
    if(src.name == src.squad.leader_name)
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
        
    if(src.name != src.squad.leader_name)
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
        
    src.squad.leader_name = new_leader.name
    src << "You have transferred squad leadership to [new_leader]."
    new_leader << "You are now the leader of the squad."

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
    S.leader_name = src.name
    src.squad = S
    var/squad_name = input(src, "Enter a name for your squad:", "Squad Name", "Squad [rand(1,100)]") as null|text
    if(!squad_name)
        src << "You didn't enter a valid squad name."
        return
    S.name = squad_name
    if(GLOBAL_SQUAD_MANAGER.squads[S.name])
        src << "A squad with that name already exists."
        return
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
        
    if(src.name != src.squad.leader_name)
        src << "Only the squad leader can kick members from the squad."
        return
        
    if(src.squad.members.len <= 1)
        src << "There are no other members to kick from the squad."
        return
        
    var/list/possible_kicks = src.squad.members.Copy()
    possible_kicks -= src
    
    var/mob/selected = input("Who would you like to kick from your [name]?") as null|anything in possible_kicks
    if(!selected)
        return
        
    src.squad.RemoveMember(selected)
    src << "You have kicked [selected] from your [name]."
    selected << "You have been kicked from [src]'s [name]."

/datum/squad/war_squad
    New()
        ..()
        max_members = 4 // Override the default max_members
    
    // Override the canAddMember proc
    canAddMember(mob/M)
        if(members.len >= max_members)
            return 0
            
        // Get the leader mob
        var/mob/leader = null
        for(var/mob/L in members)
            if(L.name == leader_name)
                leader = L
                break
                
        // Check if the member is from another village
        if(leader && M.village != leader.village)
            src << "You cannot add a member from another village to your war squad."
            return 0
            
        // Check if the member is an academy student
        if(M.rank.rank_name == "Academy Student")
            src << "You cannot add an academy student to your war squad."
            return 0
            
        // Check if the member is a civilian
        if(M.rank.rank_name == "Civilian")
            src << "You cannot add a civilian to your war squad."
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
    S.leader_name = src.name
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

// Add this to your globals
var/global/list/players_in_squads = list()

// Updated squad_check
mob/proc/squad_check(var/is_logout = FALSE)
    if(is_logout)
        if(squad)
            squad.MemberOffline(src)
            players_in_squads[ckey] = 1
        return
    
    // Handle login case (default)
    if(GLOBAL_SQUAD_MANAGER)
        for(var/datum/squad/S in GLOBAL_SQUAD_MANAGER.squads)
            if(S.offline_members[name] == ckey)
                S.MemberOnline(src)
                src << "You have reconnected to your squad."
                players_in_squads -= ckey
                return
    
    if(players_in_squads[ckey])
        src << "Your squad was disbanded while you were offline."
        players_in_squads -= ckey
    
    if(squad)
        squad = null
