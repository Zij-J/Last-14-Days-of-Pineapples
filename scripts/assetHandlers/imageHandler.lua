-----------------------------------------------------------------------------------------
-- 圖片載入 & 使用
-----------------------------------------------------------------------------------------

-- 引用 寫於其他地方的 function
require("images.usageTable_Image") -- 引用 images/usageTable_Image.lua (引用路徑一切都看 main.lua)
local utf8 = require( "plugin.utf8" ) -- 要轉換中文用

-----------------------------------------------
-- 可以通用於其他 file 的 function (命名：程式名_能做的事)
-----------------------------------------------

-- 把  UI 的圖片載入
function imageHandler_LoadImage(imageName)
    local imagePath = utf8.sub("images/"..UsageTable_Images[imageName], 1) -- 換成能接受格式，1 表示從頭開始全部
    local loadedImage = { type="image", filename= imagePath}
    return loadedImage 
end

-- 在  Rect 顯示已載入的圖片，覆蓋掉原本的
function imageHandler_ShowImageInRect(rectObject, loadedImage)
    rectObject.fill =  loadedImage
end


-- 直接創立 Image 物件
function imageHandler_SpawnDirectlyImage(imageName)
    local imagePath = utf8.sub("images/"..UsageTable_Images[imageName], 1) -- 換成能接受格式，1 表示從頭開始全部
    local loadedImage = display.newImage(imagePath)
    return loadedImage 
end

-- 只處理 path 的部分
function imageHandler_GetImagePath(imageName)
  return utf8.sub("images/"..UsageTable_Images[imageName], 1)
end