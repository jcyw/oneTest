--[[
    Author: songzeming
    Function: 通用组件 道具使用或购买面板
]]
local GD = _G.GD
local LongItemDisplay = UIMgr:NewUI("LongItemBox/LongItemDisplay")

import("UI/Common/LongItemBox/LongItemBoxGray")

function LongItemDisplay:OnInit()
    self:AddListener(self._btnReturn.onClick,function()
        if self.data.cb then
            self.data.cb()
        end
        UIMgr:Close("LongItemBox/LongItemDisplay")
    end)
end

--[[
    data = {
        from 来自何方
        cb 回调
    }
]]
function LongItemDisplay:OnOpen(data)
    self.data = data

    self._list.numItems = 0
    self:UpdataData()
end

function LongItemDisplay:UpdataData()
    --列表展示
    local items = {}
    if self.data.from == CommonType.LONG_ITEM_BOX_DISPLAY.JointCommandUpgrade then
        --联合指挥部升级
        local item = Model.Items[GlobalItem.ItemUpgradeJointCommand]
        local amount = 0
        if item then
            amount = item.Amount
        end
        local confId, level = Global.BuildingJointCommand, 1
        for _, v in pairs(Model.Buildings) do
            if v.ConfId == Global.BuildingJointCommand then
                level = v.Level
                break
            end
        end
        local conf = ConfigMgr.GetItem("configBuildingUpgrades", confId + level)
        local values = {
            own_num = amount,
            need_num = conf.item.amount
        }
        self._textDesc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_GETMORE_ASSEMBLY", values)

        items = GD.ItemAgent.GetItemsBysubType(PropType.ALL.Gift, GlobalItem.ItemGiftJointCommand)
        self._list.numItems = #items
        for i = 1, self._list.numChildren do
            local child = self._list:GetChildAt(i - 1)
            child:Init(self.data.from, items[i], function()
                self:UpdataData()
            end)
        end
    end

    --列表刷新 是否可滑动
    self._list:EnsureBoundsCorrect()
    self._list.scrollPane.touchEffect = self._list.scrollPane.contentHeight > self._list.height
end

return LongItemDisplay
