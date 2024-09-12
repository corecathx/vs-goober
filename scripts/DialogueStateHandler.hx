// This script basically handles the CustomState of the dialogue editor
// press 1 on any song to open the editor.
import("meta.states.CustomState");

function update(){
    if (FlxG.keys.justPressed.ONE){
        trace("Going to da editor!!");
        PlayState.current.vocals.pause();
        FlxG.sound.music.pause();
        FlxG.switchState(new CustomState("DialogueEditor"));
    }
}