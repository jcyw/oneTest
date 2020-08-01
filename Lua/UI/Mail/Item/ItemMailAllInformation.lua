--author: 	Amu
--time:		2020-04-08 11:06:37
local GD = _G.GD
local ItemMailAllInformation = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailAllInformation", ItemMailAllInformation)

function ItemMailAllInformation:ctor()
    self:InitEvent()
end

function ItemMailAllInformation:InitEvent()
end

function ItemMailAllInformation:SetData(info, index)
    self.info = info
    self.index = index
    self._member.text = #info
    self._title.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Class_R"..index)
    self._name.text = UnionModel.GetAppellation(index)
    self._checkBox.asButton.selected = false
end

function ItemMailAllInformation:GetIndex()
    return self.index
end

function ItemMailAllInformation:SetSeclect(flag)
    self._checkBox.asButton.selected = flag
end

return ItemMailAllInformation