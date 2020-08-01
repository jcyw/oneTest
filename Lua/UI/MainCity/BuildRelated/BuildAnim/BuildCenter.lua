--[[
    Author: songzeming
    Function: 建筑 指挥中心
]]
local BuildCenter = fgui.extension_class(GButton)
fgui.register_extension("ui://Build/Building400000", BuildCenter)

local NAME = {
    down = "down",
    top = "top",
    loop = "loop"
}

function BuildCenter:ctor()
    self:StopAnim()
end

--播放开始建造、升级动画
function BuildCenter:PlayStartAnim()
    self:StopAnim()
    for i = 1, self.numChildren do
        local item = self:GetChildAt(i - 1)
        if Tool.Equal(item.name, NAME.down, NAME.top, NAME.loop) then
            item.visible = true
            item:GetTransition("Start"):Play(function()
                if item.name == NAME.loop then
                    item:GetTransition("Loop"):Play(-1, 0, nil)
                end
            end)
        end
    end
end

--循环播放建造中、升级中动画
function BuildCenter:PlayLoopAnim()
    self:StopAnim()
    local count = 0
    for i = 1, self.numChildren do
        local item = self:GetChildAt(i - 1)
        item.visible = true
        if item.name == NAME.loop then
            if count == 0 then
                count = 1
                self:GtweenOnComplete(item:TweenFade(1, math.random(2, 8) / 10),function()
                    item:GetTransition("Loop"):Play(-1, 0, nil)
                end)
            else
                item:GetTransition("Loop"):Play(-1, 0, nil)
            end
        end
    end
end

--播放完成建造、升级动画
function BuildCenter:PlayEndAnim()
    self:StopAnim()
    for i = 1, self.numChildren do
        local item = self:GetChildAt(i - 1)
        item.visible = true
        if Tool.Equal(item.name, NAME.down, NAME.top, NAME.loop) then
            item:GetTransition("End"):Play(function()
                item.visible = false
            end)
         end
    end
end

--关闭所有动画
function BuildCenter:StopAnim()
    for i = 1, self.numChildren do
        local item = self:GetChildAt(i - 1)
        if Tool.Equal(item.name, NAME.down, NAME.top, NAME.loop) then
            item.visible = false
            item:GetTransition("Start"):Stop()
            item:GetTransition("End"):Stop()
            if item.name == NAME.loop then
                GTween.Kill(item)
                item:GetTransition("Loop"):Stop()
            end
         end
    end
end

--指挥中心升级弹窗
function BuildCenter:Upgrade()
    if Model.Player.Level >= Global.BuildCenterUpgradePrompt then
        PopupWindowQueue:Push("BuildCenterUpgrade", Model.Player.Level)
    end
end

return BuildCenter
