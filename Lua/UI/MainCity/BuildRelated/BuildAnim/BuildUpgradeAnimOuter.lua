--[[
    Author: songzeming
    Function: 城外建筑建造、升级动画
]]
local BuildUpgradeAnimOuter = fgui.extension_class(GComponent)
fgui.register_extension("ui://Build/BuildUpgradeAnimOuter", BuildUpgradeAnimOuter)

local BuildUpgradeAnim = import("UI/MainCity/BuildRelated/BuildAnim/BuildUpgradeAnim")

function BuildUpgradeAnimOuter:ctor()
end

--播放开始建造、升级动画
function BuildUpgradeAnimOuter:PlayStartAnim()
    BuildUpgradeAnim:PlayStartAnim(self)
end

--循环播放建造中、升级中动画
function BuildUpgradeAnimOuter:PlayLoopAnim()
    BuildUpgradeAnim:PlayLoopAnim(self)
end

--播放完成建造、升级动画
function BuildUpgradeAnimOuter:PlayEndAnim(cb)
    BuildUpgradeAnim:PlayEndAnim(self, cb)
end

function BuildUpgradeAnimOuter:StopAnim()
    BuildUpgradeAnim:StopAnim(self)
end

return BuildUpgradeAnimOuter
