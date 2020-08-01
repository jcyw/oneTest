--[[
    Author: songzeming
    Function: 城内、巨兽、城外、围墙建筑建造、升级动画
]]
local BuildUpgradeAnim = {}

--播放开始建造、升级动画
function BuildUpgradeAnim:PlayStartAnim(ctx)
    self:StopAnim(ctx)
    for i = 1, ctx.numChildren do
        local item = ctx:GetChildAt(i - 1)
        item:GetTransition("Start"):Play(function()
            if item.name == "Crane" then
                item:GetTransition("Loop"):Play(-1, 0, nil)
            end
        end)
    end
end

--循环播放建造中、升级中动画
function BuildUpgradeAnim:PlayLoopAnim(ctx)
    self:StopAnim(ctx)
    local item = ctx:GetChild("Crane")
    item:GetTransition("Loop"):Play(-1, 0, nil)
end

--播放完成建造、升级动画
function BuildUpgradeAnim:PlayEndAnim(ctx, cb)
    self:StopAnim(ctx)
    for i = 1, ctx.numChildren do
        local item = ctx:GetChildAt(i - 1)
        item:GetTransition("End"):Play(cb)
    end
end

--关闭所有动画
function BuildUpgradeAnim:StopAnim(ctx)
    for i = 1, ctx.numChildren do
        local item = ctx:GetChildAt(i - 1)
        item:GetTransition("Start"):Stop()
        item:GetTransition("End"):Stop()
        if item.name == "Crane" then
            item:GetTransition("Loop"):Stop()
        end
    end
end

return BuildUpgradeAnim
