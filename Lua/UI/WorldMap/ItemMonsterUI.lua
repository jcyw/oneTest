--[[
    author:{zhanzhang}
    time:2020-04-08 13:53:59
    function:{function}
]]
local ItemMonsterUI = {}

function ItemMonsterUI:ctor()
end

function ItemMonsterUI:OnRegister()
end
--index 100003
function ItemMonsterUI:Init(index)
    local resInfos = ConfigMgr.GetItem("configWorldMapUIs", index)
    self.resList = {}
    self.tranSprite = GameUtil.CreateObj(resInfos.nodeSprite[1]).transform
    self.tranTextLevel = GameUtil.CreateObj(resInfos.nodeText[1]).transform
    self.tranTextName = GameUtil.CreateObj(resInfos.nodeText[2]).transform
    table.insert(self.resList, self.tranSprite)
    table.insert(self.resList, self.tranTextLevel)
    table.insert(self.resList, self.tranTextName)
    self.tranSprite:SetParent(WorldMap.Instance():GetNodeSprite(), false)
    self.tranTextLevel:SetParent(WorldMap.Instance().NodeTextYellow, false)
    self.tranTextName:SetParent(WorldMap.Instance():GetNodeText(), false)
end

function ItemMonsterUI:Refresh(areaId, position)
    local area = MapModel.GetArea(areaId)
    if not area then
        return
    end

    local info = ConfigMgr.GetItem("configMonsters", area.ConfId)
    if info.type ~= 1 and info.type ~= 2 then
        self.tranSprite:Find("imgBg").gameObject:SetActive(false)
        self.tranSprite:Find("imgBg2").gameObject:SetActive(true)
        self.tranImgBgWithName = self.tranSprite:Find("imgBg2").transform
        self.tranImgBgWithLevel = self.tranImgBgWithName:Find("iconBg").transform
        self._rectImgBg = self.tranSprite:Find("imgBg2"):GetComponent("RectTransform")
        self._imgIconBg = self.tranImgBgWithLevel:GetComponent("Image")
        self._textLevel = self.tranTextLevel:GetComponent("Text")
        self._textName = self.tranTextName:GetComponent("Text")
        self._contentFiler = self._textName:GetComponent("ContentSizeFitter")
        self._rectName = self._textName:GetComponent("RectTransform")
    else
        self.tranSprite:Find("imgBg").gameObject:SetActive(true)
        self.tranSprite:Find("imgBg2").gameObject:SetActive(false)
        self.tranImgBgWithName = self.tranSprite:Find("imgBg").transform
        self.tranImgBgWithLevel = self.tranImgBgWithName:Find("iconBg").transform
        self._rectImgBg = self.tranSprite:Find("imgBg"):GetComponent("RectTransform")
        self._imgIconBg = self.tranImgBgWithLevel:GetComponent("Image")
        self._textLevel = self.tranTextLevel:GetComponent("Text")
        self._textName = self.tranTextName:GetComponent("Text")
        self._contentFiler = self._textName:GetComponent("ContentSizeFitter")
        self._rectName = self._textName:GetComponent("RectTransform")
    end
    self._textLevel.text = info.level

    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_" .. info.id)
    self._textName.color = Color(213/255,224/255,224/255)
    self._contentFiler:SetLayoutHorizontal()

    self._rectImgBg.sizeDelta = CVector2(self._rectName.rect.width + 72, self._rectImgBg.sizeDelta.y)

    self.tranSprite.position = position
    self.tranTextLevel.position = self.tranImgBgWithLevel.position - CVector3(0.085, 0, -0.085)
    self.tranTextName.position = self.tranImgBgWithName.position
    --self.tranTextName.transform.localPostion = CVector3(self.tranTextName.transform.localPostion.x + 11, self.tranTextName.transform.localPostion.y, self.tranTextName.transform.localPostion.z)
end

function ItemMonsterUI:OnClose()
    for i = 1, #self.resList do
        self.resList[i].position = CVector3.one * 1000
    end
end

function ItemMonsterUI:InitTrans()
    for i = 1, #self.resList do
        local temp = self.resList[i]
        temp.localScale = CVector3.one
        temp.localEulerAngles = CVector3.zero
    end
end

return ItemMonsterUI
