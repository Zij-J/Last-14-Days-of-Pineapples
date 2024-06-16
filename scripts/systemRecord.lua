-----------------------------------------------------------------------------------------
-- �@�ǳq�Ϊ��t�γ]�w
-----------------------------------------------------------------------------------------

-- ���U�h�Y�p�j�p
systemRecord_Interaction = {
  bounce_shrinkSize = 0.9,
}

-- ����n���檺 function (���ǤJ�� nextDay function �� group �άO��L gameObject)
systemRecord_nextDayListeners = {}


-- �Ы� filter.custom.frame �� shader (�w����)
--local kernel =
--[[
--P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
--{
--    P_COLOR vec4 texColor = texture2D( CoronaSampler0, texCoord );
--    if(texColor[3] >= 0.1)
--    {
--      texColor[0] = 0.9;
--      texColor[1] = 0.0;
--      texColor[2] = 0.0;
--    }
--    else
--      texColor[3] = 0.0;
--    
--      
--    return CoronaColorScale(texColor);
--}
--]]
--graphics.defineEffect{category = "filter", group = "custom", name = "frame", fragment = kernel}


-- �ޥ� �g���L�a�誺 function

-----------------------------------------------
-- �i�H�q�Ω��L file �� function (�R�W�G�{���W_�వ����)
-----------------------------------------------
-- fade-in, fade-out �ʵe (�n���ܪ���B�ʵe�`�@�ɶ�(tick �����)�A�O in ? (���O�N�O Out))�A�|�^�Ǳ���A�i�H����ʵe + �վ��L�F��    
function systemRecord_fadeAnimation(fadingObject, totalFadeTime, isFadeIn)
  local animationController = display.newGroup()
  animationController.delayTime = 20
  animationController.fadeAlphaGap = 1 / (totalFadeTime / animationController.delayTime)
  
  -- �u���ʵe
  local function fadeIn()
    fadingObject.alpha = fadingObject.alpha + animationController.fadeAlphaGap
    if fadingObject.alpha < 1 then 
       animationController.playing = timer.performWithDelay(animationController.delayTime, fadeIn) -- ���_�ܲM���A���짹���л\
    else
      display.remove(animationController)  -- �����I
    end
  end
  
  local function fadeOut()
    fadingObject.alpha = fadingObject.alpha - animationController.fadeAlphaGap
    if fadingObject.alpha > 0 then 
      animationController.playing = timer.performWithDelay(animationController.delayTime, fadeOut) -- ���_�ܲM���A���짹���л\
    else
      display.remove(animationController)  -- �����I(�|�Ϫ���۰��ܦ^ nil)
    end
  end
  
  -- ����
  if isFadeIn then
    fadeIn()
  else
    fadeOut()
  end
  
  -- �j����ʵe�\��
  animationController.stop = function()
    if not (animationController.x == nil) then -- �C���v(�ާ@�ɶ��Y)�����P�ɳQ�I�s�o�ӡA�Φ��קK
      timer.cancel(animationController.playing) -- �o�˴N Ok !
      display.remove(animationController) -- �����ۤv
    end
  end
  
  return animationController
end


-- ���X + ���� +  fade Out ���ʵe�A���槹�������� (�n����, �`�@�Z��, �ʵe�`�@�ɶ�(tick �����), �h�[��}�l fade,)�A�|�^�Ǳ���A�i�H����ʵe + �վ��L�F��    
function systemRecord_jumpAnimationAndRemove(jumpingObject, totalGoDistance, totalJumpTime, fadeDelay)
  local animationController = display.newGroup()
  animationController.delayTime = 20 -- �C�����j
  animationController.totalCallTime = totalJumpTime / animationController.delayTime
  animationController.goDistancePerMove = totalGoDistance /animationController.totalCallTime-- �C�����ʶZ��
  animationController.fadePlaying = nil -- �p���O�_���h��ʵe
  
  
  -- �u���ʵe (���W or ���U)
  local nowCalledTime = 0
  local function move()
    nowCalledTime = nowCalledTime +1
    jumpingObject.y = jumpingObject.y + animationController.goDistancePerMove -- ���ʦb��
    if nowCalledTime < animationController.totalCallTime then 
       animationController.playing = timer.performWithDelay(animationController.delayTime, move)
    else -- �ʵe����
      if not (animationController.fadePlaying == nil) then
        animationController.fadePlaying.stop() -- �j����h��ʵe
      end
      animationController:removeSelf()  -- �����I
      jumpingObject:removeSelf() -- �������ʪ���
    end
  end
  
  -- ����ʵe
  local function startFading()
      animationController.fadePlaying = systemRecord_fadeAnimation(jumpingObject, totalJumpTime-fadeDelay, false) -- ���� fade out �ʵe
  end
  timer.performWithDelay(fadeDelay, startFading) -- �L�@�q�ɶ��A���� fade out �ʵe
  move()
  

  
  -- �j����ʵe�\��
  animationController.stop = function()
    animationController.fadePlaying.stop() -- ���� fade out �ʵe
    timer.cancel(animationController.playing) -- ����ʵe
    animationController:removeSelf()  -- �����I
    jumpingObject:removeSelf() -- �������ʪ���
  end
  
  return animationController
end


-- ��¸��ʤ@�U���ʵe (���ʪ���, �O�_�W(���O�N�O�U), �^�Ӫ����j)
function systemRecord_hopAnimation(hopingObject, isUp, backTime)
  local moveDirection = 1
  if isUp then
    moveDirection = -1
  end
  local originY = hopingObject.y
  
  local function back()
     hopingObject.y = originY
  end
  
 hopingObject.y =  hopingObject.y + hopingObject.height/10 * moveDirection
 timer.performWithDelay(backTime, back)
end



--�O���{�{���ʵe (���ʪ���, aplha ���W�[�q, �^�Ӫ����j)�A�w�]�O alpha �ܰ��A�A�ܦ^��˳�I (�|�ЫءB�^�Ǳ��)
function systemRecord_partyShineAnimation(shineObject, totalIncreseAlpha, backTime, isFadeBack)
  local animationController = display.newGroup()
  animationController.timePerCall = 20
  animationController.totalCallTime = backTime / animationController.timePerCall
  local lnOfIncrease = math.log((shineObject.alpha + totalIncreseAlpha) / shineObject.alpha) / animationController.totalCallTime
  animationController.perIncrease = math.exp(lnOfIncrease)
  -- �ʵe�e����
  animationController.originAlpha = shineObject.alpha
  
  -- �u�ʵe(�G)
  local nowCalledTime = 0
  local nowAlpha = shineObject.alpha -- ���Ǯɭ� alpha �|��s���ѡA�ҥH���B�~���� alpha 
  local function shineBright()
    if nowCalledTime < animationController.totalCallTime then
      nowCalledTime = nowCalledTime +1
      nowAlpha = nowAlpha * animationController.perIncrease 
      shineObject.alpha = nowAlpha

      animationController.playing = timer.performWithDelay(animationController.timePerCall, shineBright)
    else -- �����A���Y�A��
      nowCalledTime = 0 -- �p�ƳW�k 0
      
      if isFadeBack then -- �n�A�^�h�I��V����
        if animationController.perIncrease > 1 then -- �]�����ƼƦr�~�t�A�p�G���h���|�s�X�A�n�A�^�k��Ʀr
          nowAlpha = animationController.originAlpha + totalIncreseAlpha
        else
          nowAlpha = animationController.originAlpha
        end
        animationController.perIncrease = 1/ animationController.perIncrease -- ����V�I
      else -- �����͵w���ܦ^�h
        nowAlpha = animationController.originAlpha
      end
      
      animationController.playing = timer.performWithDelay(animationController.timePerCall, shineBright)
    end
  end
  shineBright() -- ����
  
  -- �j����ʵe�\��
  animationController.stop = function()
    shineObject.alpha = animationController.originAlpha -- �٭� alpha
    timer.cancel(animationController.playing) -- ����ʵe
    animationController:removeSelf()  -- �����I
  end
  
  -- �^�Ǫ���
  return animationController
end


-- �Y�񪺰ʵe 
function systemRecord_zoomInOrOut(showingObject, animtionTime, isShow)
  -- �S�ʳ]�w
  local timePerCall = 10  -- �C���I�s�ɶ�
  local totalCallTime = animtionTime / timePerCall
  local shrinkPerTime = math.exp( math.log(1/8)/totalCallTime )-- �H���ƧΦ��Y�p (�Y�p�� 1/8 �ɵ���)
  
  if isShow then -- ��j�N���Ϥ�V
    shrinkPerTime = 1/shrinkPerTime
    showingObject.isVisible = true -- �}����������
  end
  
  -- �u�ʵe
  local nowCalledTime = 0
  local function trueAnime()
    showingObject:scale(shrinkPerTime, shrinkPerTime)
    
    nowCalledTime = nowCalledTime + 1
    if nowCalledTime < totalCallTime then
      timer.performWithDelay(timePerCall, trueAnime)
    else
      if not isShow then -- �Y�p�����A�����Ҧ��F��
        showingObject.isVisible = false -- �w�]����
      end
    end
  end
  trueAnime() -- ����
end




-- �Ыش��Ѷ¥� (���T�w why �L�k get ���ù��j�p�A�`�� *2 �H�T�O�\�� all)
function systemRecord_createBlackCover(alpha)
  local blackCover = display.newRect(display.contentWidth/2, display.contentHeight/2, display.contentWidth*2,  display.contentHeight*2) -- �e���ù����¥�
  local blackPaint = { 0, 0, 0 }
  blackCover.fill = blackPaint 
  blackCover.alpha = alpha
  local function onTouch( event ) -- �� touch ���� if �¥��s�b(alpha != 0)
      return true -- ����¥��N�����
  end
  blackCover:addEventListener( "touch", onTouch )
  
  return blackCover
end
local blackCover = systemRecord_createBlackCover(0) -- ���]���z��

-- ����
function systemRecord_nextDay()
  -- �t�U����Ƴ]�w
  blackTime = 1000
  local blackTime_darkingPropotion = 0.25 -- �t�U���ɶ��e���ɶ����
  
  blackCover:toFront() -- �n��¥�����̳̫e��
  systemRecord_fadeAnimation(blackCover, blackTime * blackTime_darkingPropotion, true) --  fade in
  local function blackResume()
    if blackCover.alpha < 1 then -- ���ɭԥi�ण�|�� fade in ���A���u fade in ���A fade out
      timer.performWithDelay(1, blackResume)
    else
      -- �� listener ���C�� NextDay function ���s�@��
      local i = 1
      local Max = #systemRecord_nextDayListeners
      while i <= Max  do 
        if not (systemRecord_nextDayListeners[i].x == nil) then -- removeSelf �|�� table ���F���� nil �Ӥw�A�ҥH�n�H�K check �@�� table �~��T�w�O�_�M��
          systemRecord_nextDayListeners[i].nextDay()
          i = i +1
        else -- �M���Ū� Listener
          table.remove(systemRecord_nextDayListeners, i)
          Max = Max -1 
        end
      end 
      -- fade out
      systemRecord_fadeAnimation(blackCover, blackTime* (1-blackTime_darkingPropotion), false) -- fade out
    end
  end
  timer.performWithDelay(blackTime * blackTime_darkingPropotion, blackResume)-- �� fade in ���~�� fade out  
end
