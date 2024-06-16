-----------------------------------------------------------------------------------------
-- 使用者介面的物件
-----------------------------------------------------------------------------------------

-- 引用 寫於其他地方的 function
require("scripts.assetHandlers.imageHandler") -- 引用 script/asestHandler/imageHandler.lua (引用路徑一切都看 main.lua)
require("scripts.assetHandlers.soundHandler") -- 引用 script/asestHandler/soundHandler.lua (引用路徑一切都看 main.lua)
require("fronts.usgaeTable_Fronts") -- 直接引用 usageTable 以使用字型\
require("scripts.systemRecord") -- for 動畫
require("scripts.inventory") 


-----------------------------------------------
-- 在這個 file 才會用到的 function
-----------------------------------------------
--[=====[  用於把 pressed/unpressed 的圖 Load 進去的 function (已無用)
local function loadButtonImages(unpressedPictureName, pressedPictureName)
  -- 把圖片名字綁在一起，比較好一起處理
  local imageCache = {
    unpressedPictureName,
    pressedPictureName,
  }
  
  -- 處理所有圖片 (把 type。filename 寫好，才能用於 fill)
  local images = {}
  for i = 1,#imageCache do
      images[i] = { type="image", filename="images/UI/"..UsageTable_Image_UI[imageCache[i]] }
  end
  
  return images
end
--]=====]

-- 有長按不放處理的 touch listener (event, 有依以下處理製作的 buttonObject, 放手時要做的 function)
local function buttonFocusTouchHandle(event, buttonObject, doingFunction)
  -- 按下去
  if event.phase == "began" then
    imageHandler_ShowImageInRect(buttonObject, buttonObject.showImages["pressed"]) -- 換成按下去的圖  
    if not (buttonObject.soundEffects["pressed"] == nil) then -- 可以不要有按下去的音效，設成 nil 即可
      soundHandler_PlaySoundEffect(buttonObject.soundEffects["pressed"]) -- 播放按下去音效
    end
    buttonObject.isPress = true
    display.getCurrentStage():setFocus( buttonObject ) -- 設定 focus，這樣移到其他地方仍會按住此按鈕
    if not (buttonObject.showText == nil) then
      buttonObject.showText.y = buttonObject.showText.y + buttonObject.showText.height/10
    end
  -- 放開
  else
    if buttonObject.isPress and ( event.phase == "ended" or event.phase == "cancelled" )then
      imageHandler_ShowImageInRect(buttonObject, buttonObject.showImages["unpress"]) -- 換成原本的圖 
--        soundHandler_PlaySoundEffect(buttonObject.soundEffects["released"]) -- 播放放開音效
      buttonObject.isPress = false
      display.getCurrentStage():setFocus( nil ) -- 設定 focus 回沒有
      if not (buttonObject.showText == nil) then -- 還原文字
        buttonObject.showText.y = buttonObject.showText.y - buttonObject.showText.height/10
      end
      
      doingFunction()-- 做事！
    end
  end
end


-----------------------------------------------
-- 可以通用於其他 file 的 function (命名：程式名_能做的事)
-----------------------------------------------
-- 創建 devil button 物件 (文字, x, y ,width, height, 彈起的時間,  按下去會執行的 function)
function UIobjects_DevilButton(showText, x, y, width, height, delayTicks, onClickFunction)
    -- 創建物件
    local buttonObject = display.newRect(x, y, width, height)
    
    ------ // 特性設定 // --------
    -- 位置
    buttonObject.x = x
    buttonObject.y = y 
    -- 是否按下去
    buttonObject.isPress = false
    -- load 所有需要的圖，並顯示沒按的圖
    buttonObject.showImages = {unpress = imageHandler_LoadImage("devilButton_unpressed"), 
                               pressed = imageHandler_LoadImage("devilButton_pressed")}
    imageHandler_ShowImageInRect(buttonObject, buttonObject.showImages["unpress"]) -- 顯示 unpress
    -- 按鈕的文字 (文字放於正中心，x,y 座標都是指圖片中心)
    buttonObject.text = display.newText(showText, x, y, system.nativeFont, height/6)
    buttonObject.text:setTextColor(0, 0, 0) -- 黑色
    -- load 所需音效
    buttonObject.soundEffects = {pressed = soundHandler_LoadSoundEffect("devilButton_pressed"),
                                 released = soundHandler_LoadSoundEffect("devilButton_released")}
    
    ----- // 溝通方式 // --------
    -- 按鈕自動放開要做的事
    local autoRelease = function(event)
        imageHandler_ShowImageInRect(buttonObject, buttonObject.showImages["unpress"]) -- 換成原本的圖 
--        soundHandler_PlaySoundEffect(buttonObject.soundEffects["released"]) -- 播放放開音效
        buttonObject.isPress = false
    end
    -- 監聽，按到就換圖 + 執行決定的 function
    local onTouch = function(event)
      -- 按下去
      if event.phase == "began" and not buttonObject.isPress then
        imageHandler_ShowImageInRect(buttonObject, buttonObject.showImages["pressed"]) -- 換成按下去的圖  
        soundHandler_PlaySoundEffect(buttonObject.soundEffects["pressed"]) -- 播放按下去音效
        buttonObject.isPress = true
        
        onClickFunction()-- 呼叫要執行的 function
        timer.performWithDelay( delayTicks, autoRelease ) -- 時間到放開
      end
    end
    buttonObject:addEventListener("touch", onTouch)
    
    -- 回傳已創建物件
    return buttonObject
end



-- 創建顯示物品數量的文字 (要顯示的 Inventory, 在的 Group, 固定的 左上 位置, 字大小, 顏色)
function UIobjects_InventoryNumberText(showingInventory, inGroup, leftX, upY, frontSize, colorArray)
    -- 創建物件
    local showingWord = "×"..showingInventory.number
    local textObject =  display.newText(inGroup, showingWord, 0, 0, UsageTable_Fronts["inventory_recordNumber"], frontSize) 
  
 
    ------ // 特性設定 // --------
    -- 計算位置 
    textObject.x = leftX + textObject.width/2
    textObject.y = upY + textObject.height/2
    -- 顏色設定
    textObject.colors = {origin = colorArray,
                         empty = {1, 0, 0},
                        }
    if showingInventory.number == 0 then -- 一開始是 0 就要顯示紅色
      textObject.nowUsingColor = textObject.colors["empty"]
    else
      textObject.nowUsingColor = textObject.colors["origin"]
    end
    textObject:setTextColor(textObject.nowUsingColor[1], textObject.nowUsingColor[2], textObject.nowUsingColor[3])
    -- 記住正在紀錄的數字
    textObject.nowRecordNumber = showingInventory.number
    
    ----- // 溝通方式 // --------    
    -- 數字閃爍動畫
    local shiningTime = 6 -- 閃  6 次 
    local nowShiningTime = shiningTime
    textObject.shiningAnimation = function()
      -- 閃 (偶數變白，奇數變回本色)
      if nowShiningTime > 0 then
        if nowShiningTime %2 == 0 then
          textObject:setTextColor(1, 1, 1)
        else
          textObject:setTextColor(textObject.nowUsingColor[1], textObject.nowUsingColor[2], textObject.nowUsingColor[3])
        end
        nowShiningTime = nowShiningTime -1
        timer.performWithDelay( 60, textObject.shiningAnimation) -- 換下一個閃
      -- 結束，重置
      else
        nowShiningTime = shiningTime
      end
    end
        
    -- 更新現在的文字 (要傳入想更新的數字)
    textObject.updateText = function(getNewNumber)
      textObject.text = "×"..getNewNumber
      -- 計算新位置 
      textObject.x = leftX + textObject.width/2
      textObject.y = upY + textObject.height/2
      -- // 顏色設定 // --
      -- 改變失敗，提醒
      if (textObject.nowRecordNumber == getNewNumber) then 
        if nowShiningTime == shiningTime then -- 歸零警示，在警示結束前不能再警示
          textObject.shiningAnimation()
        else -- 警示未結束，增加警示時間 (有上限)
          if nowShiningTime < shiningTime then
            nowShiningTime = nowShiningTime + shiningTime 
          end
        end
      -- 數字有變
      elseif not (textObject.nowRecordNumber == getNewNumber) then  
        -- 數字變色
        if getNewNumber == 0 then -- 沒數字時時變紅色 
          textObject.nowUsingColor = textObject.colors["empty"]
        else -- 有數字時時變原本色 
          textObject.nowUsingColor = textObject.colors["origin"]
        end
        textObject:setTextColor(textObject.nowUsingColor[1], textObject.nowUsingColor[2], textObject.nowUsingColor[3]) -- 設定顏色
        -- 數字跳出動畫 (位置設定在文字上面一點)
        local changingNumber = getNewNumber - textObject.nowRecordNumber
        local jumpingWord =  display.newText(inGroup, changingNumber, textObject.x, 0, UsageTable_Fronts["inventory_recordNumber"], frontSize) 
        local jumpDistance = -jumpingWord.height /2
        if changingNumber > 0 then
           jumpingWord.text = "+"..changingNumber
           jumpingWord.y = textObject.y - textObject.height/2
           jumpingWord:setTextColor(0, 0.85, 0) -- 綠色
           isJumpingUp = true
           systemRecord_hopAnimation(textObject, true, 100) -- 原文字往上移！ (跳動物件, 是否上(不是就是下), 回來的間隔)
        else
           jumpingWord.y = textObject.y + textObject.height /2
           jumpingWord:setTextColor(1, 0, 0) -- 紅色
           systemRecord_hopAnimation(textObject, false, 100) -- 原文字往下移！
           jumpDistance = jumpDistance * -1 -- 要變往下
        end
        systemRecord_jumpAnimationAndRemove(jumpingWord, jumpDistance, 700, 200) -- 一秒動畫, 0.2 秒開始 fade
        
        
        textObject.nowRecordNumber = getNewNumber -- 紀錄新數字
      end  
    end
    
    -- 紀錄 + 回傳此物件
    showingInventory.showUI = textObject
    return textObject
end




-- 創建物品欄被選時的 UI (width, height)
function UIobjects_InventoryChoosedFrame(width, height)
   -- 創建物件
   local toolUIObject = display.newRect(0, 0, width, height) -- 預設 x, y 為 0, 0 加入 Group 才會在中間
   ------ // 特性設定 // --------
   -- 顯示選擇框圖片
   imageHandler_ShowImageInRect(toolUIObject, imageHandler_LoadImage("inventory_backbroundChoosed")) 
   --預設不顯示
   toolUIObject.isVisible = false
   
   ----- // 溝通方式 // --------
   -- 把這個物件顯示在哪個 group 裡 (限定物品欄 UI)
   toolUIObject.showTo = function(toUI)
      toolUIObject.isVisible = true -- 顯示！
      toUI:insert(toolUIObject) -- 加入 toUI 群組
      toolUIObject:toBack() -- 變到下層
   end

   return toolUIObject
end


-- 創建物品欄 UI (x, y ,width, height, toolName, ChoosedFrame(選擇的框框))，支援 toolName: "hoe", "sickle", "wateringCan", "seedBag"
function UIobjects_InventoryTool(x, y, width, height, toolName, choosedFrame)
    -- 創建 group
    local toolUIGroup = display.newGroup()
    -- 創建物件，加入 Group (是以 group 為相對位置)
    local toolUIObject = display.newRect(toolUIGroup, 0, 0, width, height)
    toolUIObject:scale(0.9, 0.9) -- 稍微縮小一點才能放入物品藍
    ------ // 特性設定 // --------
    -- group 位置
    toolUIGroup.x = x
    toolUIGroup.y = y
    -- seedBag 與 wateringCan 要顯釋剩餘次數
    local gapToMargin = 2.9
    local wordLeftX = -(width/2 - gapToMargin)
    local wordUpY = -(height/2 - gapToMargin)
    local frontSize = 12
    local frontColor = {0, 0.3, 0.8} -- 0 - 1 顏色
    if toolName == "seedBag" then --紀錄現在使用的次數的 UI
      toolUIObject.remainTimeUI = UIobjects_InventoryNumberText(Inventory["seed"], toolUIGroup, wordLeftX, wordUpY, frontSize, frontColor)
    elseif toolName == "wateringCan" then
      toolUIObject.remainTimeUI = UIobjects_InventoryNumberText(Inventory["wateringTime"], toolUIGroup, wordLeftX, wordUpY, frontSize, frontColor)
    elseif string.find(toolName, "Pineapple") then
      toolUIObject.remainTimeUI = UIobjects_InventoryNumberText(Inventory[toolName], toolUIGroup, wordLeftX, wordUpY, frontSize, frontColor)
    end
    -- 顯示工具
    if string.find(toolName, "Pineapple") then
      imageHandler_ShowImageInRect(toolUIObject, imageHandler_LoadImage("icon_"..toolName)) -- 顯示鳳梨
    else
      imageHandler_ShowImageInRect(toolUIObject, imageHandler_LoadImage("inventory_"..toolName)) -- 顯示工具
    end 
    -- load 所有需要的背景框、 顯示沒按的圖
    toolUIObject.background = display.newRect(toolUIGroup, 0, 0, width, height)
    toolUIObject.backgroundPictures = {normal = imageHandler_LoadImage("inventory_backbroundNormal"),
                                        using = imageHandler_LoadImage("inventory_backbroundChoosed")
                                       }
    imageHandler_ShowImageInRect(toolUIObject.background, toolUIObject.backgroundPictures["normal"])  -- 顯示 正常情況
    toolUIObject.background:toBack()
    

    -- 邊框製作 (放大 & 縮小邊框)，已不用，需要有 group
--    toolUIObject.usedFrameEffect = {} -- 用 list 存
--    for i=0, 5 do
--      local nowFrame = display.newRect(0, 0, width, height)
--      imageHandler_ShowImageInRect(nowFrame, toolUIObject.showImages["normal"])
--       
--      if i == 5 then
--        nowFrame.fill.effect = "filter.woodCut" -- 去到剩白邊的 shader
--        nowFrame.fill.effect.intensity = 0.065 -- 愈小邊愈粗
--      else
--        local frameScale = 0.075 -- 1+frameScale 為邊框放大倍率f
--        nowFrame:scale(1 +frameScale, 1 +frameScale)
--        nowFrame.x = nowFrame.x+ (i+1)%2 * (-1 * i%2) -- 0, 2 有值  (0 正 2 負)
--        nowFrame.y = nowFrame.y+ i%2 * (-1 * i%2) -- 1, 3 有值 (1 正 3 負)
--        nowFrame.fill.effect = "filter.custom.frame" -- 在 systemRecord 內創建，塗城全顏色的 shader
--      end
--      
--      nowFrame:setFillColor(1, 0, 0)
--      UIObjectGroup:insert( nowFrame)
--      nowFrame:toBack() -- 把它移到這個 group 最底下 (不用 Group 會到背景底下)
--      table.insert(nowFrame, nowFrame)
--    end

    -- load 所需音效
    toolUIObject.soundEffects = {use = soundHandler_LoadSoundEffect("inventory_use"),
                                 unuse = soundHandler_LoadSoundEffect("inventory_unuse")}
    
    
    ----- // 溝通方式 // --------
    -- 放手偵測
    local function toolUIObject_detactBounceReleased(event)
      -- 放手 > 回復 + 已不用聽
      if event.phase == "ended" then
        local scaleToBack = 1/ systemRecord_Interaction["bounce_shrinkSize"]
        toolUIObject:scale(scaleToBack, scaleToBack)
        -- task finsihed, remove listener
        Runtime:removeEventListener("touch", toolUIObject_detactBounceReleased) 
      end
    end
    -- 監聽，按下去時縮小，放手時回復
    local onTouch = function(event)
      if event.phase == "began"  then
          local shrinkSize = systemRecord_Interaction["bounce_shrinkSize"]
          toolUIObject:scale(shrinkSize, shrinkSize) -- 大小改變
            
          -- 是正在使用工具，取消使用
          if not (Inventory_nowUsingStuff == nil) and Inventory_nowUsingStuff.name == toolName then
            Inventory_nowUsingStuff = nil  
            choosedFrame.isVisible = false -- 把框框取消顯示
            soundHandler_PlaySoundEffect(toolUIObject.soundEffects["unuse"]) -- 播放取消使用音效
          -- 依 toolName 使用對應工具 + 移動選擇框框到此
          else
            Inventory_nowUsingStuff = Inventory_tools[toolName]
            choosedFrame.showTo(toolUIGroup) -- 把顯示框移到這裡顯示
            toolUIObject.background:toBack() -- 把原本背景移到最後面
            soundHandler_PlaySoundEffect(toolUIObject.soundEffects["use"]) -- 播放按下去(被使用)音效          
          end
          
          Runtime:addEventListener("touch", toolUIObject_detactBounceReleased)  -- 監聽何時放手
      end
    end
    toolUIObject:addEventListener("touch", onTouch)
    
    -- 回傳已創建物件
    return toolUIGroup
end



-- 創建顯示物品 UI (x, y ,width, height, toolName)，支援 stuffName: "money", "normalPineapple", "silverPineapple", "goldPineapple", "iridumPineapple"
function UIobjects_InventoryStuffShow(x, y, width, height, stuffName)
   -- 創建 group
    local stuffUIGroup = display.newGroup()
    -- 創建物件，加入 Group (是以 group 為相對位置)
    local stuffUIObject = display.newRect(stuffUIGroup, 0, 0, width, height)
    ------ // 特性設定 // --------
    -- group 位置
    stuffUIGroup.x = x
    stuffUIGroup.y = y
    -- seedBag 與 wateringCan 要顯釋剩餘次數
    local frontSize = height * 3 / 8 -- 黃金比例大約是 3:5 喔
    local wordLeftX = width/4 -- 隨便抓舒服的地方而已
    local wordUpY = height/2 - frontSize -- 字的底貼齊圖底
    local frontColor = {0, 0.3, 0.8} -- 0 - 1 顏色
    -- 紀錄現在使用的次數的 UI  (因支援 stuffName 與 inventory 名字同步，所以可直接 load)
    stuffUIObject.remainTimeUI = UIobjects_InventoryNumberText(Inventory[stuffName], stuffUIGroup, wordLeftX, wordUpY, frontSize, frontColor)
    -- 顯示icon (因支援 stuffName 來自此，可以直接 load)
    imageHandler_ShowImageInRect(stuffUIObject, imageHandler_LoadImage("icon_"..stuffName)) -- 顯示 icon
    -- load 所有需要的背景框、 顯示沒按的圖
--    stuffUIObject.background = display.newRect(stuffUIGroup, 0, 0, width, height)
--    stuffUIObject.backgroundPictures = {normal = imageHandler_LoadImage("inventory_backbroundNormal"),
--                                        using = imageHandler_LoadImage("inventory_backbroundChoosed")
--                                       }
--    imageHandler_ShowImageInRect(toolUIObject.background, toolUIObject.backgroundPictures["normal"])  -- 顯示 正常情況
--    toolUIObject.background:toBack()
    
    -- load 所需音效
--    stuffUIObject.soundEffects = {use = soundHandler_LoadSoundEffect("inventory_use"),
--                                 unuse = soundHandler_LoadSoundEffect("inventory_unuse")}
    
    
    ----- // 溝通方式 // --------
    -- 回傳已創建物件
    return stuffUIGroup
end




 -- 創建開關商店的按鈕 (x, y ,width, height)
function UIobjects_shopButton(x, y, width, height, shopUI)
  -- 創建物件
  local buttonObject = display.newRect(x, y, width, height)
  
  ------ // 特性設定 // --------
  -- 位置
  buttonObject.x = x
  buttonObject.y = y 
  -- 是否按下去
  buttonObject.isPress = false
  -- load 所有需要的圖，並顯示沒按的圖
  buttonObject.showImages = {unpress = imageHandler_LoadImage("shopOpenButton_unpressed"), 
                             pressed = imageHandler_LoadImage("shopOpenButton_pressed")}
  imageHandler_ShowImageInRect(buttonObject, buttonObject.showImages["unpress"]) -- 顯示 unpress
  -- load 所需音效
  buttonObject.soundEffects = {pressed = soundHandler_LoadSoundEffect("shopOpenButton_pressed"),
                               released = soundHandler_LoadSoundEffect("shopOpenButton_released")}
  
  ----- // 溝通方式 // --------
  -- 這顆按鈕主要要做的事
  local function doingFunction()
    -- 商店沒開就打開，有開就關閉
    if not shopUI.isVisible then
      shopUI.toggleAnimation(100, true)
    else
      shopUI.toggleAnimation(50, false)
    end
  end
  
  -- 監聽，按到就換圖 + 執行決定的 function
  local onTouch = function(event)
    buttonFocusTouchHandle(event, buttonObject, doingFunction)
  end
  buttonObject:addEventListener("touch", onTouch)
    
  return buttonObject
end



-- 創建商店內的買賣區域(含按鈕) (x, y , icon 大小, icon 圖片名, 玩家的物品, 物品增加數量, 錢錢增加數量)
function UIobjects_shopTradingSection(x, y, iconSize, iconImageName, playerInventory, inventoryAddNumber, moneyAddNumber)
  -- 創建物件
  local tradingObjectGroup = display.newGroup()
  tradingObjectGroup.x = x
  tradingObjectGroup.y = y
  
  -- 創建 icon
  tradingObjectGroup.icon = display.newRect(tradingObjectGroup, 0, 0, iconSize, iconSize)
  imageHandler_ShowImageInRect(tradingObjectGroup.icon, imageHandler_LoadImage(iconImageName)) -- 顯示  icon
  
  -- 創建按鈕
  tradingObjectGroup.button = display.newRect(tradingObjectGroup, 0, 0, iconSize, iconSize/3) -- maybe 長寬比 1:3
  
  ------ // 特性設定 // --------
  -- 位置調整 (畫個圖就可了解！)
  local gapBetweenIconAndButton = 4
  local halfTotalHeight = (tradingObjectGroup.icon.height + tradingObjectGroup.button.height + gapBetweenIconAndButton) /2
  tradingObjectGroup.icon.y = tradingObjectGroup.icon.height/2 - halfTotalHeight
  tradingObjectGroup.button.y = (tradingObjectGroup.icon.height - halfTotalHeight) + gapBetweenIconAndButton + tradingObjectGroup.button.height/2
  -- 是否按下去
  tradingObjectGroup.button.isPress = false
  -- 按鈕 & icon 的文字 (文字放於正中心，x,y 座標都是指按鈕中心，不知為何文字會上飄(推測是字體關係)，下移 1 解決)
  tradingObjectGroup.button.showText = display.newText(tradingObjectGroup, "", tradingObjectGroup.button.x, tradingObjectGroup.button.y+1, UsageTable_Fronts["shop_salesNumber"], tradingObjectGroup.button.height*0.6)
  tradingObjectGroup.iconnText = display.newText(tradingObjectGroup, "", tradingObjectGroup.icon.x + tradingObjectGroup.icon.width*0.4, tradingObjectGroup.icon.y+ tradingObjectGroup.icon.height*0.4, UsageTable_Fronts["shop_salesNumber"], tradingObjectGroup.icon.height*0.35)
  tradingObjectGroup.iconnText:setTextColor(166/255, 123/255, 84/255) -- 隨便設的咖啡色 
  if moneyAddNumber >= 0 then
    tradingObjectGroup.button.showText:setTextColor(0, 0.7, 0) -- 綠色
    tradingObjectGroup.button.showText.text = "$ +"..moneyAddNumber
    tradingObjectGroup.iconnText.text = inventoryAddNumber
    tradingObjectGroup.isSelling = true -- 紀錄這是賣東西
  else
    tradingObjectGroup.button.showText:setTextColor(0.85, 0, 0) -- 紅色
    tradingObjectGroup.button.showText.text = "$ "..moneyAddNumber
    tradingObjectGroup.iconnText.text = "+"..inventoryAddNumber
    tradingObjectGroup.isSelling = false -- 紀錄這是買東西
  end
  
  -- load 所有需要的圖，並顯示沒按的圖
  tradingObjectGroup.button.showImages = {unpress = imageHandler_LoadImage("shopTradingButton_unpressed"), 
                                           pressed = imageHandler_LoadImage("shopTradingButton_pressed")}
  imageHandler_ShowImageInRect(tradingObjectGroup.button, tradingObjectGroup.button.showImages["unpress"]) -- 顯示 unpress
  -- load 所需音效
  tradingObjectGroup.button.soundEffects = {pressed = nil} -- 音效由 是否買成 負責，所以 button 音效設為 nil
  tradingObjectGroup.soundEffects = {pay = soundHandler_LoadSoundEffect("shop_pay"),
                                     earn = soundHandler_LoadSoundEffect("shop_earn"),
                                     payFail = soundHandler_LoadSoundEffect("shop_TooPoorToPay"),
                                     earnFail = soundHandler_LoadSoundEffect("shop_nothingToSell"),
                                     }
  
  ----- // 溝通方式 // --------
  -- 這顆按鈕主要要做的事
  local function doingFunction()
    if tradingObjectGroup.isSelling then
      if not Inventory[playerInventory].modifyNumber(inventoryAddNumber) then-- 還有東西賣
        Inventory["money"].modifyNumber(moneyAddNumber) -- 賺錢
        systemRecord_hopAnimation(tradingObjectGroup.iconnText, false, 100) -- 文字跳動一下
        soundHandler_PlaySoundEffect(tradingObjectGroup.soundEffects["earn"]) 
      else
        soundHandler_PlaySoundEffect(tradingObjectGroup.soundEffects["earnFail"]) 
      end
    else
      if not Inventory["money"].modifyNumber(moneyAddNumber) then -- 還有錢買
        Inventory[playerInventory].modifyNumber(inventoryAddNumber) -- 買物品
        systemRecord_hopAnimation(tradingObjectGroup.iconnText, true, 100) -- 文字跳動一下
        soundHandler_PlaySoundEffect(tradingObjectGroup.soundEffects["pay"]) 
         
        if playerInventory == "wateringTime" then -- 買澆水次數，要順便擴充最大值
          Inventory_tools["wateringCan"].timePerDay = Inventory_tools["wateringCan"].timePerDay + inventoryAddNumber
        end
      else
        soundHandler_PlaySoundEffect(tradingObjectGroup.soundEffects["payFail"]) 
      end
    end
    
    
  end
  
  -- 監聽，按到就換圖 + 執行決定的 function
  local onTouch = function(event)
    buttonFocusTouchHandle(event, tradingObjectGroup.button, doingFunction)
  end
  tradingObjectGroup.button:addEventListener("touch", onTouch)
    
  return tradingObjectGroup
end