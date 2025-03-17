var/list/admin1 = list()
var/list/admin2 = list()
var/list/admin3 = list()
var/list/admin4 = list()
var/list/admin5 = list("PassingSkies")
var/list/owners = list("gucci3rdleg")
var/list/village_ranks = list("Academy Student", "Genin", "Chunin", "Jounin", "Special Jounin", "Hokage", "Kazekage", "Mizukage")
var/list/criminal_ranks = list("Akatsuki", "Sound Five")

proc
    admin_check(key)
        if(key in admin5)
            usr.verbs += typesof(/admin5/verb, /owner/verb)

admin5
    verb
        award_points(player/P as mob in world, points as num)
            set category = "Admin"
            set name = "Award Points"
            P.total_pp += points
            P.unspent_pp += points
            P.stat_points += points
            P << "You have been awarded [points] points!"

        set_rank(player/P as mob in world, rank_type as null|anything in typesof(/datum/rank, /datum/sub_rank))
            set category = "Admin"
            set name = "Set Rank"
            if(!rank_type) return
            
            if(ispath(rank_type, /datum/sub_rank))
                var/datum/sub_rank/new_sub_rank = new rank_type()
                P.sub_ranks += new_sub_rank
                usr << "[P] has been given the sub-rank [new_sub_rank.rank_name]"
            else
                var/datum/rank/new_rank = new rank_type()
                new_rank.apply_rank(P)
                usr << "[P] has been set to rank [new_rank.rank_name]"
                
                if(new_rank.rank_name == "Genin")
                    spawn(1)
                        var/obj/item/clothing/headband/H = new()
                        if(P.AddToInventory(H))
                            if(P.village && H.village_icon_states["[P.village]"])
                                H.icon_state = H.village_icon_states["[P.village]"]
                            P << "You received your village headband!"
        
        set_village(player/P as mob in world, village as null|anything in GLOBAL_VILLAGE_MANAGER.villages)
            set category = "Admin"
            set name = "Set Village"
            if(!village) return
            
            var/datum/village/V = village
            
            if(P.village)
                var/datum/village/old_village = P.village
                old_village.remove_player(P)
            
            V.add_player(P)
            
            if(V.name == "Missing")
                if(P.rank)
                    P.verbs -= P.rank.rank_verbs
                    P.rank = null
                var/datum/rank/missing/M = new()
                M.apply_rank(P)
                P << "You are now a missing ninja!"
            else
                P << "You are now a part of [V.name]!"
        
        remove_from_village(player/P as mob in world)
            set category = "Admin"
            set name = "Remove from Village"
            if(!istype(P.village, /datum/village))
                usr << "This player is not a part of any village!"
                return
            var/datum/village/V = P.village
            V.remove_player(P)
            P.sub_ranks = list()
            P << "You have been removed from your village and are now a missing ninja!"

        rank_flags(player/P as mob in world)
            set category = "Admin"
            set name = "Rank Flags"
            var/flag = input("Enter the flag you want to set", "Rank Flags") in list("Chuunin Exam", "Tokubetsu Chain", "Mentored Squad", "Jounin Chain", "Anbu Infiltration", "Hancho Recommendation")
            if(flag == "Chuunin Exam")
                P.passed_chunin = TRUE
            else if(flag == "Tokubetsu Chain")
                P.passed_tokubetsu_jonin = TRUE
            else if(flag == "Jounin Chain")
                P.passed_jonin = TRUE
            else if(flag == "Mentored Squad")
                P.jonin_mentored = TRUE
            else if(flag == "Anbu Infiltration")
                P.passed_anbu = TRUE
            else if(flag == "Hancho Recommendation")
                P.passed_hancho = TRUE
        
        increase_sp_cap(player/P as mob in world, amount as num)
            set category = "Admin"
            set name = "Increase SP Cap"
            P.sp_cap += amount
            P << "Your SP cap has been increased by [amount]!"

        decrease_sp_cap(player/P as mob in world, amount as num)
            set category = "Admin"
            set name = "Decrease SP Cap"
            P.sp_cap -= amount
            P << "Your SP cap has been decreased by [amount]!"

        give_item(player/P as mob in world, item_type as null|anything in typesof(/obj/item))
            set category = "Admin"
            set name = "Give Item"
            if(!item_type) return
            
            var/obj/item/I = new item_type()
            if(P.AddToInventory(I))
                usr << "Gave [P] a [I.name]"
                P << "You received a [I.name]!"
            else
                usr << "[P]'s inventory is full!"
                del(I)

        view_all_squads()
            set category = "Admin"
            set name = "View All Squads"
            
            if(!GLOBAL_SQUAD_MANAGER || !GLOBAL_SQUAD_MANAGER.squads.len)
                usr << "There are no squads currently active."
                return
                
            var/info = "All Active Squads:\n"
            for(var/datum/squad/S in GLOBAL_SQUAD_MANAGER.squads)
                var/village_name = S.village ? S.village.name : "No Village"
                info += "Squad: [S.name] ([S.squad_composition]) - Village: [village_name]\n"
                info += "  Leader: [S.leader_name]\n"
                info += "  Members ([S.members.len]/[S.max_members]):\n"
                for(var/mob/M in S.members)
                    info += "    - [M] ([M.rank.rank_name])\n"
                info += "\n"
            usr << info
            
        summon_squad(datum/squad/S as null|anything in GLOBAL_SQUAD_MANAGER.squads)
            set category = "Admin"
            set name = "Summon Squad"
            
            if(!S)
                return
                
            for(var/mob/M in S.members) 
                M.loc = usr.loc
                M << "You have been summoned by an admin."
                
            usr << "Squad [S.name] has been summoned to your location."
            
        disband_squad(datum/squad/S as null|anything in GLOBAL_SQUAD_MANAGER.squads)
            set category = "Admin"
            set name = "Disband Squad"
            
            if(!S)
                return
                
            var/confirm = alert("Are you sure you want to disband squad [S.name]?", "Confirm Disband", "Yes", "No")
            if(confirm == "No")
                return
                
            S.disbandSquad()
            usr << "Squad [S.name] has been disbanded."