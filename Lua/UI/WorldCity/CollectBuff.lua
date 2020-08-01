--[[
    author:{zhanzhang}
    time:2019-09-24 19:33:40
    function:{采集buff界面}
]]
local GD = _G.GD
local CollectBuff = UIMgr:NewUI("CollectBuff")
local BuffItemModel = import("Model/BuffItemModel")

local mineInfo
function CollectBuff:OnInit()
    local view = self.Controller.contentPane
    self._timeControl = view:GetController("timeControl")
    self:OnRegister()
end

function CollectBuff:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Open("CollectDetails", mineInfo)
            UIMgr:Close("CollectBuff")
        end
    )
end

function CollectBuff:OnOpen(info)
    mineInfo = info
    local list = GD.ItemAgent.GetItemListByPage(Global.PageGatherBuff)
    self._contentList:RemoveChildrenToPool()
    self:RefreshTime()
    for i = 1, #list do
        local item = self._contentList:AddItemFromPool()
        item:Init(
            list[i],
            ItemType.CollectBuffProp,
            nil,
            function()
                self:RefreshTime()
            end
        )
    end
end

function CollectBuff:RefreshTime()
    local model = BuffItemModel.GetModelByConfigId(Global.GatherSpeedBuffCategory)
    if model and model.ExpireAt > Tool.Time() then
        self._timeControl.selectedPage = "show"

        if self.schedule_funtion then
            self:UnSchedule(self.schedule_funtion)
        end

        local total = model.ExpireAt - model.StartAt
        local ct = model.ExpireAt - Tool.Time()
        self.schedule_funtion = function()
            ct = ct - 1
            if ct >= 0 then
                self._proqressBarCheckPopup.value = (ct / total) * 100
                self._textTime.text = Tool.FormatTime(ct)
            else
                self._timeControl.selectedPage = "hide"
                if self.schedule_funtion then
                    self:UnSchedule(self.schedule_funtion)
                end
            end
        end
        self.schedule_funtion()
        self:Schedule(self.schedule_funtion, 1)
    else
        self._timeControl.selectedPage = "hide"
    end
end

return CollectBuff
