--author: 	Amu
--time:		2020-05-08 20:34:11
local GD = _G.GD
local ItemMailUnion1 = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailUnion1", ItemMailUnion1)

function ItemMailUnion1:ctor()

    self._itemList = self:GetChild("itemList")

    self._authorText = self:GetChild("textTagName")
    self._timeText = self:GetChild("textTime")
    self._systemNameText = self:GetChild("textSystemName")
    self._describText = self:GetChild("textDescribe")

    self._textY = self._describText.y
    self._textH = self._describText.height


    self._H = self.height
    self._itemListH = self._itemList.height

    self:InitEvent()
end

function ItemMailUnion1:InitEvent(  )
end

function ItemMailUnion1:SetData(index, _info, panel, subType)
    self.info = _info
    self._panel = panel
    self.subType = subType

    self._authorText.text = self.info.Preview
    self._timeText.text = TimeUtil:GetTimesAgo(self.info.CreatedAt)
    self._systemNameText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_ SystemName")
    -- self.info.Subject
    self._describText.text = self.info.Content

    if #self.info.Rewards <= 0 then
        if self.subType == MAIL_SUBTYPE.subMailSubTypeNewPlayer then
            self._itemList.visible = true
        else
            self._itemList.visible = false
        end
    else
        self._itemList.visible = true
    end

    self:InitListView()
end

function ItemMailUnion1:InitListView()
    self._itemList:SetData(1, self.info, self._panel, self.subType)
    self._itemList.y = self._textY + self._describText.displayObject.height + 50

    self.height = self._H + self._describText.height - self._textH + self._itemList.height - self._itemListH
end

return ItemMailUnion1