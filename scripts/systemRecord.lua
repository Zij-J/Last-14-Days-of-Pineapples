-----------------------------------------------------------------------------------------
-- 一些通用的系統設定
-----------------------------------------------------------------------------------------

-- 按下去縮小大小
systemRecord_Interaction = {
  bounce_shrinkSize = 0.9,
}

-- 換日要執行的 function (限傳入有 nextDay function 的 group 或是其他 gameObject)
systemRecord_nextDayListeners = {}


-- 創建 filter.custom.frame 的 shader (已不用)
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


-- 引用 寫於其他地方的 function

-----------------------------------------------
-- 可以通用於其他 file 的 function (命名：程式名_能做的事)
-----------------------------------------------
-- fade-in, fade-out 動畫 (要改變物件、動畫總共時間(tick 為單位)，是 in ? (不是就是 Out))，會回傳控制器，可以中止動畫 + 調整其他東西    
function systemRecord_fadeAnimation(fadingObject, totalFadeTime, isFadeIn)
  local animationController = display.newGroup()
  animationController.delayTime = 20
  animationController.fadeAlphaGap = 1 / (totalFadeTime / animationController.delayTime)
  
  -- 真正動畫
  local function fadeIn()
    fadingObject.alpha = fadingObject.alpha + animationController.fadeAlphaGap
    if fadingObject.alpha < 1 then 
       animationController.playing = timer.performWithDelay(animationController.delayTime, fadeIn) -- 不斷變清楚，直到完全覆蓋
    else
      display.remove(animationController)  -- 移除！
    end
  end
  
  local function fadeOut()
    fadingObject.alpha = fadingObject.alpha - animationController.fadeAlphaGap
    if fadingObject.alpha > 0 then 
      animationController.playing = timer.performWithDelay(animationController.delayTime, fadeOut) -- 不斷變清楚，直到完全覆蓋
    else
      display.remove(animationController)  -- 移除！(會使物件自動變回 nil)
    end
  end
  
  -- 播放
  if isFadeIn then
    fadeIn()
  else
    fadeOut()
  end
  
  -- 強制結束動畫功能
  animationController.stop = function()
    if not (animationController.x == nil) then -- 低機率(操作時間嚴)移除同時被呼叫這個，用此避免
      timer.cancel(animationController.playing) -- 這樣就 Ok !
      display.remove(animationController) -- 移除自己
    end
  end
  
  return animationController
end


-- 跳出 + 移動 +  fade Out 的動畫，執行完移除物件 (要物件, 總共距離, 動畫總共時間(tick 為單位), 多久後開始 fade,)，會回傳控制器，可以中止動畫 + 調整其他東西    
function systemRecord_jumpAnimationAndRemove(jumpingObject, totalGoDistance, totalJumpTime, fadeDelay)
  local animationController = display.newGroup()
  animationController.delayTime = 20 -- 每次間隔
  animationController.totalCallTime = totalJumpTime / animationController.delayTime
  animationController.goDistancePerMove = totalGoDistance /animationController.totalCallTime-- 每次移動距離
  animationController.fadePlaying = nil -- 計錄是否有退色動畫
  
  
  -- 真正動畫 (往上 or 往下)
  local nowCalledTime = 0
  local function move()
    nowCalledTime = nowCalledTime +1
    jumpingObject.y = jumpingObject.y + animationController.goDistancePerMove -- 移動在此
    if nowCalledTime < animationController.totalCallTime then 
       animationController.playing = timer.performWithDelay(animationController.delayTime, move)
    else -- 動畫結束
      if not (animationController.fadePlaying == nil) then
        animationController.fadePlaying.stop() -- 強制結束退色動畫
      end
      animationController:removeSelf()  -- 移除！
      jumpingObject:removeSelf() -- 移除移動物件
    end
  end
  
  -- 播放動畫
  local function startFading()
      animationController.fadePlaying = systemRecord_fadeAnimation(jumpingObject, totalJumpTime-fadeDelay, false) -- 撥放 fade out 動畫
  end
  timer.performWithDelay(fadeDelay, startFading) -- 過一段時間再撥放 fade out 動畫
  move()
  

  
  -- 強制結束動畫功能
  animationController.stop = function()
    animationController.fadePlaying.stop() -- 移除 fade out 動畫
    timer.cancel(animationController.playing) -- 停止動畫
    animationController:removeSelf()  -- 移除！
    jumpingObject:removeSelf() -- 移除移動物件
  end
  
  return animationController
end


-- 單純跳動一下的動畫 (跳動物件, 是否上(不是就是下), 回來的間隔)
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



--燈光閃爍的動畫 (跳動物件, aplha 的增加量, 回來的間隔)，預設是 alpha 變高，再變回原樣喔！ (會創建、回傳控制器)
function systemRecord_partyShineAnimation(shineObject, totalIncreseAlpha, backTime, isFadeBack)
  local animationController = display.newGroup()
  animationController.timePerCall = 20
  animationController.totalCallTime = backTime / animationController.timePerCall
  local lnOfIncrease = math.log((shineObject.alpha + totalIncreseAlpha) / shineObject.alpha) / animationController.totalCallTime
  animationController.perIncrease = math.exp(lnOfIncrease)
  -- 動畫前紀錄
  animationController.originAlpha = shineObject.alpha
  
  -- 真動畫(亮)
  local nowCalledTime = 0
  local nowAlpha = shineObject.alpha -- 有些時候 alpha 會更新失敗，所以需額外紀錄 alpha 
  local function shineBright()
    if nowCalledTime < animationController.totalCallTime then
      nowCalledTime = nowCalledTime +1
      nowAlpha = nowAlpha * animationController.perIncrease 
      shineObject.alpha = nowAlpha

      animationController.playing = timer.performWithDelay(animationController.timePerCall, shineBright)
    else -- 播完，重頭再撥
      nowCalledTime = 0 -- 計數規歸 0
      
      if isFadeBack then -- 要再回去！方向改變
        if animationController.perIncrease > 1 then -- 因為指數數字誤差，如果做多次會編籬，要再回歸原數字
          nowAlpha = animationController.originAlpha + totalIncreseAlpha
        else
          nowAlpha = animationController.originAlpha
        end
        animationController.perIncrease = 1/ animationController.perIncrease -- 換方向！
      else -- 直接生硬的變回去
        nowAlpha = animationController.originAlpha
      end
      
      animationController.playing = timer.performWithDelay(animationController.timePerCall, shineBright)
    end
  end
  shineBright() -- 播放
  
  -- 強制結束動畫功能
  animationController.stop = function()
    shineObject.alpha = animationController.originAlpha -- 還原 alpha
    timer.cancel(animationController.playing) -- 停止動畫
    animationController:removeSelf()  -- 移除！
  end
  
  -- 回傳物件
  return animationController
end


-- 縮放的動畫 
function systemRecord_zoomInOrOut(showingObject, animtionTime, isShow)
  -- 特性設定
  local timePerCall = 10  -- 每次呼叫時間
  local totalCallTime = animtionTime / timePerCall
  local shrinkPerTime = math.exp( math.log(1/8)/totalCallTime )-- 以指數形式縮小 (縮小到 1/8 時結束)
  
  if isShow then -- 放大就往反方向
    shrinkPerTime = 1/shrinkPerTime
    showingObject.isVisible = true -- 開啟關閉的圖
  end
  
  -- 真動畫
  local nowCalledTime = 0
  local function trueAnime()
    showingObject:scale(shrinkPerTime, shrinkPerTime)
    
    nowCalledTime = nowCalledTime + 1
    if nowCalledTime < totalCallTime then
      timer.performWithDelay(timePerCall, trueAnime)
    else
      if not isShow then -- 縮小結束，關閉所有東西
        showingObject.isVisible = false -- 預設關閉
      end
    end
  end
  trueAnime() -- 播放
end




-- 創建換天黑布 (不確定 why 無法 get 全螢幕大小，總之 *2 以確保蓋到 all)
function systemRecord_createBlackCover(alpha)
  local blackCover = display.newRect(display.contentWidth/2, display.contentHeight/2, display.contentWidth*2,  display.contentHeight*2) -- 占全螢幕的黑布
  local blackPaint = { 0, 0, 0 }
  blackCover.fill = blackPaint 
  blackCover.alpha = alpha
  local function onTouch( event ) -- 讓 touch 失效 if 黑布存在(alpha != 0)
      return true -- 按到黑布就停止偵測
  end
  blackCover:addEventListener( "touch", onTouch )
  
  return blackCover
end
local blackCover = systemRecord_createBlackCover(0) -- 先設為透明

-- 換天
function systemRecord_nextDay()
  -- 暗下的秒數設定
  blackTime = 1000
  local blackTime_darkingPropotion = 0.25 -- 暗下的時間占全時間比例
  
  blackCover:toFront() -- 要把黑布移到最最前面
  systemRecord_fadeAnimation(blackCover, blackTime * blackTime_darkingPropotion, true) --  fade in
  local function blackResume()
    if blackCover.alpha < 1 then -- 有時候可能不會完 fade in 完，等真 fade in 完再 fade out
      timer.performWithDelay(1, blackResume)
    else
      -- 把 listener 內每個 NextDay function 都叫一次
      local i = 1
      local Max = #systemRecord_nextDayListeners
      while i <= Max  do 
        if not (systemRecord_nextDayListeners[i].x == nil) then -- removeSelf 會把 table 內東西變 nil 而已，所以要隨便 check 一個 table 才行確定是否清空
          systemRecord_nextDayListeners[i].nextDay()
          i = i +1
        else -- 清除空的 Listener
          table.remove(systemRecord_nextDayListeners, i)
          Max = Max -1 
        end
      end 
      -- fade out
      systemRecord_fadeAnimation(blackCover, blackTime* (1-blackTime_darkingPropotion), false) -- fade out
    end
  end
  timer.performWithDelay(blackTime * blackTime_darkingPropotion, blackResume)-- 等 fade in 完才能 fade out  
end
