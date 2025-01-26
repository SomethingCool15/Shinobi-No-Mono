// Base page datum
/datum/databook_page
    var/content = ""  // Will store the complete HTML for each page

// Homepage implementation
/datum/databook_page/home
    var/datum/databook/owner

    New(datum/databook/D)
        ..()
        owner = D
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
                        <li><a href='?src=\ref[owner];page=combat'>Combat Guide</a></li>
                        <li><a href='?src=\ref[owner];page=world'>World Information</a></li>
                    </ul>
                </body>
            </html>
        "}

// Placeholder for combat page
/datum/databook_page/combat
    var/datum/databook/owner

    New(datum/databook/D)
        ..()
        owner = D
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

// Placeholder for world page
/datum/databook_page/world
    var/datum/databook/owner

    New(datum/databook/D)
        ..()
        owner = D
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

// Add a dynamic page type for custom pages
/datum/databook_page/dynamic
    var/datum/databook/owner
    var/page_title

    New(datum/databook/D)
        ..()
        owner = D

    proc/setup(title, content_text)
        page_title = title
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
                    <h1>[page_title]</h1>
                    <p>[content_text]</p>
                </body>
            </html>
        "}