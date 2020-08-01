--[[
    author:{zhanzhang}
    time:2019-05-31 13:50:06
    function:{行军加速功能页面}
]]
local GD = _G.GD
local MarchAcceleration = UIMgr:NewUI("MarchAcceleration")
local MapModel = import("Model/MapModel")
local refreshBarFunc
local onMissionInfoFunc
local delMissionFunc
local refreshAggregationFunc
local configList = {}

function MarchAcceleration:OnInit()
    local view = self.Controller.contentPane
    self._btnReturn = view:GetChild("btnReturn")
    self._btnGold = view:GetChild("btnGold")
    self._txtGoldNum = self._btnGold:GetChild("textNumber")
    self._progressBar = view:GetChild("proqressBarCheckPopup")
    self._textTime = view:GetChild("textTime")
    self.content = view:GetChild("liebiao").asList
    local temp = ConfigMgr.GetList("configItems")

    for k, v in ipairs(temp) do
        if v.type2 == 7 and v["type"] == 2 then
            table.insert(configList, v)
        end
    end

    refreshBarFunc = function()
        self:RefreshProgressBar()
    end

    onMissionInfoFunc = function(val)
        if not val.OK and ((self.data.Uuid == val.Uuid) or self.data.AllianceBattleId == val.AllianceBattleId) then
            if self.data.IsReturn and self.data.IsReturn ~= val.IsReturn then
                UIMgr:Close("MarchAcceleration")
                return
            end
            UIMgr:Close("ConfirmPopupText")
            self.data = val
        end
    end

    delMissionFunc = function(rsp)
        if self.data.Uuid == rsp.Uuid then
            UIMgr:Close("MarchAcceleration")
            UIMgr:Close("ConfirmPopupText")
        end
    end

    refreshAggregationFunc = function(rsp)
        if rsp and rsp.Mission and (self.data.Uuid == rsp.Mission.Uuid) then
            if rsp.Mission.IsReturn and self.data.IsReturn ~= rsp.Mission.IsReturn then
                UIMgr:Close("MarchAcceleration")
                return
            end
            self.data = rsp.Mission
        end
    end

    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("MarchAcceleration")
        end
    )
end

function MarchAcceleration:OnRegister()
    self:AddEvent(EventDefines.UIOnMissionInfo, onMissionInfoFunc)
    self:AddEvent(EventDefines.UIDelMarchLine, delMissionFunc)
    self:AddEvent(EventDefines.UIOnRefreshAggregation, refreshAggregationFunc)
end

function MarchAcceleration:OnOpen(data)
    self:OnRegister()

    self:UnSchedule(refreshBarFunc)
    self.data = data
    self:Schedule(refreshBarFunc, 1, true)

    self.content:RemoveChildrenToPool()
    local list = GD.ItemAgent.GetItemListByPage(Global.PageMarchSpeed)
    for i = 1, #list do
        local item = self.content:AddItemFromPool()
        item:Init(list[i], ItemType.SpeedupProp, data)
    end
end
function MarchAcceleration:OnClose()
    self:UnSchedule(refreshBarFunc)
    Event.RemoveListener(EventDefines.UIOnMissionInfo, onMissionInfoFunc)
    Event.RemoveListener(EventDefines.UIDelMarchLine, delMissionFunc)
    Event.RemoveListener(EventDefines.UIOnRefreshAggregation, refreshAggregationFunc)
end

function MarchAcceleration:RefreshProgressBar()
    local timeTamp = self.data.FinishAt - Tool.Time()
    if (timeTamp <= 0) then
        UIMgr:Close("MarchAcceleration")
        UIMgr:Close("ConfirmPopupText")
        self:UnSchedule(refreshBarFunc)
        return
    end
    self._textTime.text = TimeUtil.SecondToHMS(timeTamp)
    self._progressBar.value = GameUtil.CalTimeSilderVal(self.data) * 100
end

return MarchAcceleration
