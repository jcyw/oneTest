--author: 	Amu
--time:		2020-04-25 17:33:36

local BeautyGirlModel = import("Model/BeautyGirlModel")

local ItemBeautyReloading = fgui.extension_class(GComponent)
fgui.register_extension("ui://BeautySystem/itemBeautyReloading", ItemBeautyReloading)

function ItemBeautyReloading:ctor()
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")
    self._text = self:GetChild("text")
    self._textBg = self:GetChild("textBg")
    self:SetPivot(0.5, 0.5)
    self:InitEvent()
end

function ItemBeautyReloading:InitEvent()

end

function ItemBeautyReloading:SetData(info, curCostume, OwnCostumes, index)
    self._info = info
    self.index = index

    if BeautyGirlModel.Shield then
        self._icon.icon = UITool.GetIcon(self._info.sipneIconUrl)
    else
        self._icon.icon = UITool.GetIcon(self._info.clothing_picture)
    end
    if info.id == curCostume then
        self._textBg.visible = true
        self._text.visible = true
    else
        self._text.visible = false
        self._textBg.visible = false
    end
    local isHave = false
    for _,id in ipairs(OwnCostumes)do
        if info.id == id then
            isHave = true
            break
        end
    end
    if isHave then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Girl_Change_Cloth_Tips2")
    else
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Girl_Change_Cloth_Tips1")
    end
end

function ItemBeautyReloading:GetIndex(  )
    return self.index
end

return ItemBeautyReloading