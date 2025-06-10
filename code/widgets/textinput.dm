/*
On-screen input controls allow you to define text entry fields that use an HTML control layered over the map to handle the text entry on the client side.

This is more responsive and flexible than just about any other method. However, it doesn't obey any masking you might have set up, and it can potentially clip out of the map.

The text field will receive updates on focus loss or pressing Enter or Escape while it is focused, so there may be a little bit of flickering.

Override Value() to respond to changes in the text field.

You may need to pass additional fonts to the user during InitializeInputs().

This widget will construct the browsers it needs on world startup. At this time, only inputs in the main map control are supported.
	If you use multiple maps, you are on your own for support.
*/

client
	//override InitializeUI() to add on-screen input management setup code
	InitializeUI()
		InitializeInputs()
		..()

	proc
		#ifndef HUDLIB_INPUT_INFO
			#warn InitializeInputs is called from InitializeUI(). Click here for more info or define HUDLIB_INPUT_INFO to dismiss this warning
		#endif
		//InitializeInputs should be called to set up the textinput widget managers. This will send the necessary HTML/JS code to the client on connection.
		//The MAP_BROWSER_HTML creates a browser widget that matches your map's size, position, and anchors. This is used to help position inputs over the map.
		//The MAP_INPUT_HTML acts as an input widget that matches the on-screen input widget's size, position, style, etc. This is used to actually handle input processing.
		InitializeInputs()
			set waitfor = 0

			var/params = params2list(winget(src,":map","parent;pos;size;anchor1;anchor2")) + list("type"="browser","is-visible"="false","on-size"=@'.winset ":map.focus=true"')

			winset(src,"mapbrowser",params)
			winset(src,"hudinput",list("parent"=params["parent"],
									   "type"="browser",
									   "size"="1x1",
									   "pos"="-1,-1",
									   "is-visible"="true"))

			src << output(MAP_BROWSER_HTML,"mapbrowser")
			src << output(MAP_INPUT_HTML,"hudinput")

	verb
		//handle callbacks from focused on-screen input controls
		onTextInput(focus as text, value = "" as text|null)
			set hidden = 1, instant = 1
			locate(focus)?:Value(url_decode(value))


hud/widget/textinput
	var/tmp
		//stores the current raw text of the control
		value = ""

		//maptext stylesheet for the control
		maptext_style

		//stylesheet for the control when rendered in the browser
		html_style

	//override New to update the maptext of this input field. either maptext or value can be set to the raw text. The stylesheet will be applied.
	New(loc,hud/hud)
		if(value)
			Value(value)
		else if(maptext)
			Value(maptext)
		..()

	//When this control is clicked on, we need to notify the screen manager of where the mouse hit happened and tell it to open an input control on the screen at that location
	MouseDown(atom/location,control,params)
		var/list/p = params2list(params)
		var/client/client = usr.client
		client << output(list2params(list(p["screen-loc"],"[text2num(p["icon-x"]) - 1 + maptext_x]x[text2num(p["icon-y"]) -1 + maptext_y]","[maptext_width]x[maptext_height]",client.view,world.icon_size,"\ref[src]",html_style||maptext_style,value)),"mapbrowser:onTextInput")

	proc
		//called when the text of this field has been changed
		Value(value)
			src.value = value
			maptext = "<style>[maptext_style]</style>[value]"


//define the browser code for doing client-side screen positioning of input elements
var/const/MAP_BROWSER_HTML = @(__"""__)
<!doctype html>
<html>
<head>
<script type="text/javascript" defer>

var active_control;

function screenloc(string,icon_size) {
	let items = string.split(/[:,]/);
	return {"x": (parseInt(items[0]) - 1) * icon_size + (parseInt(items[1]) - 1), "y": (parseInt(items[2]) - 1) * icon_size + (parseInt(items[3]) - 1)};
}

function sizestr(string) {
	let items = string.split(/[x,]/);
	return {"x": parseInt(items[0]), "y": parseInt(items[1])};
}

function onTextInput(screen,handle,size,view,icon_size,field_id,style,content) {
	icon_size = parseInt(icon_size);
	screen = screenloc(screen,icon_size);
	handle = sizestr(handle);
	view = sizestr(view);
	size = sizestr(size);

	let wndx = (view.x * icon_size - window.innerWidth) / -2 + screen.x - handle.x;
	let wndy = (view.y * icon_size - window.innerHeight) / 2 + window.innerHeight - screen.y - size.y + handle.y;

	active_control = field_id;

	BYOND.winset("[[parent as raw]].hudinput",{"pos": `${wndx},${wndy}`,
									 "size":`${size.x}x${size.y}`,
									 "is-visible": "true",
									 "focus": "true"});

	BYOND.winset("",{"command": `.output [[parent as raw]].hudinput:onTextInput "${encodeURIComponent(style)}&${encodeURIComponent(content||"")}&${encodeURIComponent(field_id)}"`});
}
</script>
</head>
<body>
</body>
</html>
__"""__

//define the browser code for doing client-side styling and handling of input elements
var/const/MAP_INPUT_HTML = @(__"""__)
<!doctype html>
<html>
<head>
<style>
HTML { height: 100%; }
BODY { height: 100%; display: flex; margin: 0}
INPUT { flex-grow: 1; outline: 0; border: 0; padding: 0;};
</style>
<script type="text/javascript" defer>

var active_control;

function onTextInput(style,content,field_id) {
	active_control = field_id;
	field.value = content;
	console.log(style);
	field.style = style.substring(style.indexOf('{')+1,style.indexOf('}')-1);
	field.focus();
}

function fieldBlur() {
	BYOND.winset("",{"command": `onTextInput "${active_control}" "${encodeURIComponent(field.value)}\n.winset "[[parent as raw]].hudinput.is-visible=false;[[parent as raw]].hudinput.pos=-1,-1;[[parent as raw]].hudinput.size=1x1;"`});
	field.value = "";
	active_control = null;
}

function forceBlur() {
	BYOND.winset(":map",{"focus": "true"});
}

function fieldKey(event) {
	switch(event.key) {
		case "Escape":
		case "Enter":
			forceBlur();
			event.preventDefault();
			event.stopPropagation();
			return;
	}
}

window.addEventListener('load', function() {
	field.addEventListener('blur',fieldBlur);
	field.addEventListener('keydown',fieldKey);
});

</script>
</head>
<body>
<input type="text" id="field" spellcheck="false"/>
</body>
</html>
__"""__