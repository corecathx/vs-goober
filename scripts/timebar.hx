// SHAPES & SIZES HERE
var thickness:Float = 0.07; // Mess with these values until you get what you want.
var border:Float = 0.04;
var length:Float = 1.965;
var barX = (FlxG.width/2)-((334*(length/4)));
var barY = 12.5;

//TEXT CONFIG HERE

var textX:Float = 1000;
var textU:Float = barY; // Change "barY" to a number for more positioning options
var textSize = 30;
var textColor = 0xFFFFFFFF; //These colors must be in hex codes
var timeLeft:Bool = true; //whether to show time left or time elapsed.

//COLORS & SHADING HERE

var fillingBarColor = 0xff964b00; //These colors must be in hex codes
var emptyBarColor = 0xff5a5a5a;
var borderColor = 0xff000000;

//IGNORE
var sborder:FlxSprite;
var semptyBar:FlxSprite;
var sfillBar:FlxSprite;

var nametext:FlxText;

function create(){
    
    sborder = new FlxSprite(barX - (border * (175/6)), barY - (border * (165/6))-150).loadGraphic(Paths.image("colorShadedDown"));
    semptyBar = new FlxSprite(barX, barY-150).loadGraphic(Paths.image("color"));
    sfillBar = new FlxSprite(barX, barY-150).loadGraphic(Paths.image("colorShadedDown"));

    add(sborder);
    add(semptyBar);
    add(sfillBar);
    
    sborder.cameras = [PlayState.camHUD];
    semptyBar.cameras = [PlayState.camHUD];
    sfillBar.cameras = [PlayState.camHUD];
    
    sborder.scale.set(length + border, thickness + border);
    semptyBar.scale.set(length, thickness);
    sfillBar.scale.set(length, thickness);

    sborder.color = borderColor;
    semptyBar.color = emptyBarColor;
    sfillBar.color = fillingBarColor;

    sborder.alpha = 0;
    semptyBar.alpha = 0;
    sfillBar.alpha = 0;

    for (i in [sborder,semptyBar,sfillBar]){
        FlxTween.tween(i, {alpha:1}, 1);
    }
    CDevConfig.saveData.songtime = false;

    if (border == 0) {
        sborder.destroy();
        remove(sborder);
    }
}

function postCreate() {
    createText(textX, barY, 0, PlayState.SONG.song);
    nametext.size = textSize;
    nametext.color = textColor;
    add(nametext);
}

function update(e){
    CDevConfig.songtime = false;

    if (nametext!=null){
        if (timeLeft)
            nametext.text = getSongDuration(FlxG.sound.music.time, FlxG.sound.music.length);
        else 
            nametext.text = getCurrentDuration(FlxG.sound.music.time);
        sfillBar.scale.set(length * (FlxG.sound.music.time / FlxG.sound.music.length), thickness);
    }
}

///////////////////////////////////////////////////////////////////

function createText(x,y,w,t){
    nametext = new FlxText(x, y, w, t, 16);
    nametext.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
    nametext.cameras = [PlayState.camHUD];
    nametext.scrollFactor.set();
    nametext.borderSize = 2;
    
}

function getSongDuration(musicTime:Float, musicLength:Float):String
{
	var secondsMax:Int = Math.floor((musicLength - musicTime) / 1000); // 1 second = 1000 miliseconds
	var seconds:String = '' + secondsMax % 60;

	if (secondsMax < 0)
		secondsMax = 0;

	var minutes:Int = Math.floor(secondsMax / 60); // 1 minute = 60 seconds
	if (musicTime < 0)
		musicTime = 0;

	if (seconds.length < 2)
		seconds = '0' + seconds;

	var lastTextString:String = minutes + ':' + seconds;
	return lastTextString;
}

function getCurrentDuration(musicTime:Float):String
{
	var theshit:Int = Math.floor(musicTime / 1000);
	var secs:String = '' + theshit % 60;

	var mins:Int = Math.floor(theshit / 60);
	if (theshit < 0)
			theshit = 0;
	if (musicTime < 0)
		musicTime = 0;

	if (secs.length < 2)
		secs = '0' + secs;

	var shit:String = mins + ":" + secs;
	return shit;
}
