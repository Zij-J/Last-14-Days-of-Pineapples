-----------------------------------------------------------------------------------------
-- 農地配置
-----------------------------------------------------------------------------------------

-- 引用 寫於其他地方的 function
require("scripts.objects.landObjects") -- 引用 scripts/objects/landObjects (引用路徑一切都看 main.lua)
require("scripts.objects.cropObjects")
require("scripts.winJudge") -- for 勝利條件判斷

-----------------------------------------------
-- 可以通用於其他 file 的 function (命名：程式名_能做的事)
-----------------------------------------------
function farm_SpawnDefault()
  local landSizeX = 60
  local landSizeY = 30
  local defaultFarmSize = 6
  local startX = 196
  local startY = 152
  
  -- 紀錄 row, column 數
  landObjects_Grounds["row"] = defaultFarmSize
  landObjects_Grounds["column"] = defaultFarmSize
  
  -- 生成農地 + 紀錄
  for i=0, defaultFarmSize-1 do
    local rowGrounds = {}
    
    for j=0, defaultFarmSize-1 do
      local nowX = startX - i*(landSizeX/2) -- 45度放法
      local nowY = startY + i*(landSizeY/2)
      local groundObject = landObjects_NormalGround(nowX +j*(landSizeX/2), nowY +j*(landSizeY/2), landSizeX, landSizeY)
      groundObject.indexInMatrix = {i+1, j+1}-- 加入 index (row, column)
      table.insert(rowGrounds, groundObject) -- 加入紀錄
    end
    
    table.insert(landObjects_Grounds["matrix"], rowGrounds) -- 陣列紀錄
  end
  
  winJudge_pineappleNumber["Max"] = defaultFarmSize * defaultFarmSize -- 總共需多少才能贏
end