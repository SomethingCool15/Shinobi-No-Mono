datum/village
    var
        name
        list/players = list()
        list/clans = list()
        economy = 15000
        kage

    proc/add_player(mob/player)
        players += player
        player.village = src

    proc/remove_player(mob/player)
        players -= player
        player.village = "Missing"

    proc/increase_economy(amount)
        economy += amount

    