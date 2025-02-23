/datum/rank
    var
        rank_name
        sp_cap
        list/rank_verbs = list()
        list/tasks = list()
        list/requirements = list()
        preserves_old_cap = FALSE 

    New(name, cap)
        rank_name = name
        sp_cap = cap

    proc/apply_rank(mob/M)
        if(!M) return
        var/old_cap = 0
        if(M.rank)
            old_cap = M.rank.sp_cap
            M.verbs -= M.rank.rank_verbs
        
        M.rank = src
        if(preserves_old_cap)
            M.sp_cap = old_cap
        else
            M.sp_cap = sp_cap
        M.verbs += rank_verbs

        if(rank_name == "Missing")
            M << "You are now a criminal!"
        else
            M << "You have been promoted to [rank_name]!"

/datum/rank/civilian
    New()
        ..("Civilian", 45)

/datum/rank/academy_student
    New()
        ..("Academy Student", 80)

/datum/rank/genin
    New()
        ..("Genin", 115)

/datum/rank/missing
    New()
        ..("Missing", 115)

/datum/rank/chunin
    New()
        ..("Chunin", 150)
        rank_verbs = list(
            /datum/rank/chunin/verb/promote_to_academy_student
        )

    verb/promote_to_academy_student()
        set category = "Chunin"
        set name = "Promote to Academy Student"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/civilian))
                choices += P
        var/player/P = input("Choose a civilian to promote") as null|anything in choices
        if(!P) return
        var/datum/rank/R = new /datum/rank/academy_student()
        R.apply_rank(P)

/datum/rank/tokubetsu_jonin
    New()
        ..("Tokubetsu Jōnin", 185) 

/datum/rank/jonin
    New()
        ..("Jōnin", 220)
        rank_verbs = list(
            /datum/rank/jonin/verb/promote_to_academy_student,
            /datum/rank/jonin/verb/promote_to_genin
        )

    verb/promote_to_academy_student()
        set category = "Jonin"
        set name = "Promote to Academy Student"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/civilian))
                choices += P
        var/player/P = input("Choose a civilian to promote") as null|anything in choices
        if(!P) return
        var/datum/rank/R = new /datum/rank/academy_student()
        R.apply_rank(P)

    
    verb/promote_to_genin()
        set category = "Jonin"
        set name = "Promote to Genin"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/academy_student))
                choices += P
        var/player/P = input("Choose an academy student to promote") as null|anything in choices
        if(!P) return

        var/list/required_jutsu = list(
            "Bunshin no Jutsu",
            "Henge no Jutsu",
            "Kawarimi no Jutsu"
        )
        
        var/missing_jutsu = FALSE
        for(var/jutsu_name in required_jutsu)
            var/has_jutsu = FALSE
            for(var/obj/jutsu/J in P.jutsu_list)
                if(J.name == jutsu_name)
                    has_jutsu = TRUE
                    break
            if(!has_jutsu)
                usr << "[P] doesn't know [jutsu_name]!"
                missing_jutsu = TRUE
            
        if(missing_jutsu)
            return

        var/datum/rank/R = new /datum/rank/genin()
        R.apply_rank(P)
        src << "You have promoted [P] to Genin!"

/datum/rank/hancho_jonin
    New()
        ..("Jōnin Hanchō", 250)

/datum/rank/sannin
    New()
        ..("Sannin", 280)

/datum/rank/hokage // Maximum tiles distance for promotions
    New()
        ..("Hokage", 0)
        preserves_old_cap = TRUE
        rank_verbs = list(
            /datum/rank/hokage/verb/declare_war,
            /datum/rank/hokage/verb/make_announcement,
            /datum/rank/hokage/verb/exile,
            /datum/rank/hokage/verb/make_council_member,
            /datum/rank/hokage/verb/promote_to_academy_student,
            /datum/rank/hokage/verb/promote_to_genin,
            /datum/rank/hokage/verb/promote_to_chunin,
            /datum/rank/hokage/verb/promote_to_tokubetsu_jonin,
            /datum/rank/hokage/verb/make_ANBU,
            /datum/rank/hokage/verb/promote_to_jonin,
            /datum/rank/hokage/verb/promote_to_hancho_jonin,
            /datum/rank/hokage/verb/demote_anbu,
            /datum/rank/hokage/verb/remove_council_member,
            /datum/rank/hokage/verb/make_anbu_buntaicho,
            /datum/rank/hokage/verb/demote_anbu_buntaicho,
            /datum/rank/hokage/verb/assign_official_team
        )
    
    verb/declare_war()
        set category = "Hokage"
        set name = "Declare War"
        usr << "You have declared war!"

    verb/make_announcement(msg as text)
        set category = "Hokage"
        set name = "Make Village Announcement"
        for(var/player/P in usr.village.players)
            P << "[msg]"
    
    verb/promote_to_academy_student()
        set category = "Hokage"
        set name = "Promote to Academy Student"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/civilian))
                choices += P
        var/player/P = input("Choose a civilian to promote") as null|anything in choices
        if(!P) return
        var/datum/rank/R = new /datum/rank/academy_student()
        R.apply_rank(P)

    verb/promote_to_genin()
        set category = "Hokage"
        set name = "Promote to Genin"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/academy_student))
                choices += P
        var/player/P = input("Choose an academy student to promote") as null|anything in choices
        if(!P) return

        var/list/required_jutsu = list(
            "Bunshin no Jutsu",
            "Henge no Jutsu",
            "Kawarimi no Jutsu"
        )
        
        var/missing_jutsu = FALSE
        for(var/jutsu_name in required_jutsu)
            var/has_jutsu = FALSE
            for(var/obj/jutsu/J in P.jutsu_list)
                if(J.name == jutsu_name)
                    has_jutsu = TRUE
                    break
            if(!has_jutsu)
                usr << "[P] doesn't know [jutsu_name]!"
                missing_jutsu = TRUE
            
        if(missing_jutsu)
            return

        var/datum/rank/R = new /datum/rank/genin()
        R.apply_rank(P)
        src << "You have promoted [P] to Genin!"
    
    verb/promote_to_chunin()
        set category = "Hokage"
        set name = "Promote to Chunin"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/genin))
                choices += P
        var/player/P = input("Choose a genin to promote") as null|anything in choices
        if(!P) return

        if(!P.passed_chunin)
            usr << "[P] hasn't passed the Chunin exam!"
            return
        if(P.c_rank_missions_completed < 3)
            usr << "[P] hasn't completed enough C-rank missions!"
            return

        var/datum/rank/R = new /datum/rank/chunin()
        R.apply_rank(P)
    
    verb/promote_to_tokubetsu_jonin()
        set category = "Hokage"
        set name = "Promote to Tokubetsu Jonin"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/chunin))
                choices += P
        var/player/P = input("Choose a chunin to promote") as null|anything in choices
        if(!P) return

        if(P.b_rank_missions_completed < 4)
            usr << "[P] hasn't completed enough B-rank missions!"
            return
        if(P.a_rank_missions_completed < 1)
            usr << "[P] hasn't completed enough A-rank missions!"
            return
        if(!P.passed_tokubetsu_jonin)
            usr << "[P] hasn't completed a Tokujō Mission-Chain!"
            return

        var/datum/rank/R = new /datum/rank/tokubetsu_jonin()
        R.apply_rank(P)
    
    verb/promote_to_jonin()
        set category = "Hokage"
        set name = "Promote to Jonin"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/tokubetsu_jonin))
                choices += P
        var/player/P = input("Choose a tokubetsu jonin to promote") as null|anything in choices
        if(!P) return

        if(!P.jonin_mentored)
            usr << "[P] has not mentored a squad!"
            return
        if(P.a_rank_missions_completed < 3)
            usr << "[P] hasn't completed enough A-rank missions!"
            return
        if(!P.passed_tokubetsu_jonin)
            usr << "[P] hasn't completed a Tokujō Mission-Chain!"
            return

        var/datum/rank/R = new /datum/rank/jonin()
        R.apply_rank(P)
    
    verb/promote_to_hancho_jonin()
        set category = "Hokage"
        set name = "Promote to Hancho Jonin"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/jonin))
                choices += P
        var/player/P = input("Choose a jonin to promote") as null|anything in choices
        if(!P) return

        if(P.s_rank_missions_completed < 5)
            usr << "[P] hasn't completed enough S-rank missions!"
            return
        if(!P.passed_hancho)
            usr << "[P] hasn't passed recieved a Hancho recommendation!"
            return

        var/datum/rank/R = new /datum/rank/hancho_jonin()
        R.apply_rank(P)
    
    verb/make_ANBU()
        set category = "Hokage"
        set name = "Make ANBU"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && !istype(P.rank, /datum/rank/genin) && !istype(P.rank, /datum/rank/academy_student) && !istype(P.rank, /datum/rank/civilian))
                var/already_anbu = FALSE
                for(var/datum/sub_rank/SR in P.sub_ranks)
                    if(istype(SR, /datum/sub_rank/anbu))
                        already_anbu = TRUE
                        break
                if(!already_anbu)
                    choices += P
        var/player/P = input("Choose who to invite to ANBU") as null|anything in choices
        if(!P) return
        
        if(P.age < 13)
            usr << "[P] is too young to be an ANBU!"
            return
        if(P.b_rank_missions_completed < 4)
            usr << "[P] hasn't completed enough B-rank missions!"
            return
        if(!P.passed_anbu)
            usr << "[P] has not earned an Anbu Recommendation!"
            return

        var/datum/sub_rank/anbu/A = new()
        A.apply_rank(P)
    
    verb/demote_anbu()
        set category = "Hokage"
        set name = "Demote ANBU"
        var/list/choices = list()
        for(var/player/P in oview(20))
            var/already_anbu = FALSE
            for(var/datum/sub_rank/SR in P.sub_ranks)
                if(istype(SR, /datum/sub_rank/anbu))
                    already_anbu = TRUE
                    break
            if(already_anbu)
                choices += P
        var/player/P = input("Choose who to demote from ANBU") as null|anything in choices
        if(!P) return

        var/datum/sub_rank/anbu/A = new()
        A.remove_sub_rank(P)

    verb/make_anbu_buntaicho()
        set category = "Hokage"
        set name = "Make Anbu Buntaicho"
        var/list/choices = list()
        for(var/player/P in oview(20))
            var/already_buntaicho = FALSE
            var/already_anbu = FALSE
            for(var/datum/sub_rank/SR in P.sub_ranks)
                if(istype(SR, /datum/sub_rank/anbu_buntaicho))
                    already_buntaicho = TRUE
                    break
                if(istype(SR, /datum/sub_rank/anbu))
                    already_anbu = TRUE
            if(already_buntaicho)
                continue
            else if(already_anbu)  
                choices += P
        
        var/player/P = input("Select a ninja to make an Anbu Buntaicho") as null|anything in choices
        if(!P) return

        var/datum/sub_rank/anbu_buntaicho/AB = new()
        AB.apply_rank(P)
    
    verb/demote_anbu_buntaicho()
        set category = "Hokage"
        set name = "Demote Anbu Buntaicho"
        var/list/choices = list()
        for(var/player/P in oview(20))
            var/already_buntaicho = FALSE
            for(var/datum/sub_rank/SR in P.sub_ranks)
                if(istype(SR, /datum/sub_rank/anbu_buntaicho))
                    already_buntaicho = TRUE
                    break
            if(already_buntaicho)
                choices += P
        var/player/P = input("Select a ninja to demote from Anbu Buntaicho") as null|anything in choices
        if(!P) return

        var/datum/sub_rank/anbu_buntaicho/AB = new()
        AB.remove_sub_rank(P)

    verb/make_council_member()
        set category = "Hokage"
        set name = "Make Council Member"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && !istype(P.rank, /datum/rank/genin) && !istype(P.rank, /datum/rank/academy_student) && !istype(P.rank, /datum/rank/civilian))
                var/already_cm = FALSE
                for(var/datum/sub_rank/SR in P.sub_ranks)
                    if(istype(SR, /datum/sub_rank/council_member))
                        already_cm = TRUE
                        break
                if(!already_cm)
                    choices += P
        var/player/P = input("Select a ninja to make a council member") as null|anything in choices
        if(!P) return
        
        if(P.age < 18)
            usr << "[P] is too young to be a council member!"
            return

        var/datum/sub_rank/council_member/C = new()
        C.apply_rank(P)
    
    verb/remove_council_member()
        set category = "Hokage"
        set name = "Remove Council Member"
        var/list/choices = list()
        for(var/player/P in oview(20))
            var/already_cm = FALSE
            for(var/datum/sub_rank/SR in P.sub_ranks)
                if(istype(SR, /datum/sub_rank/council_member))
                    already_cm = TRUE
                    break
            if(already_cm)
                choices += P
        var/player/P = input("Choose who to remove as a council member") as null|anything in choices
        if(!P) return

        var/datum/sub_rank/council_member/C = new()
        C.remove_sub_rank(P)

    verb/exile(player/P as mob in usr.village.players)
        set category = "Hokage"
        set name = "Exile"
        if(!P)
            return
        if(P == usr)
            usr << "You cannot exile yourself!"
            return
        var/datum/village/V = P.village
        V.remove_player(P)
        usr << "You have exiled [P]!"
    
    verb/assign_official_team()
        set category = "Hokage"
        set name = "Assign Official Team"

/datum/rank/mizukage
    New()
        ..("Mizukage", 300)
        preserves_old_cap = TRUE
        rank_verbs = list(
            /datum/rank/mizukage/verb/declare_war,
            /datum/rank/mizukage/verb/make_announcement,
            /datum/rank/mizukage/verb/exile,
            /datum/rank/mizukage/verb/make_council_member,
            /datum/rank/mizukage/verb/promote_to_academy_student,
            /datum/rank/mizukage/verb/promote_to_genin,
            /datum/rank/mizukage/verb/promote_to_chunin,
            /datum/rank/mizukage/verb/promote_to_tokubetsu_jonin,
            /datum/rank/mizukage/verb/promote_to_jonin,
            /datum/rank/mizukage/verb/promote_to_hancho_jonin,
            /datum/rank/mizukage/verb/make_hunter_nin,
            /datum/rank/mizukage/verb/demote_hunter_nin,
            /datum/rank/mizukage/verb/remove_council_member,
            /datum/rank/mizukage/verb/make_hunter_taicho,
            /datum/rank/mizukage/verb/demote_hunter_taicho,
            /datum/rank/mizukage/verb/make_ssm,
            /datum/rank/mizukage/verb/demote_ssm,
            /datum/rank/mizukage/verb/assign_official_team
        )

    verb/declare_war()
        set category = "Mizukage"
        set name = "Declare War"
        usr << "You have declared war!"

    verb/make_announcement(msg as text)
        set category = "Mizukage"
        set name = "Make Village Announcement"
        for(var/player/P in usr.village.players)
            P << "[msg]"
    
    verb/promote_to_academy_student()
        set category = "Mizukage"
        set name = "Promote to Academy Student"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/civilian))
                choices += P
        var/player/P = input("Choose a civilian to promote") as null|anything in choices
        if(!P) return
        var/datum/rank/R = new /datum/rank/academy_student()
        R.apply_rank(P)

    verb/promote_to_genin()
        set category = "Mizukage"
        set name = "Promote to Genin"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/academy_student))
                choices += P
        var/player/P = input("Choose an academy student to promote") as null|anything in choices
        if(!P) return

        var/list/required_jutsu = list(
            "Bunshin no Jutsu",
            "Henge no Jutsu",
            "Kawarimi no Jutsu"
        )
        
        var/missing_jutsu = FALSE
        for(var/jutsu_name in required_jutsu)
            var/has_jutsu = FALSE
            for(var/obj/jutsu/J in P.jutsu_list)
                if(J.name == jutsu_name)
                    has_jutsu = TRUE
                    break
            if(!has_jutsu)
                usr << "[P] doesn't know [jutsu_name]!"
                missing_jutsu = TRUE
            
        if(missing_jutsu)
            return

        var/datum/rank/R = new /datum/rank/genin()
        R.apply_rank(P)
        src << "You have promoted [P] to Genin!"
    
    verb/promote_to_chunin()
        set category = "Mizukage"
        set name = "Promote to Chunin"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/genin))
                choices += P
        var/player/P = input("Choose a genin to promote") as null|anything in choices
        if(!P) return

        if(!P.passed_chunin)
            usr << "[P] hasn't passed the Chunin exam!"
            return
        if(P.c_rank_missions_completed < 3)
            usr << "[P] hasn't completed enough C-rank missions!"
            return

        var/datum/rank/R = new /datum/rank/chunin()
        R.apply_rank(P)
    
    verb/promote_to_tokubetsu_jonin()
        set category = "Mizukage"
        set name = "Promote to Tokubetsu Jonin"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/chunin))
                choices += P
        var/player/P = input("Choose a chunin to promote") as null|anything in choices
        if(!P) return

        if(P.b_rank_missions_completed < 4)
            usr << "[P] hasn't completed enough B-rank missions!"
            return
        if(P.a_rank_missions_completed < 1)
            usr << "[P] hasn't completed enough A-rank missions!"
            return
        if(!P.passed_tokubetsu_jonin)
            usr << "[P] hasn't completed a Tokujō Mission-Chain!"
            return

        var/datum/rank/R = new /datum/rank/tokubetsu_jonin()
        R.apply_rank(P)
    
    verb/promote_to_jonin()
        set category = "Mizukage"
        set name = "Promote to Jonin"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/tokubetsu_jonin))
                choices += P
        var/player/P = input("Choose a tokubetsu jonin to promote") as null|anything in choices
        if(!P) return

        if(!P.jonin_mentored)
            usr << "[P] has not mentored a squad!"
            return
        if(P.a_rank_missions_completed < 3)
            usr << "[P] hasn't completed enough A-rank missions!"
            return
        if(!P.passed_tokubetsu_jonin)
            usr << "[P] hasn't completed a Tokujō Mission-Chain!"
            return

        var/datum/rank/R = new /datum/rank/jonin()
        R.apply_rank(P)
    
    verb/promote_to_hancho_jonin()
        set category = "Mizukage"
        set name = "Promote to Hancho Jonin"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && istype(P.rank, /datum/rank/jonin))
                choices += P
        var/player/P = input("Choose a jonin to promote") as null|anything in choices
        if(!P) return

        if(P.s_rank_missions_completed < 5)
            usr << "[P] hasn't completed enough S-rank missions!"
            return
        if(!P.passed_hancho)
            usr << "[P] hasn't passed recieved a Hancho recommendation!"
            return

        var/datum/rank/R = new /datum/rank/hancho_jonin()
        R.apply_rank(P)
    
    verb/make_hunter_nin()
        set category = "Mizukage"
        set name = "Make Hunter-Nin"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && !istype(P.rank, /datum/rank/genin) && !istype(P.rank, /datum/rank/academy_student) && !istype(P.rank, /datum/rank/civilian))
                var/already_hunter = FALSE
                for(var/datum/sub_rank/SR in P.sub_ranks)
                    if(istype(SR, /datum/sub_rank/hunter_nin))
                        already_hunter = TRUE
                        break
                if(!already_hunter)
                    choices += P
        var/player/P = input("Choose who to invite to Hunter-Nin") as null|anything in choices
        if(!P) return
        
        if(P.age < 13)
            usr << "[P] is too young to be a Hunter-Nin!"
            return
        if(P.b_rank_missions_completed < 4)
            usr << "[P] hasn't completed enough B-rank missions!"
            return
        if(!P.passed_anbu)
            usr << "[P] has not earned a Hunter-Nin Recommendation!"
            return

        var/datum/sub_rank/hunter_nin/HN = new()
        HN.apply_rank(P)
    
    verb/demote_hunter_nin()
        set category = "Mizukage"
        set name = "Demote Hunter-Nin"
        var/list/choices = list()
        for(var/player/P in oview(20))
            var/already_hunter = FALSE
            for(var/datum/sub_rank/SR in P.sub_ranks)
                if(istype(SR, /datum/sub_rank/hunter_nin))
                    already_hunter = TRUE
                    break
            if(already_hunter)
                choices += P
        var/player/P = input("Choose who to demote from Hunter-Nin") as null|anything in choices
        if(!P) return

        var/datum/sub_rank/hunter_nin/HN = new()
        HN.remove_sub_rank(P)

    verb/make_hunter_taicho()
        set category = "Mizukage"
        set name = "Make Hunter Taicho"
        var/list/choices = list()
        for(var/player/P in oview(20))
            var/already_taicho = FALSE
            var/already_hunter = FALSE
            for(var/datum/sub_rank/SR in P.sub_ranks)
                if(istype(SR, /datum/sub_rank/hunter_taicho))
                    already_taicho = TRUE
                    break
                if(istype(SR, /datum/sub_rank/hunter_nin))
                    already_hunter = TRUE
            if(already_taicho)
                continue
            else if(already_hunter)  
                choices += P
        
        var/player/P = input("Select a ninja to make a Hunter Taicho") as null|anything in choices
        if(!P) return

        var/datum/sub_rank/hunter_taicho/HT = new()
        HT.apply_rank(P)
    
    verb/demote_hunter_taicho()
        set category = "Mizukage"
        set name = "Demote Hunter Taicho"
        var/list/choices = list()
        for(var/player/P in oview(20))
            var/already_taicho = FALSE
            for(var/datum/sub_rank/SR in P.sub_ranks)
                if(istype(SR, /datum/sub_rank/hunter_taicho))
                    already_taicho = TRUE
                    break
            if(already_taicho)
                choices += P
        var/player/P = input("Select a ninja to demote from Hunter Taicho") as null|anything in choices
        if(!P) return

        var/datum/sub_rank/hunter_taicho/HT = new()
        HT.remove_sub_rank(P)
    
    verb/make_ssm()
        set category = "Mizukage"
        set name = "Make SSM"
        var/list/choices = list()
        for(var/player/P in oview(20))
            var/already_ssm = FALSE
            for(var/datum/sub_rank/SR in P.sub_ranks)
                if(istype(SR, /datum/sub_rank/ssm))
                    already_ssm = TRUE
                    break
            if(P.village == usr.village && !already_ssm)
                choices += P
        var/player/P = input("Select a ninja to make a Seven Swordsmen Of The Mist") as null|anything in choices
        if(!P) return

        var/datum/sub_rank/ssm/SSM = new()
        SSM.apply_rank(P)
    
    verb/demote_ssm()
        set category = "Mizukage"
        set name = "Demote SSM"
        var/list/choices = list()
        for(var/player/P in oview(20))
            var/already_ssm = FALSE
            for(var/datum/sub_rank/SR in P.sub_ranks)
                if(istype(SR, /datum/sub_rank/ssm))
                    already_ssm = TRUE
                    break
            if(already_ssm)
                choices += P
        var/player/P = input("Select a ninja to demote from SSM") as null|anything in choices
        if(!P) return

        var/datum/sub_rank/ssm/SSM = new()
        SSM.remove_sub_rank(P)

    verb/make_council_member()
        set category = "Mizukage"
        set name = "Make Council Member"
        var/list/choices = list()
        for(var/player/P in oview(20))
            if(P.village == usr.village && !istype(P.rank, /datum/rank/genin) && !istype(P.rank, /datum/rank/academy_student) && !istype(P.rank, /datum/rank/civilian))
                var/already_cm = FALSE
                for(var/datum/sub_rank/SR in P.sub_ranks)
                    if(istype(SR, /datum/sub_rank/council_member))
                        already_cm = TRUE
                        break
                if(!already_cm)
                    choices += P
        var/player/P = input("Select a ninja to make a council member") as null|anything in choices
        if(!P) return
        
        if(P.age < 18)
            usr << "[P] is too young to be a council member!"
            return

        var/datum/sub_rank/council_member/C = new()
        C.apply_rank(P)
    
    verb/remove_council_member()
        set category = "Mizukage"
        set name = "Remove Council Member"
        var/list/choices = list()
        for(var/player/P in oview(20))
            var/already_cm = FALSE
            for(var/datum/sub_rank/SR in P.sub_ranks)
                if(istype(SR, /datum/sub_rank/council_member))
                    already_cm = TRUE
                    break
            if(already_cm)
                choices += P
        var/player/P = input("Choose who to remove as a council member") as null|anything in choices
        if(!P) return

        var/datum/sub_rank/council_member/C = new()
        C.remove_sub_rank(P)

    verb/exile(player/P as mob in usr.village.players)
        set category = "Mizukage"
        set name = "Exile"
        if(!P)
            return
        if(P == usr)
            usr << "You cannot exile yourself!"
            return
        var/datum/village/V = P.village
        V.remove_player(P)
        usr << "You have exiled [P]!"

    verb/assign_official_team()
        set category = "Mizukage"
        set name = "Assign Official Team"

/datum/sub_rank
    var
        rank_name
        list/sub_rank_verbs = list()
    
    New(sub_rank_name)
        rank_name = sub_rank_name

    proc/apply_rank(mob/M)
        if(!M) return
        if(!(src in M.sub_ranks))
            M.sub_ranks += src
            M.verbs += sub_rank_verbs
            M << "You have been made an [rank_name]!"
    
    proc/remove_sub_rank(mob/M)
        if(!M) return
        for(var/datum/sub_rank/SR in M.sub_ranks)
            if(istype(SR, type))  // Check if it matches our type
                M.sub_ranks -= SR
                M.verbs -= SR.sub_rank_verbs
                M << "You have been removed from the position of [SR.rank_name]."
                del(SR)
                break

/datum/sub_rank/anbu
    New()
        ..("ANBU")

/datum/sub_rank/anbu_buntaicho
    New()
        ..("Anbu Buntaichō")

/datum/sub_rank/council_member
    New()
        ..("Council Member") 

/datum/sub_rank/hokage_secretary
    New()
        ..("Hokage Secretary")
        sub_rank_verbs = list(
            /datum/rank/hokage/verb/make_announcement,
            /datum/rank/hokage/verb/promote_to_academy_student,
            /datum/rank/hokage/verb/promote_to_genin,
            /datum/rank/hokage/verb/promote_to_chunin
        )
    
/datum/sub_rank/mizukage_secretary
    New()
        ..("Mizukage Secretary")
        sub_rank_verbs = list(
            /datum/rank/mizukage/verb/make_announcement,
            /datum/rank/mizukage/verb/promote_to_academy_student,
            /datum/rank/mizukage/verb/promote_to_genin,
            /datum/rank/mizukage/verb/promote_to_chunin
        )

/datum/sub_rank/hunter_nin
    New()
        ..("Hunter-Nin")

/datum/sub_rank/hunter_taicho
    New()
        ..("Hunter Buntaichō")

/datum/sub_rank/ssm
    New()
        ..("Seven Swordsmen Of The Mist")