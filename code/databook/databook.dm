var/global/datum/databook/GLOBAL_DATABOOK  // Global singleton instance

/world/New()
    ..()
    GLOBAL_DATABOOK = new()

// Verb to open the databook
/mob/verb/view_databook()
    set name = "View Databook"
    set category = "IC"
    
    if(!client)
        return
    
    GLOBAL_DATABOOK.show(src)

/mob

/datum/databook
    var/list/pages = list()
    var/current_page = "home"
    var/savefile_path = "data/databook_pages.sav"

    proc/save_pages()
        var/savefile/S = new(savefile_path)
        var/list/custom_pages = list()
        
        // Save only the current dynamic pages
        for(var/page_id in pages)
            var/datum/databook_page/P = pages[page_id]
            if(istype(P, /datum/databook_page/dynamic))
                custom_pages[page_id] = list(
                    "title" = P.title,
                    "content" = P.content
                )
        
        // Save the list to the file
        S["pages"] = custom_pages

    // Add proc to load pages
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
            add_page(page_data["title"], page_data["content"])

    proc/add_page(title, content)
        var/page_id = lowertext(replacetext(title, " ", "_"))
        
        // Create a new dynamic page
        var/datum/databook_page/dynamic/new_page = new(src)
        new_page.title = title
        new_page.content = content
        
        // Add it to our pages list
        pages[page_id] = new_page
        
        // Save the updated pages
        save_pages()

    // Show the current page's content
    proc/show(mob/user)
        var/datum/databook_page/page = pages[current_page]
        if(!page)
            return
        
        user << browse(page.content, "window=databook;size=600x400;can_close=1")

    // Handle topic calls from UI interactions
    Topic(href, href_list)
        if(href_list["page"])
            current_page = href_list["page"]
            usr.view_databook()

/datum/databook/New()
    ..()
    pages["home"] = new /datum/databook_page/home(src)
    pages["combat"] = new /datum/databook_page/combat(src)
    pages["world"] = new /datum/databook_page/world(src)
    
    // Load any custom pages
    load_pages()

// Verb to create new pages
/owner
    verb
        add_databook_page()
            set name = "Add Databook Page"
            set category = "Owner"
            
            var/title = input(src, "Enter page title:", "New Page") as text|null
            if(!title)
                return
                
            var/content = input(src, "Enter page content:", "New Page") as message|null
            if(!content)
                return
            
            // Format the content with HTML
            var/formatted_content = {"
                <html>
                    <head>
                        <style>
                            body { padding: 10px; }
                            h1 { color: #333; }
                        </style>
                    </head>
                    <body>
                        <h1><a href='?src=\ref[GLOBAL_DATABOOK];page=home'>Return home</a></h1>
                        <h1>[title]</h1>
                        <p>[content]</p>
                    </body>
                </html>
            "}
            
            // Add the page with formatted content
            GLOBAL_DATABOOK.add_page(title, formatted_content)
            
            world << "Page <a href='?src=\ref[GLOBAL_DATABOOK];page=[lowertext(replacetext(title, " ", "_"))]'>[title]</a> added."
    
        view_databook_pages()
            set name = "View Databook Pages"
            set category = "Owner"
            
            var/list/pages = GLOBAL_DATABOOK.pages
            var/html = "<h1>Databook Pages</h1>"
            html += "<ul>"
            for(var/page_id in pages)
                var/datum/databook_page/P = pages[page_id]
                html += "<li><a href='?src=\ref[GLOBAL_DATABOOK];page=[page_id]'>[P.title]</a></li>"
            html += "</ul>"
            usr << browse(html, "window=databook_pages;size=600x400;can_close=1")
    
        delete_databook_page()
            set name = "Delete Databook Page"
            set category = "Owner"
            
            var/list/deletable_pages = list()
            
            // Only show dynamic/custom pages as options
            for(var/page_id in GLOBAL_DATABOOK.pages)
                var/datum/databook_page/P = GLOBAL_DATABOOK.pages[page_id]
                deletable_pages[P.title] = page_id
            
            if(!length(deletable_pages))
                usr << "No custom pages to delete!"
                return
            
            var/choice = input(usr, "Select page to delete:", "Delete Page") as null|anything in deletable_pages
            if(!choice)
                return
                
            var/page_id = deletable_pages[choice]
            
            // Remove from current pages list
            GLOBAL_DATABOOK.pages -= page_id
            
            // Update save file
            GLOBAL_DATABOOK.save_pages()
            
            world << "Page '[choice]' has been deleted."


        edit_databook_page()
            set name = "Edit Databook Page"
            set category = "Owner"
            
            var/list/editable_pages = list()
            
            // Only show dynamic/custom pages as options
            for(var/page_id in GLOBAL_DATABOOK.pages)
                var/datum/databook_page/P = GLOBAL_DATABOOK.pages[page_id]
                editable_pages[P.title] = page_id
            
            if(!length(editable_pages))
                usr << "No custom pages to edit!"
                return
            
            var/choice = input(usr, "Select page to edit:", "Edit Page") as null|anything in editable_pages
            if(!choice)
                return
                
            var/page_id = editable_pages[choice]
            var/datum/databook_page/dynamic/page = GLOBAL_DATABOOK.pages[page_id]
            
            var/new_title = input(usr, "Edit page title:", "Edit Page", page.title) as text|null
            if(!new_title)
                return
                
            var/new_content = input(usr, "Consider using an online HTML editor to format and view the page contents!", "Edit Page", page.content) as message|null
            if(!new_content)
                return
        
            // Remove old page
            GLOBAL_DATABOOK.pages -= page_id
            
            // Add updated page
            GLOBAL_DATABOOK.add_page(new_title, new_content)

            var/new_page_id = lowertext(replacetext(new_title, " ", "_"))

            GLOBAL_DATABOOK.save_pages()
            
            world << "Page '<a href='?src=\ref[GLOBAL_DATABOOK];page=[new_page_id]'>[new_title]</a>' has been updated."