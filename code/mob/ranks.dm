/datum/ruling
    var/text
    var/author
    var/date
    var/last_editor
    var/last_edited

    New(new_text, new_author)
        text = new_text
        author = new_author
        date = time2text(world.realtime, "DD-MM-YYYY")
        last_editor = author
        last_edited = date

/datum/rank
    var
        rank_name
        sp_cap
        list/rank_verbs = list()
        list/tasks = list()
        list/requirements = list()
        preserves_old_cap = FALSE
        power_level = 0
        criminal_grade = ""

    New(name, cap, power_level, criminal_grade = "")
        rank_name = name
        sp_cap = cap
        src.power_level = power_level
        src.criminal_grade = criminal_grade

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
            if(criminal_grade && criminal_grade != "")
                M << "You are now a [criminal_grade]-Rank Criminal!"
            else
                M << "You are now a criminal!"
        else
            M << "You have been promoted to [rank_name]!"

// Shared verbs — defined once, added to rank_verbs as needed.
/datum/rank/verb/promote_to_academy_student()
    set category = "Rank"
    set name = "Promote to Academy Student"
    var/list/choices = list()
    for(var/player/P in oview(20))
        if(P.village == usr.village && istype(P.rank, /datum/rank/civilian))
            choices += P
    var/player/P = input("Choose a civilian to promote") as null|anything in choices
    if(!P) return
    var/datum/rank/R = new /datum/rank/academy_student()
    R.apply_rank(P)

/datum/rank/verb/promote_to_genin()
    set category = "Rank"
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

/datum/rank/verb/promote_to_chunin()
    set category = "Rank"
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

/datum/rank/verb/promote_to_tokubetsu_jonin()
    set category = "Rank"
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

/datum/rank/verb/promote_to_jonin()
    set category = "Rank"
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

/datum/rank/verb/promote_to_hancho_jonin()
    set category = "Rank"
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

/datum/rank/verb/declare_war()
    set category = "Leader"
    set name = "Declare War"
    usr << "You have declared war!"

/datum/rank/verb/make_announcement(msg as text)
    set category = "Leader"
    set name = "Make Village Announcement"
    for(var/player/P in usr.village.players)
        P << "[msg]"

/datum/rank/verb/exile(player/P as mob in usr.village.players)
    set category = "Leader"
    set name = "Exile"

    if(!P)
        return
    if(P == usr)
        usr << "You cannot exile yourself!"
        return

    if(make_missing_ninja(P))
        usr << "You have exiled [P]! They are now a [P.rank.criminal_grade]-Grade Criminal!"
    else
        usr << "Failed to exile [P]."

/datum/rank/verb/make_council_member()
    set category = "Leader"
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

/datum/rank/verb/remove_council_member()
    set category = "Leader"
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

/datum/rank/verb/assign_official_team()
    set category = "Leader"
    set name = "Assign Official Team"

// ──────────────────────────────────────────────
// Rank definitions — New() composes rank_verbs with +=
// ──────────────────────────────────────────────

/datum/rank/civilian
    New()
        ..("Civilian", 45, 0)

/datum/rank/missing
    New()
        ..("Missing", 0, 0)

    proc/get_criminal_rank(mob/M)
        if(!M) return new /datum/rank/missing/d_rank()

        var/total_spent = M.get_total_points_spent()

        if(total_spent <= 115)
            return new /datum/rank/missing/d_rank()
        else if(total_spent <= 150)
            return new /datum/rank/missing/c_rank()
        else if(total_spent <= 185)
            return new /datum/rank/missing/b_rank()
        else if(total_spent <= 220)
            return new /datum/rank/missing/a_rank()
        else
            return new /datum/rank/missing/s_rank()

/datum/rank/missing/d_rank
    New()
        ..("Missing", 115, 2)
        criminal_grade = "D"

/datum/rank/missing/c_rank
    New()
        ..("Missing", 150, 3, "C")
        criminal_grade = "C"

/datum/rank/missing/b_rank
    New()
        ..("Missing", 185, 4, "B")
        criminal_grade = "B"

/datum/rank/missing/a_rank
    New()
        ..("Missing", 220, 5, "A")
        criminal_grade = "A"

/datum/rank/missing/s_rank
    New()
        ..("Missing", 280, 7, "S")
        criminal_grade = "S"

/datum/rank/academy_student
    New()
        ..("Academy Student", 80, 1)

/datum/rank/genin
    New()
        ..("Genin", 115, 2)

/datum/rank/chunin
    New()
        ..("Chunin", 150, 3)
        rank_verbs += /datum/rank/verb/promote_to_academy_student

/datum/rank/tokubetsu_jonin
    New()
        ..("Tokubetsu Jonin", 185, 4)
        rank_verbs += /datum/rank/verb/promote_to_academy_student

/datum/rank/jonin
    New()
        ..("Jonin", 220, 5)
        rank_verbs += /datum/rank/verb/promote_to_academy_student
        rank_verbs += /datum/rank/verb/promote_to_genin

/datum/rank/hancho_jonin
    New()
        ..("Jōnin Hanchō", 250, 6)
        rank_verbs += /datum/rank/verb/promote_to_academy_student
        rank_verbs += /datum/rank/verb/promote_to_genin

/datum/rank/sannin
    New()
        ..("Sannin", 280, 7)
        rank_verbs += /datum/rank/verb/promote_to_academy_student
        rank_verbs += /datum/rank/verb/promote_to_genin

/datum/rank/hokage
    New()
        ..("Hokage", 0, 8)
        preserves_old_cap = TRUE
        rank_verbs += /datum/rank/verb/declare_war
        rank_verbs += /datum/rank/verb/make_announcement
        rank_verbs += /datum/rank/verb/exile
        rank_verbs += /datum/rank/verb/make_council_member
        rank_verbs += /datum/rank/verb/remove_council_member
        rank_verbs += /datum/rank/verb/promote_to_academy_student
        rank_verbs += /datum/rank/verb/promote_to_genin
        rank_verbs += /datum/rank/verb/promote_to_chunin
        rank_verbs += /datum/rank/verb/promote_to_tokubetsu_jonin
        rank_verbs += /datum/rank/verb/promote_to_jonin
        rank_verbs += /datum/rank/verb/promote_to_hancho_jonin
        rank_verbs += /datum/rank/hokage/verb/make_ANBU
        rank_verbs += /datum/rank/hokage/verb/demote_anbu
        rank_verbs += /datum/rank/hokage/verb/make_anbu_buntaicho
        rank_verbs += /datum/rank/hokage/verb/demote_anbu_buntaicho
        rank_verbs += /datum/rank/verb/assign_official_team

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

/datum/rank/mizukage
    New()
        ..("Mizukage", 300, 8)
        preserves_old_cap = TRUE
        rank_verbs += /datum/rank/verb/declare_war
        rank_verbs += /datum/rank/verb/make_announcement
        rank_verbs += /datum/rank/verb/exile
        rank_verbs += /datum/rank/verb/make_council_member
        rank_verbs += /datum/rank/verb/remove_council_member
        rank_verbs += /datum/rank/verb/promote_to_academy_student
        rank_verbs += /datum/rank/verb/promote_to_genin
        rank_verbs += /datum/rank/verb/promote_to_chunin
        rank_verbs += /datum/rank/verb/promote_to_tokubetsu_jonin
        rank_verbs += /datum/rank/verb/promote_to_jonin
        rank_verbs += /datum/rank/verb/promote_to_hancho_jonin
        rank_verbs += /datum/rank/mizukage/verb/make_hunter_nin
        rank_verbs += /datum/rank/mizukage/verb/demote_hunter_nin
        rank_verbs += /datum/rank/mizukage/verb/make_hunter_taicho
        rank_verbs += /datum/rank/mizukage/verb/demote_hunter_taicho
        rank_verbs += /datum/rank/mizukage/verb/make_ssm
        rank_verbs += /datum/rank/mizukage/verb/demote_ssm
        rank_verbs += /datum/rank/verb/assign_official_team

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
            if(istype(SR, type))
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
        sub_rank_verbs += /datum/rank/verb/make_announcement
        sub_rank_verbs += /datum/rank/verb/promote_to_academy_student
        sub_rank_verbs += /datum/rank/verb/promote_to_genin
        sub_rank_verbs += /datum/rank/verb/promote_to_chunin

/datum/sub_rank/mizukage_secretary
    New()
        ..("Mizukage Secretary")
        sub_rank_verbs += /datum/rank/verb/make_announcement
        sub_rank_verbs += /datum/rank/verb/promote_to_academy_student
        sub_rank_verbs += /datum/rank/verb/promote_to_genin
        sub_rank_verbs += /datum/rank/verb/promote_to_chunin

/datum/sub_rank/hunter_nin
    New()
        ..("Hunter-Nin")

/datum/sub_rank/hunter_taicho
    New()
        ..("Hunter Buntaichō")

/datum/sub_rank/ssm
    New()
        ..("Seven Swordsmen Of The Mist")
