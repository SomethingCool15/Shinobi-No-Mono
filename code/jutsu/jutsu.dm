/obj/jutsu
    var/jutsu_name
    var/jutsu_desc
    var/jutsu_rank
    var/jutsu_type
    var/jutsu_category
    var/chakra_cost
    var/content

    New(new_jutsu_name, new_jutsu_desc, new_jutsu_rank, new_cost, new_jutsu_category, new_jutsu_type)
        ..()
        jutsu_name = new_jutsu_name
        jutsu_desc = new_jutsu_desc
        jutsu_rank = new_jutsu_rank
        jutsu_type = new_jutsu_type
        jutsu_category = new_jutsu_category
        chakra_cost = new_cost
        setup_content()
    
    proc/show_jutsu(jutsu_name)
        world << "[usr] has activated a technique! <a href='?src=\ref[src];jutsu=[jutsu_name]'>[jutsu_name]</a>"

    Topic(href, href_list)
        if(href_list["jutsu"])
            var/jutsu_name = href_list["jutsu"]
            usr << browse(content, "window=jutsu_[jutsu_name];size=400x500;can_close=1")

    proc/setup_content()
        content = {"
            <html>
                <head>
                    <style>
                        body { padding: 10px; }
                        h1 { color: #333; }
                        .jutsu-info { margin: 10px 0; }
                    </style>
                </head>
                <body>
                    <h1>[jutsu_name]</h1>
                    <div class='jutsu-info'>
                        <p><strong>Rank:</strong> [jutsu_rank]</p>
                        <p><strong>Chakra Cost:</strong> [chakra_cost]</p>
                        <p><strong>Description:</strong></p>
                        <p>[jutsu_desc]</p>
                    </div>
                </body>
            </html>
        "}

    // Handle double-click from stat panel
    DblClick()
        if(usr && usr.client)
            show_jutsu(src.jutsu_name)

/obj/jutsu/Rasengan  // Changed from /datum/jutsu/rasengan
    New()
        ..("Rasengan", "A powerful spinning sphere of chakra", "A-Rank", 50)

/obj/jutsu/Chidori  // Changed from /datum/jutsu/chidori
    New()
        ..("Chidori", "Lightning blade technique", "A-Rank", 50)

/mob/verb/give_jutsu()
    set name = "Give Jutsu"
    set category = "IC"
    
    if(!client)
        return
    
    var/obj/jutsu/J = new /obj/jutsu/Rasengan()
    var/obj/jutsu/J2 = new /obj/jutsu/Chidori()
    jutsu_list += J  // Add to jutsu_list instead of inventory
    jutsu_list += J2
    src << "You learned [J.jutsu_name]!"