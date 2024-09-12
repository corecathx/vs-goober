
var rating:FlxSprite;
var myArray:Array<FlxSprite> = [];
var box:FlxSprite;
var combo:Int = 0;

var thiccness:Float = 5;

function create()
{
	box = new FlxSprite(0, FlxG.height - 170).makeGraphic(235, 170, FlxColor.GRAY);
	box.cameras = [PlayState.camHUD];

	var ubox:FlxSprite = new FlxSprite(box.x-thiccness, box.y-thiccness).makeGraphic(box.width+(thiccness*2), box.height+(thiccness*2), FlxColor.BLACK);
	ubox.cameras = [PlayState.camHUD];
	add(ubox);
	add(box);
}

function postCreate()
{
	PlayState.ratingPosition.x = 20;
	PlayState.ratingPosition.y = FlxG.height + 140;

	PlayState.comboPosition.x = 30;
	PlayState.comboPosition.y = FlxG.height + 40;

	rating = new FlxSprite();
	rating.loadGraphic(Paths.image("rating/sick"));
	rating.setPosition(box.x + 100, box.y + 50);
	rating.cameras = [PlayState.camHUD];
	rating.scale.set(0.5, 0.5);
	rating.antialiasing = CDevConfig.saveData.antialiasing;
	rating.updateHitbox();
	rating.visible = false;
	add(rating);

    _initGraphic();
   // box.x -= box.width;
    //FlxTween.tween(box,{x:0}, 1, {ease: FlxEase.sineOut});
}
var tweeen:FlxTween;
function onP1Hit(n:Note)
{
    combo++;
	if (rating != null)
	{
		remove(rating);
	}
	rating = new FlxSprite();
	rating.loadGraphic(_getGraphic(n.rating));
	rating.setPosition(box.x + 10, box.y + 10);
	rating.cameras = [PlayState.camHUD];
	rating.scale.set(0.64, 0.64);
	rating.antialiasing = CDevConfig.saveData.antialiasing;
	rating.updateHitbox();
	rating.visible = true;
	add(rating);

    if (tweeen != null)
        tweeen.cancel();
    tweeen = FlxTween.tween(rating.scale, {x:0.6,y:0.6}, 0.2, {onComplete:function(a:FlxTween){
        tweeen = null;
    }});

	var seperatedScore:Array<Int> = [];

	var comboString:String = Std.string(combo);
	var comboArray:Array<String> = comboString.split('');
	for (i in 0...comboArray.length)
	{
		seperatedScore.push(Std.parseInt(comboArray[i]));
	}
	var daLoop:Int = 0;

    for (data in 0...myArray.length){
        remove(myArray[data]);
        myArray.remove(data);
    }
	for (i in seperatedScore)
	{
		var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('rating/num' + Std.int(i)));
		numScore.screenCenter();
		numScore.x = rating.x + (36 * daLoop);
		numScore.y = rating.y+95;
		numScore.ID = daLoop;
		numScore.cameras = [PlayState.camHUD];
		numScore.antialiasing = CDevConfig.saveData.antialiasing;
		numScore.scale.set(0.4,0.4);
		numScore.updateHitbox();

        add(numScore);
        myArray.push(numScore);

		daLoop++;
	}
}

function onNoteMiss(n) {
    combo = 0;
}

var graphics:Array<Dynamic> = [];
function _initGraphic() {
    graphics.push(Paths.image("rating/sick"));
    graphics.push(Paths.image("rating/good"));
    graphics.push(Paths.image("rating/bad"));
    graphics.push(Paths.image("rating/shit"));
    trace("Init Graphics Completed.");
}

function _getGraphic(a:String){
    switch (a){
        case "sick":
            return graphics[0];
        case "good":
            return graphics[1];
        case "bad":
            return graphics[2];
        case "shit":    
            return graphics[3];
    }
    return graphics[3];
}