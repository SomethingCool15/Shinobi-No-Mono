// Define the base Item class
/obj/item
    var
        description = ""
        slot_size = 1
        can_be_stored_in_kit = TRUE
        wearing = FALSE
        kit_number = 0
        tmp/datum/databook_page/databook_page
        equippable = FALSE
        tmp/is_double_clicking = FALSE

    Topic(href, href_list)
        if(href_list["item"])
            usr << browse(databook_page.content, "window=databook;size=600x400;can_close=1;can_resize=0;border=0;is-naked=1")

    New()
        ..()
        update_databook_page()

    proc/update_databook_page()
        if(GLOBAL_ITEM_MANAGER.item_databook_pages[type])
            var/page_id = GLOBAL_ITEM_MANAGER.item_databook_pages[type]
            databook_page = GLOBAL_DATABOOK.pages[page_id]

    Click()
        spawn(3)
            if(!is_double_clicking)
                if(equippable)
                    if(!wearing)
                        wearing = TRUE
                        suffix = "Worn"
                        usr.overlays += icon
                        on_equip()
                    else
                        wearing = FALSE
                        suffix = null
                        usr.overlays -= icon
                        on_unequip()
        return ..()

    DblClick()
        is_double_clicking = TRUE
        if(usr && usr.client)
            if(databook_page)
                get_brandish_message()
            else
                usr << "You examine the [name]."
        spawn(3)
            is_double_clicking = FALSE

    proc/get_brandish_message()
        usr << "[usr] brandishes their <a href='?src=\ref[src];item=[name]'>[name]</a>!"

    proc/Use()
        usr << "You use the [name]."

    verb/PickUp()
        set src in oview(1)
        set category = "Commands"
            
        if(usr.AddToInventory(src))
            usr << "You picked up [name]."
        else
            usr << "Not enough space in your inventory for [name]."
        
    verb/Drop()
        set src in usr
        set category = "Commands"
        if(!(src in usr.inventory))
            return
                
        src.loc = get_step(usr, usr.dir)
        usr.inventory -= src
        usr << "You dropped [name]."
        
    proc/Examine()
        set src in oview(1)
        set src in usr
        set name = "Examine"

        if(databook_page)
            usr << "You glance at your <a href='?src=\ref[src];item=[name]'>[name]</a>."
        else
            usr << "You glance at [name]."
        
    proc/check_if_equipped()
        return FALSE

    proc/get_display_name()
        if(src in usr.worn_items)
            return "[name] (equipped)"
        return name

    MouseDrop(over_object, src_location, over_location)
        // Move to Shinobi kit when added over_locatoin == "Shinobi Kit"
        if(src_location == "Inventory" && over_location == "Inventory" && src in usr.inventory)
            if(get_dist(usr, src) <= 1)
                if(!can_be_stored_in_kit)
                    usr << "[name] cannot be stored in the shinobi kit."
                    return
                if(usr.shinobi_kit.len >= usr.shinobi_kit_max_slots)
                    usr << "Not enough space in your shinobi kit."
                    return
                usr.inventory -= src
                usr.shinobi_kit += src
                usr << "[name] has been added to your shinobi kit."
        
        // Move to Inventory when added over_location == "Inventory"
        else if(src_location == "Inventory" && over_location == "Inventory" && src in usr.shinobi_kit)
            if(get_dist(usr, src) <= 1)
                if(usr.inventory.len >= usr.inventory_max_slots)
                    usr << "Not enough space in your inventory."
                    return
                usr.shinobi_kit -= src
                usr.inventory += src
                usr << "[name] has been moved to your inventory."

    proc/on_equip()
        return

    proc/on_unequip()
        return

/obj/item/clothing
    description = "Base clothing type"
    can_be_stored_in_kit = FALSE
    wearing = FALSE
    equippable = TRUE
    layer = MOB_LAYER + 1

/obj/item/clothing/headband
    name = "Headband"
    description = "A symbol of village allegiance."
    icon = 'icons/clothing/headband.dmi'
    equippable = TRUE
    can_be_stored_in_kit = FALSE
    var/village_icon_states = list(
        "Kirigakure no Sato" = "KirigakureInv",
        "Konohagakure no Sato" = "KonohagakureInv",
        "Sunagakure no Sato" = "SunagakureInv",
        "Kumogakure no Sato" = "KumogakureInv",
        "Iwagakure no Sato" = "IwagakureInv"
    )

    var/missing_village_icon_states = list(
        "Konohagakure no Sato" = "MissingKonohagakureInv",
        "Kirigakure no Sato" = "MissingKirigakureInv",
        "Sunagakure no Sato" = "MissingSunagakureInv",
        "Kumogakure no Sato" = "MissingKumogakureInv",
        "Iwagakure no Sato" = "MissingIwagakureInv"
    )

    New()
        ..()
        if(loc && ismob(loc))
            var/mob/M = loc
            var/village_name = "[M.village]"
            if(village_name && village_icon_states[village_name])
                icon_state = village_icon_states[village_name]
    
    verb/abandon_village()
        set category = "Commands"
        if(!usr.village || usr.village.name == "Missing")
            usr << "You are not part of any village!"
            return
            
        // Store reference to the missing village
        var/datum/village/missing_village
        for(var/datum/village/V in GLOBAL_VILLAGE_MANAGER.villages)
            if(V.name == "Missing")
                missing_village = V
                break
        
        if(!missing_village)
            usr << "Error: Missing village not found!"
            return
            
        // Store old village name for headband
        var/old_village_name = usr.village.name
        usr << "Debug: Old village name: [old_village_name]"
        usr << "Debug: Available missing states: [missing_village_icon_states]"
        
        // Remove from current village and add to missing
        var/datum/village/old_village = usr.village
        old_village.remove_player(usr)
        missing_village.add_player(usr)
        
        // Set missing rank
        if(usr.rank)
            usr.verbs -= usr.rank.rank_verbs
            usr.rank = null
        var/datum/rank/missing/M = new()
        M.apply_rank(usr)
        
        // Update headband icon using the missing_village_icon_states mapping
        if(missing_village_icon_states[old_village_name])
            usr << "Debug: Found matching icon state: [missing_village_icon_states[old_village_name]]"
            icon_state = missing_village_icon_states[old_village_name]
        else
            usr << "Debug: No matching icon state found for [old_village_name]"
        
        usr << "Current icon_state: [icon_state]"
        usr << "You have abandoned your village and become a missing ninja!"

/obj/item/clothing/shirt
    name = "Shirt"
    description = "A basic shirt."
    icon = 'icons/Clothing/1st Hokage.dmi'
    icon_state = ""

/obj/item/throwing_weapon
    description = "Base weapon type"
    slot_size = 1
    icon = 'icons/base/Base_Black.dmi'
    icon_state = ""
    can_be_stored_in_kit = TRUE

/obj/item/throwing_weapon/shuriken
    name = "Shuriken"
    slot_size = 1
    icon = 'icons/base/Base_Black.dmi'
    icon_state = ""
    can_be_stored_in_kit = TRUE

/obj/item/throwing_weapon/kunai
    name = "Kunai"
    slot_size = 1
    icon = 'icons/base/Base_Tan.dmi'
    icon_state = ""
    can_be_stored_in_kit = TRUE

/obj/item/throwing_weapon/windmill_shuriken
    name = "Windmill Shuriken"
    slot_size = 1
    icon = 'icons/base/Base_Tan.dmi'
    icon_state = ""
    can_be_stored_in_kit = TRUE

/obj/item/melee_weapons
    description = "Base melee weapon type"
    can_be_stored_in_kit = FALSE
    equippable = TRUE
    layer = MOB_LAYER + 1

/obj/item/melee_weapons/katana
    name = "Katana"
    icon = 'icons/weapons/katana_sheathed.dmi'
    icon_state = "Inv"
    var/unsheathed = TRUE

    verb/Unsheathe()
        if(unsheathed)
            icon = 'icons/weapons/katana(atk).dmi'
            usr.overlays += icon
            unsheathed = FALSE
        else
            icon = 'icons/weapons/katana(atk).dmi'
            usr.overlays -= icon
            unsheathed = TRUE

/obj/item/melee_weapons/samehada
    name = "Samehada"
    icon = ""

    get_brandish_message()
        usr << "[usr] asserts control over the voracious/insatiable leviathan. Feast, <a href='?src=\ref[src];item=[name]'>[name]</a>!"

/obj/item/melee_weapons/kubikiri
    name = "Kubikiribōchō"

    get_brandish_message()
        usr << "[usr] relishes in their role as executioner, wielding the legendary <a href='?src=\ref[src];item=[name]'>[name]</a>!"

/obj/item/melee_weapons/kabutowari
    name = "Kabutowari"
    
    DblClick()
        if(usr && usr.client)
            if(databook_page)
                usr << "[usr] takes control of the protective armor, <a href='?src=\ref[src];item=[name]'>[name]</a>!"
            else
                usr << "You examine the [name]."
                
/obj/item/melee_weapons/nuibari
    name = "Nuibari"

    DblClick()
        if(usr && usr.client)
            if(databook_page)
                usr << "[usr] flourishes the infamous sewing needle, <a href='?src=\ref[src];item=[name]'>[name]</a>!"
            else
                usr << "You examine the [name]."

/obj/item/melee_weapons/hiramekarei
    name = "Hiramekarei"

    DblClick()
        if(usr && usr.client)
            if(databook_page)
                usr << "[usr] channels forth their chakra, awakening the twinsword, <a href='?src=\ref[src];item=[name]'>[name]</a>!"
            else
                usr << "You examine the [name]."

/obj/item/melee_weapons/kiba
    name = "Kiba"

    DblClick()
        if(usr && usr.client)
            if(databook_page)
                usr << "[usr] brings the storm through their twin fangs, <a href='?src=\ref[src];item=[name]'>[name]</a>!"
            else
                usr << "You examine the [name]."
                
/obj/item/melee_weapons/shibuki
    name = "Shibuki"

    DblClick()
        if(usr && usr.client)
            if(databook_page)
                usr << "[usr] forces the world to tremble before the blastsword <a href='?src=\ref[src];item=[name]'>[name]</a>!"
            else
                usr << "You examine the [name]."

/obj/item/melee_weapons/uchiha_gunbai
    name = "Gunbai Uchiwa"
    
    DblClick()
        if(usr && usr.client)
            if(databook_page)
                usr << "[usr] wields the infamous <a href='?src=\ref[src];item=[name]'>[name]</a>, fanning the flames of destiny!"
            else
                usr << "You examine the [name]."

/obj/item/combat_clothing
    name = "Combat Clothing"
    description = "A protective clothing."
    slot_size = 1
    icon_state = ""
    can_be_stored_in_kit = TRUE
    kit_number = 1
    wearing = FALSE

    Click()
        if(!wearing)
            if(check_if_wearing())
                return
            increase_shinobi_kit(kit_number)
        else
            decrease_shinobi_kit(kit_number)

    proc/increase_shinobi_kit(number)
        wearing = TRUE
        usr.shinobi_kit_max_slots += number
        usr << "You increase the size of your shinobi kit."
    
    proc/decrease_shinobi_kit(number)
        var/remainder = usr.shinobi_kit_max_slots - number
        if(remainder < usr.shinobi_kit.len)
            usr << "Your shinobi kit cannot be decreased any further."
            return
        else
            wearing = FALSE
            usr.shinobi_kit_max_slots -= number
            usr << "You decrease the size of your shinobi kit."

    proc/check_if_wearing()
        for(var/obj/item/combat_clothing/C in usr.inventory)
            if(C.wearing)
                usr << "You are already wearing a [C.name]!"
                return TRUE
        return FALSE

/obj/item/combat_clothing/chunin_vest
    name = "Chunin Vest"
    description = "A protective vest."
    slot_size = 1
    icon = 'icons/base/Base_Tan.dmi'
    icon_state = ""
    can_be_stored_in_kit = TRUE
    kit_number = 1

/obj/item/combat_clothing/anbu_vest
    name = "Anbu Vest"
    description = "A protective vest."
    slot_size = 1
    icon = 'icons/base/Base_Tan.dmi'
    icon_state = ""
    can_be_stored_in_kit = TRUE
    kit_number = 1