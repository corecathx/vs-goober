var ZOOM_POWER:Float = 1; //change how much zoom power to give to the camera
function onEvent(name, value1, value2){
    switch (name){
        case "CameraZoom":
            if (PlayState.camZooming) FlxG.camera.zoom += 0.05 * ZOOM_POWER;
    }
}