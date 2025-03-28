// Base Mission Object
/obj/mission
    name = "Mission"
    desc = "A mission assignment"
    var
        reward = 100              // Ryo reward
        rank = "D"                // Mission rank (D, C, B, A, S)
        
        // Squad tracking
        list/squads = list()      // Squads assigned to this mission
        max_squads = 2            // Maximum number of squads allowed
        
        // Mission state
        completed = FALSE         // Whether mission is completed
        datum/squad/completed_by  // Squad that completed the mission
        datum/squad/failed_by     // Squad that failed the mission
        
        // Timing and cooldowns
        started_at = 0            // World.time when mission started
        completed_at = 0          // World.time when mission completed
        fail_cooldown = 18000     // 30 minutes
        success_cooldown = 6000   // 10 minutes
    
    // Initialize the mission
    New()
        ..()
        started_at = world.time
    
    // Give mission to a squad
    proc/give_mission(datum/squad/S)
        if(!S || (S in squads) || squads.len >= max_squads)
            return FALSE
        
        S.mission = src
        squads += S
        return TRUE
    
    // Remove mission from a squad
    proc/remove_mission(datum/squad/S)
        if(!S || !(S in squads))
            return FALSE
        
        S.mission = null
        squads -= S
        return TRUE
    
    // Complete the mission for a squad
    proc/complete(datum/squad/S)
        if(completed || !S || !(S in squads))
            return FALSE
        
        completed = TRUE
        completed_at = world.time
        completed_by = S
        
        // Award rewards
        award_rewards(S)
        
        // Fail other squads
        for(var/datum/squad/other_squad in squads)
            if(other_squad != S)
                fail_mission(other_squad)
        
        // Remove mission from all squads
        for(var/datum/squad/assigned_squad in squads.Copy())
            remove_mission(assigned_squad)
        
        // Clean up after a short delay (to allow messages to be seen)
        spawn(100)
            del(src)
        
        return TRUE
    
    // Fail a squad
    proc/fail_mission(datum/squad/S)
        if(!S || !(S in squads) || S == completed_by)
            return FALSE
        
        failed_by = S
        
        // Apply cooldowns
        for(var/mob/M in S.members)
            M.mission_cooldown = world.time + fail_cooldown
            M << "You've failed the mission. Cooldown: [fail_cooldown/600] minutes."
        
        return TRUE
    
    // Award rewards to a squad
    proc/award_rewards(datum/squad/S)
        if(!S)
            return FALSE
        
        // Apply cooldowns
        for(var/mob/M in S.members)
            M.mission_cooldown = world.time + success_cooldown
            M.ryo += reward
            M.mission_complete(rank)
            M << "Mission complete! You received [reward] ryo. Cooldown: [success_cooldown/600] minutes."
        
        return TRUE
    
    // Surrender a mission
    proc/surrender(datum/squad/S)
        if(!S || !(S in squads))
            return FALSE
        
        fail_mission(S)
        remove_mission(S)
        
        // If no more squads, clean up
        if(squads.len <= 0)
            del(src)
        
        return TRUE

/obj/mission/c_rank/delivery
    name = "C-Rank: Package Delivery"
    desc = "Deliver a package to the client."
    reward = 300
    rank = "C"
    var
        timer = 1800          // 30 minute default timer
        min_timer = 300       // 5 minute minimum (when contested)
        check_interval = 10   // How often to check for nearby players
        timer_reduction = 1   // How many secondds to reduce per check
        obj/mission_post/target_post  // The delivery target post
        timer_running = FALSE

    proc/setup_post()
        if(timer_running)
            return
            
        timer_running = TRUE
        spawn(check_interval)
            while(!completed && !failed_by)
                var/list/nearby_mission_squads = list()
                var/others_present = FALSE
                
                // Check for players near the post
                for(var/mob/M in view(1, target_post))
                    if(M.squad && (M.squad in squads))
                        nearby_mission_squads |= M.squad
                    else
                        world << "Squad: [M.squad] not in mission squads: [squads]"
                        others_present = TRUE
                // If any assigned squad is present
                if(nearby_mission_squads.len > 0)
                    // If others are present or multiple squads, stop at min_timer
                    if(others_present || nearby_mission_squads.len > 1)
                        timer = max(min_timer, timer - timer_reduction)
                        world << "Timer: [timer]"
                    else
                        // Single squad alone - can complete
                        timer = max(0, timer - timer_reduction)
                        world << "Timer: [timer]"
                    
                    // Complete mission when timer reaches 0
                    if(timer <= 0)
                        // Give completion to the first squad in the list
                        complete(nearby_mission_squads[1])
                        break
                
                sleep(check_interval)
    
    // Start the delivery mission at a specific post
    proc/start_delivery_at(obj/mission_post/P, datum/squad/S)
        if(!P || !S)
            return FALSE
        
        target_post = P
        P.active_mission = src
        
        if(!give_mission(S))
            return FALSE
        
        setup_post()
        return TRUE
    
    // Join ongoing delivery mission
    proc/add_squad_to_delivery(datum/squad/S)
        if(!give_mission(S))
            return FALSE
            
        return TRUE

// Mission Verb for surrender
mob/verb/surrender_mission()
    set name = "Surrender Mission"
    set category = "Commands"
    
    if(!usr.squad || !usr.squad.mission)
        usr << "You are not on a mission."
        return
    
    var/obj/mission/M = usr.squad.mission
    M.surrender(usr.squad)
    usr << "You have surrendered your mission."
