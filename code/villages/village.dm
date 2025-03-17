/datum/village_manager
    var
        list/villages = list()
        savefile_path = "data/villages.sav"

    proc/save_villages()
        var/savefile/S = new(savefile_path)
        var/list/saved_villages = list()
        
        for(var/datum/village/V in villages)
            var/list/village_data = list(
                "name" = V.name,
                "economy" = V.economy,
                "clans" = V.clans
            )
            saved_villages += list(village_data)
        
        S["villages"] = saved_villages

    proc/load_villages()
        if(!fexists(savefile_path))
            log_debug("No save file found for villages. Initializing default villages.")
            initialize_default_villages()
            return
            
        var/savefile/S = new(savefile_path)
        var/list/loaded_villages
        S["villages"] >> loaded_villages
        
        for(var/list/village_data in loaded_villages)
            var/datum/village/V = new()
            V.name = village_data["name"]
            V.economy = village_data["economy"]
            V.clans = village_data["clans"]
            villages += V
            
        log_debug("Loaded [villages.len] villages.")

    proc/initialize_default_villages()
        // Only called if no save file exists
        var/datum/village/kono = new()
        kono.name = "Konohagakure no Sato"
        kono.economy = 500000
        villages += kono

        var/datum/village/kiri = new()
        kiri.name = "Kirigakure no Sato"
        kiri.economy = 250000
        villages += kiri
        
        var/datum/village/M = new()
        M.name = "Missing"
        M.economy = 0
        villages += M

        save_villages()

/datum/village
    var
        name
        list/players = list()
        list/clans = list()
        list/squads = list()
        treasury = 15000
        economy
        list/jutsu_library = list()
        tax_rates = list(
            "weapon" = 0.05,
            "clothing" = 0.05,
            "food" = 0.05,
            "medicine" = 0.05,
            "jutsu" = 0.05,
            "missions" = 0.05
        )
        obj/village/location
        enabled = TRUE

    // proc/calculate_tax(obj/item/I)
    //     if(!I(I.category in tax_rates))
    //         return 0
    //     return round(I.price * tax_rates[I.category])

    proc/add_player(mob/player)
        players += player
        player.village = src

    proc/remove_player(mob/player)
        players -= player
        var/old_cap = 0
        if(player.rank)
            old_cap = player.sp_cap
            player.verbs -= player.rank.rank_verbs
            
        for(var/datum/sub_rank/SR in player.sub_ranks)
            player.verbs -= SR.sub_rank_verbs
            player.sub_ranks -= SR
        
        player.village = null  // Just clear the village reference
        player.sp_cap = old_cap

    proc/increase_economy(amount)
        economy += amount

    proc/decrease_economy(amount)
        if(amount > economy)
            return 0
        economy -= amount
        return 1

    // proc/get_clan_count()
    //     return length(clans)

    // proc/add_clan(datum/clan/new_clan)
    //     if(!new_clan || (new_clan in clans))
    //         return 0
    //     clans += new_clan
    //     return 1

    // proc/remove_clan(datum/clan/target_clan)
    //     if(!target_clan || !(target_clan in clans))
    //         return 
    //     clans -= target_clan
    
    // proc/disable_clan(datum/clan/target_clan)
    //     if(!target_clan || !(target_clan in clans))
    //         return
    //     target_clan.disabled = TRUE
        
    // proc/enable_clan(datum/clan/target_clan)
    //     if(!target_clan || !(target_clan in clans))
    //         return
    //     target_clan.disabled = FALSE

    proc/get_population()
        return length(players)

    proc/get_squads()
        return length(squads)

/obj/village
    var
        datum/village/data
    //     list/territory_ranges = list()

    // proc/is_in_territory(turf/T)
    //     for(var/list/range in territory_ranges)
    //         if(T.x >= range["x1"] && T.x <= range["x2"] &&
    //            T.y >= range["y1"] && T.y <= range["y2"])
    //             return TRUE
    //     return FALSE