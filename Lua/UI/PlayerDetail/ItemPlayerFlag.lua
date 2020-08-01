local ItemPlayerFlag = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/itemPlayerFlag", ItemPlayerFlag)

function ItemPlayerFlag:ctor()
end

function ItemPlayerFlag:SetData(info)
    self.info = info
    self._icon.icon = UITool.GetIcon(info.icon)
    self._name.text = info.language
end

function ItemPlayerFlag:SetLight(flag)
    self._light.visible = flag
end

function ItemPlayerFlag:GetIndex()
    return self.info.id
end

return ItemPlayerFlag