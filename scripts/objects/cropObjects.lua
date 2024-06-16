-----------------------------------------------------------------------------------------
-- '作物' 的物件設定
-----------------------------------------------------------------------------------------

-- 引用   寫於其他地方的 function
require("scripts.assetHandlers.imageHandler") -- 引用 script/asestHandler/imageHandler.lua (引用路徑一切都看 main.lua)
require("scripts.assetHandlers.soundHandler") -- 引用 script/asestHandler/soundHandler.lua (引用路徑一切都看 main.lua)
require("scripts.systemRecord") -- for 換天
require("scripts.winJudge") -- for 勝利條件判斷

-----------------------------------------------
-- 可以通用於其他 file 的 function (命名：程式名_能做的事)
-----------------------------------------------
-- 鳳梨
function cropObjects_Pineapple(x, y, width, height, plantedLand)
    -- 創建空物件
    local cropObject = display.newGroup()
    
    ------ // 特性設定 // --------
    -- 位置
    cropObject.x = x
    cropObject.y = y
    -- 種下去的土地
    cropObject.atLand = plantedLand
    -- 狀態 (1 - 6)，因陣列從 1 開始
    cropObject.state = 1
    cropObject.maxState = 6
    -- 最後的星等判定
    local levelNumber = math.random(100) -- 從 1 - 100 抽
    if levelNumber <= 1 then
      cropObject.level = "iridum"
    elseif levelNumber <= 15 then
      cropObject.level = "gold"
    elseif levelNumber <= 40 then
      cropObject.level = "silver"
    else
      cropObject.level = "normal"
    end   
    -- 把收成時所需圖片 load 好
    cropObject.levelIcon = imageHandler_LoadImage("icon_"..cropObject.level.."Pineapple")

        
    -- 紀錄動畫
    cropObject.playingAnimation = nil
    -- // load 所有需要的圖，並顯示 default // --
    cropObject.showImages = {}
    local imageScale = 0
    -- 先 load 最大的，取得 scaling, 才能 scale 全部 (-1 才會由最大往前 loop)
    for i = cropObject.maxState, 1, -1 do
      local newCrop = imageHandler_SpawnDirectlyImage("pineapple_stage"..i)
      if imageScale == 0 then
        imageScale = width / newCrop.width
      end
      
      newCrop.width = newCrop.width * imageScale
      newCrop.height = newCrop.height * imageScale
      newCrop.x = 0
      if i == 1 then  -- 種子放正中央，其他依高度
        newCrop.y = 0
      else
        newCrop.y = -newCrop.height/2 + height/4  -- 確保 底 是一樣的 (才有長大的 fu) + 要下移一點比較好看
      end
      newCrop.isVisible = false -- 一率先影藏
      table.insert(cropObject.showImages, 1, newCrop) -- 加入紀錄(從最前面 加入)
      cropObject:insert(newCrop) -- 加入物件 group
    end
    cropObject.showImages[1].isVisible = true -- 顯示第一張 (種子)
    -- load 所需音效
--    buttonObject.soundEffects = {nothingClicked = soundHandler_LoadSoundEffect("ground_nothingClicked"), 
--                                 watered = soundHandler_LoadSoundEffect("ground_watered"), 
--                                 seeded = soundHandler_LoadSoundEffect("ground_seeded"),
--                                  }
 
    
    ----- // 溝通方式 // --------
    
    -- 農作物的動畫
    local danceAnimation = function (nowCrop)
      local totalShrinkTime = 1000 -- 記得要用 ticks
      local shrinkMostHeight = nowCrop.height * 0.925
      local originHeight = nowCrop.height
      local shrinkPerCall = 0.1
      local perCallTime = totalShrinkTime / ((originHeight - shrinkMostHeight) / shrinkPerCall) -- 總時間 / 要縮小次數
      local direction = 1
      
      -- 真正動畫
      local function trueAnimation()
        nowCrop.height = nowCrop.height - shrinkPerCall * direction
        nowCrop.y = nowCrop.y  + shrinkPerCall/2 * direction
        
        if nowCrop.height <= shrinkMostHeight then
          direction = -1
        elseif nowCrop.height > originHeight then
          direction = 1
        end
        
        cropObject.playingAnimation = timer.performWithDelay(perCallTime, trueAnimation)
      end
      cropObject.playingAnimation = trueAnimation()
    end
    
    -- 刪除動畫
    cropObject.removeAnimationIfHave = function()
      if not (cropObject.playingAnimation == nil) then
        timer.cancel(cropObject.playingAnimation) -- 結束現在動畫 (如果有)
        cropObject.playingAnimation = nil
      end
    end
    
    -- 換天時要做的事
    cropObject.nextDay = function()
      -- 有特殊狀態 + 沒長最大 > 就長大
      if not (cropObject.atLand.state == "normal") and cropObject.state < cropObject.maxState then
        cropObject.showImages[cropObject.state].isVisible = false -- 現在的取消顯示
        if cropObject.atLand.state == "watered" then -- 澆水，加 1
          cropObject.state = cropObject.state +1
        elseif cropObject.atLand.state == "fertilized" then -- 施肥，直接長到最大
          cropObject.state = cropObject.maxState
        end
        cropObject.showImages[cropObject.state].isVisible = true -- 顯示 現在的圖     
        
        cropObject.removeAnimationIfHave()
        danceAnimation(cropObject.showImages[cropObject.state]) -- 開始新動畫
        
        if cropObject.state == cropObject.maxState then -- 勝利條件增加
          winJudge_pineappleNumber["now"] = winJudge_pineappleNumber["now"] +1
        end
      end
    end
    table.insert(systemRecord_nextDayListeners, 1, cropObject) -- 加入換天時會呼叫的 function 內(要最先呼叫，這樣可加於最前面)
    

    -- 移除 crop
    cropObject.removeCrop = function()
      cropObject.removeAnimationIfHave() -- 刪動畫
      cropObject:removeSelf()
--      cropObject.nextDay:removeSelf() -- 移除換天 function (已用邊掃描邊移出方式解決)
    end
    
    -- 回傳已創建物件
    return cropObject
end