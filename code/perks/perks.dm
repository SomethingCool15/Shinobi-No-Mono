obj/perk
    var/title
    var/description
    var/requirement
    var/cost

// Beginning of Perk Tree Code.

datum/perktree

	var/mob/treeowner

	var/Pagenum

	var/MaximumPages

	var/page_id

	var/obj/TreeBackgrounds

	var/obj/TreeBG

	var/list/PerkContainer

	var/list/GeneratedTrees = list()

	var/list/nodes

	var/list/lines





	var/list/TreeBGPages = list(
		new/obj/TreeBackgrounds/KatonTreeBG,
		new/obj/TreeBackgrounds/SuitonTreeBG,
		new/obj/TreeBackgrounds/AburameTreeBG
		)





	var/list/KatonTreeConnections = list(
		list(1, 2, 90, 64),    // vertical line up
		list(2, 3, 45, 64),    // diagonal line up-right
		list(2, 4, -45, 64),   // diagonal line up-left
		list(3, 5, 45, 64),    // continue diagonal up-right
		list(4, 6, -45, 64)    // continue diagonal up-left
	)

	proc/PageSort()
		if (!treeowner || !treeowner.client)
			return

		//Pagenum = 1

		usr << "Start of Proc num: [Pagenum]."
		if(Pagenum < 1)
			Pagenum = MaximumPages
		else if(Pagenum > MaximumPages)
			Pagenum = 1

		if(Pagenum >= 0 && Pagenum <= MaximumPages)
			var/p = TreeBGPages[Pagenum]
			usr << "This is the page ID: [p]"
			for (var/obj/TreeBackgrounds/page in TreeBGPages)

				if(page == p)
					usr << "[page] is equal to [p]."
					treeowner.client.screen -= page
					treeowner.client.screen += page

					// This is the beginning of the code that sets up the SkillTree Nodes/Lines.
					if (page == TreeBGPages[1]) //  "TreeBGPages[1]" is the Katon Tree
						usr << "Changing Katon Tree Node Matrix."
						page.vis_contents = list()
						nodes = list()
						lines = list()



						// Create and position lines based on connections
						for(var/list/connection in KatonTreeConnections)
							var/obj/InterfaceIcons/BlankLine/NewLine = new
							NewLine.alpha = 255
							// Calculate line position and rotation
							var/angle = connection[3]
							NewLine.transform = turn(NewLine.transform, angle)
							// Position line based on nodes it connects
							var/base_x = 200  // center x position
							var/base_y = 100  // base y position
							NewLine.pixel_x = base_x + (connection[1] * 80)
							NewLine.pixel_y = base_y + (connection[2] * 80)
							lines += NewLine
							page.vis_contents += NewLine
							GeneratedTrees += NewLine

						for (var/i = 1 to page.PerkAmount)
							var/obj/InterfaceIcons/BlankNode/NewNode = new
							page.vis_contents += NewNode
							NewNode.alpha = 255
							NewNode.pixel_x = (i + 1) *32
							NewNode.pixel_y = 200
							GeneratedTrees += NewNode
							usr << "KatonNode iteration: [i]"

							// Code above is for spawning and positioning the Tree's (Katons) Nodes, the code below will be for rotating.


					if (page == TreeBGPages[2]) // The Suiton Tree
						usr << "Changing Suiton Tree Node Matrix.]"
						page.vis_contents = list() // empty out the list


						for (var/i = 1 to page.PerkAmount)
							var/obj/InterfaceIcons/BlankLine/NewLine = new
							page.vis_contents += NewLine
							NewLine.alpha = 255
							NewLine.pixel_x = (i + 1) *32
							NewLine.pixel_y = 400
							GeneratedTrees += NewLine
							usr << "SuitonLine iteration: [i]"
							NewLine.transform = turn(NewLine.transform, 45)



						for (var/i = 1 to page.PerkAmount)
							var/obj/InterfaceIcons/BlankNode/NewNode = new
							page.vis_contents += NewNode
							NewNode.alpha = 255
							NewNode.pixel_x = (i + 1) *32
							NewNode.pixel_y = 200
							GeneratedTrees += NewNode
							usr << "SuitonNode iteration: [i]"

					if (page == TreeBGPages[3]) // The Aburame Tree
						usr << "Changing Aburame Tree Node Matrix.]"
						page.vis_contents = list() // empty out the list


						for (var/i = 1 to page.PerkAmount)
							var/obj/InterfaceIcons/BlankLine/NewLine = new
							page.vis_contents += NewLine
							NewLine.alpha = 255
							NewLine.pixel_x = (i + 1) *32
							NewLine.pixel_y = 400
							GeneratedTrees += NewLine
							usr << "AburameLine iteration: [i]"
							NewLine.transform = turn(NewLine.transform, 45)



						for (var/i = 1 to page.PerkAmount)
							var/obj/InterfaceIcons/BlankNode/NewNode = new
							page.vis_contents += NewNode
							NewNode.alpha = 255
							NewNode.pixel_x = (i + 1) *32
							NewNode.pixel_y = 200
							GeneratedTrees += NewNode
							usr << "AburameNode iteration: [i]"



								// Code above is for spawning and positioning the Tree's Nodes. Need to tweak so they're positioned properly.





				else if (page ==! p)
					Pagenum = Pagenum
					usr << "There is no page that exists."

				//usr << "End of Proc num: [Pagenum]."




	proc/ShowSkillTree()
		winset(usr, "NewPerkTree", "is-visible = true")
		PageSort()



	proc/NextPage1()
		if(Pagenum <= MaximumPages)
			Pagenum += 1
			usr << "Turning to page [Pagenum]."
	

		//	else

			//	Pagenum = 1

			//PageSort()

		if(!length(GeneratedTrees) == 0)
			for (var/obj/treepart in GeneratedTrees) 
				del treepart
				GeneratedTrees = list()                         // code is for deleting trees from page to page so that the right tree layout can be displayed
				usr << "Deleted generated tree parts.[GeneratedTrees]"
		PageSort()
		usr << "GeneratedTrees Length: [GeneratedTrees.len]"



	proc/PreviousPage1()
		if(Pagenum > 0)
			Pagenum -= 1
			usr << "Turning to page [Pagenum]."

		//	else

			//	Pagenum = MaximumPages

				//PageSort()

		if(!length(GeneratedTrees) == 0)
			for (var/obj/treepart in GeneratedTrees)
				del treepart
				GeneratedTrees = list()
				usr << "Deleted generated tree parts.[GeneratedTrees]"
		else usr << "You can't go back any further."
		PageSort()
		usr << "GeneratedTrees Length: [GeneratedTrees.len]"



	New(mob/M)
		treeowner = M
		MaximumPages = length(TreeBGPages)
		Pagenum = 1



// end of skill tree code (pretty sure it works but shoutout to byond BETA for sucking)



//beginning of perk code

/obj/perk
	var/perk_name 
	var/perk_desc // perk fluff
	var/perk_note // actual perk effect
	var/perk_tier // tier, e.g adept, expert, etc or just none
	var/perk_category // category, e.g genjutsu, katon, doton etc
	var/perk_cost
	var/perk_requirements
	var/content



	New(new_perk_name, new_perk_desc, new_perk_note, new_perk_tier, new_perk_category, new_perk_cost, new_perk_requirements)
		..()
		perk_name = new_perk_name
		perk_desc = new_perk_desc
		perk_note = new_perk_note
		perk_tier = new_perk_tier
		perk_category = new_perk_category
		perk_cost = new_perk_cost
		perk_requirements = new_perk_requirements
		setup_content()



	proc/show_perk(perk_name)
		world << "[usr] has activated a perk! <a href='?src=\ref[src];perk=[perk_name]'>[perk_name]</a>"

	

	Topic(href, href_list)
		if(href_list["perk"])
			var/perk_name = href_list["perk"]
			usr << browse(content, "window=perk_[perk_name];size=800x400;can_close=1")
    
	proc/setup_content()
		content = {"<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Perks</title>
    <style>
        body {
            background: #F5E9DC;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .perk-container {
            background: #f5e9dc; /* Scroll background */
            border: 10px solid #636b2f; /* Outer border */
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
            position: relative;
            width: 70%; /* Wider than tall */
            max-width: 800px;
            height: auto;
            display: flex;
            flex-direction: row;
            align-items: center;
        }

        .perk-content {
            background: #fffaf0; /* Inner parchment color */
            border: 2px solid #636b2f;
            padding: 20px;
            border-radius: 10px;
            text-align: left;
            flex: 1;
            position: relative;
        }

        .Title {
            background: linear-gradient(#dbc3a3, #d2b48c);
            padding: 10px;
            font-size: 24px;
            font-weight: bold;
            color: #2d2d2d;
            text-shadow: 1px 1px 2px black;
            border-radius: 10px;
            margin-bottom: 10px;
            text-align: center;
            position: relative;
        }

        .icon {
            width: 60px; /* Adjust size */
            height: 60px;
            margin-right: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 3px solid #636b2f; /* Match border color */
            border-radius: 5px;
            background: #f5e9dc; /* Match outer container background */
            padding: 5px;
        }

        .icon img {
            width: 100%;
            height: auto;
            border: none;
            border-radius: 0;
        }

        .perk-description {
            font-size: 16px;
            color: #2d2d2d;
            margin-bottom: 10px;
        }

        .perk-notes {
            font-size: 14px;
            font-style: italic;
            color: #636b2f;
        }
    </style>
</head>
<body>

    <div class="perk-container">
        <div class="icon">
            <img src="https://i.ibb.co/fYQhFydC/No-Image-Selected.png" alt="Icon">
        </div>
        <div class="perk-content">
            <div class="Title">[perk_name]</div>
            <div class="perk_desc">Desc:[perk_desc]</div>
            <div class="perk_note">Note:[perk_note]</div>
        </div>
    </div>

</body>
</html>
        "}
    
	DblClick()
		if(usr && usr.client)
			show_perk(src.perk_name)





/obj/perk/Shikyaku_Master

	New()
		..("Shikyaku Master","This character has trained for a great portion of their lifetime to master the techniques and strategies of the Inuzuka Clan. They could be considered a true master of their craft.","This perk grants techniques with 'Tsuuga' in their name +3 steps of Power.","Master","Inuzuka",15)


/mob/verb/give_perk()
	set name = "Give Perk"
	set category = "IC"

	if(!client)
		usr << "Perk not given."
		return

	var/obj/perk/p = new /obj/perk/Shikyaku_Master()
	perk_list += p
	src << "You purchased this perk: [p.perk_name]"