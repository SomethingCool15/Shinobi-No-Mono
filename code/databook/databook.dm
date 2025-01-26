var/global/datum/databook/GLOBAL_DATABOOK  // Global singleton instance

// Verb to open the databook
/mob/verb/view_databook()
    set name = "View Databook"
    set category = "IC"
    
    if(!client)
        return
    
    if(!GLOBAL_DATABOOK)  // Initialize global databook if it doesn't exist
        GLOBAL_DATABOOK = new()
    GLOBAL_DATABOOK.show(src)

/mob

/datum/databook
    var/list/pages = list()
    var/current_page = "home"  // Track current page

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

    // Add proc to create new pages
    proc/add_page(title, content)
        var/page_id = lowertext(replacetext(title, " ", "_"))
        
        // Create a new dynamic page
        var/datum/databook_page/dynamic/new_page = new(src)
        new_page.setup(title, content)
        
        // Add it to our pages list
        pages[page_id] = new_page
        
/datum/databook/New()
    ..()
    // Initialize pages
    pages["home"] = new /datum/databook_page/home(src)
    pages["combat"] = new /datum/databook_page/combat(src)
    pages["world"] = new /datum/databook_page/world(src)

// Verb to create new pages
/mob/verb/add_databook_page()
    set name = "Add Databook Page"
    set category = "IC"
    
    if(!client)
        return
    
    if(!GLOBAL_DATABOOK)
        GLOBAL_DATABOOK = new()
    
    var/title = input(src, "Enter page title:", "New Page") as text|null
    title = lowertext(replacetext(title, " ", "_"))  // Convert to lowercase and replace spaces with underscores
    if(!title)
        return
        
    var/content = input(src, "Enter page content:", "New Page") as message|null
    if(!content)
        return
    
    GLOBAL_DATABOOK.add_page(title, content)
    world << "Page <a href='?src=\ref[GLOBAL_DATABOOK];page=[title]'>[title]</a> added."
    
