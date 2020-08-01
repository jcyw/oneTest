local itemPlayerAchievimentMission = fgui.extension_class(GComponent)
fgui.register_extension("ui://PlayerDetail/ItemPlayerAchievementWall_Top", itemPlayerAchievimentMission)

local TaskModel = import("Model/TaskModel")
local AchievementModel = import("Model/AchievementModel")
local STAR_SWITCH = 5

function itemPlayerAchievimentMission:ctor()
    self._ctr = self:GetController("c1")
    self._textGold = self:GetChild("textGold")
    self._textFinished = self:GetChild("textFinished")

    self:InitEvent()
    self:InitI18n()
end

function itemPlayerAchievimentMission:InitEvent()
    NodePool.Init(NodePool.KeyType.StarShowEffect, "Effect", "EffectNode")
    NodePool.Init(NodePool.KeyType.StarSweepEffect, "Effect", "EffectNode")
    self:AddListener(self._btnArrow.onClick,function()
        if self.accomplished then
            return
        end

        local status = self:GetCacheStatus()
        if status ~= nil then
            self:ChangeCacheStatus(not status)
            self._par._listViewMission:RefreshVirtualList()
        end
    end)

    self:AddListener(self._clickBg.onClick,function()
        if self.accomplished then
            return
        end

        local status = self:GetCacheStatus()
        if status ~= nil then
            self:ChangeCacheStatus(not status)
            self._par._listViewMission:RefreshVirtualList()
        end
    end)

    self:AddListener(self._btnAwards.onClick,function()
        local curData = self.dataList[1]
        self.canPlayStarEffect = true
        if not curData.Accomplished then
            return
        end
        Net.Achievement.GetAwards(curData.Id,function(rsp)
            --播放领奖动画
            UITool.ShowReward(rsp.Rewards.Rewards)
            self._par.hasCompleteAchievement = true
            self.star = self.star + 1        
            table.remove(self.dataList,1)
            self._par:UpdateMissionItem(self.dataType, self.star)
            AchievementModel.SetTaken(curData.Id)
            self._par:DatasDeal()
            self._par:UpdateMissionList()
        end)
    end)
end

function itemPlayerAchievimentMission:InitI18n()
    self._btnAwards.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_REWARD")
    self._btnAwards2.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_REWARD")
end

function itemPlayerAchievimentMission:SetData(data,index,_par)
    self.data = data
    self.index = index
    self._par = _par
    self.dataType = data.dataType
    self.star = data.star
    self.dataList = data.data
    -- if index ~= _par.curMissionIndex then
    --     self._ctr.selectedIndex = 0
    -- end
    self._ctr.selectedIndex = 0
    self.accomplished = self.dataList[1].AwardTaken   --成就任务已经完成
    if self.effect then
        self.effect:StopEffect()
        NodePool.Set(NodePool.KeyType.StarShowEffect, self.effect)
    end
    self:UpdateShowInfo()
end

function itemPlayerAchievimentMission:UpdateShowInfo()
    if self.star > STAR_SWITCH then
        self._ctr.selectedIndex = self._ctr.selectedIndex > 1 and 3 or 1
        self:GetChild("textStarNum").text = 'x'..self.star
        for i = 1, STAR_SWITCH do
            if self["effectStar"..i] then
                self["effectStar"..i]:StopEffect()
                NodePool.Set(NodePool.KeyType.StarSweepEffect, self["effectStar"..i])
            end
        end
        local starImage = self:GetChild("iconStar"..6)
        if not self["effectStar"..6] then
            self["effectStar"..6] = NodePool.Get(NodePool.KeyType.StarSweepEffect)
            self:AddChild(self["effectStar"..6])
            self["effectStar"..6].xy = Vector2(starImage.x + starImage.width / 2, starImage.y + starImage.height / 2)
        end
        self["effectStar"..6]:PlayDynamicEffectLoop("effect_collect","effect_star_sweep_prefab",Vector3(100, 100, 100),1)
    else
        if self["effectStar"..6] then
            self["effectStar"..6]:StopEffect()
            NodePool.Set(NodePool.KeyType.StarSweepEffect, self["effectStar"..6])
        end
        self._ctr.selectedIndex = self._ctr.selectedIndex > 1 and 2 or 0
        for i = 1, STAR_SWITCH do
            local starImage = self:GetChild("iconStar"..i)
            starImage.visible = false
            if i <= self.star then
                if self.canPlayStarEffect and i == self.star then
                    self.canPlayStarEffect = false
                    self.effect = NodePool.Get(NodePool.KeyType.StarShowEffect)
                    self:AddChild(self.effect)
                    self.effect.xy = Vector2(starImage.x + starImage.width / 2, starImage.y + starImage.height / 2 + 1)
                    self.effect:PlayDynamicEffectSingle("effect_collect","effect_star_dot",
                        function()
                            NodePool.Set(NodePool.KeyType.StarShowEffect, self.effect)
                            starImage.visible = true
                            self.effect = nil
                            if not self["effectStar"..i] then
                                self["effectStar"..i] = NodePool.Get(NodePool.KeyType.StarSweepEffect)
                                self:AddChild(self["effectStar"..i])
                                self["effectStar"..i].xy = Vector2(starImage.x + starImage.width / 2, starImage.y + starImage.height / 2)
                            end
                            self["effectStar"..i]:PlayDynamicEffectLoop("effect_collect","effect_star_sweep_prefab",Vector3(100, 100, 100),1)
                        end, Vector3(100, 100, 1),nil,1)
                else
                    starImage.visible = true
                    if not self["effectStar"..i] then
                        self["effectStar"..i] = NodePool.Get(NodePool.KeyType.StarSweepEffect)
                        self:AddChild(self["effectStar"..i])
                        self["effectStar"..i].xy = Vector2(starImage.x + starImage.width / 2, starImage.y + starImage.height / 2)
                    end
                    self["effectStar"..i]:PlayDynamicEffectLoop("effect_collect","effect_star_sweep_prefab",Vector3(100, 100, 100),1)
                end
            else
                if self["effectStar"..i] then
                    self["effectStar"..i]:StopEffect()
                    NodePool.Set(NodePool.KeyType.StarSweepEffect, self["effectStar"..i])
                end
                starImage.visible = false
            end
        end
    end
    local curData = self.dataList[1]
    local configData = curData.configData
    self._icon.url = UITool.GetIcon(configData.img)
    local goalNum = math.max(configData.finish.para2 or 0, 1)
    local count = curData.Accomplished and goalNum or curData.CurrentProcess or 0
    self._progressBar.value = count / goalNum * 100
    self._textProgressNum.text = string.format("%s/%s", Tool.FormatNumberThousands(count), Tool.FormatNumberThousands(goalNum))

    local typeData = ConfigMgr.GetItem("configAchievementTypes", configData.type)
    local level = self.accomplished and self.star or self.star + 1
    self._textName.text = StringUtil.GetI18n(I18nType.Tasks, typeData.info) .. StringUtil.GetI18n(I18nType.Commmon, "UI_ROMAN_NUMERAL_" .. level)

    -- 由于显示要用千位隔开,用TaskModel.GetTaskNameByType()的方法可能会出错,所以单独进行处理
    local confType = configData.finish.type
    local params = {num = MathUtil.Formatnumberthousands(configData.finish.para2)}
    for i, v in ipairs(configData.trans_key or {}) do
        params["key_" .. i] = StringUtil.GetI18n(configData.trans_I18n[i], v)
    end
    for i, v in ipairs(configData.trans_value or {}) do
        params["value_" .. i] = v
    end
    local finishtypeData = ConfigMgr.GetItem("configTaskTypes", confType)
    local name = StringUtil.GetI18n(I18nType.Tasks, finishtypeData.name, params)
    self._textProgressName.text = name

    local id = curData.Id
    local awardID = ConfigMgr.GetItem("configAchievementTasks", id).award
    local awardGold = ConfigMgr.GetItem("configGifts", awardID).res[1].amount
    self._textGold.text = awardGold

    if self.accomplished then
        self._textFinished.text =  StringUtil.GetI18n(I18nType.Commmon, "UI_ALLREADY_FINISH")
        self._progressBar.visible = false
        self._textProgressNum.visible = false
        self:SwitchCtr(false)
        return
    else
        self._textFinished.text = ""
        self._progressBar.visible = true
        self._textProgressNum.visible = true
    end


    if curData.AwardTaken then
        self._ctr.selectedIndex = self.star > STAR_SWITCH and 1 or 0
    elseif not curData.Accomplished then
        if self._ctr.selectedIndex == 3 then
            self._ctr.selectedIndex = 5
        elseif self._ctr.selectedIndex == 2 then
            self._ctr.selectedIndex = 4
        end
    end
    local status = self:GetCacheStatus()
    if status ~= nil then
        self:SwitchCtr(status)
    else
        if not self.accomplished and curData.Accomplished then
            self:SwitchCtr(true)
            table.insert(self._par.itemDataStatus, {dataType = self.dataType, status = true})
        else 
            self:SwitchCtr(false)
            table.insert(self._par.itemDataStatus, {dataType = self.dataType, status = false})
        end
    end
end

--留了一些注释代码便于之后需求变更
function itemPlayerAchievimentMission:SwitchCtr(isOpen)
    local curData = self.dataList[1]
    local index
    if isOpen then
        index = curData.Accomplished and 2 or 4
        if self.star > STAR_SWITCH then
            index = index + 1
        end
    else
        index = 0
        if self.star > STAR_SWITCH then
            index = index + 1
        end
    end
    self._ctr.selectedIndex = index
end

function itemPlayerAchievimentMission:GetCacheStatus()
    for _,v in pairs(self._par.itemDataStatus) do
        if v.dataType == self.dataType then
            return v.status
        end
    end
end

function itemPlayerAchievimentMission:ChangeCacheStatus(value)
    for k,v in pairs(self._par.itemDataStatus) do
        if v.dataType == self.dataType then
            self._par.itemDataStatus[k].status = value
        end
    end
end

return itemPlayerAchievimentMission