/*
	DIALOGUE EDITOR v0.0.1 - Core5570R
 */

// ---      Imports     --- //
import("flixel.addons.ui.FlxUITabMenu");
import("flixel.addons.ui.FlxUIInputText");
import("game.cdev.UIDropDown");
import("flixel.addons.ui.FlxUICheckBox");
import("flixel.addons.ui.FlxUINumericStepper");
import("flixel.ui.FlxButton");
import("sys.io.File");
import("sys.FileSystem");
import("haxe.format.JsonParser");

// ---       Misc       --- //
var status:String = "Dialog";

// 0 = char, 1 = dialog, 2 = boxtype,
// 3 = speed, 4 = position, 5 = spriteanimation, 6 = [0=x, 1=y, 2=flipx]
var currentData = {
	dialog: [["bf", "This is where you will put dialouge.", "normal", 0.05, "r", "normal", [0,0,false]]],
	music: "breakfast"
};

var savedCharacterData:Array<Dynamic> = [];

var currentDialogue:Int = 0;

// --- Sprite Variables --- //
var textBox:FlxSprite;
var currentText:FlxTypeText;
var tab:FlxSprite;
var tabBody:FlxSprite;
var tabVisible:FlxSprite;
var tabGroup:Dynamic;
var tabLabel:FlxText;
var indicator:FlxText;
var currentSprite:FlxSprite = null;

// --- Array Variables  --- //
var buttons:Array<Dynamic> = []; // [[FlxSprite, Label], function]
var currentlyShowing:Array<Dynamic> = [];
var dialog_inputBox:FlxUIInputText;
var dialog_charTalk:FlxUIInputText;
var dialog_charStat:FlxUIInputText;
var dialog_dropDown:UIDropDown;
var dialog_checkBox:FlxUICheckBox;
var dialog_stepper:FlxUINumericStepper;

var dialog_xpos:FlxUINumericStepper;
var dialog_ypos:FlxUINumericStepper;
var dialog_checkFlip:FlxUICheckBox;

var dialog_droppedDown:UIDropDown;

var dialog_stuf = {
	text: ""
};

var settings_inputBox:FlxUIInputText;
var debug = true;

function _loadUI()
{
	// Loading text box.
	textBox = new FlxSprite();
	textBox.frames = Paths.getSparrowAtlas("dialogue/speech_bubble_talking");
	textBox.animation.addByPrefix("start_normal", "Speech Bubble Normal Open", 24, false);
	textBox.animation.addByPrefix("normal_anim", "speech bubble normal", 24, true);
	textBox.animation.addByPrefix("start_loud", "speech bubble loud open", 24, false);
	textBox.animation.addByPrefix("loud_anim", "AHH speech bubble", 24, true);
	textBox.animation.play("normal_anim", true);
	textBox.visible = true;
	textBox.scale.set(0.9, 0.9);
	textBox.screenCenter();
	textBox.x += 30;
	textBox.y += 240;
	add(textBox);

	currentText = new FlxTypeText(textBox.x + 150, textBox.y + 140, textBox.width - (35 + 250), "", 18);
	currentText.setFormat(Paths.font("fnffont"), 32, FlxColor.BLUE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
	add(currentText);
	currentText.borderSize = 3;
	currentText.borderQuality = 1;
	_loadTabMenu();

	var blackBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 22, FlxColor.BLACK);
	blackBG.alpha = 0.6;
	blackBG.y = FlxG.height - 22;
	add(blackBG);

	var info = new FlxText(0, 0, -1,
		"[Q / E] - Change current dialogue // [R] Remove Current dialogue // [A] Add new dialogue // [CTRL + S / L] Save / Load dialog data", 18);
	info.setFormat("VCR OSD Mono", 16, FlxColor.BLUE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
	info.setPosition(10, FlxG.height - 18.5);
	add(info);
	info.antialiasing = true;
	info.borderSize = 2;

	indicator = new FlxText(0, 0, -1, "Dialogue: " + (currentDialogue + 1) + " / " + currentData.dialog.length, 18);
	indicator.setFormat("VCR OSD Mono", 22, FlxColor.BLUE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
	indicator.setPosition(20, 50);
	add(indicator);
	indicator.antialiasing = true;
	indicator.borderSize = 2;
}

function _loadTabMenu()
{
	var buttonList = [
		{
			name: "Dialog",
			func: __UI_Dialog
		},
		{
			name: "Settings",
			func: __UI_Settings
		},

	];
	tab = new FlxSprite().makeGraphic(350, 400, 0xFF000000);
	tab.alpha = 0.4;
	tab.setPosition(FlxG.width - tab.width - 10, 10);
	add(tab);

	var loop:Int = 0;
	for (bt in buttonList)
	{
		var n:FlxSprite = new FlxSprite(tab.x + (((tab.width / buttonList.length)) * loop) + buttonList.length,
			tab.y + 2).makeGraphic((tab.width / buttonList.length) - 4, 30, 0xFF000000);
		n.alpha = 0.4;
		add(n);
		var l:FlxText = new FlxText(0, 0, -1, bt.name, 20);
		l.setFormat("VCR OSD Mono", 16, FlxColor.RED, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
		l.setPosition((n.x + (n.width / 2) - (l.width / 2)), n.y + (n.height / 2) - (l.height / 2));
		add(l);
		buttons.push([[n, l], bt.func]);
		loop++;
	}

	tabBody = new FlxSprite(tab.x + 4, tab.y + 34).makeGraphic(tab.width - 8, tab.height - 38, 0xFF000000);
	tabBody.alpha = 0.4;
	add(tabBody);

	tabVisible = new FlxSprite(tab.x + 4, tab.y + tab.height - 24).makeGraphic(tab.width - 8, 24, 0xFF000000);
	tabVisible.alpha = 0.4;
	add(tabVisible);

	tabLabel = new FlxText(0, 0, -1, "(Press TAB to hide / show this panel)", 18);
	tabLabel.setFormat("VCR OSD Mono", 14, FlxColor.BLUE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
	tabLabel.setPosition(tabVisible.x
		+ (tabVisible.width / 2)
		- (tabLabel.width / 2), tabVisible.y
		+ (tabVisible.height / 2)
		- (tabLabel.height / 2));
	add(tabLabel);
	tabLabel.antialiasing = true;

	__UI_Dialog();
}

var checc:FlxBackdrop;

function create()
{
	FlxG.sound.playMusic(Paths.music("breakfast"), 0);
	FlxG.sound.music.fadeIn(1, 0, 0.6);
	FlxG.camera.bgColor = 0xFF000000;
	var nu = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFa7a7a7);
	add(nu);

	checc = new FlxBackdrop(Paths.image('checker'), FlxAxes.XY);
	add(checc);
	checc.scale.set(0.5, 0.5);
	checc.alpha = 0.2;

	// MAIN GUI STUFF
	_loadUI();

	trace("Dialogue Editor initialized.");
}

function postCreate()
{
	changeCurrent(0);
}

var currentlyVisible = true;
var curOverlap = null;
var last = "";
var lastInputted:String = "";
var lastVal:Float = 0;
var playingSong:String = "breakfast";
var lastXY = [0,0];
function update(e:Float)
{
	FlxG.mouse.visible = true;
	var stuffs = [
		(dialog_inputBox != null ? dialog_inputBox.hasFocus : false),
		(dialog_charTalk != null ? dialog_charTalk.hasFocus : false),
		(settings_inputBox != null ? settings_inputBox.hasFocus : false),
		(dialog_stuf != null ? dialog_stuf.hasFocus : false),
		(dialog_charStat != null ? dialog_charStat.hasFocus : false),
		(dialog_xpos != null ? dialog_xpos.hasFocus : false),
		(dialog_ypos != null ? dialog_ypos.hasFocus : false)
	];
	if (controls.BACK && !stuffs.contains(true))
	{
		FlxG.sound.play(Paths.sound("cancelMenu"), 0.6);
		FlxG.sound.music.fadeOut(0.4, 0);
		current.changeState(new PlayState());
	}

	if (FlxG.keys.justPressed.SPACE && !stuffs.contains(true) && debug)
	{
		trace("reload");
		FlxG.switchState(new CustomState("DialogueEditor"));
	}
	checc.x -= 0.45 / (CDevConfig.saveData.fpscap / 60);
	checc.y -= (0.16 / (CDevConfig.saveData.fpscap / 60));

	if (currentlyVisible)
		for (obj in 0...buttons.length)
		{
			var current:FlxSprite = buttons[obj][0][0];

			if (FlxG.mouse.overlaps(current))
			{
				if (curOverlap != current)
				{
					curOverlap = current;
					FlxG.sound.play(Paths.sound("scrollMenu"), 0.6);
				}
				current.alpha = 0.9;
				if (FlxG.mouse.justPressed)
				{
					FlxG.sound.play(Paths.sound("clickText"), 0.6);
					buttons[obj][1]();
				}
			}
			else
			{
				current.alpha = 0.4;
			}
		}

	if (textBox.animation.curAnim != null)
	{
		if (textBox.animation.curAnim.name == "start_normal" && textBox.animation.curAnim.finished)
		{
			_box_playAnim("normal_anim", true);
		}

		if (textBox.animation.curAnim.name == "start_loud" && textBox.animation.curAnim.finished)
		{
			_box_playAnim("loud_anim", true);
		}
	}

	if (currentText != null)
		if (last != currentText.text)
		{
			last = currentText.text;
			if (!stuffs.contains(true))
				FlxG.sound.play(Paths.sound("dialogue.ogg"));
			if (currentSprite != null)
				currentSprite.animation.play("idle");
		}

	if (FlxG.keys.justPressed.TAB && !stuffs.contains(true))
	{
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.6);
		currentlyVisible = !currentlyVisible;
		for (i in 0...buttons.length)
		{
			buttons[i][0][0].visible = currentlyVisible;
			buttons[i][0][1].visible = currentlyVisible;
		}
		tab.visible = currentlyVisible;
		tabBody.visible = currentlyVisible;
		tabVisible.visible = currentlyVisible;
		tabLabel.visible = currentlyVisible;
		for (i in currentlyShowing)
		{
			i.visible = currentlyVisible;
			i.active = currentlyVisible;
		}
	}

	if (FlxG.keys.justPressed.A && !stuffs.contains(true))
	{
		FlxG.sound.play(Paths.sound("confirmMenu"), 0.6);
		currentData.dialog.push(["bf", "New Dialog Text", "normal", 0.05, "r", "normal", [0,0,false]]);
		currentDialogue = Std.parseInt(currentData.dialog.length - 1);
		changeCurrent(0);
	}

	if (FlxG.keys.justPressed.R && currentData.dialog.length != 1 && !stuffs.contains(true))
	{
		currentData.dialog.remove(currentData.dialog[currentDialogue]);
		changeCurrent(0);
	}

	if (FlxG.keys.justPressed.Q && !stuffs.contains(true))
	{
		changeCurrent(-1);
	}

	if (FlxG.keys.justPressed.E && !stuffs.contains(true))
	{
		changeCurrent(1);
	}

	if (FlxG.keys.pressed.CONTROL && !stuffs.contains(true))
	{
		if (FlxG.keys.justPressed.S)
		{
			if (FileSystem.exists(Paths.currentModFolder("data/charts/" + dialog_stuf.text + "/")))
				saveChar(dialog_stuf.text);
		}
		if (FlxG.keys.justPressed.L)
		{
			if (FileSystem.exists(Paths.currentModFolder("data/charts/" + dialog_stuf.text + "/dialogue.json")))
				loadChar(dialog_stuf.text);
		}
	}

	switch (status)
	{
		case "dialog":
			currentData.dialog[currentDialogue][1] = dialog_inputBox.text;
			if (dialog_inputBox.hasFocus)
			{
				if (lastInputted != currentData.dialog[currentDialogue][1])
				{
					FlxG.sound.play(Paths.sound("dialogue.ogg"),0.6);
					lastInputted = currentData.dialog[currentDialogue][1];
					if (currentText != null)
						currentText.resetText(currentData.dialog[currentDialogue][1]);
					if (currentText != null)
						currentText.start(0.00001, true);
				}
			}

			if (dialog_charTalk.hasFocus)
			{
				currentData.dialog[currentDialogue][0] = dialog_charTalk.text;
				if (lastInputted != dialog_charTalk.text)
				{
					lastInputted = dialog_charTalk.text;
					if (FileSystem.exists(Paths.currentModFolder("images/dialogue/portraits/" + dialog_charTalk.text + ".png")))
					{
						startDialogue();
					}
				}
			}

			if (dialog_charStat.hasFocus)
			{
				currentData.dialog[currentDialogue][5] = dialog_charStat.text;
				if (lastInputted != dialog_charStat.text)
				{
					lastInputted = dialog_charStat.text;
					startDialogue();
				}
			}

			currentData.dialog[currentDialogue][3] = dialog_stepper.value;
			if (lastXY[0] != dialog_xpos.value ||lastXY[1] != dialog_ypos.value){
				lastXY = [dialog_xpos.value, dialog_ypos.value];
				currentData.dialog[currentDialogue][6][0] = dialog_xpos.value;
				currentData.dialog[currentDialogue][6][1] = dialog_ypos.value;
				startDialogue();
			}

			if (lastVal != currentData.dialog[currentDialogue][3])
			{
				startDialogue();
				lastVal = currentData.dialog[currentDialogue][3];
			}

			if (FlxG.keys.justPressed.ENTER && stuffs.contains(true))
			{
				for (i in stuffs)
				{
					i = false;
				}
			}
		case "settings":
			currentData.music = settings_inputBox.text;
			if (lastInputted != settings_inputBox.text)
			{
				lastInputted = settings_inputBox.text;
				if (Paths.music(settings_inputBox.text + ".ogg") != "assets/music/" + settings_inputBox.text + ".ogg")
					updateSong(currentData.music);
			}
	}
}

function updateSong(to)
{
	// if (Paths.music(to+".ogg") != null)
	// {
	//	trace("exists");
	if (playingSong != to)
	{
		trace(to);
		playingSong = to;
		FlxG.sound.music.stop();
		FlxG.sound.playMusic(Paths.music(to + ".ogg"), 0);
		FlxG.sound.music.fadeIn(1, 0, 0.8);
	}
	// }
}

function changeCurrent(?change:Int = 0)
{
	// FlxG.sound.play(Paths.sound("scrollMenu"), 0.6);
	currentDialogue += change;
	if (currentDialogue < 0)
		currentDialogue = currentData.dialog.length - 1;
	if (currentDialogue > currentData.dialog.length - 1)
		currentDialogue = 0;
	switch (status)
	{
		case "dialog":
			dialog_inputBox.text = currentData.dialog[currentDialogue][1];
			dialog_dropDown.selectedLabel = currentData.dialog[currentDialogue][4];
			dialog_checkBox.checked = (currentData.dialog[currentDialogue][2] == "loud");
			dialog_charTalk.text = currentData.dialog[currentDialogue][0];
			dialog_charStat.text = currentData.dialog[currentDialogue][5];
			dialog_stepper.value = currentData.dialog[currentDialogue][3];

			dialog_xpos.value = currentData.dialog[currentDialogue][6][0];
			dialog_ypos.value = currentData.dialog[currentDialogue][6][1];
			dialog_checkFlip.checked = currentData.dialog[currentDialogue][6][2];
			lastXY = [dialog_xpos.value, dialog_ypos.value];
	}
	updateText();
	startDialogue();
}

function updateText()
{
	var indie:Int = currentDialogue + 1;
	indicator.text = "Dialogue Index: "
		+ indie
		+ " / "
		+ currentData.dialog.length
		+ "\n- Character: "
		+ currentData.dialog[currentDialogue][0]
			+ "\n- Type: "
			+ currentData.dialog[currentDialogue][2]
				+ "\n- Position: "
				+
				(currentData.dialog[currentDialogue][4] == "l" ? "Left (l)" : (currentData.dialog[currentDialogue][4] == "c" ? "Center (c)" : (currentData.dialog[currentDialogue][4] == "r" ? "Right (r)" : "Undefined.")))
				+ "\n\n== Settings =="
				+ "\nBackground music: "
				+ currentData.music;
}

function startDialogue()
{
	if (currentSprite != null)
	{
		currentSprite.destroy();
		remove(currentSprite);
		currentSprite = null;
	}
	FlxG.sound.play(Paths.sound("dialogueClose"), 0.6);
	if (currentText != null)
		currentText.resetText(currentData.dialog[currentDialogue][1]);
	if (currentText != null)
		currentText.start(currentData.dialog[currentDialogue][3], true);
	textBox.visible = true;
	_box_playAnim("start_" + currentData.dialog[currentDialogue][2], true);

	currentSprite = new FlxSprite();
	currentSprite.frames = Paths.getSparrowAtlas("dialogue/portraits/" + currentData.dialog[currentDialogue][0]);
	//trace(currentData.dialog[currentDialogue][5]);
	currentSprite.animation.addByPrefix("idle", currentData.dialog[currentDialogue][5], 24, false);
	currentSprite.updateHitbox();
	currentSprite.antialiasing = CDevConfig.saveData.antialiasing;
	currentSprite.flipX = currentData.dialog[currentDialogue][6][2];
	_insertBehindBox(currentSprite);

	var strX:Float = 0;
	var strY:Float = 0;
	var intX:Float = 0;
	var intY:Float = 0;
	var offX:Float = currentData.dialog[currentDialogue][6][0];
	var offY:Float = currentData.dialog[currentDialogue][6][1];

	intY = (textBox.y + 160) - currentSprite.height;
	strY = intY;
	switch (currentData.dialog[currentDialogue][4])
	{
		case "l":
			strX = 0 - currentSprite.width;
			intX = textBox.x + 120;
			textBox.flipX = true;
		case "c":
			strY = FlxG.height;
			intX = (FlxG.width / 2) - (currentSprite.width / 2);
			strX = intX;
			textBox.flipX = false;
		case "r":
			strX = FlxG.width + currentSprite.width;
			intX = (textBox.x + (textBox.width * textBox.scale.x)) - 380;
			textBox.flipX = false;
		default:
			strX = 0 - currentSprite.width;
			intX = textBox.x + 120;
			textBox.flipX = true;
	}
	tweenChar(strX+offX, strY+offY, intX+offX, intY+offY, 0.2);
}

function __UI_Dialog()
{
	__UI_Clear();
	status = "dialog";

	dialog_inputBox = new FlxUIInputText(tab.x + 10, tab.y + 62, 300, currentData.dialog[currentDialogue][1], 8);
	_UI_Add(dialog_inputBox);
	_UI_Add(new FlxText(dialog_inputBox.x, dialog_inputBox.y - 14, FlxG.width, "Dialogue Text", 8));

	dialog_checkBox = new FlxUICheckBox(tab.x + 10, dialog_inputBox.y + 26, null, null, "Loud text box", 100);
	dialog_checkBox.checked = false;
	dialog_checkBox.callback = function()
	{
		if (dialog_checkBox.checked)
		{
			currentData.dialog[currentDialogue][2] = "loud";
		}
		else
		{
			currentData.dialog[currentDialogue][2] = "normal";
		}
		startDialogue();
	};
	_UI_Add(dialog_checkBox);

	var wa:Array<String> = ["l", "c", "r"];
	dialog_dropDown = new UIDropDown(tab.x + 10, tab.y + 130, UIDropDown.makeStrIdLabelArray(wa, true), function(c:String)
	{
		currentData.dialog[currentDialogue][4] = wa[Std.parseInt(c)];
		startDialogue();
	});
	dialog_dropDown.selectedLabel = currentData.dialog[currentDialogue][4];

	_UI_Add(new FlxText(dialog_dropDown.x, dialog_dropDown.y - 14, FlxG.width, "Character Positioning (l = left, c = center, r = right)", 8));

	dialog_charTalk = new FlxUIInputText(dialog_dropDown.x, dialog_dropDown.y + 38, 120, currentData.dialog[currentDialogue][0], 8);
	_UI_Add(dialog_charTalk);
	_UI_Add(new FlxText(dialog_charTalk.x, dialog_charTalk.y - 14, FlxG.width, "Character Sprite", 8));

	dialog_charStat = new FlxUIInputText(dialog_charTalk.x, dialog_charTalk.y + 38, 120, currentData.dialog[currentDialogue][5], 8);
	_UI_Add(dialog_charStat);
	_UI_Add(new FlxText(dialog_charStat.x, dialog_charStat.y - 14, FlxG.width, "Character XML Animation name", 8));
	_UI_Add(dialog_dropDown);

	// new(X:Float = 0, Y:Float = 0, StepSize:Float = 1, DefaultValue:Float = 0, Min:Float = -999, Max:Float = 999, Decimals:Int = 0, Stack:Int = STACK_HORIZONTAL, ?TextField:FlxText, ?ButtonPlus:FlxUITypedButton<FlxSprite>, ?ButtonMinus:FlxUITypedButton<FlxSprite>, IsPercent:Bool = false)
	dialog_xpos = new FlxUINumericStepper(dialog_charTalk.x+130, dialog_charTalk.y, 10, 0, -1000, 1000, 0);
	dialog_xpos.value = currentData.dialog[currentDialogue][6][0];
	_UI_Add(new FlxText(dialog_xpos.x, dialog_xpos.y-14, FlxG.width, "X Offset", 8));
	_UI_Add(dialog_xpos);

	// new(X:Float = 0, Y:Float = 0, StepSize:Float = 1, DefaultValue:Float = 0, Min:Float = -999, Max:Float = 999, Decimals:Int = 0, Stack:Int = STACK_HORIZONTAL, ?TextField:FlxText, ?ButtonPlus:FlxUITypedButton<FlxSprite>, ?ButtonMinus:FlxUITypedButton<FlxSprite>, IsPercent:Bool = false)
	dialog_ypos = new FlxUINumericStepper(dialog_xpos.x+60, dialog_charTalk.y, 10, 0, -1000, 1000, 0);
	dialog_ypos.value = currentData.dialog[currentDialogue][6][1];
	_UI_Add(new FlxText(dialog_ypos.x, dialog_ypos.y-14, FlxG.width, "Y Offset", 8));
	_UI_Add(dialog_ypos);

	dialog_checkFlip = new FlxUICheckBox(dialog_ypos.x + 64, dialog_charTalk.y-2, null, null, "Flip X", 100);
	dialog_checkFlip.checked = currentData.dialog[currentDialogue][6][2];
	dialog_checkFlip.callback = function()
	{
		currentData.dialog[currentDialogue][6][2] = dialog_checkFlip.checked;
		startDialogue();
	};
	_UI_Add(dialog_checkFlip);

	// new(X:Float = 0, Y:Float = 0, StepSize:Float = 1, DefaultValue:Float = 0, Min:Float = -999, Max:Float = 999, Decimals:Int = 0, Stack:Int = STACK_HORIZONTAL, ?TextField:FlxText, ?ButtonPlus:FlxUITypedButton<FlxSprite>, ?ButtonMinus:FlxUITypedButton<FlxSprite>, IsPercent:Bool = false)
	dialog_stepper = new FlxUINumericStepper(dialog_charStat.x, dialog_charStat.y + 38, 0.01, 0.05, 0.0, 2.0, 2);
	dialog_stepper.value = currentData.dialog[currentDialogue][3];
	_UI_Add(new FlxText(dialog_stepper.x + 60, dialog_stepper.y, FlxG.width, "Typing time (higher = slower, lower = faster)", 8));
	_UI_Add(dialog_stepper);

	var wae:Array<String> = FileSystem.readDirectory(Paths.currentModFolder("data/charts/"));
	dialog_droppedDown = new UIDropDown(tab.x + 10, dialog_stepper.y + 50, UIDropDown.makeStrIdLabelArray(wae, true), function(c:String)
	{
		dialog_stuf.text = wae[Std.parseInt(c)];
	});
	dialog_droppedDown.selectedLabel = PlayState.SONG.song;

	_UI_Add(new FlxText(dialog_droppedDown.x, dialog_droppedDown.y - 14, FlxG.width, "Current song chart folder: ", 8));
	_UI_Add(dialog_droppedDown);
	_UI_Add(new FlxButton(tab.x + tab.width - 100, dialog_stepper.y + 50, "Save", function()
	{
		if (FileSystem.exists(Paths.currentModFolder("data/charts/" + dialog_stuf.text + "/")))
		{
			saveChar(dialog_stuf.text);
		}
	}));

	_UI_Add(new FlxButton(tab.x + tab.width - 100, dialog_stepper.y + 80, "Load", function()
	{
		if (FileSystem.exists(Paths.currentModFolder("data/charts/" + dialog_stuf.text + "/dialogue.json")))
		{
			loadChar(dialog_stuf.text);
		}
	}));
}

function __UI_Char()
{
	__UI_Clear();
	status = "sprite";
}

function saveChar(to)
{
	// weird way to do this
	var dialogdata:String = "";
	var lp:Int = 0;
	for (i in currentData.dialog)
	{
		dialogdata += '["' + i[0] + '","' + i[1] + '","' + i[2] + '", ' 
		+ i[3] + ', "' + i[4] + '", "' + i[5] + '", ['
		+ i[6][0] + ', '+i[6][1]+", "+i[6][2]+"]]";
		if (lp != currentData.dialog.length - 1)
			dialogdata += ",\n		";
		lp++;
	}
	var json:String = "{\n	\"dialog\": [\n		" + dialogdata + "\n	],\n	\"music\":\"" 
	+ currentData.music + "\"\n}";

	if (json.length > 0)
	{
		File.saveContent(Paths.currentModFolder("data/charts/" + to + "/dialogue.json"), json);
		FlxG.sound.play(Paths.sound('confirmMenu'));
		trace("Saved to " + Paths.currentModFolder("data/charts/" + to + "/dialogue.json") + "!");
	}
}

function loadChar(to)
{
	var json = new JsonParser(File.getContent(Paths.currentModFolder("data/charts/" + to + "/dialogue.json"))).doParse();
	currentData.dialog = json.dialog;
	currentData.music = json.music;
	trace("Loaded successfully.");

	currentDialogue = 0;
	playingSong = "00000000000000000000000"; // what?
	changeCurrent(0);
	updateSong(json.music);
	FlxG.sound.play(Paths.sound('confirmMenu'));

	FlxG.camera.flash();
}

function __UI_Settings()
{
	__UI_Clear();
	status = "settings";
	settings_inputBox = new FlxUIInputText(tab.x + 10, tab.y + 62, 200, currentData.music, 8);
	_UI_Add(settings_inputBox);

	_UI_Add(new FlxText(settings_inputBox.x, settings_inputBox.y - 14, FlxG.width, "Background music", 8));
}

function _UI_Add(object)
{
	add(object);
	currentlyShowing.push(object);
}

function __UI_Clear()
{
	while (currentlyShowing.length != 0)
	{
		for (i in currentlyShowing)
		{
			// if (i != null)
			// {
			i.kill();
			remove(i);
			i.destroy();
			currentlyShowing.remove(i);
			// }
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
	dialogue box stuff
 */
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// format: ["prefix", [x,y]]
var _box_offsets:Array<Dynamic> = [
	["start_normal", [30, 0]],
	["normal_anim", [-20, 0]],
	["start_loud", [40, 80]],
	["loud_anim", [10, 60]],
];

// Used for playing animations
function _box_playAnim(prefix:String, forced:Bool)
{
	textBox.animation.play(prefix, forced);

	if (_offsetExists(prefix))
	{
		var pos:Array<Float> = _getOffset(prefix);
		// trace(pos);
		textBox.offset.set(pos[0], pos[1]);
	}
	else
	{
		textBox.offset.set(0, 0);
	}
}

function _offsetExists(prefix:String)
{
	for (i in _box_offsets)
	{
		if (i[0] == prefix)
		{
			return true;
		}
	}
	return false;
}

function _getOffset(prefix:String)
{
	for (i in _box_offsets)
	{
		if (i[0] == prefix)
		{
			return i[1];
		}
	}
	return null;
}

var _hiddenUI:Bool = true;

function _toggleUI()
{
	_hiddenUI = !_hiddenUI;
	for (i in [
		PlayState.healthBarBG,
		PlayState.healthBar,
		PlayState.scoreTxt,
		PlayState.iconP1,
		PlayState.iconP2
	])
	{
		i.visible = _hiddenUI;
	}
}

function _insertBehindBox(spr:FlxSprite)
{
	var i:Dynamic = FlxG.state;
	var e:CustomState = i;
	insert(e.members.indexOf(checc) + 1, spr);
}

function _addCharacter(name:String, sprite:FlxSprite, playerPos:String)
{
	characters.push([name, sprite, playerPos]);
}

var tween:FlxTween;

function tweenChar(defX, defY, posX, posY, time)
{
	if (tween != null)
		tween.cancel();
	currentSprite.setPosition(defX, defY);

	tween = FlxTween.tween(currentSprite, {x: posX, y: posY}, time, {
		ease: FlxEase.sineOut,
		onComplete: function(a:FlxTween)
		{
			tween = null;
		}
	});
}