-----------------------------------------------------------------------------------------
-- 紀錄玩家物品各種狀態
-----------------------------------------------------------------------------------------

-- 能互動的物件寫於下面，請往下找

-- 引用 寫於其他地方的 function
require("scripts.systemRecord") -- for 換天

-----------------------------------------------
-- 此 file 才能用的 function (命名：程式名_能做的事)
-----------------------------------------------
-- 創建物品 (有初始數量即可)
local function Inventory_initInventory(startNumber)
    -- 創建新的空物件
    local inventoryObject = display.newGroup()
    
    ------ // 特性設定 // --------
    -- 初始數量
    inventoryObject.number = startNumber
    -- 顯示的 UI (要記錄！)
    inventoryObject.showUI = nil
    
    ----- // 溝通方式 // -------
    -- 增加 / 減少物品數量 (修改數量)，會回傳是否小於 0
    inventoryObject.modifyNumber = function(changeNumber)
      -- 數量沒動就什麼都不做
      if changeNumber == 0 then 
        return false
      end
    
      local isLessZero = false
      -- 改數量
      local originNumber = inventoryObject.number
      inventoryObject.number = inventoryObject.number + changeNumber
      -- 是否 < 0 判斷 (不能 < 0!)
      if inventoryObject.number < 0 then
        inventoryObject.number = originNumber -- 做事失敗，回歸原狀
        isLessZero = true
      end
      -- 改顯示
      if not (inventoryObject.showUI == nil) then
        inventoryObject.showUI.updateText(inventoryObject.number)
      end
      -- 回傳
      return isLessZero
    end
    
    -- 回傳已創造物件
    return inventoryObject 
end


-- 創建種子袋 (需沿用 toolName)
local function Inventory_SeedBag(toolName)
    -- 創建新的空物件
    local seedBagObject = display.newGroup()
    
    ------ // 特性設定 // --------
    -- 名字沿用 toolName
    seedBagObject.name = toolName
    -- load 所需音效
    seedBagObject.soundEffects = {empty = soundHandler_LoadSoundEffect("seedBag_empty"),}
    
    ----- // 溝通方式 // --------
    
--    -- 監聽，要用 點的 才動作
--    local onTap = function(event)
--      -- 在用，關掉！
--      if toolUIObject.isUsing then
--        imageHandler_ShowImageInRect(buttonObject, buttonObject.showImages["pressed"]) -- 換成按下去的圖  
--        soundHandler_PlaySoundEffect(buttonObject.soundEffects["pressed"]) -- 播放按下去音效
--        buttonObject.isPress = true
--        
--        timer.performWithDelay( delayTicks, autoRelease ) -- 時間到放開
--      -- 在用其他工具
--      end
--    end
--    toolUIObject:addEventListener("tap", onTap)
--    
    -- 回傳已創建物件
    return seedBagObject
end


-- 創建鋤頭 (需沿用 toolName)
local function Inventory_Hoe(toolName)
    -- 創建新的空物件
    local hoeObject = display.newGroup()
    
    ------ // 特性設定 // --------
    -- 名字沿用 toolName
    hoeObject.name = toolName
     -- load 所需音效
    hoeObject.soundEffects = {removeCrop = soundHandler_LoadSoundEffect("hoe_removeCrop"),}

    ----- // 溝通方式 // --------
    
    -- 回傳已創建物件
    return hoeObject
end


-- 創建澆水器 (需沿用 toolName)
local function Inventory_WateringCan(toolName)
    -- 創建新的空物件
    local canObject = display.newGroup()
    
    ------ // 特性設定 // --------
    -- 名字沿用 toolName
    canObject.name = toolName
    -- 預設一天能澆水的數量 (先設定能保存)
    canObject.timePerDay = 6
     -- load 所需音效
    canObject.soundEffects = {empty = soundHandler_LoadSoundEffect("wateringCan_empty"),
                              filling = soundHandler_LoadSoundEffect("wateringCan_filling"),
                              }
    

    ----- // 溝通方式 // --------
    -- 換天要做的事
    canObject.nextDay = function()
      local addNumber = canObject.timePerDay - Inventory["wateringTime"].number
      if addNumber > 0 then -- 要不足最大值才加到最大值
        Inventory["wateringTime"].modifyNumber(addNumber) -- 把澆水次數加上這次能澆水的次數
        soundHandler_PlaySoundEffect(canObject.soundEffects["filling"]) -- 水增加的音效
      end
    end
    table.insert(systemRecord_nextDayListeners, canObject) -- 加入換天時會呼叫的 function 內
    
    -- 回傳已創建物件
    return canObject
end


-- 創建鐮刀 (需沿用 toolName)
local function Inventory_Sickle(toolName)
    -- 創建新的空物件
    local sickleObject = display.newGroup()
    
    ------ // 特性設定 // --------
    -- 名字沿用 toolName
    sickleObject.name = toolName
     -- load 所需音效
    sickleObject.soundEffects = {harvest = soundHandler_LoadSoundEffect("sickle_harvest"),}

    ----- // 溝通方式 // --------
    
    -- 回傳已創建物件
    return sickleObject
end


-- 創建鳳梨們 (需沿用 toolName)
local function Inventory_Pineapples(toolName)
    -- 創建新的空物件
    local pineappleObject = display.newGroup()
    
    ------ // 特性設定 // --------
    -- 名字沿用 toolName
    pineappleObject.name = toolName
     -- load 所需音效
    pineappleObject.soundEffects = {empty = soundHandler_LoadSoundEffect("pineapple_emptyTofertilize"),}

    ----- // 溝通方式 // --------
    
    -- 回傳已創建物件
    return pineappleObject
end

-----------------------------------------------
-- 可互動物件、紀錄
-----------------------------------------------
-- 現在手持物品紀錄，直接紀錄物件，nil 就是沒拿 ("nothing": 沒拿 、 "hoe": 鋤頭 、 "sickle": 鐮刀、"wateringCan": 澆花器 、"seedbag": 種子)
Inventory_nowUsingStuff = nil
-- 可以使用的物品，支援 toolName: "hoe", "sickle", "wateringCan", "seedBag" (用物件方式，之後新增功能比較好擴充)
Inventory_tools =
{
  hoe = Inventory_Hoe("hoe"),
  sickle = Inventory_Sickle("sickle"),
  wateringCan = Inventory_WateringCan("wateringCan"), 
  seedBag = Inventory_SeedBag("seedBag"),
  normalPineapple = Inventory_Pineapples("normalPineapple"),
  silverPineapple = Inventory_Pineapples("silverPineapple"),
  goldPineapple = Inventory_Pineapples("goldPineapple"),
  iridumPineapple = Inventory_Pineapples("iridumPineapple"),
}

-- 物品紀錄
Inventory = 
{
  money = Inventory_initInventory(0),
  seed = Inventory_initInventory(10),
  normalPineapple = Inventory_initInventory(2),
  silverPineapple = Inventory_initInventory(2),
  goldPineapple = Inventory_initInventory(0),
  iridumPineapple = Inventory_initInventory(0),
  wateringTime = Inventory_initInventory(Inventory_tools["wateringCan"].timePerDay),
  
  leftTime = Inventory_initInventory(14),
}


  


-----------------------------------------------
-- 可以通用於其他 file 的 function (命名：程式名_能做的事)
-----------------------------------------------
-- 增加
