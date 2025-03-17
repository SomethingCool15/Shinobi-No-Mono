/*
    These are simple defaults for your project.
 */

world
    fps = 25		// 25 frames per second
    icon_size = 32	// 32x32 icon size by default

    view = 6		// show up to 6 tiles outward from center (13x13 view)

    mob = /player

obj
    step_size = 8

var
    list/playerList = list()

/world/New()
    ..()
    // Initialize all global managers in a centralized location
    
    // Village manager
    GLOBAL_VILLAGE_MANAGER = new()
    GLOBAL_VILLAGE_MANAGER.load_villages()
    
    // Squad manager
    GLOBAL_SQUAD_MANAGER = new()
    
    // Jutsu manager
    GLOBAL_JUTSU_MANAGER = new()
    GLOBAL_JUTSU_MANAGER.load_jutsu()
    
    // Item manager
    GLOBAL_ITEM_MANAGER = new()
    GLOBAL_ITEM_MANAGER.load_item_databook()
    
    // Databook manager
    GLOBAL_DATABOOK = new()

    log_debug("World initialization complete.")

// Helper proc for debug logging
proc/log_debug(text)
    world.log << "\[[time2text(world.timeofday, "hh:mm:ss")]\] DEBUG: [text]"