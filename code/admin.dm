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
        
        set_village(player/P as mob in world, village as null|anything in GLOBAL_VILLAGE_MANAGER.villages)
            set category = "Admin"
            set name = "Set Village"
            if(!village) return
            
            var/datum/village/V = village
            if(istype(P.village, /datum/village/missing))
                V.add_player(P)
                P << "You are now a part of [V.name]!"
                return
            
            if(P.village && istype(P.village, /datum/village))
                var/datum/village/old_village = P.village
                old_village.remove_player(P)
            V.add_player(P)
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