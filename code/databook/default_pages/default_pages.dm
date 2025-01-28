// Base page datum
/datum/databook_page
    var/title = ""
    var/content = ""  // Will store the complete HTML for each page
    var/last_edited = ""
    var/last_editor = ""
    var/visible = TRUE
    var/page_type = "dynamic" 

/datum/databook_page/home
    var/datum/databook/owner

    New(datum/databook/D)
        ..()
        owner = D
        title = "Home"
        page_type = "home"
        content = {"
            <html>
                <head>
                    <style>
                        body { padding: 10px; }
                        h1 { color: #333; }
                        ul { list-style-type: none; padding: 0; }
                        li { margin: 10px 0; }
                        a { color: #2196F3; text-decoration: none; }
                        a:hover { text-decoration: underline; }
                    </style>
                </head>
                <body>
                    <h1>Welcome to the Databook</h1>
                    <p>Select a section to learn more:</p>
                    <ul>
                        <li><a href='?src=\ref[owner];page=navigation'>Navigation</a></li>
                        <li><a href='?src=\ref[owner];page=combat'>Combat Guide</a></li>
                        <li><a href='?src=\ref[owner];page=world'>World Information</a></li>
                    </ul>
                </body>
            </html>
        "}

/datum/databook_page/combat
    var/datum/databook/owner

    New(datum/databook/D)
        ..()
        owner = D
        title = "Combat Guide"
        page_type = "combat"
        content = {"
            <html>
                <head>
                    <style>
                        body { padding: 10px; }
                        h1 { color: #333; }
                    </style>
                </head>
                <body>
                    <h1><a href='?src=\ref[owner];page=home'>Return home</a></h1>
                    <h1>Combat Guide</h1>
                    <p>Combat guide content goes here.</p>
                </body>
            </html>
        "}

/datum/databook_page/world
    var/datum/databook/owner

    New(datum/databook/D)
        ..()
        owner = D
        title = "World Information"
        page_type = "world"
        content = {"
            <html>
                <head>
                    <style>
                        body { padding: 10px; }
                        h1 { color: #333; }
                    </style>
                </head>
                <body>
                    <h1><a href='?src=\ref[owner];page=home'>Return home</a></h1>
                    <h1>World Information</h1>
                    <p>World information content goes here.</p>
                </body>
            </html>
        "}

/datum/databook_page/dynamic
    var/datum/databook/owner

    New(datum/databook/D)
        ..()
        owner = D

    proc/setup(title, content_text)
        src.title = title
        content = {"
            <html>
                <head>
                    <style>
                        body { padding: 10px; }
                        h1 { color: #333; }
                    </style>
                </head>
                <body>
                    <h1><a href='?src=\ref[owner];page=home'>Return home</a></h1>
                    <h1>[title]</h1>
                    <p>[content_text]</p>
                </body>
            </html>
        "}

/datum/databook_page/navigation
    var/datum/databook/owner

    New(datum/databook/D)
        ..()
        owner = D
        title = "Navigation"
        visible = FALSE
        page_type = "navigation"
        update_content()

    proc/update_content()
        content = {"
            <html>
                <head>
                    <style>
                        body { padding: 10px; }
                        h1 { color: #333; }
                        ul { list-style-type: none; padding: 0; }
                        li { margin: 10px 0; }
                        a { color: #2196F3; text-decoration: none; }
                        a:hover { text-decoration: underline; }
                    </style>
                </head>
                <body>
                    <h1>Navigation</h1>
                    <p>Available Pages:</p>
                    <ul>
        "}

        for(var/page_id in owner.pages)
            var/datum/databook_page/P = owner.pages[page_id]
            if(P.visible)
                content += "<li><a href='?src=\ref[owner];page=[page_id]'>[P.title]</a></li>"

        content += {"
                    </ul>
                    <p><a href='?src=\ref[owner];page=home'>Return to Home</a></p>
                </body>
            </html>
        "}