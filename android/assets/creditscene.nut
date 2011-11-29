/*
 * credit scene
 */
class CreditScene {
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
        
        if (background != null) {
            background.remove();
        }
        
        background = emo.Sprite(getHdImageName("credit_background.png"));
        background.moveCenter(stageCenterX, stageCenterY);
        background.setZ(0);
        background.load();
        
        layer = emo.Rectangle();
        layer.setSize(stage.getWindowWidth(), stage.getWindowHeight());
        layer.color(0.5, 0.5, 0.5, 0.78);
        layer.setZ(1);
        layer.load();
        
        foreground = emo.SpriteSheet(getHdImageName("credit.png"), bgWidth, bgHeight);
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
        
        okButton = emo.SpriteSheet(getHdImageName("credit_button.png"), btWidth, btHeight);
        okButton.move(
            foreground.getX() + foreground.getWidth()  - okButton.getWidth(),
            foreground.getY() + foreground.getHeight() - okButton.getHeight());
        okButton.setZ(3);
        okButton.load();
        okButton.setFrame(1);
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
        background.remove();
        
        background = null;
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
                        null, emo.AlphaModifier(0, 1, 500, emo.easing.CubicOut));
                }
            }
        }
    }
}
