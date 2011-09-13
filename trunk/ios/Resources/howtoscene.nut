/*
 * howto scene
 */
class HowToScene {
    foreground = null;
    okButton   = null;
    layer      = null;
    
    fadingOut = false;
    
    function onLoad() {
        stage.bgcolor(0, 0, 0, 1);
        
        local stageCenterX = stage.getWindowWidth()  * 0.5;
        local stageCenterY = stage.getWindowHeight() * 0.5;
        
        local bgWidth  = 480;
        local bgHeight = 320;
        
        if (useHD) {
            bgWidth  = 960;
            bgHeight = 640;
        }
        
        layer = emo.Rectangle();
        layer.setSize(stage.getWindowWidth(), stage.getWindowHeight());
        layer.color(0.5, 0.5, 0.5, 0.78);
        layer.setZ(1);
        layer.load();
        
        foreground = emo.SpriteSheet(getHdImageName("howto.png"), bgWidth, bgHeight);
        foreground.moveCenter(stageCenterX, stageCenterY);
        foreground.setZ(2);
        foreground.load();
        
        foreground.animate(0, 2, 200, -1);
        
        local btWidth  = 159;
        local btHeight = 52;
        
        if (useHD) {
            btWidth  = 318;
            btHeight = 104;
        }
        
        okButton = emo.SpriteSheet(getHdImageName("howto_button.png"), btWidth, btHeight);
        okButton.setFrame(1);
        okButton.move(
            foreground.getX() + foreground.getWidth()  - okButton.getWidth(),
            foreground.getY() + foreground.getHeight() - okButton.getHeight());
        okButton.setZ(3);
        okButton.load();
    }
    
    /*
     * Called when the app has gained focus
     */
    function onGainedFocus() {
        audio.playBGM();
    }

    /*
     * Called when the app has lost focus
     */
    function onLostFocus() {
        audio.pauseBGM();
    }
    
    function onDispose() {
        okButton.remove();
        foreground.remove();
        layer.remove();
    }

    /*
     * touch event
     */
    function onMotionEvent(mevent) {
        local x = mevent.getX();
        local y = mevent.getY();
        if (mevent.getAction() == MOTION_EVENT_ACTION_DOWN) {
            if (okButton.contains(x, y)) {
                okButton.setFrame(0);
                audio.playSE0();
                if (!fadingOut) {
                    fadingOut = true;
                    stage.load(TitleScene(),
                        emo.AlphaModifier(1, 0, 500, emo.easing.Linear));
                }
            }
        }
    }
}
