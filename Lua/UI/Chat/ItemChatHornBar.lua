--author: 	Amu
--time:		2019-07-18 15:48:38
local GD = _G.GD

local ItemChatHornBar = fgui.extension_class(GComponent)
fgui.register_extension("ui://Chat/itemChatHornBar", ItemChatHornBar)

ItemChatHornBar.tempList = {}

function ItemChatHornBar:ctor()
    self._checkBox = self:GetChild("checkBox")
    self._icon = self:GetChild("icon")
    self._text = self:GetChild("text")

    self:InitEvent()
end

function ItemChatHornBar:InitEvent()
    self._checkBox.asButton.selected = false
end

function ItemChatHornBar:SetData(info)
    self.info = info
    self.myItemInfo = GD.ItemAgent.GetItemModelById(info.id)
    self._icon.icon = UITool.GetIcon(info.icon)
    local name = GD.ItemAgent.GetItemNameByConfId(info.id)
    local num = 0
    if self.myItemInfo then
        num = self.myItemInfo.Amount
    end
    self.info.Amount = num
    self._text.text = StringUtil.GetI18n("configI18nCommons", "CHAT_HORN_LEFT", {name = name, amount = num})
end

function ItemChatHornBar:GetData()
    return self.info
end

function ItemChatHornBar:GetAmount()
    return self.info.Amount
end

function ItemChatHornBar:SetChoose(flag)
    self._checkBox.asButton.selected = flag
end

return ItemChatHornBar