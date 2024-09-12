var defaultZoom:Float = 0;
function postCreate(){
    defaultZoom = PlayState.defaultCamZoom;
}
function onEvent(name:String, value1:String, value2:String){
    trace("xddd");
    if(name != "duetCam") return;
    if(value1 == "true"){
        trace("ddd");
        PlayState.forceCameraPos = true;
          PlayState.camPosForced = [PlayState.gf.getMidpoint().x+PlayState.gf.charCamPos[0],PlayState.gf.getMidpoint().y+PlayState.gf.charCamPos[1]];
          PlayState.defaultCamZoom = defaultZoom - 0.3;
    }
    else{
        PlayState.forceCameraPos = false;
        PlayState.defaultCamZoom = defaultZoom;
        trace("ddd");
    }
}
