--[[
    Author: songzeming,maxiaolong
    Function: 主界面UI 右侧主动技能
]]
local MainUISkill = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/btnMainSkill", MainUISkill)
import("Model/SkillModel")
function MainUISkill:ctor()
    self:AddListener(self.onClick,
        function()
            self:OnBtnClick()
        end
    )

    self:Init()
end

function MainUISkill:Init()
    --显示
    self.visible = true
    local SkillModel = ConfigMgr.GetList("configPlayerSkills")
end

function MainUISkill:OnBtnClick()
    UIMgr:Open("MainActiveSkills")
    if self.triggerFunc then
        self.triggerFunc()
    end
end

function MainUISkill:TriggerOnclick(callback)
        self.triggerFunc = callback
end

return MainUISkill
