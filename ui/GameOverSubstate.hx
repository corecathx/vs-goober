import ("game.objects.Boyfriend");
import("flixel.FlxObject");
import("meta.states.LoadingState");
import("flixel.util.FlxGradient");

var stageSuffix:String = "";
var deathCharacter:String = "bf";
var disableFlipX:Bool = false; // false= flipX, true= no flipX
var songBpm:Float = 100;
var isEnding:Bool = false;
var textTitle:FlxText = null;
var startDeath:FlxSound = null;
var state:String = "firstDeath";
var voicelines:FlxSound;

function create(x, y)
{
	trace("you're dead");
	Conductor.songPosition = 0;
	startDeath = FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
	startDeath.onComplete = () ->
	{
		textTitle.text = "Try again?";
		textTitle.screenCenter(FlxAxes.XY);
		FlxG.sound.playMusic(Paths.music('gameOver'));
	}
	Conductor.changeBPM(115);

	FlxG.camera.scroll.set();
	FlxG.camera.target = null;

	textTitle = new FlxText(0, 0, -1, "", 30 / PlayState.defaultCamZoom);
	textTitle.setFormat("VCR OSD Mono", 60 / PlayState.defaultCamZoom, FlxColor.RED, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
	add(textTitle);
	textTitle.scrollFactor.set();

	voicelines = FlxG.sound.play(Paths.sound('goober/voiceline' + Std.string(FlxG.random.int(0, 3))));
	voicelines.pause();
}
var played:Bool = false;
var changed:Bool = false;
function update(elapsed)
{
	FlxG.camera.zoom = FlxMath.lerp(PlayState.defaultCamZoom, FlxG.camera.zoom, 1 - (elapsed * 6));

	if (controls.ACCEPT)
		endBullshit();

	if (controls.BACK)
	{
		FlxG.sound.music.stop();

		if (PlayState.isStoryMode)
			FlxG.switchState(new StoryMenuState());
		else
			FlxG.switchState(new FreeplayState());
	}

	if (FlxG.sound.music.playing && !changed)
	{
		if (!voicelines.playing)
		{
			voicelines.play();
			played = true;
		}

		if (voicelines.playing)
		{
			FlxG.sound.music.fadeOut(0.5, 0.3);
		}
		if (!voicelines.playing && played)
		{
			FlxG.sound.music.fadeIn(0.5, 0.3, 1);
			changed = true;
		}
	}

	if (FlxG.sound.music.playing)
	{
		Conductor.songPosition = FlxG.sound.music.time;
	}
}

function beatHit(b)
{
	FlxG.camera.zoom += 0.020;
}

function endBullshit():Void
{
	if (!isEnding)
	{
		if (textTitle != null)
			textTitle.text = "Try again.";
		isEnding = true;
		textTitle.screenCenter(FlxAxes.XY);

		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			FlxTween.tween(PlayState, {defaultCamZoom: PlayState.defaultCamZoom - 0.5}, 5, {ease: FlxEase.sineInOut});
			FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
			{
				LoadingState.loadAndSwitchState(new PlayState());
			});
		});
	}
}
