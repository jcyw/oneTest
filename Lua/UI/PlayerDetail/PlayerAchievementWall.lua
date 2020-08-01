
local PlayerAchievementWall = UIMgr:NewUI("PlayerAchievementWall")

local AchievementModel = import("Model/AchievementModel")

function PlayerAchievementWall:OnInit()
    self._view = self.Controller.contentPane
    self._listViewMission = self._view:GetChild("liebiao")
    self._listViewMission = self._listViewMission:GetChild("liebiao")
    self.refresh_func = function(rsp)
        self:DatasDeal()
        self:RefreshMissionList()
    end

    self:InitEvent()

    self:InitI18n()
end

function PlayerAchievementWall:InitI18n()
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "UI__achievementTab")
end

function PlayerAchievementWall:InitEvent()
    self:AddListener(self._btnReturn.onClick,function()
        UIMgr:Close("PlayerAchievementWall")
    end)

    self._listViewMission.itemRenderer = function(index, item)
        if not index then
            return
        end
        index = index + 1
        item:SetData(self.showMissionData[index],index,self)
    end
    self._listViewMission:SetVirtual()
end

function PlayerAchievementWall:OnOpen(datas)
    self._listViewMission.scrollPane:ScrollTop()
    self.hasCompleteAchievement = false
    self.itemDataStatus = {}
    AchievementModel.SetData(datas)
    self:DatasDeal()
    self:RefreshMissionList()

    self:AddEvent(EventDefines.UnlockedAchievementUI, self.refresh_func)
    self:AddEvent(EventDefines.AccomplishedAchievementsUI, self.refresh_func)
end

function PlayerAchievementWall:DatasDeal()
    local tmpDatas = AchievementModel.tmpDatas
    local tmpMissionDatas = {}
    local configDatas = ConfigMgr.GetList("configAchievementTasks")
    self.totalNum = #configDatas
    for _,v in ipairs(configDatas) do
        local tmpData = tmpDatas[v.id] or {Id=v.id}
        tmpData.configData = v
        local achType = v.type
        tmpMissionDatas[achType] = tmpMissionDatas[achType] or {star=0,data={}}
        table.insert(tmpMissionDatas[achType].data,tmpData)
        if tmpData.AwardTaken then
            tmpMissionDatas[achType].star = tmpMissionDatas[achType].star + 1
        end
    end

    local missionDatas = {}
    for i,v in pairs(tmpMissionDatas) do
        table.insert(missionDatas,{dataType=i,star=v.star,data=v.data})
    end
    table.sort(missionDatas,function(a,b)
        return a.dataType < b.dataType
    end)
    self.totalMissionDatas = missionDatas
end

function PlayerAchievementWall:UpdateMissionItem(dataType, star)
    for i, v in ipairs(self.totalMissionDatas) do
        if v.dataType == dataType then
            self.totalMissionDatas[i].star = star
            local t = self.totalMissionDatas[i].data
            t[star].AwardTaken = true
        end
    end
end

function PlayerAchievementWall:UpdateMissionList()
    self:RefreshMissionList()
end

function PlayerAchievementWall:RefreshMissionList()
    local unaccMissionData = {}
    for i,v in ipairs(self.totalMissionDatas) do
        local tmpData = {}
        if v.star < #v.data then
            for _,vv in ipairs(v.data) do
                if not vv.AwardTaken then
                    table.insert(tmpData,vv)
                end
            end
            table.sort(tmpData,function(a,b)
                return a.Id < b.Id
            end)
        elseif v.star == #v.data then
            table.insert(tmpData, v.data[#v.data])
        end
        table.insert(unaccMissionData,{dataType=v.dataType,star=v.star,data=tmpData})
    end
    table.sort(unaccMissionData, function (a, b)
        local dataA = a.data[1]
        local dataB = b.data[1]

        if (dataA.AwardTaken and dataB.AwardTaken) or
            (not dataA.Accomplished and not dataB.Accomplished) then
            return a.dataType < b.dataType
        end

        if dataA.AwardTaken then
            return false
        end

        if dataB.AwardTaken then
            return true
        end

        if (dataA.Accomplished and dataB.Accomplished) or
            (not dataA.Accomplished and not dataB.Accomplished) then
            return a.dataType < b.dataType
        end

        if dataA.Accomplished then
            return true
        end

        if dataB.Accomplished then
            return false
        end
    end)

    self.showMissionData = unaccMissionData
    self._listViewMission.numItems = #self.showMissionData
end

function PlayerAchievementWall:OnClose()
    Event.RemoveListener(EventDefines.UnlockedAchievementUI, self.refresh_func)
    Event.RemoveListener(EventDefines.AccomplishedAchievementsUI, self.refresh_func)
    if self.hasCompleteAchievement then
        Net.Achievement.GetAchievementsInfo(
            function(rsp)
                Model.UpdateList(ModelType.AccomplishedAchievement, "Id", rsp.Accomplished)
                Event.Broadcast(EventDefines.AchievementRewardChange)
            end
        )
    else
        Event.Broadcast(EventDefines.AchievementRewardChange)
    end
end

return PlayerAchievementWall