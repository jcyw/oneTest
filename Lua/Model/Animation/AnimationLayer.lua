--[[
    Author: songzeming
    Function: 公用模板 界面打开关闭动画
]]
if AnimationLayer then
    return AnimationLayer
end
AnimationLayer = {}

local PANEL_TIME1 = 0.1 --面板动画时间
local PANEL_TIME2 = 0.2 --面板动画时间
local PANEL_MOVE_UP_DISTANCE = GRoot.inst.height --面板打开、关闭向上移动距离
local PANEL_MOVE_LR_DISTANCE = GRoot.inst.width --面板打开、关闭向左、右移动距离
local ACTIVE_SKILLS_DISTANCE = 80 --主动技能上下移动距离

--面板打开、关闭动画
function AnimationLayer.PanelAnim(animType, ctx, isClose, cb)
    local ctr = ctx.Controller
    GTween.Kill(ctr)
    ctr.touchable = false
    local originPivot = ctr.pivot --初始锚点
    -- local originPos = ctr.xy --初始位置
    local originScale = ctr.scale --初始大小

    if ctr._uiName ~= "ToolTip" then
        Event.Broadcast(EventDefines.LayerMask, true)
    end

    local function anim_func()
        --还原初始锚点、位置、大小
        ctr.touchable = true
        ctr.pivot = originPivot
        -- ctr.xy = originPos
        ctr.xy = Vector2.zero
        ctr.scale = originScale
        if ctr._uiName ~= "ToolTip" then
            Event.Broadcast(EventDefines.LayerMask, false)
        end
        --动画播放完成动画
        if isClose then
            GRoot.inst:HideWindowImmediately(ctr)
        end
        if cb then
            cb()
        end
    end

    if animType == AnimationType.PanelScaleOpen then
        --面板打开缩放动画
        ctr:SetPivot(0.5, 0.5)
        ctr:SetScale(1, 1)
        ctx:GtweenOnComplete(ctr:TweenScale({x = 1.1, y = 1.1}, PANEL_TIME1):SetEase(EaseType.Linear), function()
            ctx:GtweenOnComplete(ctr:TweenScale({x = 1, y = 1}, PANEL_TIME1):SetEase(EaseType.Linear), anim_func)
        end)
    elseif animType == AnimationType.PanelScaleClose then
        --面板关闭缩放动画
        ctr:SetPivot(0.5, 0.5)
        ctr:SetScale(1, 1)
        ctx:GtweenOnComplete(ctr:TweenScale({x = 1.1, y = 1.1}, PANEL_TIME1):SetEase(EaseType.Linear), function()
            ctx:GtweenOnComplete(ctr:TweenScale({x = 0, y = 0}, PANEL_TIME1):SetEase(EaseType.Linear), anim_func)
        end)
    elseif animType == AnimationType.PanelMoveUp then
        --面板向上移动动画
        ctr:SetPivot(0, 0)
        ctr.y = PANEL_MOVE_UP_DISTANCE
        ctx:GtweenOnComplete(ctr:TweenMoveY(0, PANEL_TIME2), anim_func)
    elseif animType == AnimationType.PanelMovePreUp then
        --面板向上移动动画 (移动到(0,0))
        ctr:SetPivot(0, 0)
        ctr.y = 0
        ctx:GtweenOnComplete(ctr:TweenMoveY(-PANEL_MOVE_UP_DISTANCE, PANEL_TIME2), anim_func)
    elseif animType == AnimationType.PanelMoveDown then
        --面板向下移动动画
        ctr:SetPivot(0, 0)
        ctr.y = 0
        ctx:GtweenOnComplete(ctr:TweenMoveY(PANEL_MOVE_UP_DISTANCE, PANEL_TIME2), anim_func)
    elseif animType == AnimationType.PanelMovePreDown then
        --面板向下移动动画(移动到(0,0))
        ctr:SetPivot(0, 0)
        ctr.y = -PANEL_MOVE_UP_DISTANCE
        ctx:GtweenOnComplete(ctr:TweenMoveY(0, PANEL_TIME2), anim_func)
    elseif animType == AnimationType.PanelMoveLeft then
        --面板向左移动动画
        ctr:SetPivot(0, 0)
        ctr.x = PANEL_MOVE_LR_DISTANCE
        ctx:GtweenOnComplete(ctr:TweenMoveX(0, PANEL_TIME2), anim_func)
    elseif animType == AnimationType.PanelMovePreLeft then
        --面板向左移动动画(移动到(-distance,0))
        ctr:SetPivot(0, 0)
        ctr.x = 0
        ctx:GtweenOnComplete(ctr:TweenMoveX(-PANEL_MOVE_LR_DISTANCE, PANEL_TIME2), anim_func)
    elseif animType == AnimationType.PanelMoveRight then
        --面板向右移动动画
        ctr:SetPivot(0, 0)
        ctr.x = 0
        ctx:GtweenOnComplete(ctr:TweenMoveX(PANEL_MOVE_LR_DISTANCE, PANEL_TIME2), anim_func)
    elseif animType == AnimationType.PanelMovePreRight then
        --面板向右移动动画(移动到(0,0))
        ctr:SetPivot(0, 0)
        ctr.x = -PANEL_MOVE_LR_DISTANCE
        ctx:GtweenOnComplete(ctr:TweenMoveX(0, PANEL_TIME2), anim_func)
    elseif animType == AnimationType.ActiveSkills then
        --面板向上、下移动
        ctr:SetPivot(0, 0)
        ctr.y = 0
        ctx:GtweenOnComplete(ctr:TweenMoveY(-ACTIVE_SKILLS_DISTANCE, PANEL_TIME1), function()
            ctx:GtweenOnComplete(ctr:TweenMoveY(0, PANEL_TIME1), anim_func)
        end)
    end
end
--界面打开缩放动画
function AnimationLayer.PanelScaleOpenAnim(ctx, cb)
    AnimationLayer.PanelAnim(AnimationType.PanelScaleOpen, ctx, false, cb)
end
--界面关闭缩放动画
function AnimationLayer.PanelScaleCloseAnim(ctx, cb)
    AnimationLayer.PanelAnim(AnimationType.PanelScaleClose, ctx, true, cb)
end
--格子列表由下向上
function AnimationLayer.UIDownToTopBoxAnim(list,mvDistance,ctx)
    local lineCount = list.curLineItemCount
    list.touchable = false
    for i = 1, list.numChildren do
        local item = list:GetChildAt(i - 1)
        GTween.Kill(item)
        local col = math.floor((i - 1) / lineCount)
        item.y = col * (list.lineGap + item.height) + mvDistance
        item.alpha = 0
        ctx:GtweenOnComplete(
            item:TweenFade(0, 0.1 * i),
            function()
                item.alpha = 1
                ctx:GtweenOnComplete(
                    item:TweenMoveY(item.y - mvDistance, 0.1):SetEase(EaseType.CubicOut),
                    function()
                        if i == list.numChildren then
                            list.touchable = true
                        end
                    end
                )
            end
        )
    end
end
--横条列表由右到左或左到右
function AnimationLayer.PlayListLeftToRightAnim(animType,list,duration,ctx)
    if list.numChildren<=0 then
        return
    end
    list.touchable = false
    for i = 1, list.numChildren do
        local item = list:GetChildAt(i - 1)
        AnimationLayer.UIHorizontalMove(ctx,item,i,duration,animType,0,function()
            if i == list.numChildren then
                list.touchable = true
            end
        end)
    end
end
function AnimationLayer.UIHorizontalMove(ctx,item,index,duration,animType,mvDistance,cb)
    GTween.Kill(item)
    if not mvDistance or mvDistance==0 then
        mvDistance = animType == AnimationType.UIRightToLeft and item.width or -item.width
        item.x = mvDistance
    else
        item.x = item.x + mvDistance
    end
    ctx:GtweenOnComplete(
        item:TweenMoveX(item.x, 0.1),
        function()
            ctx:GtweenOnComplete(
            item:TweenMoveX(item.x - mvDistance, duration*index):SetEase(EaseType.CubicOut),
            function()
                if cb then
                    cb()
                end
            end
            )
        end
    )
end
--横条列表由下到上
function AnimationLayer.UIDownToTopAnim(list,mvDistance,duration,ctx)
    list.touchable = false
    for i = 1, list.numChildren do
        local item = list:GetChildAt(i - 1)
        GTween.Kill(item)
        local y = (i-1)*(list.lineGap + item.height)
        item.y = y + mvDistance
        item.alpha = 0
        ctx:GtweenOnComplete(
            item:TweenFade(0, duration * i),
            function()
                item.alpha = 1
                ctx:GtweenOnComplete(
                    item:TweenMoveY(y, duration):SetEase(EaseType.CubicOut),
                    function()
                        if i == list.numChildren then
                            list.touchable = true
                        end
                    end
                )
            end
        )
    end
end
--组件缩放出现 
function AnimationLayer.UIAlphaAndScale(ctx,item,index,scale,duration,cb, arg)
    if index<=1 then
        index = 1
    end
    GTween.Kill(item)
    item.alpha = 0
    local tween = item:TweenFade(0, duration*index)
    ctx:GtweenOnComplete(
        tween,
        function()
            item.alpha = 1
            ctx:GtweenOnComplete(item:TweenScale(scale, duration):SetEase(EaseType.CubicOut),function()
                item:TweenScale(Vector2(1, 1), duration):SetEase(EaseType.CubicOut)
                if cb then
                    cb(arg)
                end
            end)
        end
    )
end

return AnimationLayer
