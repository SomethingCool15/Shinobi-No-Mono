mob
    var/inventory_max_slots = 30
    var/shinobi_kit_max_slots = 4

    proc/AddToInventory(obj/item/item)
        if ((inventory.len + item.slot_size) <= inventory_max_slots)
            inventory += item
            item.loc = src
            usr << "[item.name] added to inventory."
            return TRUE
        else
            usr << "Not enough space in inventory!"
            return FALSE

    proc/AddToShinobiKit(obj/item/item)
        if ((shinobi_kit.len + item.slot_size) <= shinobi_kit_max_slots)
            shinobi_kit += item
            item.loc = src
            usr << "[item.name] added to shinobi kit."
            return TRUE
        else
            usr << "Not enough space in shinobi kit!"
            return FALSE
    
    proc/RemoveFromShinobiKit(obj/item/item)
        if (item in shinobi_kit)
            shinobi_kit -= item
            item.loc = src
            usr << "[item.name] removed from shinobi kit."
            return TRUE
            

    proc/MoveToShinobiKit(obj/item/item)
        if (item in inventory)
            if (AddToShinobiKit(item))
                inventory -= item
                usr << "[item.name] moved to shinobi kit."
                return TRUE
            else
                usr << "Failed to move [item.name] to shinobi kit."
        else
            usr << "[item.name] is not in your inventory."
        return FALSE
