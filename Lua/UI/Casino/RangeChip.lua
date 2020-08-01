--[[
    Author: songzeming
    Function: (高级)幸运币使用或购买
]]
local GD = _G.GD
local ChatModel = import("Model/ChatModel")

local RangeChip = UIMgr:NewUI("RangeChip")

import("UI/Casino/ItemRangeChip")
local CTR = {
    Normal = "Normal",
    High = "High"
}
local CTR_USE = {
    Have = "Have",
    No = "No"
}

function RangeChip:OnInit()
    local view = self.Controller.contentPane
    self._ctr = view:GetController("Ctr")
    self._ctrUse = view:GetController("CtrUse")

    self:AddListener(self._btnReturn.onClick,function()
        UIMgr:Close("RangeChip")
        Event.Broadcast(EventDefines.UIRangeTurntableData, self.casinoData)
        ChatModel:OpenCasinoRadio()
    end)
    self:AddListener(self._btnUse.onClick,function()
        self:OnBtnUseClick()
    end)
end

function RangeChip:OnOpen(from, casinoData)
    self.from = from
    self.casinoData = casinoData
    self._ctr.selectedPage = from
    ChatModel:CloseCasinoRadio()

    if from == CTR.Normal then
        self.items = GD.ItemAgent.GetItemsBysubType(PropType.ALL.Effect, Global.ResCasinoCounter)
        self.textNumI18n = "ShootingReward_5"
        self.textTipI18n = "ShootingReward_7"
    else
        self.items = GD.ItemAgent.GetItemsBysubType(PropType.ALL.Effect, Global.ResCasinoHyperCounter)
        self.textNumI18n = "ShootingReward_6"
        self.textTipI18n = "ShootingReward_8"
    end
    table.sort(self.items, function(a, b) return a.id < b.id end)

    self:UpdateData()
end

function RangeChip:SetDataCount(number)
    if self.from == CTR.Normal then
        self.casinoData.Counts = number
    else
        self.casinoData.HyperCounts = number
    end
end

function RangeChip:GetDataCount()
    if self.from == CTR.Normal then
        return self.casinoData.Counts
    else
        return self.casinoData.HyperCounts
    end
end

function RangeChip:GetChipImage()
    if self.from == CTR.Normal then
        return ConfigMgr.GetItem("configResourcess", Global.ResCasinoCounter).img
    else
        return ConfigMgr.GetItem("configResourcess", Global.ResCasinoHyperCounter).img
    end
end

function RangeChip:UpdateData()
    local number = self:GetDataCount()
    local values = {
        num = Tool.FormatNumberThousands(number)
    }
    self._text.text = StringUtil.GetI18n(I18nType.Commmon, self.textNumI18n, values)
    self._list.numItems = #self.items
    local isHave = false
    for i = 1, self._list.numChildren do
        if Model.Items[self.items[i].id] then
            isHave = true
        end
        self._list:GetChildAt(i - 1):Init(self.from, self.items[i], function(addNumber)
            self:SetDataCount(number + addNumber)
            self:UpdateData()
        end)
    end
    self._ctrUse.selectedPage = isHave and CTR_USE.Have or CTR_USE.No
end

--点击一键使用(高级)幸运币道具
function RangeChip:OnBtnUseClick()
    local number = self:GetDataCount()
    local itemAmounts = {}
    local addNumber = 0
    for _, v in pairs(self.items) do
        local item = Model.Items[v.id]
        if item then
            addNumber = addNumber + v.value * item.Amount
            table.insert(itemAmounts, item)
        end
    end
    local use_func = function()
        Net.Items.BatchUse(itemAmounts, function()
            self:SetDataCount(number + addNumber)
            self:UpdateData()
            TipUtil.TipById(50266)
        end)
    end
    local data = {
        icon = UITool.GetIcon(self:GetChipImage()),
        amount = Tool.FormatNumberThousands(addNumber),
        content = StringUtil.GetI18n(I18nType.Commmon, self.textTipI18n),
        sureCallback = use_func
    }
    UIMgr:Open("ResourceDisplayTips", data)
end

return RangeChip
