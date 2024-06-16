-----------------------------------------------------------------------------------------
-- 程式 & 音樂、音效溝通檔案
------------------------------------------------------------------------------------------

-- 如果要中文，請確保檔案是以「utf-8 格式」儲存，
-- 如果用 Lua Development Tool，可以複製 print(utf8.sub("♡ 你好，世界 ♡", 1))，儲存，就會轉成 utf-8 模式 + 不影響原本文字 


-- 需求（在程式碼內的名字）　 =　 用的音效（圖片的路徑(從 sounds/soundEffects/ 開始)＋名字）
-- 如果沒找到，我預設都用 ShitAgain/AweShit.mp4 或 ShitAgain/HereWeGoAgain.mp4
UsageTable_SoundEffects = 
{
  devilButton_released = "ShitAgain/HereWeGoAgain.mp4", -- 換日按紐，放手 (看要不要)
  devilButton_pressed = "動作/換天按鈕.mp3", -- 換日按鈕，按下去

  shopOpenButton_released = "ShitAgain/AweShit.mp4", -- 商店開關按鈕，放手 (看要不要)
  shopOpenButton_pressed = "動作/商店開關.mp3", -- 商店開關按鈕，按下

--  shopTradingButton_released = "ShitAgain/AweShit.mp4", -- 商店內部的交易按鈕，放手 (看要不要)
--  shopTradingButton_pressed = "動作/商店花錢.mp3", -- 商店內部的交易按鈕，按下  => 因為會使商店音效過於混亂而取消

  ground_nothingClicked = "動作/挖地 新.mp3",  -- 按地板，沒做事
  ground_watered = "動作/澆水.mp3", -- 澆水音效
  ground_seeded = "動作/撒.mp3", -- 種下去的音效
  ground_fertilized = "動作/game-bonus-144751_Audio Trimmer.mp3",  -- 施肥音效
  
  inventory_use = "動作/選擇東西.mp3",  -- 道具欄 (如種子袋) 被選擇時的音效
  inventory_unuse = "動作/取消選擇.mp3", -- 取消選擇道具時的音效
  
  seedBag_empty = "動作/袋子空了.mp3", -- 種種子，發現種子帶空了的音效 
  wateringCan_empty = "動作/澆水器空.mp3", -- 澆水，發見澆水器空了
  pineapple_emptyTofertilize = "動作/沒鳳梨可施肥.mp3", -- 沒有鳳梨可以施肥
  wateringCan_filling = "動作/澆花器裝水.mp3", -- 澆水器補充水的音效
  hoe_removeCrop = "動作/移除作物.mp3", -- 移除作物音效
  sickle_harvest = "動作/收成.mp3", -- 收成音效
  
  shop_pay = "動作/商店交易.mp3", -- 商店花錢
  shop_earn = "動作/賺錢.mp3", -- 商店賺錢 
  shop_TooPoorToPay = "動作/商店沒錢花.mp3", -- 商店沒錢花
  shop_nothingToSell = "動作/商店沒東西賣.mp3", -- 商店沒東西賣 
  
  winJudge_AdayGone = "動作/日歷翻頁.mp3", 
  winPage_lose = "elden-ring-you-died---emotional-damage.mp3", -- 最後失敗的音效
} 



UsageTable_BGMs =
{
  default = "mo-er-zhuang-yuan-kai.mp3",
  win_prelude = "VictoryPrelude.wav",
  win_mainLoop = "VictoryFanfare.wav", -- loop 不可用 mp3，會有中斷感
--  tension_prelude = "chase.wav",
  tension_mainLoop = "chase.wav",
} 
