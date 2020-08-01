--author: 	Amu
--time:		2020-03-11 20:51:26

local ItemBeautyIntroduce = fgui.extension_class(GComponent)
fgui.register_extension("ui://BeautySystem/itemBeautyIntroduce", ItemBeautyIntroduce)

function ItemBeautyIntroduce:ctor()
    self._textAge = self:GetChild("textAge")
    self._textPost = self:GetChild("textPost")
    self._textBirthday = self:GetChild("textBirthday")
    self._textHeight = self:GetChild("textHeight")
    self._textLike = self:GetChild("textLike")
    self._textDec = self:GetChild("textDec")

    self:InitEvent()
end

function ItemBeautyIntroduce:InitEvent()

end

function ItemBeautyIntroduce:SetData(grilInfo)
    self._grilInfo = grilInfo

    self._textAge.text = StringUtil.GetI18n("configI18nCommons", grilInfo.age)
    self._textPost.text = StringUtil.GetI18n("configI18nCommons", grilInfo.position)
    self._textBirthday.text = StringUtil.GetI18n("configI18nCommons", grilInfo.birth)
    self._textHeight.text = StringUtil.GetI18n("configI18nCommons", grilInfo.height)
    self._textLike.text = StringUtil.GetI18n("configI18nCommons", grilInfo.hobby)
    self._textDec.text = StringUtil.GetI18n("configI18nCommons", grilInfo.introduce)

end

return ItemBeautyIntroduce