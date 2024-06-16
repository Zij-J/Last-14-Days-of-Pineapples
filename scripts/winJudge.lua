-----------------------------------------------------------------------------------------
-- 勝利條件相關
-----------------------------------------------------------------------------------------

-- 引用 寫於其他地方的 function
require("scripts.assetHandlers.soundHandler") -- 引用 script/asestHandler/soundHandler.lua (引用路徑一切都看 main.lua)
require("scripts.inventory") -- for 剩餘天數 get
require("scripts.systemRecord") -- for 換天

-----------------------------------------------
-- 此 file 才能用的 function (命名：程式名_能做的事)
-----------------------------------------------



-- 紀錄在農場上鳳梨總數 for 勝利判斷
winJudge_pineappleNumber =
{
  now = 0,
  Max = 0,
}

-----------------------------------------------
-- 可以通用於其他 file 的 function (命名：程式名_能做的事)
-----------------------------------------------
-- 緊張時刻
function winJudge_tension(backgroundGroup)
  local tensionRecords = display.newGroup()
  tensionRecords.textShineAnimation = nil
  tensionRecords.MaskAnimation = nil

  -- 文字會換色 + 不斷閃爍
  Inventory["leftTime"].showUI.colors["origin"] = {216/255, 63/255, 49/255}
  local function textShinging()
    Inventory["leftTime"].showUI.shiningAnimation()
    tensionRecords.textShineAnimation = timer.performWithDelay(1500, textShinging) -- 等開頭音樂播完換動畫
  end
  textShinging()
  
  -- 背景圖片 tint
  backgroundGroup.tintMask = display.newRect(display.contentWidth/2, display.contentHeight/2, display.contentWidth*2,  display.contentHeight*2) -- 占全螢幕的黑布
  backgroundGroup.tintMask.x = 0
  backgroundGroup.tintMask.y = 0
  backgroundGroup:insert(backgroundGroup.tintMask)
  backgroundGroup.tintMask.fill = {245/255, 63/255, 31/255} 
  backgroundGroup.tintMask.alpha = 0.15 -- 至少需要一點 alpha 才能握動畫
  tensionRecords.MaskAnimation = systemRecord_partyShineAnimation(backgroundGroup.tintMask, 0.15, 1000, true) -- 動畫
  
  -- 撥 BGM
  soundHandler_PlayBGM("tension_mainLoop") 
  
  tensionRecords.stop = function(isStopTextShine)
    if not (tensionRecords.textShineAnimation == nil) and isStopTextShine then
      timer.cancel(tensionRecords.textShineAnimation)
    end
    if not (tensionRecords.MaskAnimation == nil) then
      tensionRecords.MaskAnimation.stop()
    end
  end
  
  return tensionRecords
end


-- 判斷成敗物件 + 成敗結果顯示
function winJudge_createJudgeObject(backgroundGroup)
  local judgeObject = display.newGroup()
  judgeObject.soundEffects = {AdayDone = soundHandler_LoadSoundEffect("winJudge_AdayGone"),}
  judgeObject.tensionRecord = nil
  
  
  -- 成功/失敗檢測 at 換天
  judgeObject.nextDay = function()
    -- 發現剩 6 天 (等下減 1 會變 5 天)，開啟緊張模式
    if Inventory["leftTime"].number == 5 then
      judgeObject.tensionRecord = winJudge_tension(backgroundGroup)
    end
  
    -- 少一天
    Inventory["leftTime"].modifyNumber(-1)     
    soundHandler_PlaySoundEffect(judgeObject.soundEffects["AdayDone"]) -- 翻日歷音效
    
    -- 成功判斷 + 結果圖
    if winJudge_pineappleNumber["now"] == winJudge_pineappleNumber["Max"] then
      -- 用黃色填滿
      local cover = systemRecord_createBlackCover(0.1)
      cover.fill = {247/255, 173/255, 64/255} 
      -- 成功圖片 
      local picture = imageHandler_SpawnDirectlyImage("winPage_win")
      picture.x = display.contentWidth/2
      picture.y = display.contentHeight/2
      local imageScale = (display.contentWidth/2) / picture.width
      picture.width = picture.width * imageScale 
      picture.height = picture.height * imageScale 
      picture.isVisible = false
      systemRecord_zoomInOrOut(picture, 10, false) -- 先縮小
      
      -- 成功動畫(圖)
      local pictureJumpWidth = picture.width/5 -- 動畫前的設定
      local pictureJumpHeight = picture.height/10 -- 動畫前的設定
      picture.x = picture.x - pictureJumpWidth/2
      local function jumpingPictureAnimation()
        local sideToSideTime = 60000/128 *0.66
        local deltaTime = 10
        local totalUnitsOfTime = sideToSideTime / deltaTime
        -- 位置參數
        local acclerate = 2*pictureJumpHeight / ((totalUnitsOfTime/2)*(totalUnitsOfTime/2)) -- 0.5at^2 = 上拋距離，可 get 要的加速度
        local upSpeed = -acclerate *(totalUnitsOfTime/2)
        local sideSpeed = pictureJumpWidth/totalUnitsOfTime -- 距離 / 速率 = 時間
        -- size 參數
        local shrinkSize = picture.height/10
        local shrinkPerTime = shrinkSize/totalUnitsOfTime
        
        -- 真動畫
        local nowUpSpeed = upSpeed
        local originY = picture.y
        local originWidth = picture.width
        local originHeight = picture.height
        local function updateTime()
          -- 位置移動
          nowUpSpeed = nowUpSpeed + acclerate
          picture.x = picture.x + sideSpeed
          picture.y = picture.y + nowUpSpeed
          -- size 縮放
          if nowUpSpeed < 0 then -- 在上升
            picture.width = picture.width - shrinkPerTime
            picture.height = picture.height + shrinkPerTime
          elseif nowUpSpeed > 0 then -- 在下墜
            picture.width = picture.width + shrinkPerTime
            picture.height = picture.height - shrinkPerTime
          end
          -- 方向調整
          if nowUpSpeed >= -upSpeed then -- 已經太低(跳完了)，往反方向跳
            sideSpeed = sideSpeed * (-1)
            nowUpSpeed = upSpeed
            picture.y = originY -- 因為誤差，所以要校正
            picture.width = originWidth
            picture.height = originHeight
          end

          
          timer.performWithDelay(deltaTime, updateTime)
        end
        updateTime()
      end
      -- 成功動畫開始
      local function winAnimation_startLoop()
        picture.backAnimation.stop() -- 停止原有的
        picture.backAnimation = systemRecord_partyShineAnimation(cover, 0.3, 60000/128, true) -- 60000: 一分鐘，128: bmp，所以會得出四分音符速度
        
        -- 顯示圖
        systemRecord_zoomInOrOut(picture, 300, true) -- 放大回來
        timer.performWithDelay(500, jumpingPictureAnimation)
      end
      local function winAnimation_first()
        if not (judgeObject.tensionRecord == nil) then -- 停止 tesion 動畫
          judgeObject.tensionRecord.stop(true)
        end
        picture.backAnimation = systemRecord_partyShineAnimation(cover, 0.35, 320, false) -- 60000: 一分鐘，128: bmp，所以會得出四分音符速度
        timer.performWithDelay(3400, winAnimation_startLoop) -- 等開頭音樂播完換動畫
      end
      winAnimation_first() -- 先撥第一段
      -- 成功音效
      soundHandler_PlayBGMandPrelude("win_prelude", "win_mainLoop")
    
    -- 失敗判斷
    elseif Inventory["leftTime"].number == 0 then
      if not (judgeObject.tensionRecord == nil) then -- 停止 tesion 動畫
        judgeObject.tensionRecord.stop(false)
      end
    
      -- 用紅色填滿
      local cover = systemRecord_createBlackCover(0.65)
      cover.fill = {161/255, 31/255, 45/255} 
      -- 失敗圖片 
      local picture = imageHandler_SpawnDirectlyImage("winPage_lose")
      picture.x = display.contentWidth/2
      picture.y = display.contentHeight/2
      local imageScale = (display.contentWidth + 400) / picture.width -- +400 是把未補齊的邊界補齊
      picture.width = picture.width * imageScale 
      picture.height = picture.height * imageScale 
      picture.alpha = 0
      -- 失敗動畫
      systemRecord_fadeAnimation(picture, 1000, true)
      -- 失敗音效
      soundHandler_StopBGM()  -- 要停止 BGM
      soundHandler_PlaySoundEffect(soundHandler_LoadSoundEffect("winPage_lose")) -- 播放收成音效
    end
    
  end
  table.insert(systemRecord_nextDayListeners, judgeObject) -- 這個要在長大後呼叫 (這樣就可放於最後面)
  
  return judgeObject
end