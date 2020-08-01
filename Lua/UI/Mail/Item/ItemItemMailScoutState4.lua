--author: 	Amu
--time:		2019-06-28 16:39:53

local ItemItemMailScoutState4 = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemItemMailScoutState4", ItemItemMailScoutState4)


function ItemItemMailScoutState4:ctor()
    self._name = self:GetChild("textIconName1")
    self._num = self:GetChild("textIconNameNumber1")

    self:InitEvent()
end

function ItemItemMailScoutState4:InitEvent(  )
end

function ItemItemMailScoutState4:SetData(info, isAcc)
    self._name.text = ConfigMgr.GetI18n('configI18nArmys', math.ceil(info.ConfId)..'_NAME')
    if isAcc then
        self._num.text =  math.ceil(info.Amount)
    else
        self._num.text = "~".. math.ceil(info.Amount)
    end
end

return ItemItemMailScoutState4