var wholeThing:Array<Dynamic> = [];
function postCreate(){
    var color = FlxColor.fromRGB(PlayState.dad.healthBarColors[0], PlayState.dad.healthBarColors[1], PlayState.dad.healthBarColors[2]);
    var bg:FlxSprite = new FlxSprite(0,80).makeGraphic(290,125,color);
    bg.cameras = [PlayState.camHUD];
    add(bg);
    
	// CDEV 1.7 Fix.
	var curSong:String = (CDevConfig.engineVersion != "1.7" ? PlayState.SONG.song : PlayState.SONG.info.name);
    var titleText:FlxText = _createTxt(bg.x+10, bg.y+20, curSong,40);
    add(titleText);
    var composer:FlxText = _createTxt(titleText.x, titleText.y+titleText.height+10, "Composer: Goober", 24);
    add(composer);

    wholeThing.push(bg);
    wholeThing.push(titleText);
    wholeThing.push(composer);

    for (i in wholeThing){
        i.x -= 300;
    }
}

function onStartSong(){
    for (i in wholeThing){
        FlxTween.tween(i, {x: i.x + 300}, (Conductor.crochet/1000)*8, {ease:FlxEase.sineInOut, onComplete: function(ea:FlxTween){
            new FlxTimer().start((Conductor.crochet/1000*8), function(oaoa:FlxTimer){
                FlxTween.tween(i, {x: i.x - 300}, (Conductor.crochet/1000)*8, {ease:FlxEase.sineInOut, onComplete:function(o:FlxTween){
                    i.destroy();
                    remove(i);
                }});
            });
        }});
    }
}

function _createTxt(x,y,text,size)
{
    var newTxt:FlxText = new FlxText(x,y,-1, text, size);
    newTxt.cameras = [PlayState.camHUD];
    newTxt.setFormat("VCR OSD Mono", size, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
    newTxt.borderSize = 2.2;
    return newTxt;
}