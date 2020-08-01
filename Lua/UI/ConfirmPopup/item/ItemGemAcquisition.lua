local ItemGemAcquisition = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://ConfirmPopup/itemAcquisition", ItemGemAcquisition)
function ItemGemAcquisition:ctor()
    --获取部件
    self._btn= self:GetChild("btn")
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")

    --点击事件
    self.clickEvent = nil

    --事件
    self:AddListener(self._btn.onClick,
        --buff信息的显示隐藏
        function()
            if self.clickEvent then
                self.clickEvent()
            end
        end
    )
end
function ItemGemAcquisition:SetData(info)
    --self._icon._icon.url = _G.UITool.GetIcon(icon)
    self._icon:SetShowData(info.icon)
    self._title.text = info.name
    self.clickEvent = info.click
    if info.btnTxt then
        self._btn.text = info.btnTxt
    else
        self._btn.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon,"Setting_button_goto")
    end

end
return ItemGemAcquisition