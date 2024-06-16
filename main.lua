-----------------------------------------------------------------------------------------
-- 整合
-----------------------------------------------------------------------------------------

-- 引用 寫於其他地方的 function
require("scripts.UI") -- 引用  script/UI.lua
require("scripts.farm") -- 引用  script/farm.lua

-- 把 status bar 消除
display.setStatusBar( display.HiddenStatusBar )
-- 產生不同隨機數列 for 隨機事件
math.randomseed( os.time() )

-----------------------------------------------
-- 背景、場景創建
-----------------------------------------------

-- 背景
local dispObj_1 = display.newGroup()
dispObj_1.x = 235
dispObj_1.y = 130
display.newImageRect(dispObj_1, "images/background.png", 750, 425 )

-- 背景音樂 
soundHandler_PlayBGM("default")

-- 勝利條件相關
UI_SpawnVictoryJudgingUI()
winJudge_createJudgeObject(dispObj_1)

-- 正常農場所需
farm_SpawnDefault()
UI_SpawnDefault()

