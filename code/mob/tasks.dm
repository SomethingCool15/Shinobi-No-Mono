/datum/task
    var
        name
        desc
        pp_reward
        completed = False
    
    proc/can_complete(mob/M)
        return FALSE
    
    proc/complete(mob/M)
        if(can_complete(M))
            completed = TRUE
            return TRUE
        return FALSE

/datum/task/mission_completions
    var
        mission_rank
        amount_needed
        next_task_type

    proc/get_completed_missions(mob/M)
        switch(mission_rank)
            if("C")
                return M.c_rank_missions_completed
            if("B")
                return M.b_rank_missions_completed
            if("A")
                return M.a_rank_missions_completed
            if("S")
                return M.s_rank_missions_completed
        return 0

    can_complete(mob/M)
        return get_completed_missions(M) >= amount_needed

    complete(mob/M)
        if(can_complete(M))
            completed = TRUE
            M.pp += pp_reward
            M << "Congratulations! You have completed [name] and received [pp_reward] PP!"
            // Add the next task in the chain if it exists
            if(next_task_type && M.rank)
                M.tasks += new next_task_type()
            return TRUE
        return FALSE

// C-Rank mission chain
/datum/task/mission_completions/c_rank_10
    name = "C Rank Missions"
    desc = "Complete 10 C-Rank missions"
    mission_rank = "C"
    amount_needed = 10
    pp_reward = 5
    next_task_type = /datum/task/mission_completions/c_rank_25

/datum/task/mission_completions/c_rank_25
    name = "C Rank Missions"
    desc = "Complete 25 C-Rank missions"
    mission_rank = "C"
    amount_needed = 25
    pp_reward = 5
    next_task_type = /datum/task/mission_completions/c_rank_50

/datum/task/mission_completions/c_rank_50
    name = "C Rank Missions"
    desc = "Complete 50 C-Rank missions"
    mission_rank = "C"
    amount_needed = 50
    pp_reward = 5
    next_task_type = /datum/task/mission_completions/c_rank_100

/datum/task/mission_completions/c_rank_100
    name = "C Rank Missions"
    desc = "Complete 100 C-Rank missions"
    mission_rank = "C"
    amount_needed = 100
    pp_reward = 5

// B-Rank mission chain
/datum/task/mission_completions/b_rank_5
    name = "B Rank Missions"
    desc = "Complete 5 B-Rank missions"
    mission_rank = "B"
    amount_needed = 5
    pp_reward = 5
    next_task_type = /datum/task/mission_completions/b_rank_10

/datum/task/mission_completions/b_rank_10
    name = "B Rank Missions"
    desc = "Complete 10 B-Rank missions"
    mission_rank = "B"
    amount_needed = 10
    pp_reward = 5
    next_task_type = /datum/task/mission_completions/b_rank_25

/datum/task/mission_completions/b_rank_25
    name = "B Rank Missions"
    desc = "Complete 25 B-Rank missions"
    mission_rank = "B"
    amount_needed = 25
    pp_reward = 5

/datum/task/mission_completions/a_rank_1
    name = "A Rank Missions"
    desc = "Complete your first A-Rank mission"
    mission_rank = "A"
    amount_needed = 1
    pp_reward = 10

/datum/task/mission_completions/a_rank_3
    name = "A Rank Missions"
    desc = "Complete 3 A-Rank missions"
    mission_rank = "A"
    amount_needed = 3
    pp_reward = 10

/datum/task/capture_rogue
    name = "Capture a Rogue Ninja"
    desc = "Successfully capture a rogue ninja"
    pp_reward = 15
    
    can_complete(mob/M)
        return FALSE

/datum/task/capture_map
    name = "Capture a Map"
    desc = "Successfuly capture territory of an opposing village"
    pp_reward = 5
    
    can_complete(mob/M)
        return FALSE

/datum/task/join_squad
    name = "Join an Official Squad"
    desc = "Become a member of an official ninja squad"
    pp_reward = 5
    
    can_complete(mob/M)
        return M.official_squad.len > 0