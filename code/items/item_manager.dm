/owner
    verb
        assign_item_databook()
            set name = "Assign Page to Item"
            set category = "Owner"

            var/list/available_pages = list()
            for(var/page_id in GLOBAL_DATABOOK.pages)
                var/datum/databook_page/P = GLOBAL_DATABOOK.pages[page_id]
                available_pages[P.title] = page_id

            if(!length(available_pages))
                usr << "No databook pages available!"
                return

            var/page_choice = input(usr, "Select databook page to assign:", "Assign Databook") as null|anything in available_pages
            if(!page_choice)
                return

            var/page_id = available_pages[page_choice]

            var/list/item_types = typesof(/obj/item) - list(
                /obj/item,
                /obj/item/combat_clothing,
                /obj/item/melee_weapons,
                /obj/item/throwing_weapon
            )
            var/type_choice = input(usr, "Select item type to assign this page to:", "Assign Databook") as null|anything in item_types
            if(!type_choice)
                return

            var/confirm = alert("This will update ALL existing items of type [type_choice]. Continue?", "Confirm Update", "Yes", "No")
            if(confirm == "No")
                return

            GLOBAL_ITEM_MANAGER.item_databook_pages[type_choice] = page_id
            GLOBAL_ITEM_MANAGER.save_item_databook()

            for(var/obj/item/I in world)
                if(I.type == type_choice)
                    I.databook_page = GLOBAL_DATABOOK.pages[page_id]

            usr << "Assigned databook page '[page_choice]' to all [type_choice] items."

        remove_item_databook()
            set name = "Remove Item Databook"
            set category = "Owner"

            var/list/items_with_pages = list()
            for(var/item_type in GLOBAL_ITEM_MANAGER.item_databook_pages)
                items_with_pages[item_type] = GLOBAL_ITEM_MANAGER.item_databook_pages[item_type]

            if(!length(items_with_pages))
                usr << "No items have databook pages assigned!"
                return

            var/type_choice = input(usr, "Select item type to remove databook from:", "Remove Databook") as null|anything in items_with_pages
            if(!type_choice)
                return

            GLOBAL_ITEM_MANAGER.item_databook_pages -= type_choice
            GLOBAL_ITEM_MANAGER.save_item_databook()

            for(var/obj/item/I in world)
                if(I.type == type_choice)
                    I.databook_page = null

            usr << "Removed databook page from all [type_choice] items."