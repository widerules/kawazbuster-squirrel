/*
 * Title scene
 */
class TitleScene {

    logo        = null;
    startButton = null;
    creditButton  = null;
    howtoButton = null;
    
    stageCenterX = 0;
    stageCenterY = 0;
    
    fadingOut = false;

    nextScene = null;
    
    /*
     * Called when this class is loaded
     */
    function onLoad() {
        stage.bgcolor(0, 0, 0, 1);
        
        stageCenterX = stage.getWindowWidth() * 0.5;
        stageCenterY = stage.getWindowHeight() * 0.5;
        
        if (background == null) {
            background = emo.Sprite(getHdImageName("title_background.png"));
            background.moveCenter(stageCenterX, stageCenterY);
            background.setZ(0);
            background.load();
        }
        
        loadCurtain();
        
        audio.loadBGM("title.wav");
        audio.loadSE0("pico.wav");
        audio.playBGM();
        
        logo = emo.Sprite(getHdImageName("logo.png"));
        logo.moveCenter(stageCenterX, logo.getHeight() * 0.5);
        logo.setZ(1);
        logo.load();
        
        loadMenu();
    }
    
    /*
     * fill the blank side areas
     * when background width is shorter than the screen width
     */ 
    function loadCurtain() {
        local backWidth    = background.getWidth();
        local windowWidth  = stage.getWindowWidth();
        local windowHeight = stage.getWindowHeight();
        
        local blankSide = (windowWidth - backWidth) * 0.5;
        
        if (blankSide > 1) {
        	local curtainLeft = emo.Rectangle();
        	curtainLeft.color(0, 0, 0, 1);
        	curtainLeft.setSize(blankSide, windowHeight);
        	curtainLeft.move(0, 0);
        	curtainLeft.setZ(1000);
        	curtainLeft.load();
        	
        	local curtainRight = emo.Rectangle();
        	curtainRight.color(0, 0, 0, 1);
        	curtainRight.setSize(blankSide, windowHeight);
        	curtainRight.move(windowWidth - blankSide, 0);
        	curtainRight.setZ(1000);
        	curtainRight.load();
        }
        
    }

    function loadMenu() {
        local btnWidth = 138;
        local btnHeight = 50;
        
        if (useHD) {
            btnWidth  = 275;
            btnHeight = 100;
        }
        
        startButton = emo.SpriteSheet(
            getHdImageName("button_start.png"), btnWidth, btnHeight);
        creditButton = emo.SpriteSheet(
            getHdImageName("button_credit.png"), btnWidth, btnHeight);
        howtoButton = emo.SpriteSheet(
            getHdImageName("button_howto.png"), btnWidth, btnHeight);
            
        startButton.setZ(1);
        creditButton.setZ(1);
        howtoButton.setZ(1);
        
        local margin = 10;
        startButton.moveCenter(
            stage.getWindowWidth() * 0.5, stage.getWindowHeight() - startButton.getHeight());
        howtoButton.move(startButton.getX() - startButton.getWidth() - margin, startButton.getY());
        creditButton.move(startButton.getX() + startButton.getWidth() + margin, startButton.getY());

        startButton.setFrame(1);
        creditButton.setFrame(1);
        howtoButton.setFrame(1);
            
        startButton.load();
        creditButton.load();
        howtoButton.load();
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

    /*
     * Called when the class ends
     */
    function onDispose() {
        if (nextScene != "howto") {
            background.remove();
            background  = null;
        }
    
        startButton.remove();
        creditButton.remove();
        howtoButton.remove();
        logo.remove();
        
        startButton = null;
        creditButton  = null;
        howtoButton = null;
        logo        = null;
    }
        
    /*
     * touch event
     */
    function onMotionEvent(mevent) {
        local x = mevent.getX();
        local y = mevent.getY();
        if (mevent.getAction() == MOTION_EVENT_ACTION_DOWN) {
            if (startButton.contains(x, y)) {
                audio.playSE0();
                startButton.setFrame(0);
                if (!fadingOut) {
                    audio.stopBGM();
                    stage.load(MainLoadingScene(),
                        null, emo.AlphaModifier(0, 1, 1000, emo.easing.Linear));
                    fadingOut = true;
                }
            } else if (creditButton.contains(x, y)) {
                audio.playSE0();
                creditButton.setFrame(0);
                if (!fadingOut) {
                    stage.load(CreditScene(),
                        null, emo.AlphaModifier(0, 1, 1000, emo.easing.Linear));
                    fadingOut = true;
                }
            } else if (howtoButton.contains(x, y)) {
                audio.playSE0();
                howtoButton.setFrame(0);
                if (!fadingOut) {
                    nextScene = "howto";
                    stage.load(HowToScene(),
                        null, emo.AlphaModifier(0, 1, 1000, emo.easing.Linear));
                    fadingOut = true;
                }
            }
        } else {
            startButton.setFrame(1);
            creditButton.setFrame(1);
            howtoButton.setFrame(1);
        }
    }
}
