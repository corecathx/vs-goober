import ("flixel.effects.FlxFlicker");

var disableTween:Bool = false;

var magenta:FlxSprite;
var menuItems:Array<Dynamic> = [];
var optionShit:Array<Dynamic> = [["story mode", "freeplay"], ["options", "youtube", "about"]];
var curSelected:Int = 0;
var bg:FlxSprite;
var bgY:Float = 0;
var funkinBump:FlxSprite;

function create()
{
	if (FlxG.sound.music != null)
	{
		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
	}

	bg = new FlxSprite(-80).loadGraphic(Paths.image('funkin/ui/menu/menuBG'));
	bg.scrollFactor.x = 0;
	bg.scrollFactor.y = 0.18;
	bg.setGraphicSize(Std.int(bg.width * 1.15));
	bg.updateHitbox();
	bg.screenCenter();
	bg.alpha = 0.7;
	bg.antialiasing = CDevConfig.saveData.antialiasing;
	add(bg);

	bgY = bg.y;

	magenta = new FlxSprite(-80).loadGraphic(Paths.image('funkin/ui/menu/menuDesat'));
	magenta.scrollFactor.x = 0;
	magenta.scrollFactor.y = 0.18;
	magenta.setGraphicSize(Std.int(magenta.width * 1.15));
	magenta.updateHitbox();
	magenta.screenCenter();
	magenta.visible = false;
	magenta.antialiasing = CDevConfig.saveData.antialiasing;
	magenta.color = 0xFFfd719b;
	add(magenta);

	var tex = Paths.getSparrowAtlas('funkin/ui/menu/FNF_main_menu_assets');
	var daX:Float = (FlxG.width / 2) + 20;
	var lastLoop:Int = 0;

	for (i in 0...optionShit.length)
	{
		var curStuff:Array<String> = optionShit[i];
		for (o in 0...curStuff.length)
		{
			var menuItem:FlxSprite = new FlxSprite();
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', curStuff[o] + " basic", 24);
			menuItem.animation.addByPrefix('selected',curStuff[o] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = lastLoop;
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.4));
			menuItems.push([menuItem, curStuff[o]]);
			add(menuItem);
			menuItem.scrollFactor.set(0, 0);
			menuItem.antialiasing = CDevConfig.saveData.antialiasing;
			menuItem.setPosition(((FlxG.width / 2) - 450) + (400 * (Math.floor(i))), 200 + (120 * o));

			if (curStuff[o] == "about"){
				menuItem.setPosition(FlxG.width - (menuItem.width*0.28), FlxG.height-(menuItem.height*0.3));
			}

			lastLoop++;
		}
	}

	var menuVer:FlxText = new FlxText(10, FlxG.height - 22, -1, "Friday Night Funkin Vs Goober", 18);
	menuVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
	add(menuVer);

	funkinBump = new FlxSprite(50);
	funkinBump.frames = Paths.getSparrowAtlas('funkin/logoBumpin');
	funkinBump.antialiasing = CDevConfig.saveData.antialiasing;
	funkinBump.animation.addByPrefix('logo bumpin', 'logo bumpin', 24);
	funkinBump.animation.play('logo bumpin');
	funkinBump.scale.set(0.5, 0.5);
	funkinBump.updateHitbox();
	funkinBump.screenCenter(FlxAxes.X);
	add(funkinBump);

	//comment this to disable movement
	if (!disableTween){
		var pos = funkinBump.y;
		funkinBump.y -= 400;
		funkinBump.alpha = 0;
		FlxTween.tween(funkinBump,{y:pos, alpha:1},0.5, {ease:FlxEase.quadInOut});
		for (i in menuItems){
			var last = i[0].y;
			i[0].y += 500;
			i[0].alpha = 0;
			FlxTween.tween(i[0],{y:last, alpha:1},0.5, {ease:FlxEase.quadInOut});
		}
	}

	changeItem(0);
}

var selectedSomethin:Bool = false;

function checkee(){
	FlxG.mouse.visible = true;
	var sel:FlxSprite = null;
	var loop:Int = 0;
	for (i in menuItems){
		if (i[1] == "about"){
			sel = i[0];
		}
	}

	if (sel != null && FlxG.mouse.x >= FlxG.width - 200
		&& FlxG.mouse.y >= FlxG.height - 150){
		sel.animation.play("selected", true);
		sel.alpha = 1;

		if (FlxG.mouse.justPressed){
			var loop:Int = 0;
			for (i in 0...optionShit.length)
			{
				var curStuff = optionShit[i];
				for (o in 0...curStuff.length)
				{
					if (curStuff[o] =="about")
					{
						curSelected = loop;
						break;
					}
					loop++;
				}
			}
			hitt("about");
		}
	} else{
		sel.animation.play("idle", true);
		sel.alpha = 0.6;
	}
}

function update(elapsed:Float)
{
	/*bg.y = FlxMath.lerp(bgY + (20*(-(curSelected))), bg.y, 1-(elapsed*5));
	magenta.y = bg.y; */
	if (FlxG.keys.justPressed.SPACE)
	{
		var newState = new MainMenuState();
		current.changeState(newState);
	}

	if (FlxG.keys.justPressed.SEVEN)
	{
		current.changeState(new ModdingState());
	}

	if (controls.BACK)
		current.changeState(new TitleState());

	if (controls.UI_UP_P)
	{
		FlxG.sound.play(Paths.sound('ui/scrollMenu'));
		changeItem(-1);
	}

	if (controls.UI_DOWN_P)
	{
		FlxG.sound.play(Paths.sound('ui/scrollMenu'));
		changeItem(1);
	}

	if (controls.UI_LEFT_P)
	{
		FlxG.sound.play(Paths.sound('ui/scrollMenu'));
		changeItem(-2);
	}

	if (controls.UI_RIGHT_P)
	{
		FlxG.sound.play(Paths.sound('ui/scrollMenu'));
		changeItem(2);
	}

	if (controls.ACCEPT)
	{
		FlxG.sound.play(Paths.sound('ui/enter'));

		var sel:String = "";
		var loop:Int = 0;
		for (i in 0...optionShit.length)
		{
			var curStuff = optionShit[i];
			for (o in 0...curStuff.length)
			{
				if (loop == curSelected)
				{
					sel = curStuff[o];
				}
				loop++;
			}
		}

		switch (sel)
		{
			case 'youtube':
				FlxG.openURL("https://youtube.com/@FiveNighsAtGoobers");

			default:
				selectedSomethin = true;
				hitt(sel);
		}
	}

	checkee();
}

function hitt(sel){
	for (spr in menuItems)
		{
			if (curSelected != spr[0].ID)
			{
				FlxTween.tween(spr[0], {alpha: 0}, 0.4, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr[0].kill();
					}
				});
			}
			else
			{
				if (CDevConfig.saveData.flashing)
				{
					FlxFlicker.flicker(spr[0], 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						openState(sel);
					});
				}
				else
				{
					new FlxTimer().start(1, function(urmom:FlxTimer)
					{
						openState(sel);
					});
				}
			}
		}
}

function openState(state)
{
	var daChoice:String = state;

	switch (daChoice)
	{
		case 'story mode':
			FlxG.switchState(new StoryMenuState());
			trace("Story Menu Selected");
		case 'freeplay':
			FlxG.switchState(new FreeplayState());
			trace("Freeplay Menu Selected");
		case 'options':
			FlxG.switchState(new OptionsState());
			trace("e Menu Selected");
		case 'about':
			FlxG.switchState(new AboutState());
	}
}

function changeItem(huh:Int = 0)
{
	curSelected += huh;

	if (curSelected >= menuItems.length)
		curSelected = 0;
	if (curSelected < 0)
		curSelected = menuItems.length - 1;

	var sel:String = "";
	var loop:Int = 0;
	for (i in 0...optionShit.length)
	{
		var curStuff = optionShit[i];
		for (o in 0...curStuff.length)
		{
			if (loop == curSelected)
			{
				sel = curStuff[o];
			}
			loop++;
		}
	}

	if (sel == "about"){
		changeItem(huh);
	}

	for (spr in menuItems)
	{
		spr[0].animation.play('idle');

		if (spr[0].ID == curSelected)
		{
			spr[0].animation.play('selected');
		}

		spr[0].updateHitbox();
	}
}
