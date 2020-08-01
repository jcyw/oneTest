--[[
    author:Temmie
    time:2019-12-20 17:10:28
    function:士兵援助记录
]]
local TroopAssistanceRecord = UIMgr:NewUI("TroopAssistanceRecord")

TroopAssistanceRecord.Step = 20

function TroopAssistanceRecord:OnInit()
    self._list.itemRenderer = function(index, item)
        local data = self.datas[index + 1]
        item:GetChild("textName").text = data.Name
        item:GetChild("textNumber").text = data.ArmyAmount
        item:GetChild("textTime").text = TimeUtil:StampTimeToYMDHMS(data.Time)
        -- CommonModel.SetUserAvatar(item:GetChild("icon"), data.Avatar, data.UserId)
        item:GetChild("n19"):SetAvatar(data, nil, data.UserId)
    end

    self:AddListener(self._list.scrollPane.onPullUpRelease,function()
        self:LoadData()
    end)

    self:AddListener(self._btnReturn.onClick,function()
        UIMgr:Close("TroopAssistanceRecord")
    end)
end

function TroopAssistanceRecord:OnOpen()
    self.curIndex = 1
    self.datas = {}

    self:LoadData()
end

function TroopAssistanceRecord:LoadData()
    Net.AllianceBattle.AssistLogs(self.curIndex, self.curIndex + self.Step, function(rsp)
        if rsp.Fail then
            return
        end

        if #rsp.Logs > 0 then
            for _,v in pairs(rsp.Logs)do
                table.insert(self.datas, v)
            end
            self.curIndex = self.curIndex + self.Step + 1
            self._list.numItems = #self.datas
        end
    end)
end

return TroopAssistanceRecord