/obj/item/mission_post
    name = "Mission Post"
    desc = "A meeting place for shinobi to meet their clients."
    icon = 'icons/Misc/BillBoard.dmi'
    icon_state = "full"
    var/datum/mission/active_mission

    // Check if this post is available for a mission
    proc/is_available()
        return !active_mission
    
    // Set the active mission for this post
    proc/set_mission(datum/mission/M)
        if(active_mission)
            return FALSE
        
        active_mission = M
        return TRUE
    
    // Clear the mission when completed
    proc/clear_mission()
        active_mission = null
        icon_state = "full" // Reset appearance

    Click()
        if(!usr || !active_mission)
            return
            
        // Handle delivery missions
        if(istype(active_mission, /datum/mission/crank/delivery))
            var/datum/mission/crank/delivery/D = active_mission
            
            if(D.client_arrived)
                if(usr.squad && (usr.squad in D.squads))
                    D.deliver_package(usr)
                else
                    usr << "This is not your mission."
            else if(usr.squad && (usr.squad in D.squads))
                usr << "The client hasn't arrived yet. [D.remaining_time/60] minutes remaining."
            else
                usr << "This post is currently occupied with a delivery mission."

/obj/item/mission_post/post1
    name = "Mission Post 1"

/obj/item/mission_post/post2
    name = "Mission Post 2"

/obj/item/mission_post/post3
    name = "Mission Post 3"

/obj/item/mission_post/post4
    name = "Mission Post 4"
    
/obj/item/mission_post/post5
    name = "Mission Post 5"

/obj/item/mission_post/post6
    name = "Mission Post 6"