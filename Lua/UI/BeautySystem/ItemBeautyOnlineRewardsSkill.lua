local ItemBeautyOnlineRewardsSkill = fgui.extension_class(GComponent)
fgui.register_extension("ui://BeautySystem/itemBeautyOnlineRewardsSkill", ItemBeautyOnlineRewardsSkill)

function ItemBeautyOnlineRewardsSkill:ctor()
    self._icon = self:GetChild("icon")
    self._favorText = self:GetChild("title")
    self._nameText = self:GetChild("textName")
    self._desText1 = self:GetChild("text1")
    self._desText2 = self:GetChild("text2")
end

function ItemBeautyOnlineRewardsSkill:SetData(info)
    self._favorText.text = StringUtil.GetI18n(I18nType.Commmon, "GirlOnlineReward_Favor") .. tostring(info.favor)
    local skillConfig = ConfigMgr.GetItem("configGirlskills", info.skill)
    self._nameText.text = StringUtil.GetI18n("configI18nCommons", skillConfig.name)
    self._icon.url = UITool.GetIcon(skillConfig.icon)
    local desCount = 0
    local descTexts = {self._desText1,self._desText2}
    for k, v in pairs(skillConfig.buff_id) do
        desCount = desCount + 1
        if desCount > 2 then
            break
        end
        local buffInfo = ConfigMgr.GetItem("configAttributes", v)
        local data = {}
        if buffInfo.value_type == 2 then
            local num = (skillConfig.buff_num[k] / 100)
            data.num = string.format("%d", num) .. "%" --tostring(skillConfig.buff_num[k] / 100) .. "%"
        elseif buffInfo.value_type == 1 then
            data.num = skillConfig.buff_num[k]
        end
        descTexts[desCount].text = StringUtil.GetI18n("configI18nSkills", string.format("SKILL_%d_DESC", v), data)
    end
end
