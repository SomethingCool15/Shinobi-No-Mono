// Global manager type definitions
// This file should be included early in the compilation process

// Squad Manager
/datum/squad_manager
    var/list/squads = list()
    
    proc/addSquad(datum/squad/S)
        if(!(S in squads))
            squads += S
            
            // If the squad has a village association, add to village's squad list
            if(S.village)
                S.village.squads += S
    
    proc/removeSquad(datum/squad/S)
        squads -= S
        
        // If associated with a village, remove from village's squad list
        if(S.village)
            S.village.squads -= S
    
    proc/getSquadsByVillage(datum/village/V)
        var/list/village_squads = list()
        for(var/datum/squad/S in squads)
            if(S.village == V)
                village_squads += S
        return village_squads

/datum/item_manager
    var/list/item_databook_pages = list()
    var/savefile_path = "data/item_databook.sav"
    
    proc/save_item_databook()
        var/savefile/S = new(savefile_path)
        var/list/saved_pages = list()
        world << "Saving item databook..."
        for(var/item_type in item_databook_pages)
            saved_pages["[item_type]"] = item_databook_pages[item_type]
        
        S["item_pages"] = saved_pages
        
    proc/load_item_databook()
        if(!fexists(savefile_path))
            log_debug("No save file found for item databook. Initializing default item databook.")
            save_item_databook()
            return
            
        var/savefile/S = new(savefile_path)
        var/list/loaded_pages
        
        S["item_pages"] >> loaded_pages
        if(!loaded_pages)
            return
            
        for(var/type_text in loaded_pages)
            var/item_type = text2path(type_text)
            if(item_type)
                item_databook_pages[item_type] = loaded_pages[type_text]

        log_debug("Loaded [item_databook_pages.len] item databook pages.")
// Declare global variables
var/global/datum/village_manager/GLOBAL_VILLAGE_MANAGER
var/global/datum/squad_manager/GLOBAL_SQUAD_MANAGER
var/global/datum/jutsu_manager/GLOBAL_JUTSU_MANAGER
var/global/datum/item_manager/GLOBAL_ITEM_MANAGER
var/global/datum/databook/GLOBAL_DATABOOK 