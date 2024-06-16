-----------------------------------------------------------------------------------------
-- '地' 的物件設定
-----------------------------------------------------------------------------------------

-- 引用   寫於其他地方的 function
require("scripts.assetHandlers.imageHandler") -- 引用 script/asestHandler/imageHandler.lua (引用路徑一切都看 main.lua)
require("scripts.assetHandlers.soundHandler") -- 引用 script/asestHandler/soundHandler.lua (引用路徑一切都看 main.lua)
require("scripts.objects.cropObjects")
require("scripts.inventory")
require("scripts.systemRecord")


-----------------------------------------------
-- 此 file 才能用的 function (命名：程式名_能做的事)
-----------------------------------------------
-- 方形澆水 or 施肥 (squareSize 限奇數)，會回傳開始執行的動畫
local function landObject_squareWatering(nowRow, nowColumn, isWatering, squareSize, startedDelay)
  local expandSize = math.floor(squareSize/2) -- 3*3 expend 1 
  
  local function trueWatering()
    for i=(nowRow-expandSize), (nowRow+expandSize) do
      for j=(nowColumn-expandSize), (nowColumn+expandSize) do
        if (1 <= i and  i <= landObjects_Grounds["row"]) and (1 <= j and  j <= landObjects_Grounds["column"]) then
          if isWatering then
            landObjects_Grounds["matrix"][i][j].beWatered()
          else
            landObjects_Grounds["matrix"][i][j].beFertilized()
          end
        end
      end
    end
  end
  
  return timer.performWithDelay(startedDelay, trueWatering)
end



-----------------------------------------------
-- 可以通用於其他 file 的 function (命名：程式名_能做的事)
-----------------------------------------------
-- 紀錄讓地可以被 access 的陣列
landObjects_Grounds = 
{
  rowNumber = 0,
  columnNumber = 0,
  matrix = {},
}



-- 農地
function landObjects_NormalGround(x, y, width, height)
    -- 創建 group
    local landGroup = display.newGroup()
    -- 創建物件
    local halfWidth = width/2
    local halfHeight = height/2
    local vertices = { -halfWidth,0, 0,halfHeight, halfWidth,0, 0,-halfHeight,} -- 45度切割
    local landObject = display.newPolygon(landGroup, halfWidth, halfHeight, vertices )
    
    ------ // 特性設定 // --------
    -- group 位置
    landGroup.x = x
    landGroup.y = y
    -- object 位置
    landObject.x = 0
    landObject.y = 0
    -- 作物
    landObject.crop = nil
    -- 現在的土地特性 (與圖片同)
    landObject.state = "normal"
    -- 是否能互動
    landObject.canInteract = true
    -- 預載好已澆水的圖
    landObject.watered = display.newPolygon(landGroup, halfWidth, halfHeight, vertices )
    landObject.watered.x = 0
    landObject.watered.y = 0
    -- 預載好已施肥的圖
    landObject.fertilized = display.newPolygon(landGroup, halfWidth, halfHeight, vertices )
    landObject.fertilized.x = 0
    landObject.fertilized.y = 0
    -- 要計錄使用的動畫，換天時要強制停止
    landObject.changingAnimation = nil
    landObject.beWateredAnimation = nil
    -- load 所有需要的圖，並顯示 default
    landObject.showImages = {normal = imageHandler_LoadImage("land_normal"), 
                             watered = imageHandler_LoadImage("land_watered"),
                             fertilized = imageHandler_LoadImage("land_fertilized"),
                             }
    imageHandler_ShowImageInRect(landObject, landObject.showImages[landObject.state]) -- 顯示 noraml
    imageHandler_ShowImageInRect(landObject.watered, landObject.showImages["watered"]) -- 載  watered
    landObject.watered.alpha = 0 -- 設定完全透明
    imageHandler_ShowImageInRect(landObject.fertilized, landObject.showImages["fertilized"]) -- 載  fertilized
    landObject.fertilized.alpha = 0 -- 設定完全透明
    -- load 所需音效
    landObject.soundEffects = {nothingClicked = soundHandler_LoadSoundEffect("ground_nothingClicked"), 
                               watered = soundHandler_LoadSoundEffect("ground_watered"), 
                               seeded = soundHandler_LoadSoundEffect("ground_seeded"),
                               fertilized = soundHandler_LoadSoundEffect("ground_fertilized"),
                               }
    
    ----- // 溝通方式 // -------- 
    -- 被施肥動作 (要用 group 比較好溝通)
    landGroup.beFertilized = function()
      if not (landObject.state == "fertilized") then -- 不會重複施肥
        landObject.state = "fertilized" -- 變成施肥狀態
        landObject.changingAnimation = systemRecord_fadeAnimation(landObject.fertilized, 200, true) -- 澆花動畫(0.75 秒, fade in) + 變成已澆水圖片
        soundHandler_PlaySoundEffect(landObject.soundEffects["fertilized"]) -- 播放施肥音效
      end
    end
    
    -- 被澆水動作 (要用 group 比較好溝通)
    landGroup.beWatered = function()
      if not (landObject.state == "fertilized") then -- 不會把更高級的取代
        landObject.state = "watered" -- 變成澆水狀態
        landObject.changingAnimation = systemRecord_fadeAnimation(landObject.watered, 750, true) -- 澆花動畫(0.75 秒, fade in) + 變成已澆水圖片
        soundHandler_PlaySoundEffect(landObject.soundEffects["watered"]) -- 播放被繳水東西音效
      end
    end
   
    -- 看 cursor 是否在邊界內
    local function landObject_isInBound(event)
        local isInBound = false
        local relativeX = math.abs(event.x - landObject.x - landGroup.x) -- 換算真正的 land 中心。才能相減
        local relativeY = math.abs(event.y - landObject.y - landGroup.y)
        
        if halfHeight * relativeX + halfWidth * relativeY <= halfWidth * halfHeight then -- 在斜對角內
          isInBound = true
        end
      return isInBound
    end

    -- 按下返回偵測 (看是否出邊界 or 放手)
    local function landObject_detactBounceReleased(event)
      -- 在邊界外 or 放手 > 回復 + 已不用聽
      if not landObject_isInBound(event) or event.phase == "ended" then
      
        -- 要未回復才回復
        if not landObject.canInteract then 
          landObject.canInteract = true 
          local scaleToBack = 1/ systemRecord_Interaction["bounce_shrinkSize"]
          landGroup:scale(scaleToBack, scaleToBack) -- 用 group 一起 scale
        end
        -- task finsihed, remove listener
        Runtime:removeEventListener("touch", landObject_detactBounceReleased) 
        
      end
    end

    -- 監聽，按到就縮小 + 執行決定的 function
    local onTouch = function(event)
      -- 按下 or 移進來 + (在邊界內 + 可以互動)，才互動
      if ( event.phase == "began"  or event.phase == "moved" ) and (landObject_isInBound(event) and landObject.canInteract) then
          -- 回饋 + 基礎設定
          landObject.canInteract = false
          local shrinkSize = systemRecord_Interaction["bounce_shrinkSize"]
          landGroup:scale(shrinkSize, shrinkSize) -- 大小改變
          Runtime:addEventListener("touch", landObject_detactBounceReleased) -- 看是否放手 or 離開 (by 隨時偵測)
          
          
          -- // 依目前使用的 inventory 狀態做事 // --
          -- 沒拿東西
          if Inventory_nowUsingStuff == nil then 
            soundHandler_PlaySoundEffect(landObject.soundEffects["nothingClicked"]) -- 播放動作失敗音效
            
          -- 種種子 (在沒作物時才能種)
          elseif Inventory_nowUsingStuff.name == "seedBag" and landObject.crop == nil then 
            if not Inventory["seed"].modifyNumber(-1) then -- 少一顆，沒有不足，才種
              landObject.crop = cropObjects_Pineapple(0, 0, 0.75*width, 0.75*height, landObject) -- 種下去
              landGroup:insert(landObject.crop) -- 加入 group
              soundHandler_PlaySoundEffect(landObject.soundEffects["seeded"]) -- 播放種東西音效
            else -- 沒種子了
              soundHandler_PlaySoundEffect(Inventory_nowUsingStuff.soundEffects["empty"]) -- 播放種子動作失敗音效
            end
            
          -- 挖除作物 (在有作物時才能挖除)
          elseif Inventory_nowUsingStuff.name == "hoe" and not (landObject.crop == nil) then 
            Inventory["seed"].modifyNumber(1) -- 還一顆種子
            -- 複製現在的作物圖片
            local nowCropImage = landObject.crop.showImages[landObject.crop.state]
            local spawnedEffectCrop = imageHandler_SpawnDirectlyImage("pineapple_stage"..landObject.crop.state)
            landGroup:insert(spawnedEffectCrop)
            spawnedEffectCrop.x = nowCropImage.x
            spawnedEffectCrop.y = nowCropImage.y
            spawnedEffectCrop.width = nowCropImage.width
            spawnedEffectCrop.height = nowCropImage.height
            -- 移除東西
            landObject.crop.removeCrop() -- 直接刪除，避免馬上換天而出問題
            landObject.crop = nil -- 移除後要設為 nil
            systemRecord_jumpAnimationAndRemove(spawnedEffectCrop, height/9, 200, 1) -- 移除！(要物件, 總共距離, 動畫總共時間(tick 為單位), 多久後開始 fade(至少要 1))
            soundHandler_PlaySoundEffect(Inventory_nowUsingStuff.soundEffects["removeCrop"]) -- 播放移除作物音效
            
          -- 澆水 (只能澆沒正常的)
          elseif Inventory_nowUsingStuff.name == "wateringCan" and (landObject.state == "normal") then
            if not Inventory["wateringTime"].modifyNumber(-1) then -- 少一次，沒有不足，才澆
              landGroup.beWatered() -- 澆水自己
            else -- 沒水澆了
              soundHandler_PlaySoundEffect(Inventory_nowUsingStuff.soundEffects["empty"]) -- 播放澆水動作失敗音效
            end  
          
          -- 收成作物 (只有長滿時才能收成)
          elseif Inventory_nowUsingStuff.name == "sickle" and (not (landObject.crop == nil) and landObject.crop.state == landObject.crop.maxState) then
              Inventory[landObject.crop.level.."Pineapple"].modifyNumber(1) -- 依等級多一顆鳳梨
              -- 複製現在的作物圖片 (產生等級對應 icon)
              local nowCropImage = landObject.crop.showImages[landObject.crop.state]
              local spawnedIcon = display.newRect(nowCropImage.x, nowCropImage.y, nowCropImage.width, nowCropImage.height)
              imageHandler_ShowImageInRect(spawnedIcon, landObject.crop.levelIcon) -- 顯示目前等級
              landGroup:insert(spawnedIcon)
              -- 移除東西
              landObject.crop.removeCrop() -- 直接刪除，避免馬上換天而出問題
              landObject.crop = nil -- 移除後要設為 nil
              systemRecord_jumpAnimationAndRemove(spawnedIcon, -height, 500, 300)  -- 動畫 + 移除！(要物件, 總共距離, 動畫總共時間(tick 為單位), 多久後開始 fade,)
              soundHandler_PlaySoundEffect(Inventory_nowUsingStuff.soundEffects["harvest"]) -- 播放收成音效
              -- 勝利條件減少
              winJudge_pineappleNumber["now"] = winJudge_pineappleNumber["now"] -1
              
          -- 施肥 (非施過肥地面都行)
          elseif string.find(Inventory_nowUsingStuff.name, "Pineapple") and not (landObject.state == "fertilized") then
             if not Inventory[Inventory_nowUsingStuff.name].modifyNumber(-1) then -- 少一次，沒有不足，才澆
              landGroup.beFertilized() -- 施肥自己
              -- 如果用更高級鳳梨，向外施肥 or 澆水
              if not (Inventory_nowUsingStuff.name == "normalPineapple") then
                local nowRow = landGroup.indexInMatrix[1]
                local nowColumn = landGroup.indexInMatrix[2]
                
                 -- 朝 9宮格澆水
                if Inventory_nowUsingStuff.name == "silverPineapple" then
                  landObject.beWateredAnimation = landObject_squareWatering(nowRow, nowColumn, true, 3, 200)
                
                -- 菱形狀 施肥 + 澆水
                elseif Inventory_nowUsingStuff.name == "goldPineapple" then
                  -- 澆水
                  local function diamondWatering()
                    for i=0, 4 do
                      for j=0, 4 do
                        if math.abs(i-j) == 2 or (i%2 == 1 and i == j) then -- 在特定外圍
                          local matrixRow = i + nowRow-2
                          local matrixColumn = j + nowColumn-2
                          if (1 <= matrixRow and  matrixRow <= landObjects_Grounds["row"]) and (1 <= matrixColumn and matrixColumn <= landObjects_Grounds["column"]) then
                              landObjects_Grounds["matrix"][matrixRow][matrixColumn].beWatered()
                          end
                        end
                      end
                    end
                  end
                  -- 施肥
                  local function diamondFertilizing()
                    for i=0, 2 do
                      for j=0, 2 do
                        if math.abs(i-j) == 1 then -- 在特定外圍
                          local matrixRow = i + nowRow-1
                          local matrixColumn = j + nowColumn-1
                          if (1 <= matrixRow and  matrixRow <= landObjects_Grounds["row"]) and (1 <= matrixColumn and matrixColumn <= landObjects_Grounds["column"]) then
                              landObjects_Grounds["matrix"][matrixRow][matrixColumn].beFertilized()
                          end
                        end
                      end
                    end
                    landObject.beWateredAnimation = timer.performWithDelay(200, diamondWatering)
                  end
                  landObject.beWateredAnimation = timer.performWithDelay(200, diamondFertilizing)    
                  
                  -- 完全 2*2 施肥 + 3*3 澆水
                  elseif Inventory_nowUsingStuff.name == "iridumPineapple" then
                    -- 因為三層有先後順序，停前面後面就要停。只想到用這種笨方式
                    local function finalAnimation ()
                      landObject_squareWatering(nowRow, nowColumn, true, 7, 1) 
                    end
                    local function secondAnimation ()
                      landObject_squareWatering(nowRow, nowColumn, false, 5, 1)
                      landObject.beWateredAnimation = timer.performWithDelay(450, finalAnimation)
                    end
                    local function firstAnimation ()
                      landObject_squareWatering(nowRow, nowColumn, false, 3, 1)
                      landObject.beWateredAnimation = timer.performWithDelay(450, secondAnimation)
                    end
                    landObject.beWateredAnimation = timer.performWithDelay(200, firstAnimation)
                  end   
                            
                end -- 更高級才施肥的判斷結束
             else -- 施肥失敗
              soundHandler_PlaySoundEffect(Inventory_nowUsingStuff.soundEffects["empty"]) -- 播放東西空了音效
             end
             
          -- 無動作 or 動作失敗 
          else 
            soundHandler_PlaySoundEffect(landObject.soundEffects["nothingClicked"]) -- 播放動作失敗音效
          end      
          
      end   
    end
    landObject:addEventListener("touch", onTouch)
    
    -- 換天要做的事
    landObject.nextDay = function()
      if not (landObject.state == "normal") then  -- 變回正常狀態
        landObject.state = "normal" 
        landObject.watered.alpha = 0 -- 澆水狀態圖設定回完全透明
        landObject.fertilized.alpha = 0 -- 施肥狀態圖設定回完全透明
      end
      if not (landObject.changingAnimation == nil) then -- 有動畫要強制停止
        landObject.changingAnimation.stop() -- 停止動畫 (會自動移除)
      end
      if not (landObject.beWateredAnimation == nil) then -- 有動畫要強制停止
        timer.cancel( landObject.beWateredAnimation ) -- 停止動畫 (所以會澆水失敗)
      end
      
    end
    table.insert(systemRecord_nextDayListeners, landObject) -- 加入換天時會呼叫的 function 內 (這個要最後呼叫，預設加於最後面)
    
    
    -- 回傳已創建物件
    return landGroup
end