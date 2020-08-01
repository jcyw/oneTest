--[[
    Author: songzeming
    Function: 靶场奖励记录
]]
local RangeRewardRecord = UIMgr:NewUI("RangeRewardRecord")

import("UI/Casino/RangeFlop/RangeFlopCard")

function RangeRewardRecord:OnInit()
    self:AddListener(self._btnClose.onClick,function()
        self:Close()
    end)
    self:AddListener(self._mask.onClick,function()
        self:Close()
    end)
    self:AddListener(self._btnShare.onClick,function()
        if self.cb then self.cb() end
    end)
    self._list.scrollPane.touchEffect = false
end

function RangeRewardRecord:OnOpen(HyperGamblingInfo, from, cb)
    self.HyperGamblingInfo = HyperGamblingInfo
    self.cb = cb
    if from == "Range" then
        self._btnShare.title = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_24")
    else
        self._btnShare.title = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_20")
    end

    Event.Broadcast(EventDefines.OpenRangeRewardRecord)

    self:UpdataData()
end

function RangeRewardRecord:Close()
    UIMgr:Close("RangeRewardRecord")
end

function RangeRewardRecord:OnClose(  )
    Event.Broadcast(EventDefines.ExitRangeRewardRecord)
end

function RangeRewardRecord:UpdataData()
    table.sort(self.HyperGamblingInfo, function(a, b) return a.ConfigIndex < b.ConfigIndex end)

    self._list.numItems = #self.HyperGamblingInfo
    for k, v in pairs(self.HyperGamblingInfo) do
        for key, value in pairs(v) do
            if type(value) == "number" then
                v[key] = math.floor(value)
            end
        end
        local item = self._list:GetChildAt(k - 1)
        item:InitCard(v)
        item:SetStep(v)
    end
end

return RangeRewardRecord
