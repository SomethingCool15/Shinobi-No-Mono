/mob/verb/view_databook()
    set name = "View Databook"
    set category = "IC"
    
    if(!client)
        return
    
    GLOBAL_DATABOOK.show(src)

/datum/databook
    var/list/pages = list()
    var/current_page = "home"
    var/savefile_path = "data/databook_pages.sav"

    proc/save_pages()
        var/savefile/S = new(savefile_path)
        var/list/custom_pages = list()
        
        for(var/page_id in pages)
            var/datum/databook_page/P = pages[page_id]
            custom_pages[page_id] = list(
                "title" = P.title,
                "content" = P.content,
                "last_edited" = P.last_edited,
                "last_editor" = P.last_editor,
                "visible" = P.visible,
                "page_type" = P.page_type
            )
        
        S["pages"] = custom_pages

    proc/load_pages()
        if(!fexists(savefile_path))
            return
            
        var/savefile/S = new(savefile_path)
        var/list/custom_pages
        
        S["pages"] >> custom_pages
        if(!custom_pages)
            return
            
        for(var/page_id in custom_pages)
            var/list/page_data = custom_pages[page_id]
            var/datum/databook_page/new_page
            
            switch(page_data["page_type"])
                if("navigation")
                    new_page = new /datum/databook_page/navigation(src)
                if("home")
                    new_page = new /datum/databook_page/home(src)
                if("combat")
                    new_page = new /datum/databook_page/combat(src)
                if("world")
                    new_page = new /datum/databook_page/world(src)
                else
                    new_page = new /datum/databook_page/dynamic(src)
            
            new_page.title = page_data["title"]
            new_page.content = page_data["content"]
            new_page.last_edited = page_data["last_edited"]
            new_page.last_editor = page_data["last_editor"]
            new_page.visible = page_data["visible"]
            pages[page_id] = new_page

    proc/add_page(title, content, visible)
        var/page_id = lowertext(replacetext(title, " ", "_"))
        
        var/datum/databook_page/dynamic/new_page = new(src)
        new_page.title = title
        new_page.content = content
        new_page.visible = visible
        new_page.last_edited = time2text(world.realtime, "DD-MM-YYYY hh:mm:ss") + " UTC"
        new_page.last_editor = usr.ckey
        
        pages[page_id] = new_page
        
        var/datum/databook_page/navigation/nav = pages["navigation"]
        if(nav)
            nav.update_content()
        
        save_pages()

    proc/show(mob/user)
        var/datum/databook_page/page = pages[current_page]
        if(!page)
            return
        
        if(current_page == "navigation")
            var/datum/databook_page/navigation/N = page
            if(istype(N))
                N.update_content()
        
        var/formatted_content = replacetext(page.content, "{databook}", "<a href='?src=\ref[src];")
        
        user << browse(formatted_content, "window=databook;size=600x400;can_close=1")

    Topic(href, href_list)
        if(href_list["page"])
            current_page = href_list["page"]
            usr.view_databook()

/datum/databook/New()
    ..()
    load_pages()
    
    if(!pages["home"])
        pages["home"] = new /datum/databook_page/home(src)
    if(!pages["combat"])
        pages["combat"] = new /datum/databook_page/combat(src)
    if(!pages["world"])
        pages["world"] = new /datum/databook_page/world(src)
    if(!pages["navigation"])
        pages["navigation"] = new /datum/databook_page/navigation(src)

/owner
    verb
        add_databook_page()
            set name = "Add Databook Page"
            set category = "Owner"

            var/title = input(src, "Enter page title:", "New Page") as text|null
            if(!title)
                return
            
            var/page_id = lowertext(replacetext(title, " ", "_"))
            if(GLOBAL_DATABOOK.pages[page_id])
                usr << "A page with that title already exists!"
                return

            var/content = input(src, "Enter page content:", "New Page") as message|null
            if(!content)
                return
            
            var/visible = alert("Should this page be visible in navigation?", "Page Visibility", "Yes", "No") == "Yes"
            
            GLOBAL_DATABOOK.add_page(title, content, visible)
            
            world << "Page <a href='?src=\ref[GLOBAL_DATABOOK];page=[lowertext(replacetext(title, " ", "_"))]'>[title]</a> added."
    
        view_databook_pages()
            set name = "View Databook Pages"
            set category = "Owner"
            
            var/html = {"
                <h1>Databook Pages</h1>
                <style>
                    table { 
                        width: 100%; 
                        border-collapse: collapse; 
                    }
                    th, td { 
                        padding: 8px; 
                        text-align: left; 
                        border: 1px solid #ddd; 
                    }
                    th { 
                        background-color: #f2f2f2; 
                    }
                </style>
                <table>
                    <tr>
                        <th>Title</th>
                        <th>Page ID</th>
                        <th>Last Edited</th>
                        <th>Last Editor</th>
                        <th>Visible</th>
                    </tr>"}
            
            var/rows = ""
            for(var/page_id in GLOBAL_DATABOOK.pages)
                var/datum/databook_page/P = GLOBAL_DATABOOK.pages[page_id]
                rows += {"
                    <tr>
                        <td><a href='?src=\ref[GLOBAL_DATABOOK];page=[page_id]'>[P.title]</a></td>
                        <td>[page_id]</td>
                        <td>[P.last_edited || "Never"]</td>
                        <td>[P.last_editor || "N/A"]</td>
                        <td>[P.visible ? "Yes" : "No"]</td>
                    </tr>"}
            
            html += rows + "</table>"
            usr << browse(html, "window=databook_pages;size=600x400;can_close=1;")
    
        delete_databook_page()
            set name = "Delete Databook Page"
            set category = "Owner"
            
            var/list/deletable_pages = list()
            
            for(var/page_id in GLOBAL_DATABOOK.pages)
                var/datum/databook_page/P = GLOBAL_DATABOOK.pages[page_id]
                deletable_pages[P.title] = page_id
            
            if(!length(deletable_pages))
                usr << "No custom pages to delete!"
                return
            
            var/choice = input(usr, "Select page to delete:", "Delete Page") as null|anything in deletable_pages
            if(!choice)
                return

            var/warning = alert(usr, "Are you sure you want to delete [choice]? This action is irreversible.", "Delete Page", "Delete [choice]","Cancel")
            if(warning == "Cancel")
                return
                
            var/page_id = deletable_pages[choice]
            GLOBAL_DATABOOK.pages -= page_id
            GLOBAL_DATABOOK.save_pages()

            var/datum/databook_page/nav = GLOBAL_DATABOOK.pages["navigation"]
            if(istype(nav, /datum/databook_page/navigation))
                var/datum/databook_page/navigation/N = nav
                N.update_content()
            
            world << "Page '[choice]' has been deleted."

        edit_databook_page()
            set name = "Edit Databook Page"
            set category = "Owner"
            
            var/list/editable_pages = list()
            
            for(var/page_id in GLOBAL_DATABOOK.pages)
                var/datum/databook_page/P = GLOBAL_DATABOOK.pages[page_id]
                editable_pages[P.title] = page_id
            
            if(!length(editable_pages))
                usr << "No custom pages to edit!"
                return
            
            var/choice = input(usr, "Select page to edit:", "Edit Page") as null|anything in editable_pages
            if(!choice)
                return

            if(choice == "Navigation")
                usr << "You cannot edit the navigation page!"
                return
                
            var/page_id = editable_pages[choice]
            var/datum/databook_page/dynamic/page = GLOBAL_DATABOOK.pages[page_id]
            
            var/new_title = input(usr, "Edit page title:", "Edit Page", page.title) as text|null
            if(!new_title)
                return
                
            var/new_content = input(usr, "Consider using an online HTML editor to format and view the page contents!", "Edit Page", page.content) as message|null
            if(!new_content)
                return

            var/visible = alert("Should this page be visible in navigation?", "Page Visibility", "Yes", "No") == "Yes"
        
            GLOBAL_DATABOOK.pages -= page_id
            GLOBAL_DATABOOK.add_page(new_title, new_content, visible)

            var/new_page_id = lowertext(replacetext(new_title, " ", "_"))
            GLOBAL_DATABOOK.save_pages()
            
            world << "Page '<a href='?src=\ref[GLOBAL_DATABOOK];page=[new_page_id]'>[new_title]</a>' has been updated."
