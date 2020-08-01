--[[
    author:{tiantian}
    time:2020-06-29 11:33:00
    function:{炮台UI}
]]
local ItemMapFortUI = {}

function ItemMapFortUI:Init(index)
    local resInfos = ConfigMgr.GetItem("configWorldMapUIs", index)
    self.tranSprite = GameUtil.CreateObj(resInfos.nodeSprite[1]).transform 
    self.tranSprite:SetParent(WorldMap.Instance():GetNodeSprite(), false)

    self.tranTextName = GameUtil.CreateObj(resInfos.nodeText[1]).transform
    self.tranTextName:SetParent(WorldMap.Instance():GetNodeText(), false)

    self._rectIcon = self.tranSprite:Find("imgIcon"):GetComponent("RectTransform")
    self._textDesc = self.tranTextName:GetComponent("Text")
    self._rectTextDesc = self._textDesc:GetComponent("RectTransform")
    self._contentFitter = self._textDesc:GetComponent("ContentSizeFitter")

    self.OffsetOut = CVector3(10000,10000,10000)
end


function ItemMapFortUI:Refresh(pos,item)
    local OwerInfo = MapModel.GetMapOwner(item.OwnerId)
    if OwerInfo then
        local str = string.len(OwerInfo.Alliance)>0 and  "[" .. OwerInfo.Alliance .. "]" or ""
        self._textDesc.text = str .. OwerInfo.Name
        self.tranSprite.position = pos
        self.tranTextName.position = pos
    else
        self.tranSprite.position = self.OffsetOut
        self.tranTextName.position = self.OffsetOut
    end

    self._contentFitter:SetLayoutHorizontal()
    self._rectIcon.sizeDelta = CVector2(self._rectTextDesc.rect.width + 15, self._rectIcon.sizeDelta.y)
    self:RefreshTextColor(OwerInfo)
end

function ItemMapFortUI:RefreshTextColor(OwerInfo)
    if OwerInfo and OwerInfo.UserId == Model.Account.accountId then
        self._textDesc.color = ColorType.Yellow
    elseif OwerInfo and OwerInfo.AllianceId == Model.Player.AllianceId and string.len(OwerInfo.AllianceId)>0 then
        self._textDesc.color = ColorType.Blue
    else
        self._textDesc.color = ColorType.White
    end
end

function ItemMapFortUI:OnClose()
    self.tranSprite.position = self.OffsetOut
    self.tranTextName.position = self.OffsetOut
end

return ItemMapFortUI