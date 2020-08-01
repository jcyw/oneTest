--[[
    author:Temmie
    time:2019-09-27 11:22:32
    function:指挥官技能解锁条件弹窗
]]
local PlayerSkillLock = UIMgr:NewUI("PlayerSkillLock")

local SkillModel = import("Model/SkillModel")

function PlayerSkillLock:OnInit()
    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("PlayerSkillLock")
    end)

    self:AddListener(self._bgMask.onClick,function()
        UIMgr:Close("PlayerSkillLock")
    end)
end

function PlayerSkillLock:OnOpen(confId)
    self.config = SkillModel.GetConfigById(confId)
    self._titleName.text = StringUtil.GetI18n(I18nType.Tech, self.config.id.."_NAME")
    self._textContent.text = StringUtil.GetI18n(I18nType.Tech, self.config.id.."_DESC")
    self._iconItem:GetChild("_icon").url = UITool.GetIcon(self.config.icon)
    self._iconItem:GetChild("_textLv").visible = false
    self._iconItem:GetChild("levelBg").visible = false
    self._iconItem:GetChild("_textTip").visible = false
    self._iconItem:GetChild("numberBg").visible = false

    self._list:RemoveChildrenToPool()
    for _,v in pairs(self.config.unlock) do
        local preConfig = SkillModel.GetConfigById(v.item)
        local item = self._list:AddItemFromPool()
        item:SetUpLineVisible(false)
        item:SetDownLineVisible(false)
        item:ConditionInit(preConfig, v.value)
        item:SetIconGrayed(true)
    end
end

return PlayerSkillLock