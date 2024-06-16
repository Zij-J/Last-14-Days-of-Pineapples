-----------------------------------------------------------------------------------------
-- 使用者介面，使用
-----------------------------------------------------------------------------------------

-- 引用 寫於其他地方的 function
require("scripts.objects.UIobjects") -- 引用 script/object.lua
require("scripts.systemRecord")


-----------------------------------------------
-- 在此 file 才能用的 function (命名：程式名_能做的事)
-----------------------------------------------
-- 創建物品欄 (用於切換種子、鋤頭、澆水器)
local function UI_SpawnInventory(x, y)
  local toolSize = 45 -- 預設的高度，工具高度一致比較好
  local toolGap = 0 -- 每個工具之間的間隔

  -- 創建選擇框
  local biggerSize = 1.05 -- 稍微大一點比較好看
  local choosedFrame = UIobjects_InventoryChoosedFrame(toolSize *biggerSize, toolSize * biggerSize)
  -- 創立種子袋等物品，支援 toolName: "hoe", "sickle", "wateringCan", "seedBag"
  local seedBag = UIobjects_InventoryTool(x, y, toolSize, toolSize, "seedBag", choosedFrame)
  local wateringCan = UIobjects_InventoryTool(x + 1*(toolSize + toolGap), y, toolSize, toolSize, "wateringCan", choosedFrame)
  local sickle = UIobjects_InventoryTool(x + 2*(toolSize + toolGap), y, toolSize, toolSize, "sickle", choosedFrame)
  local hoe = UIobjects_InventoryTool(x + 3*(toolSize + toolGap), y, toolSize, toolSize, "hoe", choosedFrame)
  -- 創立不同鳳梨顯示
  local mirrorX =  display.contentWidth - x - 80 -- 對稱位置只有 display.contentWidth - x，再減只是為了不遮住農地
  local normalPineapple = UIobjects_InventoryTool(mirrorX, y, toolSize, toolSize, "normalPineapple", choosedFrame)
  local silverPineapple = UIobjects_InventoryTool(mirrorX - 1*(toolSize + toolGap), y, toolSize, toolSize, "silverPineapple", choosedFrame)
  local goldPineapple = UIobjects_InventoryTool(mirrorX - 2*(toolSize + toolGap), y, toolSize, toolSize, "goldPineapple", choosedFrame)
  local iridumPineapple = UIobjects_InventoryTool(mirrorX - 3*(toolSize + toolGap), y, toolSize, toolSize, "iridumPineapple", choosedFrame)
end


-- 創建顯示有甚麼物品的 UI (用於顯示錢、鳳梨剩多少)
local function UI_SpawnShowingInventory(x, y)
  local stuffSize = 30 -- 預設的高度，icon 高度一致比較好
  local stuffGap = 10 -- 每個 icon 之間的間隔

  -- 支援 stuffName: "money", "leftTime", "normalPineapple", "silverPineapple", "goldPineapple", "iridumPineapple"
  local showMoney = UIobjects_InventoryStuffShow(x, y, stuffSize, stuffSize, "money")
--  local showNormalPinapple = UIobjects_InventoryStuffShow(x + 1*(stuffSize + stuffGap), y, stuffSize, stuffSize, "normalPineapple")
--  local showSilverPinapple = UIobjects_InventoryStuffShow(x + 2*(stuffSize + stuffGap), y, stuffSize, stuffSize, "silverPineapple")
--  local showGoldPinapple = UIobjects_InventoryStuffShow(x + 3*(stuffSize + stuffGap), y, stuffSize, stuffSize, "goldPineapple")
--  local showIridumPinapple = UIobjects_InventoryStuffShow(x + 4*(stuffSize + stuffGap), y, stuffSize, stuffSize, "iridumPineapple")
end


-- 創建商店 UI
local function UI_SpawnShop(x, y, shopWidth, shopHeight)
  -- 創建黑布，避免底下物件被觸控 (先創建才會在商店下、其他東西上)
  local blackCover = systemRecord_createBlackCover(0.5) -- 稍微蓋住即可，不用全黑

  -- 創建 Group
  local shopGroup = display.newGroup()
  shopGroup.x = x
  shopGroup.y = y
  shopGroup.blackCover = blackCover -- 紀錄黑布 (要蓋住全部所以不能加入 Group )
  shopGroup.isVisible = false -- 預設關閉
  shopGroup.blackCover.isVisible = false -- 預設關閉
  -- 紀錄是否正在動畫
  shopGroup.isAnimating = false
  
  -- 創建背景
  local background = display.newRect(shopGroup, 0, 0, shopWidth, shopHeight)
  imageHandler_ShowImageInRect(background, imageHandler_LoadImage("shop_background"))
  
  -- 創建內容 (x, y , icon 大小, icon 圖片名, 玩家的物品, 物品增加數量, 錢錢增加數量) ps. 這裡搞 for 迴圈會很複雜(傳入參數都不同)，所以用最笨方式
  local iconSize =  shopHeight/4.5
  local buyAndSoldGap = shopWidth/15
  
  local buySeed = UIobjects_shopTradingSection(-shopWidth/4 - buyAndSoldGap/2, -iconSize, iconSize, "inventory_seedBag", "seed", 5, -3)
  shopGroup:insert(buySeed) -- 加入 group 才行
  local expendWater = UIobjects_shopTradingSection(-shopWidth/4 - buyAndSoldGap/2, iconSize/2, iconSize, "inventory_wateringCan", "wateringTime", 1, -2)
  shopGroup:insert(expendWater) -- 加入 group 才行
  local soldPineapple = UIobjects_shopTradingSection(buyAndSoldGap/2, -iconSize, iconSize, "icon_normalPineapple", "normalPineapple", -1, 2)
  shopGroup:insert(soldPineapple) -- 加入 group 才行
  local soldPineapple_silver = UIobjects_shopTradingSection(buyAndSoldGap/2, iconSize/2, iconSize, "icon_silverPineapple", "silverPineapple", -1, 3)
  shopGroup:insert(soldPineapple_silver) -- 加入 group 才行
  local soldPineapple_gold = UIobjects_shopTradingSection(shopWidth/4 + buyAndSoldGap/2, -iconSize, iconSize, "icon_goldPineapple", "goldPineapple", -1, 12)
  shopGroup:insert(soldPineapple_gold) -- 加入 group 才行
  local soldPineapple_iridum = UIobjects_shopTradingSection(shopWidth/4 + buyAndSoldGap/2, iconSize/2, iconSize, "icon_iridumPineapple", "iridumPineapple", -1, 30)
  shopGroup:insert(soldPineapple_iridum) -- 加入 group 才行
  
  -- // 動畫 // --
  -- 顯示/隱藏 動畫 (全 animation 所需時間, 是否 show，不是就是 hide) (因為要連黑布，所以分開寫 (其實是這個先開發了，才複製到 systemReocrd) )
  shopGroup.toggleAnimation = function(animtionTime, isShow)
    -- 正在動畫，不給改！
    if shopGroup.isAnimating then
      return
    end
  
    -- 特性設定
    local shrinkPerTime = 0.85 -- 以指數形式縮小
    local totalCallTime = math.ceil(math.log(1/8) / math.log(shrinkPerTime)) -- 總呼叫次數(縮小到 1/8 時結束，用換底公式 + 指數不等式算出)
    local timePerCall = animtionTime/totalCallTime  -- 每次呼叫時間
    if isShow then -- 放大就往反方向
      shrinkPerTime = 1/shrinkPerTime
      shopGroup.isVisible = true -- 開啟關閉的圖
      shopGroup.blackCover.isVisible = true -- 開啟關閉的圖
    end
    
    -- 真動畫
    local nowCalledTime = 0
    local function trueAnime()
      shopGroup:scale(shrinkPerTime, shrinkPerTime)
      
      nowCalledTime = nowCalledTime + 1
      if nowCalledTime < totalCallTime then
        timer.performWithDelay(timePerCall, trueAnime)
      else
        shopGroup.isAnimating = false -- 結束動畫
        if not isShow then -- 縮小結束，關閉所有東西
          shopGroup.isVisible = false -- 預設關閉
          shopGroup.blackCover.isVisible = false -- 預設關閉
        end
      end
    end
    trueAnime() -- 播放
    shopGroup.isAnimating = true
  end
  
  -- 先縮小！
  shopGroup.toggleAnimation(10, false)
  
  return shopGroup
end

-----------------------------------------------
-- 可以通用於其他 file 的 function (命名：程式名_能做的事)
-----------------------------------------------


-- 創建最初的所有 UI
function UI_SpawnDefault()
  -- 換天按鈕：文字, x, y ,width, height, 彈起時間(ticks),  按下去會執行的 function (換天)
  tomorrowButton = UIobjects_DevilButton("", 535, 300, 90, 30, 1100, systemRecord_nextDay) -- 暗下動畫因重複呼叫 delay + 呼叫大量 function，會比設定的暗下時間還長，要加長彈起時間
  
  inventory = UI_SpawnInventory(320, 300)
  showingInventory = UI_SpawnShowingInventory(-70, 20) -- 不太清楚為何，但 0 不是最左上，可以再左
  
  shop = UI_SpawnShop(display.contentWidth/2, display.contentHeight/2, 320, 225)
  shopOpenButton = UIobjects_shopButton(560, 25, 30, 30, shop)
end

-- 創建勝利條件所需 UI
function UI_SpawnVictoryJudgingUI()
  local stuffSize = 30
  countDown = UIobjects_InventoryStuffShow(-30, 20, stuffSize, stuffSize, "leftTime")
end