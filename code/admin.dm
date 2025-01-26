var/list/admin1 = list()
var/list/admin2 = list()
var/list/admin3 = list()
var/list/admin4 = list()
var/list/admin5 = list("passingskies")
var/list/owners = list("gucci3rdleg")
var/list/village_ranks = list("Academy Student", "Genin", "Chunin", "Jounin", "Special Jounin", "Hokage", "Kazekage", "Mizukage")
var/list/criminal_ranks = list("Akatsuki", "Sound Five")
var/list/rank_objects = list(
    "Hokage" = /obj/rank/hokage,
)

proc
    admin_check(ckey)
        if(ckey in admin5)
            usr.verbs += typesof(/admin5/verb)

admin5
    verb
        give_rank(player/P as mob in world, rank_type as anything in list("Village Ranks", "Criminal Ranks"))
            set category = "Admin Actions"
            set name = "Give Rank"

            var/list/ranks
            if(rank_type == "Village Ranks")
                ranks = village_ranks
            else if(rank_type == "Criminal Ranks")
                ranks = criminal_ranks

            var/rank = input("Choose a rank") in ranks
            P.rank = rank // Assign the chosen rank to the player

            var/type = rank_objects[rank]
            if(type)
                var/obj/rank_obj = new type(P) // Create the rank object using the mapping
                P.contents += rank_obj // Add the rank object to the player's contents
                P << "You have been given the rank of [rank]!"
            else
                usr << "Error: No object defined for rank [rank]."

        award_points(player/P as mob in world, points as num)
            set category = "Admin Actions"
            set name = "Award Points"
            P.totalPP += points
            P.unspentPP += points
            P << "You have been awarded [points] points!"