function postCreate(){
    var color = FlxColor.fromRGB(PlayState.dad.healthBarColor[0], PlayState.dad.healthBarColor[1], PlayState.dad.healthBarColor[2]);
    var bg:FlxSprite = new FlxSprite(0,80).makeGraphic(200,125,color);
    bg.cameras = [PlayState.camHUD];
    add(bg);

    var titleText:FlxText = _createTxt(bg.x+10, bg.y+10, PlayState.SONG.song,24);
    add(titleText);
    var composer:FlxText = _createTxt(titleText.x, titleText.y+titleText.height+10, "Composer: ", 18);
    add(composer);
}

function _createTxt(x,y,text,size)
{
    var newTxt:FlxText = new FlxText(x,y,-1, text, size);
    newTxt.setFormat("VCR OSD Mono", size, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
    return newTxt;
}
