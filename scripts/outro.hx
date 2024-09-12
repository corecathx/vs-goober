function init() {runOnFreeplay = true;}

import("flixel.FlxCamera");
import("meta.states.FreeplayState");
import("game.cdev.RatingsCheck");
var newCam:FlxCamera;
var bgSprite:FlxCamera;
var textBelow:FlxTypeText;
var sprunder:FlxSprite;
var wholeText:String = "";
var wa:String = "";

var textContine:FlxText;
function outroStart() {
    wholeText = ""
    + "Sicks: " + PlayState.sick
    + "\nGoods: " + PlayState.good
    + "\nBads : " + PlayState.bad
    + "\nShits: " + PlayState.shit;
    newCam = new FlxCamera();
    newCam.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(newCam);
    
    bgSprite = new FlxSprite().loadGraphic(Paths.image("stageBack"));
    bgSprite.setGraphicSize(FlxG.width,FlxG.height);
    bgSprite.cameras = [newCam];
    bgSprite.screenCenter();
    add(bgSprite);

    sprunder = new FlxSprite().makeGraphic(1,1,FlxColor.BLACK);
    sprunder.cameras = [newCam];
    sprunder.alpha = 0.5;
    add(sprunder);

    textBelow = new FlxTypeText(0,0, -1, "", 35);
	textBelow.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
	add(textBelow);
    textBelow.borderSize = 4;
	textBelow.cameras = [newCam];

    textContine = new FlxText(0,0,-1,"Press Any Key To Continue...", 26);
    textContine.setFormat("VCR OSD Mono", 26, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
    add(textContine);
    textContine.borderSize = 4;
	textContine.cameras = [newCam];
    textContine.alpha = 0;

    bgSprite.alpha = 0;
    FlxTween.tween(bgSprite,{alpha:1},1,{ease:FlxEase.expoOut, onComplete:(_)->{
        textBelow.resetText(wholeText);
        textBelow.start(0.05, true);
    }});
}

var has:Bool = false;
var prog:Float = 0;
function update(e) {
    
    if (FlxG.keys.justPressed.ANY && has) {
        endSong();
    }
    if (textBelow == null) return;
    if (wa != textBelow.text) {
        textBelow.screenCenter();
        wa = textBelow.text;
        sprunder.setGraphicSize(textBelow.width+40, textBelow.height+40);
        sprunder.screenCenter();
        FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);
    } else if (wa == wholeText && !has) {
        has=true;
        new FlxTimer().start(1, (_)->{
            newCam.flash();
            FlxG.sound.play(Paths.sound("confirmMenu"), 0.6);
            var rating:String = RatingsCheck.getRating(PlayState.accuracy) + ", " + (CDevConfig.engineVersion != "1.7" ? RatingsCheck.getRatingText(PlayState.accuracy) : RatingsCheck.getRatingText(PlayState.accuracy)[0]); 
            var textee:FlxText = new FlxText(0,0, -1, rating, 18);
            textee.setFormat("VCR OSD Mono", 60, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
            add(textee);
            textee.screenCenter(FlxAxes.X);
            textee.y = 150;
            textee.borderSize = 4;
            textee.cameras = [newCam];
        });
    }

    if (has) {
        prog+=e*4;
        textContine.alpha = 0.5 + (Math.sin(prog)*0.5);
        textContine.setPosition(FlxG.width-(textContine.width+10),FlxG.height-(textContine.height+10));
    }
}