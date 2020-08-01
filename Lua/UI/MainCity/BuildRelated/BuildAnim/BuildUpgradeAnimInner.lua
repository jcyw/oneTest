--[[
    Author: songzeming
    Function: 城内、巨兽建筑建造、升级动画
]]
local BuildUpgradeAnimInner = fgui.extension_class(GComponent)
fgui.register_extension("ui://Build/BuildUpgradeAnimInner", BuildUpgradeAnimInner)

local BuildUpgradeAnim = import("UI/MainCity/BuildRelated/BuildAnim/BuildUpgradeAnim")

function BuildUpgradeAnimInner:ctor()
end

--播放开始建造、升级动画
function BuildUpgradeAnimInner:PlayStartAnim()
    BuildUpgradeAnim:PlayStartAnim(self)
end

--循环播放建造中、升级中动画
function BuildUpgradeAnimInner:PlayLoopAnim()
    BuildUpgradeAnim:PlayLoopAnim(self)
end

--播放完成建造、升级动画
function BuildUpgradeAnimInner:PlayEndAnim(cb)
    BuildUpgradeAnim:PlayEndAnim(self, cb)
end

function BuildUpgradeAnimInner:StopAnim()
    BuildUpgradeAnim:StopAnim(self)
end

return BuildUpgradeAnimInner
