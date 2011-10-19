emo.Runtime.import("common.nut");

stage      <- emo.Stage();
event      <- emo.Event();
runtime    <- emo.Runtime();
database   <- emo.Database();
preference <- emo.Preference();

useHD   <- false;
kawazOn <- false;
debug   <- true;

audio <- AudioLoader();

emo.Runtime.import("logoscene.nut");
emo.Runtime.import("titlescene.nut");
emo.Runtime.import("howtoscene.nut");
emo.Runtime.import("creditscene.nut");

const GAME_TIME     = 60000;
const HURRY_UP_TIME = 20000;

const DEFAULT_HIGHSCORE = 2000;
const TOUCH_POINT = 100;
const FIRE_POINT  = 500;

const PREF_HIGHSCORE = "HIGHSCORE";
local highScore      = null;

// preloaded sprites
background          <- null;

local scoreText     = null;
local timesLeftText = null;
local highScoreText = null;
local fpsText       = null;
    
local main_layer0   = null;
local main_layer1   = null;
local main_ready    = null;
local main_go       = null;
local main_finish   = null;
    
local retry_button  = null;
local return_button = null;
    
local targets       = null;

local stageCenterX  = null;
local stageCenterY  = null;

function resetScoreText() {

    highScore = DEFAULT_HIGHSCORE;

    // load high score
    if (preference.openOrCreate() == EMO_NO_ERROR) {
        local value = preference.get(PREF_HIGHSCORE)
        preference.close();
        
        if (value.len() > 0) {
            highScore = value.tointeger();
        }
    }

    local gameTime = date(GAME_TIME / 1000.0, 'u');
    scoreText.setText("SCORE:00000 ");
    timesLeftText.setText(format("TIME:%d:%02d ", gameTime.min, gameTime.sec));
    highScoreText.setText(format("HIGH: %05d ", highScore));
    fpsText.setText("FPS: 00.00");
}

class MainLoadingScene {

    loader        = null;
    loaded        = null;
    phase         = null;
    
    kawazWidth    = null;
    kawazHeight   = null;
    resultButtonWidth  = null;
    resultButtonHeight = null;
    
    loadingText = null;
    
    function onLoad() {
        targets = [];
        
        audio.close();
        
        stageCenterX = stage.getWindowWidth()  * 0.5;
        stageCenterY = stage.getWindowHeight() * 0.5;
        
        kawazWidth  = 140;
        kawazHeight = 152;
        
        if (useHD) {
            kawazWidth  = 277;
            kawazHeight = 302;
        }
        
        resultButtonWidth  = 160;
        resultButtonHeight = 81;
        
        if (useHD) {
            resultButtonWidth  = 320;
            resultButtonHeight = 162;
        }
        
        phase  = 0;
        loaded = false;
        loader = load();
        
        loadingText = emo.TextSprite("font.png",
            " !\"c*%#'{}@+,-./0123456789:;[|]?&ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            16, 16, 2, 1);
        loadingText.setText("LOADING..");
        if (useHD) loadingText.scale(2, 2);
        loadingText.moveCenter(stageCenterX, stageCenterY);
        loadingText.setZ(500);
        loadingText.load();
            
        event.enableOnDrawCallback(16);
    }
    
    function onDispose() {
        loadingText.remove();
        loadingText = null;
    }
    
    /*
     * Enabled after onDrawCalleback event is enabled by enableOnDrawCallback
     * dt parameter is a delta time (millisecond)
     */
    function onDrawFrame(dt) {
        local dot = "....".slice(0, phase % 5);
        
        loadingText.setText("LOADING" + dot);
        
        if (!loaded) {
            loaded = resume loader;
            phase++;
        } else {
            event.disableOnDrawCallback();
            stage.load(MainScene());
        }
    }

    function load() {
        loadBackground(); yield false;
        
        while(loadKawaztan()) {
            yield false;
        }
        
        loadMainLayer(0);    yield false;
        loadMainLayer(1);    yield false;
        loadNoticeSprite(0); yield false;
        loadNoticeSprite(1); yield false;
        loadNoticeSprite(2); yield false;
        loadResultSprite(0); yield false;
        loadResultSprite(1); yield false;
        loadText();
        
        return true;
    }
    
    function loadBackground() {
        background = emo.Sprite(getHdImageName("main_background.png"));
        background.moveCenter(stageCenterX, stageCenterY);
        background.alpha(0.5);
        background.setZ(0);
        background.load();
    }
    
    function loadText() {
        local margin = 10;
        local x = background.getX();
        local y = background.getY();
        
        // 16x16 text sprite with 2 pixel border and 1 pixel margin
        scoreText = emo.TextSprite("font.png",
            " !\"c*%#'{}@+,-./0123456789:;[|]?&ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            16, 16, 2, 1);
        timesLeftText = emo.TextSprite("font.png",
            " !\"c*%#'{}@+,-./0123456789:;[|]?&ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            16, 16, 2, 1);
        highScoreText = emo.TextSprite("font.png",
            " !\"c*%#'{}@+,-./0123456789:;[|]?&ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            16, 16, 2, 1);
        fpsText = emo.TextSprite("font.png",
            " !\"c*%#'{}@+,-./0123456789:;[|]?&ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            16, 16, 2, 1);
        
        resetScoreText();

        if (useHD) {
            scoreText.scale(1.5, 1.5);
            timesLeftText.scale(1.5, 1.5);
            highScoreText.scale(1.5, 1.5);
            fpsText.scale(1.5, 1.5);
        }

        scoreText.move(x + margin, y + margin);
        timesLeftText.move(scoreText.getX() + background.getWidth()
                                - timesLeftText.getScaledWidth() - margin,
                        scoreText.getY());
        highScoreText.move(scoreText.getX(), scoreText.getY() + scoreText.getScaledHeight() + margin);
        fpsText.move(x + background.getWidth()  - fpsText.getScaledWidth() - margin,
                     y + background.getHeight() - fpsText.getScaledHeight() - margin);
        
        scoreText.hide();
        timesLeftText.hide();
        highScoreText.hide();
        fpsText.hide();
        
        scoreText.setZ(500);
        timesLeftText.setZ(500);
        highScoreText.setZ(500);
        fpsText.setZ(500);
        
        scoreText.load();
        timesLeftText.load();
        highScoreText.load();
        fpsText.load();
    }
    
    function loadKawaztan() {
        local width   = kawazWidth;
        local height  = kawazHeight;
        local spacing = width * 0.5;
        
        local index = targets.len();
        
        // foreground
        if (index < 6) {
            local foreStartX = background.getX();
            local foreStartY = background.getY() + background.getHeight() - (height * 0.70);
        
            local sprite  = emo.SpriteSheet(getHdImageName("kawaztan.xml"));
            
            local zOrder = 200 + index;
            
            sprite.move(foreStartX + (spacing * index), foreStartY);
            sprite.hide();
            sprite.setZ(zOrder);
            sprite.load();
            sprite.selectFrame("kawaz0");
            
            targets.append(KawazTan(sprite));
        } else {
            local i = index - 6;
            
            local backStartX = background.getX() + background.getWidth() - width;
            local backStartY = stage.getWindowHeight() * 0.5;
            
            local sprite  = emo.SpriteSheet(getHdImageName("kawaztan.xml"));
            
            local zOrder = 100 + i;
            
            if (i == 2) {
                sprite.move(25, backStartY + (spacing * 0.5));
            } else {
                sprite.move(backStartX - (spacing * i), backStartY);
            }
            sprite.hide();
            sprite.setZ(zOrder);
            sprite.load();
            sprite.selectFrame("kawaz0");
            
            targets.append(KawazTan(sprite));
        }
        
        return targets.len() < 9;
    }
    
    function loadNoticeSprite(index) {
        if (index == 0) {
            main_ready = emo.Sprite(getHdImageName("ready.png"));
            main_ready.hide();
            main_ready.setZ(400);
            main_ready.load();
        } else if (index == 1) {
            main_go = emo.Sprite(getHdImageName("go.png"));
            main_go.hide();
            main_go.setZ(400);
            main_go.load();
        } else if (index == 2) {
            main_finish = emo.Sprite(getHdImageName("finish.png"));
            main_finish.hide();
            main_finish.setZ(400);
            main_finish.load();
        }
        
    }
    
    function loadMainLayer(index) {
        if (index == 0) {
            main_layer0 = emo.Sprite(getHdImageName("main_layer0.png"));
            main_layer0.moveCenter(stageCenterX, stageCenterY);
            main_layer0.hide();
            main_layer0.setZ(200);
            main_layer0.load();
        } else if (index == 1) {
            main_layer1 = emo.Sprite(getHdImageName("main_layer1.png"));
            main_layer1.moveCenter(stageCenterX, stageCenterY);
            main_layer1.hide();
            main_layer1.setZ(300);
            main_layer1.load();
        }
            
    }
    
    function loadResultSprite(index) {
        local width  = resultButtonWidth;
        local height = resultButtonHeight;
        
        local menuStartY = background.getY() + background.getHeight() - (height * 0.5);
        
        if (index == 0) {
            return_button = emo.SpriteSheet(getHdImageName("result_button.png"), width, height);
            return_button.setFrame(2);
            return_button.hide();
            return_button.setZ(400);
            return_button.moveCenter(stageCenterX + (width * 0.5) + 10, menuStartY);
            return_button.load();
        } else if (index == 1) {
            retry_button  = emo.SpriteSheet(getHdImageName("result_button.png"), width, height);
            retry_button.setFrame(3);
            retry_button.hide();
            retry_button.setZ(400);
            retry_button.moveCenter(stageCenterX  - (width * 0.5) - 10, menuStartY);
            retry_button.load();
        }
        
    }
}

class MainScene {
    readyModifier  = null;
    goModifier     = null;
    finishModifier = null;
    throwGoModifier = null;
    
    gameActive     = false;
    hurryUp        = false;
    menuActive     = false;
    
    startTime      = 0;
    pausedTime     = 0;
    timesLeft      = null;
    hurryStartTime = null;
    
    score          = 0;
    
    function onLoad() {
        background.show();
        main_layer0.show();
        main_layer1.show();
        
        if (debug) event.enableOnFpsCallback(3000);
        
        readyGame();
    }
    
    function readyGame() {
        audio.loadBGM("bgm_int.wav", false);
        audio.loadSE1("bomb.wav");
        audio.loadSE2("fire.wav");
        
        return_button.hide();
        retry_button.hide();
        
        resetScoreText();
        
        score = 0;
        pausedTime = 0;
        
        scoreText.show();
        timesLeftText.show();
        highScoreText.show();
        
        if (debug) {
            fpsText.show();
        }
        
        main_ready.scale(1, 1);
        main_ready.moveCenter(stageCenterX, stageCenterY);
        main_ready.scale(0, 0);
        readyModifier = emo.SequenceModifier(
            emo.ScaleModifier(0, 1, 1000, emo.easing.ExpoIn),
            emo.NoopModifier(1000));
            
        readyModifier.setEventListener(this);
        
        main_ready.show();
        main_ready.addModifier(readyModifier);
        
        menuActive = false;
        gameActive = false;
        hurryUp = false;
        kawazOn = false;
        
        audio.playBGM();
    }
    
    function showGoSprite() {
        main_ready.hide();
        main_go.moveCenter(stageCenterX, stageCenterY);
        main_go.scale(0, 0);
        
        goModifier = emo.SequenceModifier(
            emo.ScaleModifier(0, 1, 250, emo.easing.ExpoIn),
            emo.NoopModifier(250));
        goModifier.setEventListener(this);
        
        main_go.show();
        main_go.addModifier(goModifier);
    }
    
    function throwGoSprite() {
        audio.loadBGM("bgm.wav");
        audio.playBGM();
        
        main_go.clearModifier();
        
        throwGoModifier = 
            emo.MoveModifier(
                [main_go.getX(), main_go.getY()],
                [stage.getWindowWidth(), -main_go.getHeight()],
                500, emo.easing.Linear);
        throwGoModifier.setEventListener(this);
                
        main_go.addModifier(
            emo.RotateModifier(0, 720, 500, emo.easing.Linear));
        main_go.addModifier(throwGoModifier);
    }
    
    function showFinishSprite() {
        main_finish.scale(1, 1);
        main_finish.moveCenter(stageCenterX, stageCenterY);
        main_finish.show();
        finishModifier = emo.SequenceModifier(
            emo.NoopModifier(2000),
            emo.ScaleModifier(1, 0, 1000, emo.easing.ExpoOut));
        finishModifier.setEventListener(this);
        main_finish.addModifier(finishModifier);
    }
    
    function showMenu() {
        menuActive = true;
        main_finish.hide();
        
        if (score > highScore) {
            audio.loadBGM("high_score.wav", false);
            audio.playBGM();
            highScore = score;
            updateScoreText();
        } else {
            audio.loadBGM("game_over.wav", false);
            audio.playBGM();
        }
        
        saveHighScore();
        
        return_button.show();
        retry_button.show();
    }
    
    function shakeScreen() {
        local sequence1 = emo.SequenceModifier();
        local sequence2 = emo.SequenceModifier();
        local sequence3 = emo.SequenceModifier();
        
        local x = background.getX();
        local y = background.getY();
        
        for (local i = 0; i < 10; i++) {
            local modifier = emo.MoveModifier(
                [x, y],
                [30-(rand()%60), 15-(rand()%60)],
                33, emo.easing.Linear);
                
            sequence1.addModifier(clone modifier);
            sequence2.addModifier(clone modifier);
            sequence3.addModifier(modifier);
        }
        
        local modifier = emo.MoveModifier(
            [x, y],
            [x, y],
            66, emo.easing.Linear);
            
        sequence1.addModifier(clone modifier);
        sequence2.addModifier(clone modifier);
        sequence3.addModifier(modifier);
        
        main_layer0.addModifier(sequence1);
        main_layer1.addModifier(sequence2);
        background.addModifier(sequence3);
    }
    
    /*
     * Called when the app has gained focus
     */
    function onGainedFocus() {
        audio.playBGM();
        
        startTime = runtime.uptime() - pausedTime + 500;
    }

    /*
     * Called when the app has lost focus
     */
    function onLostFocus() {
        audio.pauseBGM();
        pausedTime = elapsed();
    }
    
    function onDispose() {
    
        if (debug) event.disableOnFpsCallback();
        
        main_layer0.remove();
        main_layer1.remove();
        main_go.remove();
        main_ready.remove();
        main_finish.remove();
        retry_button.remove();
        return_button.remove();
        
        scoreText.remove();
        highScoreText.remove();
        timesLeftText.remove();
        fpsText.remove();
        
        for (local i = 0; i < targets.len(); i++) {
            targets[i].remove();
        }
        
        targets.clear();
        
        background.remove();
        background = null;
    }
    
    // This function is called by modifier of the splash sprite.
    // eventType equals EVENT_MODIFIER_FINISH if the modifier ends.
    function onModifierEvent(obj, modifier, eventType) {
        if (eventType == EVENT_MODIFIER_FINISH) {
            if (modifier == readyModifier) {
                showGoSprite();
            } else if (modifier == goModifier) {
                throwGoSprite();
            } else if (modifier == throwGoModifier) {
                startGame();
            } else if (modifier == finishModifier) {
                showMenu();
            }
        }
    }
    
    function startGame() {
        main_ready.hide();
        main_go.hide();
        
        gameActive = true;
        
        startTime   = runtime.uptime();
        timesLeft   = GAME_TIME;
        
        event.enableOnDrawCallback(66);
    }
    
    function saveHighScore() {
        if (highScore > 0) {
            if (preference.open() == EMO_NO_ERROR) {
                preference.set(PREF_HIGHSCORE, highScore);
                preference.close();
            }
        }
    }
    
    function elapsed() {
        return runtime.uptime() - startTime;
    }
    
    function updateScoreText() {
        local gameTime = date(timesLeft / 1000.0, 'u');
        
        scoreText.setText(format("SCORE:%05d ", score));
        timesLeftText.setText(format("TIME:%01d:%02d ", gameTime.min, gameTime.sec));
        highScoreText.setText(format("HIGH: %05d ", highScore));
    }
    
    /*
     * Enabled after onDrawCalleback event is enabled by enableOnDrawCallback
     * dt parameter is a delta time (millisecond)
     */
    function onDrawFrame(dt) {
        
        updateScoreText();
        
        local rate = hurryUp ? 2 : 3;
        if (gameActive && rand() % rate == 0) {
            popTarget();
        }
        
        timesLeft = GAME_TIME - elapsed();
        
        if (timesLeft < HURRY_UP_TIME && !hurryUp) {
            hurryUp = true;
            audio.loadBGM("hurry_int.wav");
            audio.playBGM();
            hurryStartTime = runtime.uptime();
        }
        
        if (timesLeft < 33) {
            gameActive = false;
            event.disableOnDrawCallback();
            audio.stopBGM();
            audio.stopSE0();
            audio.stopSE1();
            audio.stopSE2();
            
            audio.loadSE2("time_up.wav");
            audio.playSE2();
            
            showFinishSprite();
        }
        
        if (gameActive && hurryUp && hurryStartTime != null &&
                        runtime.uptime() - hurryStartTime > 1000) {
            audio.loadBGM("hurry.wav");
            audio.playBGM();
            hurryStartTime = null;
        }
    }
    
    function popTarget() {
        // sometimes bomb effect makes the background position invalid 
        // so fix the background position here
        background.moveCenter(stageCenterX, stageCenterY);
        main_layer0.moveCenter(stageCenterX, stageCenterY);
        main_layer1.moveCenter(stageCenterX, stageCenterY);
        
        local n = rand() % targets.len();
        
        // check if the neighbor is visible
        if (n > 0 && targets[n-1].isVisible()) return;
        if (n < targets.len() - 1 && targets[n+1].isVisible()) return;
        
        targets[n].show();
    }
    
    /*
     * touch event
     */
    function onMotionEvent(mevent) {
        local x = mevent.getX();
        local y = mevent.getY();
        if (mevent.getAction() == MOTION_EVENT_ACTION_DOWN) {
            if (gameActive) {
                for (local i = 0; i < targets.len(); i++) {
                    if (targets[i].contains(x, y)) {
                        if (targets[i].touch()) {
                            score = score + TOUCH_POINT;
                        } else {
                            score = score - FIRE_POINT;
                            if (score < 0) score = 0;
                            shakeScreen();
                            emo.Audio.vibrate();
                        }
                        break;
                    }
                }
            } else if (menuActive) {
                if (return_button.contains(x, y)) {
                    stage.load(TitleScene());
                } else if (retry_button.contains(x, y)) {
                    readyGame();
                }
            }
        }
    }
    
    function onFps(fps) {
        fpsText.setText(format("FPS: %02.2f", fps));
    }
}

function emo::onLoad() {
    srand(time());

    runtime.setOptions(OPT_ORIENTATION_LANDSCAPE_RIGHT);
        
    local stageHeight = stage.getWindowHeight();
    // use HD image on large display device
    if (stageHeight > 320) {
        useHD = true;
        stage.setContentScale(stageHeight / 640.0);
    }
    emo.Stage().load(LogoScene());
}
