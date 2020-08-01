--[[
    Author: songzeming
    Function: 围墙建筑建造、升级动画
]]
local BuildUpgradeAnimWall = fgui.extension_class(GButton)
fgui.register_extension("ui://Build/BuildUpgradeAnimWall", BuildUpgradeAnimWall)

function BuildUpgradeAnimWall:ctor()
    self:StopAnim()
end

--播放开始建造、升级动画
function BuildUpgradeAnimWall:PlayStartAnim()
    self:StopAnim()
    for i = 1, self.numChildren do
        local item = self:GetChildAt(i - 1)
        item.visible = true
        item:GetTransition("Start"):Play(function()
            if item.name == "Crane" then
                item:GetTransition("Loop"):Play(-1, 0, nil)
            end
        end)
    end
end

--循环播放建造中、升级中动画
function BuildUpgradeAnimWall:PlayLoopAnim()
    self:StopAnim()
    for i = 1, self.numChildren do
        local item = self:GetChildAt(i - 1)
        item.visible = true
        if item.name == "Crane" then
            item:GetTransition("Loop"):Play(-1, 0, nil)
        end
    end
end

--播放完成建造、升级动画
function BuildUpgradeAnimWall:PlayEndAnim()
    self:StopAnim()
    for i = 1, self.numChildren do
        local item = self:GetChildAt(i - 1)
        item.visible = true
        item:GetTransition("End"):Play(function()
            item.visible = false
        end)
    end
end

--关闭所有动画
function BuildUpgradeAnimWall:StopAnim()
    for i = 1, self.numChildren do
        local item = self:GetChildAt(i - 1)
        item.visible = false
        item:GetTransition("Start"):Stop()
        item:GetTransition("End"):Stop()
        if item.name == "Crane" then
            item:GetTransition("Loop"):Stop()
        end
    end
end

return BuildUpgradeAnimWall
