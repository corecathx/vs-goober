import("sys.FileSystem");
var textBox:FlxSprite;
var currentText:FlxTypeText;
var bg:FlxSprite;
var currentSprite:FlxSprite = null;
var currentDialogue:Int = 0;
var playingDialog = false;
var currentData = {
	dialog: [
		[
			"bf",
			"Lorem ipsum dolor sit amet.",
			"normal",
			0.05,
			"r",
			"normal",
			[0, 0, false]
		]
	],
	music: "breakfast"
};

function init()
{
	import("flixel.addons.ui.FlxUITabMenu");
	import("flixel.addons.ui.FlxUIInputText");
	import("game.cdev.UIDropDown");
	import("flixel.addons.ui.FlxUICheckBox");
	import("flixel.addons.ui.FlxUINumericStepper");
	import("flixel.ui.FlxButton");
	import("sys.io.File");
	import("sys.FileSystem");
	import("haxe.format.JsonParser");

	runOnFreeplay = true;
}

function postIntro()
{
	// CDEV 1.7 Fix.
	var curSong:String = (CDevConfig.engineVersion != "1.7" ? PlayState.SONG.song : PlayState.SONG.info.name).toLowerCase();
	if (!FileSystem.exists(Paths.currentModFolder("data/charts/" + PlayState.SONG.song + "/dialogue.json")))
	{
		startSong();

		// if you wanted your intro stuffs to be working on a
		// specific song, put them inside your song's switch case below.
		switch (curSong){
			//case "tutorial":
		}
	} else{
		// if you wanted to do something before the dialogue starts
		// (example: video cutscene), put them inside your song's switch case below.
		switch (curSong){
			/*case "your-song":
				var video:FlxVideo = new FlxVideo();
				video.play(Paths.video("your-song-cutscene"));
				video.onEndReached.add(function()
				{
					video.dispose();
					createDialogueSection();
					return;
				}, true);*/
			default:
				createDialogueSection();
		}
	}
}

function createDialogueSection(){
	bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xff5b90a8);
	bg.cameras = [PlayState.camHUD];
	bg.alpha = 0.5;
	add(bg);
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
	textBox.cameras = [PlayState.camHUD];
	textBox.x += 30;
	textBox.y += 240;
	add(textBox);

	currentText = new FlxTypeText(textBox.x + 150, textBox.y + 140, textBox.width - (35 + 250), "", 18);
	currentText.setFormat(Paths.font("fnffont"), 32, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
	add(currentText);
	currentText.cameras = [PlayState.camHUD];
	currentText.borderSize = 3;
	currentText.borderQuality = 1;

	loadChar(PlayState.SONG.song);
	playingDialog = true;
}

var last:String = "";

function update(e)
{
	if (playingDialog){
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
		
			if (FlxG.keys.justPressed.ANY)
			{
				changeCurrent(1);
			}
		
			if (currentText != null && last != currentText.text)
			{
				last = currentText.text;
				FlxG.sound.play(Paths.sound("dialogue.ogg"),0.6);
				if (currentSprite != null)
					currentSprite.animation.play("idle");
			}
	}
}

/*function startDialogue()
{
	if (currentSprite != null)
	{
		remove(currentSprite);
	}
	FlxG.sound.play(Paths.sound("dialogueClose"), 0.6);
	if (currentText != null)
		currentText.resetText(currentData.dialog[currentDialogue][1]);
	if (currentText != null)
		currentText.start(currentData.dialog[currentDialogue][3], true);
	textBox.visible = true;
	_box_playAnim("start_" + currentData.dialog[currentDialogue][2], true);

	currentSprite = new FlxSprite().loadGraphic(Paths.image("dialogue/portraits/" + currentData.dialog[currentDialogue][0]));
	currentSprite.updateHitbox();
	currentSprite.cameras = [PlayState.camHUD];
	currentSprite.antialiasing = CDevConfig.saveData.antialiasing;
	_insertBehindBox(currentSprite);

	var strX:Float = 0;
	var strY:Float = 0;
	var intX:Float = 0;
	var intY:Float = 0;

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
	tweenChar(strX, strY, intX, intY, 0.1);
}*/

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
	// trace(currentData.dialog[currentDialogue][5]);
	currentSprite.animation.addByPrefix("idle", currentData.dialog[currentDialogue][5], 24, false);
	currentSprite.updateHitbox();
	currentSprite.cameras = [PlayState.camHUD];
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
	tweenChar(strX + offX, strY + offY, intX + offX, intY + offY, 0.2);
}

function changeCurrent(?change:Int = 0)
{
	// FlxG.sound.play(Paths.sound("scrollMenu"), 0.6);
	currentDialogue += change;
	if (currentDialogue > currentData.dialog.length - 1)
		endThis();
	else
		startDialogue();
}

function updateSong(to)
{
	FlxG.sound.music.stop();
	FlxG.sound.playMusic(Paths.music(to + ".ogg"), 0);
	FlxG.sound.music.fadeIn(1, 0, 0.6);
}

function loadChar(to)
{
	var json = new JsonParser(File.getContent(Paths.currentModFolder("data/charts/" + to + "/dialogue.json"))).doParse();
	currentData.dialog = json.dialog;
	currentData.music = json.music;

	currentDialogue = 0;

	changeCurrent(0);
	updateSong(json.music);
}

function endThis()
{
	var re = [textBox, currentText, bg, currentSprite];
	for (i in re)
		FlxTween.tween(i, {alpha: 0}, 1, {
			onComplete: function(e)
			{
				i.destroy();
				remove(i);
			}
		});
	FlxG.sound.music.fadeOut(0.4, 0);
	startSong();
	return;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
	dialogue box stuff
 */
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// format: ["prefix", [x,y]]
var _box_offsets:Array<Dynamic> = [
	["start_normal", [-20, 0]],
	["normal_anim", [-20, 0]],
	["start_loud", [10, 20]],
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
	var e:PlayState = i;
	insert(e.members.indexOf(bg) + 1, spr);
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
