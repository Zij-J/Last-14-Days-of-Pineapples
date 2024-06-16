-----------------------------------------------------------------------------------------
-- �ӧQ�������
-----------------------------------------------------------------------------------------

-- �ޥ� �g���L�a�誺 function
require("scripts.assetHandlers.soundHandler") -- �ޥ� script/asestHandler/soundHandler.lua (�ޥθ��|�@������ main.lua)
require("scripts.inventory") -- for �Ѿl�Ѽ� get
require("scripts.systemRecord") -- for ����

-----------------------------------------------
-- �� file �~��Ϊ� function (�R�W�G�{���W_�వ����)
-----------------------------------------------



-- �����b�A���W����`�� for �ӧQ�P�_
winJudge_pineappleNumber =
{
  now = 0,
  Max = 0,
}

-----------------------------------------------
-- �i�H�q�Ω��L file �� function (�R�W�G�{���W_�వ����)
-----------------------------------------------
-- ��i�ɨ�
function winJudge_tension(backgroundGroup)
  local tensionRecords = display.newGroup()
  tensionRecords.textShineAnimation = nil
  tensionRecords.MaskAnimation = nil

  -- ��r�|���� + ���_�{�{
  Inventory["leftTime"].showUI.colors["origin"] = {216/255, 63/255, 49/255}
  local function textShinging()
    Inventory["leftTime"].showUI.shiningAnimation()
    tensionRecords.textShineAnimation = timer.performWithDelay(1500, textShinging) -- ���}�Y���ּ������ʵe
  end
  textShinging()
  
  -- �I���Ϥ� tint
  backgroundGroup.tintMask = display.newRect(display.contentWidth/2, display.contentHeight/2, display.contentWidth*2,  display.contentHeight*2) -- �e���ù����¥�
  backgroundGroup.tintMask.x = 0
  backgroundGroup.tintMask.y = 0
  backgroundGroup:insert(backgroundGroup.tintMask)
  backgroundGroup.tintMask.fill = {245/255, 63/255, 31/255} 
  backgroundGroup.tintMask.alpha = 0.15 -- �ܤֻݭn�@�I alpha �~�ത�ʵe
  tensionRecords.MaskAnimation = systemRecord_partyShineAnimation(backgroundGroup.tintMask, 0.15, 1000, true) -- �ʵe
  
  -- �� BGM
  soundHandler_PlayBGM("tension_mainLoop") 
  
  tensionRecords.stop = function(isStopTextShine)
    if not (tensionRecords.textShineAnimation == nil) and isStopTextShine then
      timer.cancel(tensionRecords.textShineAnimation)
    end
    if not (tensionRecords.MaskAnimation == nil) then
      tensionRecords.MaskAnimation.stop()
    end
  end
  
  return tensionRecords
end


-- �P�_���Ѫ��� + ���ѵ��G���
function winJudge_createJudgeObject(backgroundGroup)
  local judgeObject = display.newGroup()
  judgeObject.soundEffects = {AdayDone = soundHandler_LoadSoundEffect("winJudge_AdayGone"),}
  judgeObject.tensionRecord = nil
  
  
  -- ���\/�����˴� at ����
  judgeObject.nextDay = function()
    -- �o�{�� 6 �� (���U�� 1 �|�� 5 ��)�A�}�Һ�i�Ҧ�
    if Inventory["leftTime"].number == 5 then
      judgeObject.tensionRecord = winJudge_tension(backgroundGroup)
    end
  
    -- �֤@��
    Inventory["leftTime"].modifyNumber(-1)     
    soundHandler_PlaySoundEffect(judgeObject.soundEffects["AdayDone"]) -- ½�������
    
    -- ���\�P�_ + ���G��
    if winJudge_pineappleNumber["now"] == winJudge_pineappleNumber["Max"] then
      -- �ζ����
      local cover = systemRecord_createBlackCover(0.1)
      cover.fill = {247/255, 173/255, 64/255} 
      -- ���\�Ϥ� 
      local picture = imageHandler_SpawnDirectlyImage("winPage_win")
      picture.x = display.contentWidth/2
      picture.y = display.contentHeight/2
      local imageScale = (display.contentWidth/2) / picture.width
      picture.width = picture.width * imageScale 
      picture.height = picture.height * imageScale 
      picture.isVisible = false
      systemRecord_zoomInOrOut(picture, 10, false) -- ���Y�p
      
      -- ���\�ʵe(��)
      local pictureJumpWidth = picture.width/5 -- �ʵe�e���]�w
      local pictureJumpHeight = picture.height/10 -- �ʵe�e���]�w
      picture.x = picture.x - pictureJumpWidth/2
      local function jumpingPictureAnimation()
        local sideToSideTime = 60000/128 *0.66
        local deltaTime = 10
        local totalUnitsOfTime = sideToSideTime / deltaTime
        -- ��m�Ѽ�
        local acclerate = 2*pictureJumpHeight / ((totalUnitsOfTime/2)*(totalUnitsOfTime/2)) -- 0.5at^2 = �W�߶Z���A�i get �n���[�t��
        local upSpeed = -acclerate *(totalUnitsOfTime/2)
        local sideSpeed = pictureJumpWidth/totalUnitsOfTime -- �Z�� / �t�v = �ɶ�
        -- size �Ѽ�
        local shrinkSize = picture.height/10
        local shrinkPerTime = shrinkSize/totalUnitsOfTime
        
        -- �u�ʵe
        local nowUpSpeed = upSpeed
        local originY = picture.y
        local originWidth = picture.width
        local originHeight = picture.height
        local function updateTime()
          -- ��m����
          nowUpSpeed = nowUpSpeed + acclerate
          picture.x = picture.x + sideSpeed
          picture.y = picture.y + nowUpSpeed
          -- size �Y��
          if nowUpSpeed < 0 then -- �b�W��
            picture.width = picture.width - shrinkPerTime
            picture.height = picture.height + shrinkPerTime
          elseif nowUpSpeed > 0 then -- �b�U�Y
            picture.width = picture.width + shrinkPerTime
            picture.height = picture.height - shrinkPerTime
          end
          -- ��V�վ�
          if nowUpSpeed >= -upSpeed then -- �w�g�ӧC(�����F)�A���Ϥ�V��
            sideSpeed = sideSpeed * (-1)
            nowUpSpeed = upSpeed
            picture.y = originY -- �]���~�t�A�ҥH�n�ե�
            picture.width = originWidth
            picture.height = originHeight
          end

          
          timer.performWithDelay(deltaTime, updateTime)
        end
        updateTime()
      end
      -- ���\�ʵe�}�l
      local function winAnimation_startLoop()
        picture.backAnimation.stop() -- ����즳��
        picture.backAnimation = systemRecord_partyShineAnimation(cover, 0.3, 60000/128, true) -- 60000: �@�����A128: bmp�A�ҥH�|�o�X�|�����ųt��
        
        -- ��ܹ�
        systemRecord_zoomInOrOut(picture, 300, true) -- ��j�^��
        timer.performWithDelay(500, jumpingPictureAnimation)
      end
      local function winAnimation_first()
        if not (judgeObject.tensionRecord == nil) then -- ���� tesion �ʵe
          judgeObject.tensionRecord.stop(true)
        end
        picture.backAnimation = systemRecord_partyShineAnimation(cover, 0.35, 320, false) -- 60000: �@�����A128: bmp�A�ҥH�|�o�X�|�����ųt��
        timer.performWithDelay(3400, winAnimation_startLoop) -- ���}�Y���ּ������ʵe
      end
      winAnimation_first() -- �����Ĥ@�q
      -- ���\����
      soundHandler_PlayBGMandPrelude("win_prelude", "win_mainLoop")
    
    -- ���ѧP�_
    elseif Inventory["leftTime"].number == 0 then
      if not (judgeObject.tensionRecord == nil) then -- ���� tesion �ʵe
        judgeObject.tensionRecord.stop(false)
      end
    
      -- �ά����
      local cover = systemRecord_createBlackCover(0.65)
      cover.fill = {161/255, 31/255, 45/255} 
      -- ���ѹϤ� 
      local picture = imageHandler_SpawnDirectlyImage("winPage_lose")
      picture.x = display.contentWidth/2
      picture.y = display.contentHeight/2
      local imageScale = (display.contentWidth + 400) / picture.width -- +400 �O�⥼�ɻ�����ɸɻ�
      picture.width = picture.width * imageScale 
      picture.height = picture.height * imageScale 
      picture.alpha = 0
      -- ���Ѱʵe
      systemRecord_fadeAnimation(picture, 1000, true)
      -- ���ѭ���
      soundHandler_StopBGM()  -- �n���� BGM
      soundHandler_PlaySoundEffect(soundHandler_LoadSoundEffect("winPage_lose")) -- ���񦬦�����
    end
    
  end
  table.insert(systemRecord_nextDayListeners, judgeObject) -- �o�ӭn�b���j��I�s (�o�˴N�i���̫᭱)
  
  return judgeObject
end