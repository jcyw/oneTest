--author: 	Amu
--time:		2019-06-28 11:13:05
local GD = _G.GD
local ItemItemMailScoutState1 = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemItemMailScoutState1", ItemItemMailScoutState1)

function ItemItemMailScoutState1:ctor()
    self._icon = self:GetChild("icon1")
    self._name = self:GetChild("textIconName1")
    self._num = self:GetChild("textIconNameNumber1")
    self._savenum = self:GetChild("textIconNameNumber2")

    self:InitEvent()
end

function ItemItemMailScoutState1:InitEvent(  )
end

function ItemItemMailScoutState1:SetData(info)
    -- local img = ConfigMgr.GetItem("configResourcess", info.Category).img
    if info.Category == 9 then
        return
    end
    self._icon.icon = GD.ResAgent.GetIconUrl(info.Category)--UIPackage.GetItemURL("Common", img)
    self._name.text = ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_"..math.ceil(info.Category))
    self._savenum.text = Tool.FormatAmountUnit(info.Amount)
end

function ItemItemMailScoutState1:SetUnCollectResAmount(num)
    self._num.text = Tool.FormatAmountUnit(num)
end

return ItemItemMailScoutState1