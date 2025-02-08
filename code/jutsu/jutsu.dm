/obj/jutsu
    var/jutsu_name
    var/jutsu_element
    var/jutsu_description  // This will hold the complete HTML template
    var/list/extra_sections = list()  // [section_name] = section_content
    var/list/section_requirements = list()  // [section_name] = requirement
    var/last_edited
    var/last_editor
    var/pp_cost
    var/list/jutsu_requirements = list()
    var/list/rulings = list()

    New(new_jutsu_name, new_jutsu_element, new_jutsu_description, new_section_requirements, new_extra_sections, new_pp_cost, new_jutsu_requirements)
        ..()
        jutsu_name = new_jutsu_name
        jutsu_element = new_jutsu_element
        jutsu_description = new_jutsu_description
        section_requirements = new_section_requirements
        extra_sections = new_extra_sections
        pp_cost = new_pp_cost
        jutsu_requirements = islist(new_jutsu_requirements) ? new_jutsu_requirements : list(new_jutsu_requirements)
        last_edited = time2text(world.realtime, "DD-MM-YYYY hh:mm:ss") + " UTC"
        last_editor = usr.ckey

    proc/show_jutsu(jutsu_name)
        world << "[usr] has activated a technique! <a href='?src=\ref[src];jutsu=[jutsu_name]'>[jutsu_name]</a>"

    proc/get_locked_message(requirement)
        switch(requirement)
            if("Shape Training")
                return "If I knew how to shape my chakra more accurately, I might be able to draw more power out of this technique."
            else if("Nature Training")
                return "With a better understanding of nature transformation, I could unlock new aspects of this technique."
            else
                return ""

    proc/get_formatted_html(var/mob/viewer, var/mob/performer = null)
        var/display_html = jutsu_description
        
        display_html = replacetext(display_html, "\[icon_url]", get_jutsu_icon(jutsu_element))
        display_html = replacetext(display_html, "{databook}", "<a href='?src=\ref[GLOBAL_DATABOOK];")
        
        if(usr && usr.client)
            var/insert_position = findtext(display_html, "<!--SECTIONS-->")
            if(insert_position)
                var/sections_html = ""
                
                for(var/section in extra_sections)
                    var/requirement = section_requirements[section]

                    if(usr.ckey in owners)
                        sections_html += "<hr>"
                        sections_html += "<center><div class='sub-heading'>[section]</div></center>"
                        sections_html += extra_sections[section]
                    else if((performer && performer.has_perk(requirement)))
                        sections_html += "<hr>"
                        sections_html += "<center><div class='sub-heading'>[section]</div></center>"
                        sections_html += extra_sections[section]
                    else if(requirement != "Shape Training" && requirement != "Nature Training")
                        sections_html = ""
                    else
                        sections_html += "<hr><div class='locked-section'>[get_locked_message(requirement)]</div>"
                
                var/comment_length = length("<!--SECTIONS-->")
                display_html = copytext(display_html, 1, insert_position) + sections_html + copytext(display_html, insert_position + comment_length)
        
        return display_html

    Topic(href, href_list)
        if(href_list["jutsu"]) 
            usr << browse(get_formatted_html(usr, performer = usr), "window=jutsu_[jutsu_name];size=520x680;can_close=1;can_resize=0;border=0;is-naked=1")

    DblClick()
        if(usr && usr.client)
            show_jutsu(src.jutsu_name)

/mob/verb/give_jutsu()
    set name = "Give Jutsu"
    set category = "IC"

    if(!client)
        return

    if(!GLOBAL_JUTSU_MANAGER.jutsu_list.len)
        GLOBAL_JUTSU_MANAGER.load_jutsu()

    for(var/obj/jutsu/J in GLOBAL_JUTSU_MANAGER.jutsu_list)
        jutsu_list += J
        src << "You learned [J.jutsu_name]!"

var/global/datum/jutsu_manager/GLOBAL_JUTSU_MANAGER

/world/New()
    ..()
    GLOBAL_JUTSU_MANAGER = new()
    GLOBAL_JUTSU_MANAGER.load_jutsu()

/datum/jutsu_manager
    var/list/jutsu_list = list()
    var/savefile_path = "data/jutsu_database.sav"

    proc/save_jutsu()
        var/savefile/S = new(savefile_path)
        var/list/saved_jutsu = list()
        
        for(var/obj/jutsu/J in jutsu_list)
            saved_jutsu += list(list(
                "jutsu_name" = J.jutsu_name,
                "jutsu_element" = J.jutsu_element,
                "jutsu_description" = J.jutsu_description,
                "extra_sections" = J.extra_sections,
                "section_requirements" = J.section_requirements,
                "last_edited" = J.last_edited,
                "last_editor" = J.last_editor,
                "pp_cost" = J.pp_cost,
                "jutsu_requirements" = J.jutsu_requirements
            ))
        
        S["jutsu"] = saved_jutsu

    proc/load_jutsu()
        if(!fexists(savefile_path))
            return
            
        var/savefile/S = new(savefile_path)
        var/list/loaded_jutsu
        
        S["jutsu"] >> loaded_jutsu
        if(!loaded_jutsu)
            return
            
        for(var/list/jutsu_data in loaded_jutsu)
            var/obj/jutsu/J = new(
                jutsu_data["jutsu_name"],
                jutsu_data["jutsu_element"], 
                jutsu_data["jutsu_description"],
                jutsu_data["section_requirements"],
                jutsu_data["extra_sections"],
                jutsu_data["pp_cost"],
                jutsu_data["jutsu_requirements"],
                jutsu_data["last_edited"],
                jutsu_data["last_editor"]
            )
            jutsu_list += J

/owner
    verb
        add_jutsu()
            set name = "Add Jutsu"
            set category = "Owner"

            var/jutsu_name = input(usr, "Enter the jutsu's name:", "Jutsu Name") as null|text
            if(!jutsu_name) return
            
            var/jutsu_element = input(usr, "Enter the jutsu's element (Katon, Suiton, etc):", "Jutsu Element") as null|text
            if(!jutsu_element) return
            
            var/jutsu_html = input(usr, "Enter the complete HTML template (use <!--SECTIONS--> where extra sections should appear):", "Jutsu HTML") as null|message
            if(!jutsu_html) return

            var/pp_cost = input(usr, "Enter the PP cost for this jutsu:", "PP Cost") as null|num
            if(isnull(pp_cost)) return

            var/list/new_requirements = list()
            var/adding_requirements = 1
            while(adding_requirements)
                var/requirement = input(usr, "Enter a requirement for this jutsu (or cancel to finish):", "Requirements") as null|text
                if(!requirement) 
                    break
                new_requirements += requirement
                adding_requirements = alert("Add another requirement?", "Requirements", "Yes", "No") == "Yes"
            
            if(!length(new_requirements))
                new_requirements = list("None")

            var/list/section_requirements = list()
            var/list/extra_sections = list()
            
            var/has_sections = alert("Does this jutsu have extra sections?", "Extra Sections", "Yes", "No") == "Yes"
            if(has_sections)
                var/add_section = 1
                while(add_section)
                    var/section_name = input("Enter section name (or cancel to finish):", "Section Name") as null|text
                    if(!section_name) break
                    
                    var/section_content = input("Enter the content for this section:", "Section Content") as null|message
                    if(!section_content) break
                    
                    var/requirement = input("Enter required perk to view this section (Shape Training, Nature Training, etc):", "Section Requirement") as null|text
                    if(requirement)
                        section_requirements[section_name] = requirement
                        extra_sections[section_name] = section_content
                    
                    add_section = alert("Add another section?", "Add Section", "Yes", "No") == "Yes"

            var/obj/jutsu/J = new(jutsu_name, jutsu_element, jutsu_html, section_requirements, extra_sections, pp_cost, new_requirements)
            GLOBAL_JUTSU_MANAGER.jutsu_list += J
            GLOBAL_JUTSU_MANAGER.save_jutsu()
            world << "Jutsu <a href='?src=\ref[J];jutsu=[jutsu_name]'>[jutsu_name]</a> has been added!"

        delete_jutsu()
            set name = "Delete Jutsu"
            set category = "Owner"

            var/list/jutsu_names = list()
            for(var/obj/jutsu/J in GLOBAL_JUTSU_MANAGER.jutsu_list)
                jutsu_names[J.jutsu_name] = J
            
            var/choice = input(usr, "Select jutsu to delete:", "Delete Jutsu") as null|anything in jutsu_names
            if(!choice)
                return
                
            var/obj/jutsu/selected_jutsu = jutsu_names[choice]
            GLOBAL_JUTSU_MANAGER.jutsu_list -= selected_jutsu
            GLOBAL_JUTSU_MANAGER.save_jutsu()
            usr << "Deleted jutsu: [choice]"

        view_jutsu_list()
            set name = "View Jutsu List"
            set category = "Owner"
            
            if(!GLOBAL_JUTSU_MANAGER.jutsu_list.len)
                usr << "No jutsu have been created yet."
                return
            
            var/html = {"
                <html>
                <head>
                    <style>
                        body {
                            font-family: Arial, sans-serif;
                            padding: 20px;
                        }
                        table { 
                            width: 100%; 
                            border-collapse: collapse; 
                        }
                        th, td { 
                            padding: 8px; 
                            text-align: left; 
                            border: 1px solid #636b2f; 
                        }
                        th { 
                            background-color: #d2b48c;
                            color: #2d2d2d;
                        }
                        .element-icon {
                            width: 20px;
                            height: 20px;
                            vertical-align: middle;
                        }
                    </style>
                </head>
                <body>
                    <h2>Available Jutsu</h2>
                    <table>
                        <tr>
                            <th>Element</th>
                            <th>Name</th>
                            <th>Last Editor</th>
                            <th>Last Edited</th>
                            <th>PP Cost</th>
                            <th>Requirements</th>
                        </tr>
            "}
            
            for(var/obj/jutsu/J in GLOBAL_JUTSU_MANAGER.jutsu_list)
                html += {"
                    <tr>
                        <td><center><img src='[get_jutsu_icon(J.jutsu_element)]' class='element-icon'></center></td>
                        <td><a href='?src=\ref[J];jutsu=[J.jutsu_name]'>[J.jutsu_name]</a></td>
                        <td>[J.last_editor]</td>
                        <td>[J.last_edited]</td>
                        <td>[J.pp_cost]</td>
                        <td>[jointext(J.jutsu_requirements, ", ")]</td>
                    </tr>
                "}
            
            html += "</table></body></html>"
            
            usr << browse(html, "window=jutsu_list;size=600x400;can_close=1;can_resize=1")

        edit_jutsu()
            set name = "Edit Jutsu"
            set category = "Owner"
            
            var/list/editable_jutsu = list()
            
            for(var/obj/jutsu/J in GLOBAL_JUTSU_MANAGER.jutsu_list)
                editable_jutsu[J.jutsu_name] = J
            
            if(!length(editable_jutsu))
                usr << "No jutsu to edit!"
                return
            
            var/choice = input(usr, "Select jutsu to edit:", "Edit Jutsu") as null|anything in editable_jutsu
            if(!choice)
                return
                
            var/obj/jutsu/jutsu = editable_jutsu[choice]
            
            var/new_name = input(usr, "Edit jutsu name:", "Edit Jutsu", jutsu.jutsu_name) as text|null
            if(!new_name)
                return

            var/new_pp_cost = input(usr, "Edit PP cost:", "Edit Jutsu", jutsu.pp_cost) as null|num
            if(isnull(new_pp_cost))
                return

            var/new_jutsu_requirements = jutsu.jutsu_requirements.Copy()
            var/edit_requirements = alert("Would you like to edit jutsu requirements?", "Edit Requirements", "Yes", "No") == "Yes"
            
            if(edit_requirements)
                var/action = input("What would you like to do with requirements?", "Edit Requirements") as null|anything in list("Replace All", "Add Requirement", "Remove Requirement", "Cancel")
                switch(action)
                    if("Replace All")
                        new_jutsu_requirements = list()
                        var/adding_requirements = 1
                        while(adding_requirements)
                            var/requirement = input(usr, "Enter a requirement (or cancel to finish):", "Requirements") as null|text
                            if(!requirement) 
                                break
                            new_jutsu_requirements += requirement
                            adding_requirements = alert("Add another requirement?", "Requirements", "Yes", "No") == "Yes"
                    
                    if("Add Requirement")
                        var/requirement = input(usr, "Enter new requirement:", "Add Requirement") as null|text
                        if(requirement)
                            new_jutsu_requirements += requirement
                    
                    if("Remove Requirement")
                        var/remove_choice = input("Select requirement to remove:", "Remove Requirement") as null|anything in new_jutsu_requirements
                        if(remove_choice)
                            new_jutsu_requirements -= remove_choice

                if(!length(new_jutsu_requirements))
                    new_jutsu_requirements = list("None")

            var/new_element = input(usr, "Edit jutsu element:", "Edit Jutsu", jutsu.jutsu_element) as text|null
            if(!new_element)
                return
                
            var/new_description = input(usr, "Edit jutsu description:", "Edit Jutsu", jutsu.jutsu_description) as message|null
            if(!new_description)
                return

            var/list/new_section_requirements = list()
            var/list/new_extra_sections = list()
            
            for(var/section in jutsu.extra_sections)
                new_section_requirements[section] = jutsu.section_requirements[section]
                new_extra_sections[section] = jutsu.extra_sections[section]
            
            var/edit_sections = alert("Would you like to edit sections?", "Edit Sections", "Yes", "No") == "Yes"
            while(edit_sections)
                var/action = input("What would you like to do?", "Edit Sections") as null|anything in list("Add Section", "Edit Section", "Remove Section", "Done")
                switch(action)
                    if(null, "Done")
                        break
                        
                    if("Add Section")
                        var/section_name = input("Enter section name:", "Add Section") as text|null
                        if(!section_name)
                            continue
                            
                        var/section_content = input("Enter section content:", "Add Section") as message|null
                        if(!section_content)
                            continue
                            
                        var/requirement = input("Enter required perk (Shape Training, Nature Training, etc):", "Add Section") as text|null
                        if(!requirement)
                            continue
                            
                        new_section_requirements[section_name] = requirement
                        new_extra_sections[section_name] = section_content
                    
                    if("Edit Section")
                        var/edit_choice = input("Select section to edit:", "Edit Section") as null|anything in new_extra_sections
                        if(!edit_choice)
                            continue
                            
                        var/new_content = input("Edit section content:", "Edit Section", new_extra_sections[edit_choice]) as message|null
                        if(!new_content)
                            continue
                            
                        var/new_requirement = input("Edit required perk:", "Edit Section", new_section_requirements[edit_choice]) as text|null
                        if(!new_requirement)
                            continue
                            
                        new_section_requirements[edit_choice] = new_requirement
                        new_extra_sections[edit_choice] = new_content
                    
                    if("Remove Section")
                        var/remove_choice = input("Select section to remove:", "Remove Section") as null|anything in new_extra_sections
                        if(!remove_choice)
                            continue
                            
                        new_section_requirements -= remove_choice
                        new_extra_sections -= remove_choice

            var/obj/jutsu/new_jutsu = new(new_name, new_element, new_description, new_section_requirements, new_extra_sections, new_pp_cost, new_jutsu_requirements)
            
            GLOBAL_JUTSU_MANAGER.jutsu_list -= jutsu
            GLOBAL_JUTSU_MANAGER.jutsu_list += new_jutsu
            
            // Save changes
            GLOBAL_JUTSU_MANAGER.save_jutsu()
            
            world << "Jutsu '<a href='?src=\ref[new_jutsu];jutsu=[new_name]'>[new_name]</a>' has been updated!"

proc/get_jutsu_icon(jutsu_element)
    switch(jutsu_element)
        if("Katon")
            jutsu_element = "https://i.ibb.co/kgLFmPgX/latest.png"
        if("Suiton")
            jutsu_element = "https://i.ibb.co/sJHW4GdF/latest4.png"
        if("Raiton")
            jutsu_element = "https://i.ibb.co/S4SdQ02w/latest5.png"
        if("Doton")
            jutsu_element = "https://i.ibb.co/qPb4hRv/latest2.png"
        if("Fuuton")
            jutsu_element = "https://i.ibb.co/35JLPs6g/latest3.png"
        if("Taijutsu")
            jutsu_element = "https://static-00.iconduck.com/assets.00/fist-icon-1938x2048-354jxq2n.png"
        if("Genjutsu")
            jutsu_element = "test"
        if("Shurikenjutsu")
            jutsu_element = "https://i.ibb.co/G4bpTq41/600px-Shuriken-28-Naruto29.png"
        if("Uchiha")
            jutsu_element = "test"
        if("Hyuuga")
            jutsu_element = "test"
        if("Nara")
            jutsu_element = "test"
        if("Akimichi")
            jutsu_element = "test"
        if("Yuki")
            jutsu_element = "test"
        if("Terumi")
            jutsu_element = "test"
        if("Kaguya")
            jutsu_element = "test"
        else
            jutsu_element = "https://i.ibb.co/kgLFmPgX/latest.png"
    return jutsu_element
