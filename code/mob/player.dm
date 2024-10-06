player
    parent_type = /mob
    icon = 'icons/base/Base_Pale.dmi'
        
    Login()
        ..()
        playerList += src

    Logout()
        playerList -= src
        ..()