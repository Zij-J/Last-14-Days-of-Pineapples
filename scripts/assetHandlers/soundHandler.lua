-----------------------------------------------------------------------------------------
-- 背景音樂 & 音效載入 & 播放
-----------------------------------------------------------------------------------------

-- 引用 寫於其他地方的 function
require("sounds.usageTable_Sounds") -- 引用 images/usageTable_Image.lua (引用路徑一切都看 main.lua)
local utf8 = require( "plugin.utf8" ) -- 要轉換中文用
-----------------------------------------------
-- 可以通用於其他 file 的 function (命名：程式名_能做的事)
-----------------------------------------------

local beforeSound = nil
local repeatSoundEffectLoadTime = 0
local repeatSoundEffectTimeGap = system.getTimer()
local function clearLoadTime()
  repeatSoundEffectLoadTime  = repeatSoundEffectLoadTime -1
end



-- 把 音效載入
function soundHandler_LoadSoundEffect(soundEffectName)
    local sounfPath = utf8.sub("sounds/soundEffects/"..UsageTable_SoundEffects[soundEffectName], 1) -- 換成能接受格式，1 表示從頭開始全部
    local effect = audio.loadSound(sounfPath)
    return effect
end

-- 播放音效 (避免一次大量 Load 而爆音)
function soundHandler_PlaySoundEffect(loadedSoundEffect)
    -- 新音效，就歸零
    if not (beforeSound == loadedSoundEffect) or (system.getTimer() - repeatSoundEffectTimeGap > 20) then
      beforeSound = loadedSoundEffect
      repeatSoundEffectLoadTime = 0
    else
      repeatSoundEffectLoadTime = repeatSoundEffectLoadTime +1
      repeatSoundEffectTimeGap = system.getTimer()
    end
    
    -- 要不重複 7 遍才播
    if repeatSoundEffectLoadTime <= 3 then
      audio.play(loadedSoundEffect, {onComplete=clearLoadTime})
    end
    --audio.setVolume(1)
end



-- 紀錄現在的音樂
local nowPlayingBGM = nil

-- 中止目前音樂
function soundHandler_StopBGM()
   if not (nowPlayingBGM == nil) then
--     audio.fadeOut( {time=500 } )
     audio.stop( nowPlayingBGM )
   end
end


-- 播放音樂 + 中止目前播放音樂
function soundHandler_PlayBGM(BGMname)
   soundHandler_StopBGM()

   -- 播放
   local musicPath = utf8.sub("sounds/BGM/"..UsageTable_BGMs[BGMname], 1) -- 換成能接受格式，1 表示從頭開始全部
   nowPlayingBGM = audio.play( audio.loadSound(musicPath) , {loops = -1})   
end


-- 播放音樂(有前奏) + 中止目前播放音樂
function soundHandler_PlayBGMandPrelude(PreludeName, BGMname) 
   soundHandler_StopBGM()

   -- 播主音樂 (要先 load 好，之後馬上播，避免延遲)
   local loadedMain =  nil
   local function playMainBGM()
     if not (loadedMain == nil) then
       nowPlayingBGM = audio.play(loadedMain, {loops = -1})
     else -- 應該不太可能沒 load 好但還是寫一下以防萬一
       print("PRELUDE LOAD UNFINISHED!!")
       os.exit(1) -- 會直接結束，代表這裡要 debug
     end
   end
   
   -- 播放前奏 (播完接主音樂)
   local preludePath = utf8.sub("sounds/BGM/"..UsageTable_BGMs[PreludeName], 1) -- 換成能接受格式，1 表示從頭開始全部
   nowPlayingBGM = audio.play( audio.loadSound(preludePath) , {onComplete=playMainBGM})  
   -- 在前奏時 load 主音樂
   local musicPath = utf8.sub("sounds/BGM/"..UsageTable_BGMs[BGMname], 1) -- 換成能接受格式，1 表示從頭開始全部
   loadedMain = audio.loadSound(musicPath)
end