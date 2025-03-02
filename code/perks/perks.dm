// Beginning of Perk Tree Code.

var/global/datum/perk_manager/GLOBAL_PERK_MANAGER = new()


/datum/perktree

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
	var/perk_desc
	var/perk_note
	var/perk_tier
	var/perk_category
	var/perk_cost
	var/perk_icon
	var/content
	var/perk_verb
	var/perk_statboost
	var/list/category_icons = list(
		"Katon" = list(
			"file" = 'icons/PerkIcons/KatonTree.dmi',
			"states" = list("KatonTraining" = 1, "Incendiary" = 2, "FireResistance" = 3)
		),
		"Suiton" = list(
			"file" = 'icons/PerkIcons/SuitonTree.dmi',
			"states" = list("SuitonTraining")
		),
		"Doton" = list(
			"file" = 'icons/PerkIcons/DotonTree.dmi',
			"states" = list("DotonTraining")
		),
		"Raiton" = list(
			"file" = 'icons/PerkIcons/RaitonTree.dmi',
			"states" = list("RaitonTraining")
		),
		"Fuuton" = list(
			"file" = 'icons/PerkIcons/FuutonTree.dmi',
			"states" = list("FuutonTraining")
		),
		"Shurikenjutsu" = list(
			"file" = 'icons/PerkIcons/ShurikenjutsuTree.dmi',
			"states" = list("ShurikenjutsuTraining")
		),
		"Genjutsu" = list(
			"file" = 'icons/PerkIcons/GenjutsuTree.dmi',
			"states" = list("TriggerMaster", "ShacklesOfPain")
		) 

	)

	New(new_perk_name, new_perk_desc, new_perk_note, new_perk_tier, new_perk_category, new_perk_cost, new_perk_icon)
		..()
		name = new_perk_name
		perk_name = new_perk_name
		perk_desc = new_perk_desc
		perk_note = new_perk_note
		perk_tier = new_perk_tier
		perk_category = new_perk_category
		perk_cost = new_perk_cost
		perk_icon = new_perk_icon

	proc/show_perk(perk_name)
		world << "[usr] has activated a perk! <a href='?src=\ref[src];perk=[perk_name]'>[perk_name]</a>"

	Topic(href, href_list)
		if(href_list["perk"])
			var/perk_name = href_list["perk"]
			usr << browse(content, "window=perk_[perk_name];size=800x400;can_close=1")
	

	
	DblClick()
		if(usr && usr.client)
			show_perk(src.perk_name)


	proc/get_formatted_html(var/mob/viewer, var/mob/performer = null)
		var/display_html = perk_desc

		display_html = replacetext(display_html, "{perk_name}", perk_name)
		display_html = replacetext(display_html, "\[icon_url]", perk_name) // get_perk_icon(null) // need to figure out where im getting the icon from
		display_html = replacetext(display_html, "{databook}", "<a href='?src=\ref[GLOBAL_DATABOOK];") 

	proc/get_stat_text()
		if(perk_icon)
			return "<img src='[perk_icon]' width='16' height='16'> [perk_name]"
		return "[perk_name]"  // Return just the name if no icon

proc/add_perk()
	var/template_choice = input("Select the Perk template type:") as null|anything in list("Pre-set Template (Enter Title, Desc etc)", "Custom Template (Enter HTML)")
	if(!template_choice)
		usr << "Perk Creation cancelled."
		return

	var/perk_name = input("Enter perk name:") as null|text
	if(isnull(perk_name))
		usr << "Perk creation cancelled."
		return
	while(length(perk_name) < 1 || perk_name == "")
		usr << "Perk name cannot be empty."
		perk_name = input("Enter perk name:") as null|text
		
	var/perk_desc
	var/perk_note
	
	if(template_choice == "Pre-set Template (Enter Title, Desc etc)")
		perk_desc = input("Enter perk description:") as null|text
		if(isnull(perk_desc))
			usr << "Perk Creation cancelled."
			return
		while(length(perk_desc) < 1 || perk_desc == "")
			usr << "Perk description cannot be empty."
			perk_desc = input("Enter perk description:") as null|text

		perk_note = input("Enter perk notes:") as null|text
		if(!perk_note)
			usr << "Perk creation cancelled."
			return
		while(length(perk_note) < 1 || perk_note == "")
			usr << "Perk notes cannot be empty."
			perk_note = input("Enter perk notes:") as null|text
	
	var/perk_tier = input("Select perk tier:") as null|anything in tierslist
	if(isnull(perk_tier))
		usr << "Perk creation cancelled."
		return
	if(tierslist == "None")
		usr << "Perk tier set to 'None'."
		tierslist = ""
		
	var/perk_category = input("Select perk category:") as null|anything in categorylist
	if(isnull(perk_category))
		usr << "Perk creation cancelled."
		return
	if(categorylist == "None")
		categorylist = ""
		
	var/perk_cost = input("Enter perk PP cost:") as null|num
	if(isnull(perk_cost))
		usr << "Perk creation cancelled."
		return
	while(perk_cost < 1)
		usr << "Perk cost cannot be less than 1."
		perk_cost = input("Enter perk PP cost:") as null|num
		return
	var/perk_requirements = input("Please choose from the list of requirements.") as null|anything in GLOBAL_PERK_MANAGER.perk_list + "None"
	if(isnull(perk_requirements))
		usr << "Perk creation cancelled."
		return
	else if(perk_requirements == "None")
		perk_requirements = ""
		usr << "Perk requirement set to 'None'. [perk_requirements]"

	var/icon_html
	var/obj/perk/P = new()
	if(P.category_icons[perk_category])
		var/list/icon_data = P.category_icons[perk_category]
		if(icon_data["file"])

			icon_data = input(usr,"","Choose an icon from the list:" ) as anything in P.category_icons.[perk_category]["states"]
			icon_html = "<img class='icon' src=\ref[icon_data["file"]]>"
			//perk_icon = icon_data
			usr << "Icon for [perk_category] assigned."
	else
		usr << "No Icon found for this category."
		return

	var/perk_html
	if(template_choice == "Pre-set Template (Enter Title, Desc etc)")
		perk_html = {"<!DOCTYPE html>
			<html>
			<head>
				<meta charset="UTF-8">
				<title>Perk</title>
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
						width: 32px;  // Reduced from 60px
						height: 32px; // Reduced from 60px
						margin-right: 10px; // Reduced margin
						display: flex;
						align-items: center;
						justify-content: center;
						border: 2px solid #636b2f; // Reduced border thickness
						border-radius: 3px; // Reduced border radius
						background: transparent; // Changed from #f5e9dc to transparent
						padding: 3px; // Reduced padding
					}

					.icon img {
						width: 100%;
						height: 100%; // Added height to maintain aspect ratio
						border: none;
						border-radius: 0;
						object-fit: contain; // Added to ensure icon fits properly
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
						[icon_html]
					</div>
					<div class="perk-content">
						<div class="Title">[perk_name]</div>
						<div class="perk_desc"><i>Desc</i>:[perk_desc]</div>
						<div class="perk_note"><i>Note</i>:[perk_note]</div>
					</div>
				</div>

			</body>
			</html>"}
	else
		perk_html = input(usr, "Enter the complete HTML template:", "Perk HTML") as null|message
		if(!perk_html)
			usr << "Perk creation cancelled."
			return
		if(length(perk_html) < 1)
			usr << "HTML template cannot be empty."
			return

	var/obj/perk/new_perk = new()
	new_perk.New(perk_name, perk_desc, perk_note, perk_tier, perk_category, perk_cost)
	new_perk.content = perk_html // need to make this work similarly to the jutsu_list
	GLOBAL_PERK_MANAGER.perk_list += new_perk
	GLOBAL_PERK_MANAGER.save_perks()
	usr << "Created new perk: [perk_name]"

admin5/verb
	create_perk()
		set category = "Owner"
		set name = "Create Perk"
		add_perk()

owner/verb
	create_perk()
		set category = "Owner"
		set name = "Create Perk"
		add_perk()

	view_perk_list()
		set name = "View Perk List"
		set category = "Owner"
		
		if(!GLOBAL_PERK_MANAGER.perk_list.len)
			usr << "No perks have been created yet."
			return
		
		var/html = {"
			<html>
			<head>
				<style>
					body {
						font-family: Arial, sans-serif;
						padding: 20px;
					}
					table { 
						width: 100%; 
						border-collapse: collapse; 
					}
					th, td { 
						padding: 8px; 
						text-align: left; 
						border: 1px solid #636b2f; 
					}
					th { 
						background-color: #d2b48c;
						color: #2d2d2d;
					}
					.perk-icon {
						width: 24px;
						height: 24px;
						vertical-align: middle;
					}
				</style>
			</head>
			<body>
				<h2>Available Perks</h2>
				<table>
					<tr>
						<th>Icon</th>
						<th>Name</th>
						<th>Category</th>
						<th>Tier</th>
						<th>Cost</th>
					</tr>
		"}
		
		for(var/obj/perk/P in GLOBAL_PERK_MANAGER.perk_list)
			html += {"
				<tr>
					<td><img src='[P.perk_icon]' class='perk-icon'></td>
					<td><a href='?src=\ref[P];perk=[P.perk_name]'>[P.perk_name]</a></td>
					<td>[P.perk_category]</td>
					<td>[P.perk_tier]</td>
					<td>[P.perk_cost]</td>
				</tr>
			"}
		
		html += "</table></body></html>"
		usr << browse(html, "window=perk_list;size=520x680;can_close=1;can_resize=1")

	give_perk()
		set name = "Give Perk"
		set category = "IC"
		
		if(!GLOBAL_PERK_MANAGER.perk_list.len)
			usr << "No perks available to give. Please try again later."
			return
			
		var/list/players = list()
		for(var/mob/M in world)
			if(M.client)
				players[M.name] = M
				
		var/player_choice = input("Select player to give perk to:") as null|anything in players
		if(!player_choice)
			return
			
		var/list/perk_names = list()
		for(var/obj/perk/P in GLOBAL_PERK_MANAGER.perk_list)
			perk_names[P.perk_name] = P
			
		var/perk_choice = input("Select perk to give:") as null|anything in perk_names
		if(!perk_choice)
			return
			
		var/mob/player = players[player_choice]
		var/obj/perk/chosen_perk = perk_names[perk_choice]
		
		player.perk_list += chosen_perk
		player << "You have been given the perk: [chosen_perk.perk_name]"
		usr << "Gave [chosen_perk.perk_name] to [player_choice]"
	
	edit_perk()
		set name = "Edit Perk"
		set category = "Owner"

		if(!GLOBAL_PERK_MANAGER.perk_list.len)
			usr << "No perks available to edit."
			return
	
		var/list/editable_perks = list()
		for(var/obj/perk/P in GLOBAL_PERK_MANAGER.perk_list)
			editable_perks[P.perk_name] = P
		
		var/choice = input(usr, "Select Perk to edit:", "Edit Perk") as null|anything in editable_perks
		if(isnull(choice))
			usr << "Perk editing cancelled."
			return
		

		var/obj/perk/perk = editable_perks[choice]
		
		var/new_name = input(usr, "Edit perk name:", "Edit Perk", perk.perk_name) as text|null
		if(isnull(new_name))
			return
		while(length(new_name) < 1||new_name == "")
			usr << "Perk name cannot be empty."
			new_name = input(usr, "Edit perk name:", "Edit Perk", perk.perk_name) as text|null

		var/new_desc = input(usr, "Edit perk description:", "Edit Perk", perk.perk_desc) as text|null
		if(isnull(new_desc))
			usr << "Perk creation cancelled."
			return
		while(length(new_desc) < 1 || new_desc == "")
			usr << "Perk desc cannot be empty."
			new_desc = input(usr, "Edit perk description:", "Edit Perk", perk.perk_desc) as text|null

		var/new_note = input(usr, "Edit perk effect:", "Edit Perk", perk.perk_note) as text|null
		if(isnull(new_note))
			usr << "Perk creation cancelled."
			return
		while(length(new_note) < 1 || new_note == "")
			usr << "Perk note cannot be empty."
			new_note = input(usr, "Edit perk effect:", "Edit Perk", perk.perk_note) as text|null

		var/new_tier = input(usr, "Edit perk tier:", "Edit Perk", perk.perk_tier) as null|anything in tierslist
		if(isnull(new_tier))
			usr << "Perk creation cancelled."
			return
		if(new_tier == "None")
			usr << "Perk tier set to 'None'."
			new_tier = ""

		var/new_category = input(usr, "Edit perk category:", "Edit Perk", perk.perk_category) as null|anything in categorylist
		if(isnull(new_category))
			usr << "Perk creation cancelled."
			return
		if(new_category == "None")
			usr << "Perk category set to 'None'."
			new_category = ""

		var/new_cost = input(usr, "Edit PP cost:", "Edit Perk", perk.perk_cost) as null|num
		if(isnull(new_cost))
			usr << "Perk creation cancelled."
			return
		while(new_cost == "" || new_cost < 1)
			usr << "Perk cost cannot be lower than 1."
			new_cost = input(usr, "Edit PP cost:", "Edit Perk", perk.perk_cost) as null|num

		var/icon_html
		if(perk.category_icons[new_category])
			var/list/icon_data = perk.category_icons[new_category]
			if(icon_data["file"])
				icon_html = "<img class='icon' src=\ref[icon_data["file"]]>"
				perk.perk_icon = icon_data
				usr << "Icon for [new_category] assigned."
		else
			usr << "No Icon found for this category."
			return

		// Create new perk with updated values
		var/obj/perk/new_perk = new()
		new_perk.New(new_name, new_desc, new_note, new_tier, new_category, new_cost, icon_html)
		
		// Update the HTML content
		new_perk.content = {"<!DOCTYPE html>
		<html>
		<head>
			<meta charset="UTF-8">
			<title>Perk</title>
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
					width: 32px;  // Reduced from 60px
					height: 32px; // Reduced from 60px
					margin-right: 10px; // Reduced margin
					display: flex;
					align-items: center;
					justify-content: center;
					border: 2px solid #636b2f; // Reduced border thickness
					border-radius: 3px; // Reduced border radius
					background: transparent; // Changed from #f5e9dc to transparent
					padding: 3px; // Reduced padding
				}

				.icon img {
					width: 100%;
					height: 100%; // Added height to maintain aspect ratio
					border: none;
					border-radius: 0;
					object-fit: contain; // Added to ensure icon fits properly
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
					[icon_html]
				</div>
				<div class="perk-content">
					<div class="Title">[new_name]</div>
					<div class="perk_desc"><i>Desc</i>:[new_desc]</div>
					<div class="perk_note"><i>Note</i>:[new_note]</div>
				</div>
			</div>

		</body>
		</html>"}

		// Update any existing copies players have
		for(var/mob/M in world)
			if(M.client)
				var/list/new_perk_list = list()
				for(var/obj/perk/P in M.perk_list)
					if(P.perk_name == perk.perk_name) 
						new_perk_list += new_perk      
					else
						new_perk_list += P            
				M.perk_list = new_perk_list           
				
		
		GLOBAL_PERK_MANAGER.perk_list -= perk
		GLOBAL_PERK_MANAGER.perk_list += new_perk
		
		GLOBAL_PERK_MANAGER.save_perks()
		
		world << "Perk '[new_name]' has been updated!"

	delete_perk()
		set name = "Delete Perk"
		set category = "Owner"

		var/list/existing_perks = list()
		for(var/obj/perk/P in GLOBAL_PERK_MANAGER.perk_list)
			existing_perks[P.perk_name] = P

		var/deletionchoice = input("Select perk you would like to delete:", "Delete Perk") as null| anything in existing_perks
		if(isnull(deletionchoice))
			usr << "Perk deletion cancelled."
			return
		
		var/obj/perk/selected_perk = existing_perks[deletionchoice]
		GLOBAL_PERK_MANAGER.perk_list -= selected_perk
		GLOBAL_PERK_MANAGER.save_perks()
		usr << "Deleted the following perk: [deletionchoice]"

var/list/tierslist = list("None", "Core", "Training", "Adept", "Expert", "Master", "Grandmaster")
var/list/categorylist = list("Ninjutsu", "Taijutsu", "Genjutsu", "Katon", "Suiton", "Doton", "Raiton", "Fuuton", "Inuzuka", "Aburame", "Hyuga", "Uchiha", "Senju", "Yamanaka", "Akimichi", "Hozuki", "Kaguya", "Yuki", "Hoshigaki", "Ukiyo", "Awa", "Terumi", "None")

/datum/perk_manager
	var/list/perk_list = list()
	var/savefile_path = "data/perk_database.sav"

	New()
		..()
		perk_list = list()

	proc/save_perks()
		var/savefile/S = new(savefile_path)
		var/list/saved_perks = list()
		
		for(var/obj/perk/P in perk_list)
			var/list/perk_data = list(
				"perk_name" = P.perk_name,
				"perk_desc" = P.perk_desc,
				"perk_note" = P.perk_note,
				"perk_tier" = P.perk_tier,
				"perk_category" = P.perk_category,
				"perk_cost" = P.perk_cost,
				"perk_icon" = P.perk_icon,
				"content" = P.content
			)
			saved_perks += list(perk_data)
		
		S.dir.Cut()
		S["perks"] = saved_perks

	proc/load_perks()
		perk_list = list()
		
		if(!fexists(savefile_path))
			save_perks()  // Create empty database if none exists
			return
			
		var/savefile/S = new(savefile_path)
		var/list/loaded_perks
		
		S["perks"] >> loaded_perks
		if(!loaded_perks)
			return
			
		for(var/list/perk_data in loaded_perks)
			var/obj/perk/P = new(
				perk_data["perk_name"],
				perk_data["perk_desc"],
				perk_data["perk_note"],
				perk_data["perk_tier"],
				perk_data["perk_category"],
				perk_data["perk_cost"],
				perk_data["perk_icon"]
			)
			P.content = perk_data["content"]
			perk_list += P

/world/New()
	..()
	//GLOBAL_PERK_MANAGER = new()
	GLOBAL_PERK_MANAGER.load_perks()