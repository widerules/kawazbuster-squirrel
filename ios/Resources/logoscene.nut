/*
 * Kawaz logo scene
 */
class LogoScene {
    logo = null;
    
    /*
     * Called when this class is loaded
     */
    function onLoad() {
        
        logo = emo.Sprite("kawaz.png");
        stage.bgcolor(1, 1, 1, 1);
        
        // move sprite to the center of the screen
        logo.moveCenter(stage.getWindowWidth() / 2, stage.getWindowHeight() / 2);
        
        // load sprite to the screen
        logo.load();
    }

    /*
     * Called when the app has gained focus
     */
    function onGainedFocus() {
        local fadeInModifier = emo.AlphaModifier(0, 1, 2000, emo.easing.CubicIn);
        
        // add modifier to fade in the splash sprite.
        logo.addModifier(fadeInModifier);
        
        // set modifier event listener. 
        // onModifierEvent is called when modifier event occurs.
        fadeInModifier.setEventListener(this);
    }

    /*
     * Called when the app has lost focus
     */
    function onLostFocus() {
        logo.clearModifier();
    }

    /*
     * Called when the class ends
     */
    function onDispose() {
        logo.remove();
    }
    
    /*
     * Enabled after onDrawCalleback event is enabled by enableOnDrawCallback
     * dt parameter is a delta time (millisecond)
     */
    function onDrawFrame(dt) {
        // disable onDraw listener because this is only one time event.
        event.disableOnDrawCallback();
        stage.load(TitleScene(), null, emo.AlphaModifier(0, 1, 1000, emo.easing.Linear));
    }
    
    // This function is called by modifier of the splash sprite.
    // eventType equals EVENT_MODIFIER_FINISH if the modifier ends.
    function onModifierEvent(obj, modifier, eventType) {
        if (eventType == EVENT_MODIFIER_FINISH) {
            // onDrawFrame(dt) will be called 1 seconds later
            event.enableOnDrawCallback(1000);
        }
    }
}

