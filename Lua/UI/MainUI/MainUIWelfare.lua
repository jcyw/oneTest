--[[
    Author: songzeming,maxiaolong
    Function: 主界面UI 左侧福利中心
]]
local WelfareCuePointModel = import("Model/CuePoint/WelfareCuePointModel")
local MainUIWelfare = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/btnMainWelfare", MainUIWelfare)

function MainUIWelfare:ctor()
    self._effect = self:GetChild("effect")
    self:AddListener(
        self.onClick,
        function()
            self:OnBtnClick()
        end
    )
    self:Init()
    --指挥中心升级
    self:AddEvent(
        EventDefines.UICityBuildCenterUpgrade,
        function()
            if not self.visible and _G.Model.Player.Level >= _G.Global.WelfareCentreShowLevel then
                WelfareCuePointModel:CheckDailySignPoint()
            end
            self:CheckShow()
        end
    )
    self:GetChild("icon").icon = UITool.GetIcon(_G.Global.WelfareCentreIcon)
    self:CheckShow()
    CuePointModel:CheckWelfare(self)
end

function MainUIWelfare:Init()
end

function MainUIWelfare:OnBtnClick()
    SdkModel.TrackBreakPoint(10033)
    UIMgr:Open("WelfareMain")
end

--是否显示福利中心
function MainUIWelfare:CheckShow()
    self.visible = _G.Model.Player.Level >= _G.Global.WelfareCentreShowLevel
    self:PlayEffect(self.visible)
end

function MainUIWelfare:PlayEffect(isPlay)
    --self._effect:PlayDynamicEffectLoop("effect_collect", "effect_welfare_sweep")
    self._effect:PlayEffectLoop("effects/welfare_sweep/prefab/effect_welfare_sweep", Vector3(135, 135, 135),1)
end

return MainUIWelfare
