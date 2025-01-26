obj/rank
    var/rank_name

    New(name)
        rank_name = name
        ..()
        
obj/rank/hokage
    verb
        declare_war()
            set category = "Hokage Actions"
            set name = "Declare War"
            usr << "You have declared war!"

        make_announcement()
            set category = "Hokage Actions"
            set name = "Make Village Announcement"
            usr << "You have made a village announcement."