--[[
    author:{zhanzhang}
    time:2019-06-17 15:33:37
    function:{采矿士兵详情}
]]

local TrainModel = import("Model/TrainModel")

local ItemSoldier = fgui.extension_class(GComponent)
fgui.register_extension("ui://WorldCity/itemCollectSoldier", ItemSoldier)

function ItemSoldier:ctor()
    self._icon = self:GetChild("icon")
    self._amount = self:GetChild("amount")
    self._title = self:GetChild("title")
end

function ItemSoldier:init(data)
    self._amount.text = data.Amount
    self._title.text = ConfigMgr.GetI18n("configI18nArmys", data.ConfId .. "_NAME")
    local config = ConfigMgr.GetItem("configArmys", data.ConfId)
    self._icon.icon = TrainModel.GetImageAvatar(data.ConfId)
end

return ItemSoldier
