function getHdImageName(filename) {
    local idx    = filename.find(".");
    local name   = filename.slice(0, idx);
    local suffix = filename.slice(idx);
    
    if (useHD) {
        filename = name + "-hd" + suffix;
    }
    return filename;
}

enum KawazState {
    NORMAL,
    WAITING,
    MOVING,
    DAMAGED
}

enum KawazType {
    NORMAL,
    BOMB
}

class KawazTan {
    target = null;
    damageSprite = null;
    fireSprite = null;
    
    status = KawazState.WAITING;
    type   = KawazType.NORMAL;
    
    popModifier    = null;
    hideModifier   = null;
    damageModifier = null;
    
    x = null;
    y = null;
    
    function constructor(_kawaz, _damage, _fire) {
        target = _kawaz;
        damageSprite = _damage;
        fireSprite = _fire;
        
        x = target.getX();
        y = target.getY();
    }
    
    function show() {
        if (status != KawazState.WAITING) return;
        if (kawazOn) return;
        kawazOn = true;
        
        local frame = rand() % 4;
        type = frame == 0 ? KawazType.BOMB : KawazType.NORMAL;
        
        if (type == KawazType.BOMB) {
            audio.playSE2();
        }
        
        target.setFrame(frame);
        
        status = KawazState.MOVING;
        
        target.clearModifier();
        
        target.show();
        popModifier = emo.MoveModifier(
            [x, y],
            [x, y - (target.getHeight() * 0.70)],
            250, emo.easing.CubicIn);
        popModifier.setEventListener(this);
        target.addModifier(popModifier);
    }
    
    function waitAndHide() {
        if (status != KawazState.NORMAL) return;
        
        local noop = 500;
        if (type == KawazType.BOMB) noop = 750;
        
        target.clearModifier();
        
        hideModifier = emo.SequenceModifier(
            emo.NoopModifier(noop),
            emo.MoveModifier(
                [target.getX(), target.getY()],
                [x, y],
                250,
                emo.easing.CubicOut
            ));
        hideModifier.setEventListener(this);
        target.addModifier(hideModifier);
    }
    
    function isVisible() {
        return status == KawazState.NORMAL;
    }
    
    function contains(cx, cy) {
        if (status != KawazState.NORMAL) return false;
        return target.contains(cx, cy);
    }
    
    function hide() {
        target.hide();
        target.move(x, y);
    }
    
    function touch() {
        if (type == KawazType.BOMB) {
            fire();
            return false;
        } else {
            damage();
            return true;
        }
    }
    
    function damage() {
        damageSprite.moveCenter(target.getCenterX(), target.getCenterY());
        audio.playSE0();
        hide();
        damageSprite.show();
        
        damageSprite.clearModifier();
        
        damageModifier = emo.NoopModifier(250);
        damageModifier.setEventListener(this);
        damageSprite.addModifier(damageModifier);
    }
    
    function fire() {
        fireSprite.moveCenter(target.getCenterX(), target.getCenterY());
        audio.playSE1();
        hide();
        fireSprite.show();
        
        fireSprite.clearModifier();
        
        damageModifier = emo.NoopModifier(250);
        damageModifier.setEventListener(this);
        fireSprite.addModifier(damageModifier);
    }
    
    function remove() {
        target.remove();
        damageSprite.remove();
        fireSprite.remove();
    }
    
    // This function is called by modifier of the splash sprite.
    // eventType equals EVENT_MODIFIER_FINISH if the modifier ends.
    function onModifierEvent(obj, modifier, eventType) {
        if (eventType == EVENT_MODIFIER_FINISH) {
            if (modifier == popModifier) {
                kawazOn = true
                status = KawazState.NORMAL;
                waitAndHide();
            } else if (modifier == hideModifier) {
                hide();
                status = KawazState.WAITING;
                kawazOn = false;
            } else if (modifier == damageModifier) {
                damageSprite.hide();
                fireSprite.hide();
                status = KawazState.WAITING;
                kawazOn = false;
            }
        }
    }
}

class GameSound {
    looping = false;
    name    = null;
    channel = null;
    loaded  = false;
    
    function constructor() {
    
    }
    
    function load() {
        channel.load(name);
        channel.setLoop(looping);
        loaded = true;
    }
    
    function play(reset = false) {
        channel.play(reset);
    }
    
    function pause() {
        channel.pause();
    }
    
    function stop() {
        channel.stop();
    }
    
    function close() {
        channel = null;
        loaded  = false;
    }
}

class AudioLoader {
    audio  = null;
    
    bgmCh0 = null;
    
    seCh0  = null;
    seCh1  = null;
    seCh2  = null;

    function ensure() {
        if (audio == null) {
            audio = emo.Audio(4);

            if (bgmCh0 == null) bgmCh0 = GameSound();
            if (seCh0 == null)  seCh0  = GameSound();
            if (seCh1 == null)  seCh1  = GameSound();
            if (seCh2 == null)  seCh2  = GameSound();
            
            bgmCh0.channel = audio.createChannel(0);
            seCh0.channel  = audio.createChannel(1);
            seCh1.channel  = audio.createChannel(2);
            seCh2.channel  = audio.createChannel(3);
        }
    }

    function close() {
        if (audio != null) {
            audio.closeEngine();
        }
        audio  = null;
        
        bgmCh0.close();
        seCh0.close();
        seCh1.close();
        seCh2.close();
    }
    
    function loadBGM(name, looping = true) {
        ensure();
        
        bgmCh0.name    = name;
        bgmCh0.looping = looping;
        bgmCh0.load();
    }
    
    function loadSE0(name, looping = false) {
        ensure();
        
        seCh0.name    = name;
        seCh0.looping = looping;
        seCh0.load();
    }
    
    function loadSE1(name, looping = false) {
        ensure();
        
        seCh1.name    = name;
        seCh1.looping = looping;
        seCh1.load();
    }
    
    function loadSE2(name, looping = false) {
        ensure();
        
        seCh2.name    = name;
        seCh2.looping = looping;
        seCh2.load();
    }
    
    function playBGM() {
        ensure();
        if (bgmCh0.name != null && !bgmCh0.loaded) {
            bgmCh0.load();
        }
        bgmCh0.play();
    }
    
    function playSE0() {
        ensure();
        if (seCh0.name != null && !seCh0.loaded) {
            seCh0.load();
        }
        seCh0.play(true);
    }
    
    function playSE1() {
        ensure();
        if (seCh1.name != null && !seCh1.loaded) {
            seCh1.load();
        }
        seCh1.play(true);
    }
    
    function playSE2() {
        ensure();
        if (seCh2.name != null && !seCh2.loaded) {
            seCh2.load();
        }
        seCh2.play(true);
    }
    
    function pauseBGM() {
        if (bgmCh0 != null && bgmCh0.loaded) bgmCh0.pause();
    }
    
    function pauseSE0() {
        if (seCh0 != null && seCh0.loaded) seCh0.pause();
    }
    
    function pauseSE1() {
        if (seCh1 != null && seCh1.loaded) seCh1.pause();
    }
    
    function pauseSE2() {
        if (seCh2 != null && seCh2.loaded) seCh2.pause();
    }

    function stopBGM() {
        if (bgmCh0 != null && bgmCh0.loaded) bgmCh0.stop();
    }
    
    function stopSE0() {
        if (seCh0 != null && seCh0.loaded) seCh0.stop();
    }
    
    function stopSE1() {
        if (seCh1 != null && seCh1.loaded) seCh1.stop();
    }
    
    function stopSE2() {
        if (seCh2 != null && seCh2.loaded) seCh2.stop();
    }
}
