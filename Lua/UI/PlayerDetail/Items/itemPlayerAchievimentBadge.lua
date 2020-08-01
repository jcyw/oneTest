local itemPlayerAchievimentBadge = fgui.extension_class(GComponent)
fgui.register_extension("ui://PlayerDetail/itemPlayerAchievimentBadge", itemPlayerAchievimentBadge)

function itemPlayerAchievimentBadge:ctor()
    self._ctr = self:GetController("c1")
end

function itemPlayerAchievimentBadge:SetData(data)
    self.dataType = data.dataType
    self.data = data.data

    local configData = ConfigMgr.GetItem("configAchievementTasks", self.data.Id)
    self._icon.url = UITool.GetIcon(configData.img)

    if self.data.AwardTaken then
        self._ctr.selectedIndex = 0

    	--暂时处理时间显示  根据需求 之后再修改逻辑或者造轮子
    	local timezone = TimeUtil.GetLocalTimeZone()
    	local finishTimeStr = os.date("%Y-%m-%d %H:%M", data.data.FinishTime - timezone)
        self._text.text = finishTimeStr
    else
        self._ctr.selectedIndex = 1
    end

    local typeData = ConfigMgr.GetItem("configAchievementTypes", configData.type)
    self._title.text = StringUtil.GetI18n(I18nType.Tasks, typeData.info)
end

return itemPlayerAchievimentBadge