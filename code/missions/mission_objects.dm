/obj/mission_board
    name = "Mission Board"
    desc = "A board for posting and accepting missions."
    icon = 'icons/Misc/BillBoard.dmi'
    icon_state = "full"

    Click()
        ..()
        view_missions()
    
    verb
        view_missions()
            if(!usr.squad)
                usr << "You are not in a squad."
                return

            if(!(usr in range(5, src.loc)))
                usr << "You are not close enough to the mission board."
                return
            
            for(var/mob/M in usr.squad.members)
                if(!(M in view(5, src.loc)))
                    usr << "Gather your squad members to view missions."
                    return
            
            if(usr.squad.mission)
                usr << "You already have a mission."
                return
            
            for(var/mob/M in usr.squad.members)
                if(M.mission_cooldown > world.time)
                    usr << "Someone in your squad is on cooldown."
                    return
            
            var/list/missions = list(
                "C-Rank: Package Delivery"
            )

            var/mission_choice = input("Select a mission", "Mission Selection") as null|anything in missions
            if(!mission_choice)
                return
            
            switch(mission_choice)
                if("C-Rank: Package Delivery")
                    assign_delivery_mission(usr.squad)

    proc/assign_delivery_mission(datum/squad/S)
        var/list/available_posts = new()
        
        // Gather available posts
        for(var/obj/mission_post/P in world)
            if(P.active_mission == null)
                available_posts += P  // Empty posts are always available
            else if(P.active_mission.squads.len == 1 && P.active_mission.squads[1].village.name != S.village.name)
                available_posts += P  // Only add posts where existing squad is from different village
        
        if(available_posts.len > 0)
            var/obj/mission_post/P = pick(available_posts)
            if(P.active_mission)
                // Join existing mission
                P.active_mission.add_squad_to_delivery(S)
            else
                // Create new mission
                var/obj/mission/c_rank/delivery/M = new()
                M.start_delivery_at(P, S)
            return TRUE
        else
            world << "There are no meeting posts available at the moment."
        return FALSE


                
/obj/mission_board/konoha_mission_board
    name = "Konoha Mission Board"
    desc = "A board for posting and accepting missions."

/obj/mission_post
    name = "Mission Post"
    desc = "A meeting place for shinobi to meet their clients."
    icon = 'icons/Misc/BillBoard.dmi'
    icon_state = "full"
    var/obj/mission/c_rank/delivery/active_mission

/obj/mission_post/post1
    name = "Mission Post 1"
    desc = "A meeting place for shinobi to meet their clients."
