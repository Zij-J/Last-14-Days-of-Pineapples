-----------------------------------------------------------------------------------------
-- �Ϥ����J & �ϥ�
-----------------------------------------------------------------------------------------

-- �ޥ� �g���L�a�誺 function
require("images.usageTable_Image") -- �ޥ� images/usageTable_Image.lua (�ޥθ��|�@������ main.lua)
local utf8 = require( "plugin.utf8" ) -- �n�ഫ�����

-----------------------------------------------
-- �i�H�q�Ω��L file �� function (�R�W�G�{���W_�వ����)
-----------------------------------------------

-- ��  UI ���Ϥ����J
function imageHandler_LoadImage(imageName)
    local imagePath = utf8.sub("images/"..UsageTable_Images[imageName], 1) -- �����౵���榡�A1 ��ܱq�Y�}�l����
    local loadedImage = { type="image", filename= imagePath}
    return loadedImage 
end

-- �b  Rect ��ܤw���J���Ϥ��A�л\���쥻��
function imageHandler_ShowImageInRect(rectObject, loadedImage)
    rectObject.fill =  loadedImage
end


-- �����Х� Image ����
function imageHandler_SpawnDirectlyImage(imageName)
    local imagePath = utf8.sub("images/"..UsageTable_Images[imageName], 1) -- �����౵���榡�A1 ��ܱq�Y�}�l����
    local loadedImage = display.newImage(imagePath)
    return loadedImage 
end

-- �u�B�z path ������
function imageHandler_GetImagePath(imageName)
  return utf8.sub("images/"..UsageTable_Images[imageName], 1)
end