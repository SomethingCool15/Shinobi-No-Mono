/obj/jutsu
    var/jutsu_name
    var/jutsu_power
    var/jutsu_speed
    var/jutsu_range
    var/jutsu_drain
    var/jutsu_handseals
    var/jutsu_rank
    var/jutsu_element
    var/jutsu_description
    var/jutsu_bottom_description
    var/content

    New(new_jutsu_name, new_jutsu_power, new_jutsu_speed, new_jutsu_range, new_jutsu_drain, new_jutsu_handseals, new_jutsu_rank, new_jutsu_element, new_jutsu_description, new_jutsu_bottom_description)
        ..()
        jutsu_name = new_jutsu_name
        jutsu_power = new_jutsu_power
        jutsu_speed = new_jutsu_speed
        jutsu_range = new_jutsu_range
        jutsu_drain = new_jutsu_drain
        jutsu_handseals = new_jutsu_handseals
        jutsu_rank = new_jutsu_rank
        jutsu_element = new_jutsu_element
        jutsu_description = new_jutsu_description
        jutsu_bottom_description = new_jutsu_bottom_description
        setup_content()

    proc/show_jutsu(jutsu_name)
        world << "[usr] has activated a technique! <a href='?src=\ref[src];jutsu=[jutsu_name]'>[jutsu_name]</a>"

    Topic(href, href_list)
        if(href_list["jutsu"])
            var/jutsu_name = href_list["jutsu"]
            usr << browse(content, "window=jutsu_[jutsu_name];size=520x680;can_close=1;can_resize=0;border=0;is-naked=1")

    proc/setup_content()
        var/icon_url = get_jutsu_icon(jutsu_element)
        world << "icon_url: [icon_url]"
        content = {"
           <!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Rogues</title>
    <style>
        body {
            background: none;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            overflow: hidden; /* Prevent body scrolling */
        }

        ul.custom-bullet {
            list-style-image: url("https://i.ibb.co/W4dq08ww/image.png"); /* Custom bullet image */
        }

        .scroll-container {
            background: #f5e9dc;
            border: 10px solid #636b2f;
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
            width: 500px;
            max-width: 100%;
            height: 700px;
            overflow-y: auto;
            scrollbar-width: none;
            -ms-overflow-style: none;
            transform: translateZ(0); /* Force hardware acceleration */
            backface-visibility: hidden; /* Force content rendering */
            -webkit-backface-visibility: hidden;
            will-change: transform; /* Hint to browser about scrolling */
        }

        .scroll-container::-webkit-scrollbar {
            display: none; /* Chrome, Safari and Opera */
        }

        .scroll-content {
            background: #fffaf0;
            border: 2px solid #636b2f;
            padding: 20px;
            border-radius: 10px;
            text-align: left;
            transform: translateZ(0); /* Force hardware acceleration */
            backface-visibility: hidden; /* Force content rendering */
            -webkit-backface-visibility: hidden;
        }

        .Title {
            background: linear-gradient(#dbc3a3, #d2b48c);
            padding: 10px;
            font-size: 24px; /* Fixed font size */
            font-weight: bold;
            color: #2d2d2d;
            text-shadow: 1px 1px 2px black;
            border-radius: 10px;
            margin-bottom: 10px;
            text-align: center;
            position: relative; /* For positioning the icon */
        }

        hr {
            border: none;
            border-top: 1px solid #000; /* Thin solid black line */
            margin: 10px 0;
        }

        img {
            display: block;
            margin-left: auto;
            margin-right: auto;
            width: 100%; /* Make the image fill the container width */
            max-width: 450px; /* Limit the maximum width */
            height: auto; /* Maintain aspect ratio */
            border: 4px solid #636b2f; /* Border around the image */
            border-radius: 10px;
        }

        .sub-heading {
            font-weight: bold;
            font-size: 16px; /* Fixed font size */
            color: #636b2f;
        }

        /* Jutsu Stats Section as a Table */
        .jutsu-stats {
            background: #d2b48c; /* Light brown background */
            padding: 15px;
            border-radius: 10px;
            border: 2px solid #636b2f;
            margin-top: 10px;
        }

        table {
            width: 100%;
            border-collapse: collapse; /* Ensures borders merge into a single line */
        }

        th, td {
            padding: 8px;
            text-align: left;
            border-left: 1px solid #d2b48c; /* Vertical lines between columns, blending with the background */
            border-top: 1px solid #d2b48c; /* Horizontal lines between rows, blending with the background */
        }

        th {
            background-color: #d2b48c;
            color: #fff;
        }

        td:first-child {
            border-left: none; /* Removes left border for the first column */
        }

        td {
            border-bottom: 1px solid #d2b48c; /* Horizontal lines between rows, blending with the background */
        }

        .stat-bar {
            width: 100%;
            height: 10px; /* Fixed height */
            background: #fffaf0;
            border: 1px solid #636b2f;
            border-radius: 5px;
            position: relative;
        }

        .stat-fill {
            background: #636b2f;
            height: 100%;
            border-radius: 5px;
        }

        /* Jutsu Info Section */
        .jutsu-info {
            background: #d2b48c; /* Light brown background */
            padding: 15px;
            border-radius: 10px;
            border: 2px solid #636b2f;
            margin-top: 10px;
        }

        /* Icon positioning */
        .icon {
            position: absolute;
            top: 50%; /* Center vertically */
            right: 10px; /* Adjust distance from the right edge */
            transform: translateY(-50%); /* Center vertically */
            width: 40px; /* Fixed size */
            height: 40px; /* Fixed size */
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .icon img {
            width: 100%; /* Make the image fill the icon container */
            height: auto;
            border: none;
            border-radius: 0;
        }
    </style>
</head>
<body>

    <div class="scroll-container">
        <div class="scroll-content">
            <div class="Title">
                [jutsu_name]
                <div class="icon">
                    <img src="[icon_url]" alt="Icon">
                </div>
            </div>
            <hr>
            <img src="https://i.ibb.co/5gyZD8CW/image.png">

            <div class="jutsu-stats">
                <table>
                    <tr>
                        <td>Power:</td>
                        <td>...</td>
                    </tr>
                    <tr>
                        <td>Speed:</td>
                        <td>...</td>
                    </tr>
                    <tr>
                        <td>Range:</td>
                        <td>...</td>
                    </tr>
                    <tr>
                        <td>Stamina:</td>
                        <td>...</td>
                    </tr>
                    <tr>
                        <td>Handseals:</td>
                        <td>...</td>
                    </tr>
                </table>
            </div>

            <hr>

            <font size="3">
            Missing-nin (抜け忍, nukenin) are ninja who abandon their village with no intention of returning. Missing-nin are criminals in effect, if not before their defection then certainly after abandoning their duties. As such, missing-nin are listed in their village's Bingo Book to be killed or captured on-sight. Kirigakure's hunter-nin are specifically assigned to eliminate these missing-nin. Although some missing-nin may continue wearing their village's forehead protector, they no longer swear allegiance to their village.
            </font>

            <hr>

            <div class="jutsu-info">
                <div class="sub-heading">Jutsu Info</div>
                <font size="3">
                    Jutsu are special techniques used by ninja in battle. There are three main types of jutsu:
                    <ul class="custom-bullet">
                        <li><strong>Ninjutsu:</strong> Techniques that use chakra to perform supernatural feats.</li>
                        <li><strong>Genjutsu:</strong> Illusions that affect the opponent's senses.</li>
                        <li><strong>Taijutsu:</strong> Hand-to-hand combat techniques relying on physical skill.</li>
                    </ul>
                </font>
            </div>

        </div>
    </div>

</body>
</html>
        "}

    // Handle double-click from stat panel
    DblClick()
        if(usr && usr.client)
            show_jutsu(src.jutsu_name)

/mob/verb/give_jutsu()
    set name = "Give Jutsu"
    set category = "IC"

    if(!client)
        return

    // Load jutsu from the global manager if available
    if(!GLOBAL_JUTSU_MANAGER.jutsu_list.len)
        GLOBAL_JUTSU_MANAGER.load_jutsu()
    
    // Add all jutsu from the manager to the player's jutsu list
    for(var/obj/jutsu/J in GLOBAL_JUTSU_MANAGER.jutsu_list)
        jutsu_list += J
        src << "You learned [J.jutsu_name]!"

var/global/datum/jutsu_manager/GLOBAL_JUTSU_MANAGER

/world/New()
    ..()
    GLOBAL_JUTSU_MANAGER = new()

/datum/jutsu_manager
    var/list/jutsu_list = list()
    var/savefile_path = "data/jutsu_database.sav"

    proc/save_jutsu()
        var/savefile/S = new(savefile_path)
        var/list/saved_jutsu = list()
        
        for(var/obj/jutsu/J in jutsu_list)
            saved_jutsu += list(list(
                "jutsu_name" = J.jutsu_name,
                "jutsu_power" = J.jutsu_power,
                "jutsu_speed" = J.jutsu_speed,
                "jutsu_range" = J.jutsu_range,
                "jutsu_drain" = J.jutsu_drain,
                "jutsu_handseals" = J.jutsu_handseals,
                "jutsu_rank" = J.jutsu_rank,
                "jutsu_element" = J.jutsu_element,
                "jutsu_description" = J.jutsu_description,
                "jutsu_bottom_description" = J.jutsu_bottom_description
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
            var/obj/jutsu/J = new()
            J.New(
                jutsu_data["jutsu_name"],
                jutsu_data["jutsu_power"],
                jutsu_data["jutsu_speed"],
                jutsu_data["jutsu_range"],
                jutsu_data["jutsu_drain"],
                jutsu_data["jutsu_handseals"],
                jutsu_data["jutsu_rank"],
                jutsu_data["jutsu_element"],
                jutsu_data["jutsu_description"],
                jutsu_data["jutsu_bottom_description"]
            )
            jutsu_list += J

/owner
    verb
        add_jutsu()
            set name = "Add Jutsu"
            set category = "Owner"

            var/jutsu_name = input(usr, "Enter the jutsu's name in japanese e.g Katon: Gōkakyū no Jutsu:", "Jutsu Name") as text
            if(!jutsu_name)
                return

            // Get other jutsu parameters through input
            var/jutsu_power = input(usr, "Jutsu Power:", "Jutsu Power") in list("N/A", "E-", "E", "E+", "D-", "D", "D+", "C-", "C", "C+", "B-", "B", "B+", "A-", "A", "A+", "S-", "S", "S+")
            var/jutsu_speed = input(usr, "Jutsu Speed:", "Jutsu Speed") in list("N/A", "E-", "E", "E+", "D-", "D", "D+", "C-", "C", "C+", "B-", "B", "B+", "A-", "A", "A+", "S-", "S", "S+")
            var/jutsu_range = input(usr, "Jutsu Range:", "Jutsu Range") as text|null
            var/jutsu_drain = input(usr, "Jutsu Drain:", "Jutsu Drain") in list("N/A", "E", "D", "C", "B", "A", "S")
            var/jutsu_handseals = input(usr, "Jutsu Handseals:", "Jutsu Handseals") as text|null
            var/jutsu_rank = input(usr, "Enter Rank:", "Jutsu Rank") in list("E", "D", "C", "B", "A", "S")
            var/jutsu_element = input(usr, "Jutsu Category:", "Jutsu Category") as text|null
            var/jutsu_description = input(usr, "Enter description:", "New Jutsu") as text|null
            var/jutsu_bottom_description = input(usr, "Enter bottom description:", "New Jutsu") as text|null

            var/obj/jutsu/J = new()
            J.New(jutsu_name, jutsu_power, jutsu_speed, jutsu_range, jutsu_drain, 
                 jutsu_handseals, jutsu_rank, jutsu_element, jutsu_description, 
                 jutsu_bottom_description)

            GLOBAL_JUTSU_MANAGER.jutsu_list += J
            GLOBAL_JUTSU_MANAGER.save_jutsu()
            world << "Jutsu <a href='?src=\ref[J];view=1'>[jutsu_name]</a> has been added!"

        view_jutsu_list()
            set name = "View Jutsu List"
            set category = "Owner"
            
            var/html = "<h1>Jutsu Database</h1>"
            html += "<style>"
            html += "table { width: 100%; border-collapse: collapse; }"
            html += "th, td { padding: 8px; text-align: left; border: 1px solid #ddd; }"
            html += "th { background-color: #f2f2f2; }"
            html += "</style>"
            html += "<table>"
            html += "<tr><th>Name</th><th>Rank</th><th>Element</th><th>Power</th></tr>"
            
            for(var/obj/jutsu/J in GLOBAL_JUTSU_MANAGER.jutsu_list)
                html += "<tr>"
                html += "<td><a href='?src=\ref[J];view=1'>[J.jutsu_name]</a></td>"
                html += "<td>[J.jutsu_rank]</td>"
                html += "<td>[J.jutsu_element]</td>"
                html += "<td>[J.jutsu_power]</td>"
                html += "</tr>"
            
            html += "</table>"
            usr << browse(html, "window=jutsu_list;size=600x400;can_close=1")

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
            world << "Jutsu '[choice]' has been deleted!"


proc/get_jutsu_icon(jutsu_element)
    switch(jutsu_element)
        if("Katon")
            jutsu_element = "https://i.ibb.co/kgLFmPgX/latest.png"
            world << "Katon"
        if("Suiton")
            jutsu_element = "https://i.ibb.co/sJHW4GdF/latest4.png"
            world << "Suiton"
        if("Raiton")
            jutsu_element = "https://i.ibb.co/S4SdQ02w/latest5.png"
            world << "Raiton"
        if("Doton")
            jutsu_element = "https://i.ibb.co/qPb4hRv/latest2.png"
            world << "Doton"
        if("Fuuton")
            jutsu_element = "https://i.ibb.co/35JLPs6g/latest3.png"
            world << "Fuuton"
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
