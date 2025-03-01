// Global manager type definitions
// This file should be included early in the compilation process

// Squad Manager
/datum/squad_manager
    var/list/squads = list()
    var/savefile_path = "data/squads.sav"
    
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
        
    proc/save_squads()
        var/savefile/S = new(savefile_path)
        var/list/saved_squads = list()
        
        for(var/datum/squad/SQ in squads)
            var/list/squad_data = list(
                "squad_name" = SQ.squad_name,
                "squad_composition" = SQ.squad_composition,
                "max_members" = SQ.max_members,
                "is_war_squad" = istype(SQ, /datum/squad/war_squad)
            )
            
            // Save village reference if it exists
            if(SQ.village)
                squad_data["village"] = SQ.village.name
                
            // Save member references
            var/list/member_refs = list()
            for(var/mob/M in SQ.members)
                member_refs += "\ref[M]"
            squad_data["members"] = member_refs
            
            // Save leader reference
            if(SQ.leader)
                squad_data["leader"] = "\ref[SQ.leader]"
                
            saved_squads += list(squad_data)
        
        S["squads"] = saved_squads
        
    proc/load_squads()
        if(!fexists(savefile_path))
            return
            
        var/savefile/S = new(savefile_path)
        var/list/loaded_squads
        S["squads"] >> loaded_squads
        
        for(var/list/squad_data in loaded_squads)
            var/datum/squad/SQ
            
            // Create the appropriate squad type
            if(squad_data["is_war_squad"])
                SQ = new /datum/squad/war_squad()
            else
                SQ = new /datum/squad()
                
            SQ.squad_name = squad_data["squad_name"]
            SQ.squad_composition = squad_data["squad_composition"]
            SQ.max_members = squad_data["max_members"]
            
            // Restore village reference if it exists
            if(squad_data["village"])
                for(var/datum/village/V in GLOBAL_VILLAGE_MANAGER.villages)
                    if(V.name == squad_data["village"])
                        SQ.village = V
                        break
                        
            // Restore member references
            for(var/member_ref in squad_data["members"])
                var/mob/M = locate(member_ref)
                if(M)
                    SQ.members += M
                    M.squad = SQ
                    
            // Restore leader reference
            if(squad_data["leader"])
                var/mob/L = locate(squad_data["leader"])
                if(L && (L in SQ.members))
                    SQ.leader = L
                    
            // Add to global list
            squads += SQ
            
            // Add to village's squad list if associated with a village
            if(SQ.village)
                SQ.village.squads += SQ

// Item Manager (stub - keep the actual implementation in item_manager.dm)
/datum/item_manager
    var/list/item_databook_pages = list()
    var/savefile_path = "data/item_databook.sav"
    
    proc/save_item_databook()
        // Implementation in item_manager.dm
        
    proc/load_item_databook()
        // Implementation in item_manager.dm

// Declare global variables
var/global/datum/village_manager/GLOBAL_VILLAGE_MANAGER
var/global/datum/squad_manager/GLOBAL_SQUAD_MANAGER
var/global/datum/jutsu_manager/GLOBAL_JUTSU_MANAGER
var/global/datum/item_manager/GLOBAL_ITEM_MANAGER
var/global/datum/databook/GLOBAL_DATABOOK 