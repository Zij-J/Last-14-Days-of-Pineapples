-----------------------------------------------------------------------------------------
-- 程式 & 圖片溝通檔案
-----------------------------------------------------------------------------------------

-- 如果要中文，請確保檔案是以「utf-8 格式」儲存，
-- 如果用 Lua Development Tool，可以複製 print(utf8.sub("♡ 你好，世界 ♡", 1))，儲存，就會轉成 utf-8 模式 + 不影響原本文字 

-- 需求（在程式碼內的名字）　 =　 用的圖片（圖片的路徑(從 image/ 開始)＋名字）
-- 如果缺圖，我預設都用 UI/devilButton/devilButton_unpressed.png 或 UI/devilButton/devilButton_pressed.png
UsageTable_Images = 
{
  devilButton_unpressed = "button_unpressed.png", -- 換天按鈕，放手
  devilButton_pressed = "button_pressed.png", -- 換天按鈕，按下
  
  shopOpenButton_unpressed = "shop_unpressed.png", -- 商店開關按鈕，放手
  shopOpenButton_pressed = "shop_pressed.png", -- 商店開關按鈕，按下
  
  shopTradingButton_unpressed = "trade_unpressed.png", -- 商店開關按鈕，放手
  shopTradingButton_pressed = "trade_pressed.png", -- 商店開關按鈕，按下 
  
  land_normal = "ground_ori.png",
  land_fertilized = "ground_seed.png",
  land_watered = "ground_wet.png",

  pineapple_stage1 = "pineapple_1.png",
  pineapple_stage2 = "pineapple_2.png",
  pineapple_stage3 = "pineapple_3.png",
  pineapple_stage4 = "pineapple_4.png",
  pineapple_stage5 = "pineapple_5.png",
  pineapple_stage6 = "pineapple_6.png",
  
  inventory_hoe = "T_hoe.png", 
  inventory_sickle = "T_sickle.png",
  inventory_wateringCan = "T_watering can.png",
  inventory_seedBag = "pineapple_seedbag.png",
  inventory_backbroundNormal = "T_bg (1).png",
  inventory_backbroundChoosed = "T_bg (2).png",
  
  icon_normalPineapple = "pineapple_icon.png",
  icon_silverPineapple = "pineapple_silver.png",
  icon_goldPineapple = "pineapple_gold.png",
  icon_iridumPineapple = "pineapple_iridium.png",
  icon_money = "money.png", -- 錢錢的 icon
  icon_leftTime = "kisspng-calendar.png", -- 剩餘時間  icon (缺)
  
  shop_background = "shop.png",
  
  winPage_win = "clear.png", -- 最後獲勝的畫面 (缺)
  winPage_lose = "youdied.png", -- 最後失敗的畫面
}
