/datum/mission
    var
        name
        description
        reward
        list/squads = list()
        rank
        completed = FALSE
        datum/squad/completed_by
        datum/squad/failed_by
        completed_at
        max_squads = 2
        fail_cooldown = 18000
        success_cooldown = 6000
    
    // Give a mission to a squad
    proc/give_mission(datum/squad/S)
        if(!S)
            return FALSE
        
        S.mission += src
        return TRUE

    // Remove a mission from a squad
    proc/remove_mission(datum/squad/S)
        if(!S)
            return FALSE
        
        S.mission -= src
        return TRUE

    proc/complete(datum/squad/S)
        if(completed)
            return FALSE // If mission is already completed
            
        completed = TRUE
        completed_at = world.time
        completed_by = S

        // Rewards for the completing squad
        if(completed_by)
            award_rewards(completed_by)
            
        // Fail the other squad
        for(var/datum/squad/squad in squads)
            if(squad != completed_by)
                fail_mission(squad)

            remove_mission(squad)
        
        // Reset the squad list
        squads.Cut()
        return TRUE

    // Fail a squad
    proc/fail_mission(datum/squad/S)
        if(!S)
            return FALSE
        
        if(S == completed_by)
            return FALSE

        failed_by = S

        for(var/mob/M in S.members)
            M << "You've failed [name]!"
            apply_cooldowns(TRUE)

    // Award rewards to a squad
    proc/award_rewards(datum/squad/S)
        if(!S)
            return FALSE
        
        for(var/mob/M in S.members)
            M.ryo += reward
            M.mission_complete(rank)
            apply_cooldowns(FALSE)

    proc/apply_cooldowns(failed)
        if(failed)
            for(var/mob/M in failed_by.GetMembers())
                M.mission_cooldown = world.time + fail_cooldown
        else
            for(var/mob/M in completed_by.GetMembers())
                M.mission_cooldown = world.time + success_cooldown
        
    proc/surrender_mission(datum/squad/S)
        fail_mission(S)

    proc/cleanup()
        return

mob/verb/surrender_mission()
    set name = "Surrender Mission"
    set category = "Commands"

    if(!usr.squad)
        usr << "You are not in a squad!"
        return
    
    if(!usr.squad.mission)
        usr << "You are not on a mission!"
        return
    
    surrender_mission(usr.squad)

/datum/mission/crank/delivery
    name = "Package Delivery"
    description = "Deliver a package to the specified client. Wait at the post for the client to arrive."
    reward = 300
    rank = "C"
    max_squads = 2
    var
        client_name
        obj/item/mission_post/delivery_post
        waiting_time = 2700
        remaining_time = 2700
        timer_paused = TRUE
        timer_started = FALSE
        timer_running = FALSE
        client_arrived = FALSE
        min_time_with_enemies = 300
    
    New()
        ..()
        var/list/possible_clients = list(
            "Maehata, Saga",
            "Samanosuke, Nobugi",
            "Nonomi, Kuro"
        )
        client_name = pick(possible_clients)
        description = "Deliver a package to [client_name]. Wait at the post for them to arrive."
    
    proc/setup_post(obj/item/mission_post/post)
        if(!post)
            return FALSE
        
        delivery_post = post
        post.set_mission(src)
        
        // Notify the assigned squads
        for(var/datum/squad/S in squads)
            for(var/mob/M in S.members)
                M << "Your squad has been assigned to deliver a package to [client_name]. Go to [post.name] and wait for the client."
        
        start_timer()
        return TRUE
        
    // Start mission timer
    proc/start_timer()
        if(timer_running)
            return

        timer_running = TRUE
        process_timer()
    
    // Process mission timer
    proc/process_timer()
        set waitfor = FALSE
        
        while(timer_running && !completed)
            if(delivery_post)
                check_post_status()
            sleep(10) // Sleep for 1 second
        
        timer_running = FALSE
    
    proc/check_post_status()
        // Skip if mission is done or client has arrived
        if(completed || client_arrived)
            return
        
        // Skip if post does not exist
        if(!delivery_post)
            return
        
        // Check for nearby players
        var/list/nearby_players = list()
        for(var/mob/M in range(5, delivery_post))
            nearby_players += M
        
        // Determine if authorized squad members or enemies are present
        var/enemies_present = FALSE
        var/authorized_present = FALSE
        
        for(var/mob/player in nearby_players)
            var/is_authorized = FALSE
            for(var/datum/squad/S in squads)
                if(player.squad == S)
                    is_authorized = TRUE
                    authorized_present = TRUE
                    break
            
            if(!is_authorized)
                enemies_present = TRUE

        // Start timer when first authorized squad arrives
        if(authorized_present && !timer_started)
            timer_started = TRUE
            timer_paused = FALSE
        
        if(!authorized_present) {
            timer_paused = TRUE // Pause if no authorized squads are present
        } else if(enemies_present) {
            // If enemies are present, only pause when 5 minutes remain
            timer_paused = (remaining_time <= min_time_with_enemies)
        } else {
            timer_paused = FALSE // Continue if authorized players and no enemies are present
        }

        // Count down if not paused
        if(!timer_paused && remaining_time > 0) {
            remaining_time -= 1
        }
        
        // Handle client arrival
        if(remaining_time <= 0 && !client_arrived) {
            client_arrived = TRUE
            delivery_post.icon_state = "client" // Change post icon to indicate client arrival
        }
    
    proc/deliver_package(mob/player)
        if(!player || !player.squad || !(player.squad in squads))
            return FALSE
        
        if(!client_arrived) {
            player << "The client hasn't arrived yet!"
            return FALSE
        }
        
        timer_running = FALSE
        complete(player.squad)
        return TRUE
    
    cleanup()
        timer_running = FALSE
        
        if(delivery_post)
            delivery_post.clear_mission()
            delivery_post = null

var/global/list/active_mission_posts = list() // Tracks which posts are in use

// Mission assignment proc
proc/assign_mission(datum/mission/M, datum/squad/S1, datum/squad/S2 = null)
    if(!M || !S1)
        return FALSE
    
    // Check if both squads are from the same village
    if(S2 && S1.village == S2.village)
        return
    
    // Find available posts
    var/list/available_posts = get_available_posts()
    if(!available_posts.len)
        return
    
    // Choose a random available post
    var/obj/item/mission_post/chosen_post = pick(available_posts)
    
    // Mark the post as in use
    active_mission_posts[chosen_post] = M
    
    // Assign the mission to the squad(s)
    M.give_mission(S1)
    if(S2)
        M.give_mission(S2)
    
    // Set up post for mission
    if(istype(M, /datum/mission/crank/delivery))
        var/datum/mission/crank/delivery/DM = M
        DM.setup_post(chosen_post)
    
    return TRUE

// Get available psots
proc/get_available_posts()
    var/list/available = list()
    
    for(var/obj/item/mission_post/P in world)
        if(!(P in active_mission_posts))
            available += P
    
    return available