--[[
    author:{zhanzhang}
    time:2020-04-23 10:14:00
    function:{王城UI}
]]
local ItemMapThroneUI = {}
local ActivityModel = import("Model/ActivityModel")

function ItemMapThroneUI:Init(index)
    local resInfos = ConfigMgr.GetItem("configWorldMapUIs", index)
    self.resList = {}
    self.tranSprite = GameUtil.CreateObj(resInfos.nodeSprite[1]).transform
    self.tranSprite:SetParent(WorldMap.Instance():GetNodeSprite(), false)

    self.tranTextName = GameUtil.CreateObj(resInfos.nodeText[1]).transform
    self.tranTextName:SetParent(WorldMap.Instance():GetNodeText(), false)

    -- self._imgIcon = self.tranSprite:Find("imgIcon"):GetComponent("Image")
    self._rectIcon = self.tranSprite:Find("imgIcon"):GetComponent("RectTransform")
    self._textDesc = self.tranTextName:GetComponent("Text")
    self._rectTextDesc = self._textDesc:GetComponent("RectTransform")
    self._contentFitter = self._textDesc:GetComponent("ContentSizeFitter")

    self._countDownObj = GameUtil.CreateObj("prefabs/worldmapui/nodesprite/royalcountdowntime")
    self._countDownObj.transform:SetParent(WorldMap.Instance():GetNodeSprite(), false)
    local mTransform = self._countDownObj.transform
    self._textTip = mTransform:Find("textProtect"):GetComponent("Text")
    self._textCountDown = mTransform:Find("textCountDown"):GetComponent("Text")
    self._contentFitterTips = self._textTip:GetComponent("ContentSizeFitter")
    self._textRect = self._textTip:GetComponent("RectTransform")
    self._textCountDownTransf = mTransform:Find("textCountDown"):GetComponent("RectTransform")
    self._textTipTransf = mTransform:Find("textProtect"):GetComponent("RectTransform")
    self._bgRect = mTransform:Find("bg"):GetComponent("RectTransform")
    self.offsetVec = CVector3(602, 0, 602)
    self.OffsetOut = CVector3(10000,10000,10000)

    Event.AddListener(
        EventDefines.RoyalBattleActivity,
        function()
            local isOpen = ActivityModel.IsRoyalBattleOpen()
            if isOpen then 
            else
            end
        end
    )
    Event.AddListener(
        EventDefines.KingInfoChange,
        function()
            if self.item then
                self:RefreshUI()
            end
        end
    )
end

function ItemMapThroneUI:Refresh(pos,item)
    self.posNum = pos
    self.item = item
    self.tranSprite.position = pos + self.offsetVec
    self.tranTextName.position = pos + self.offsetVec
    self._countDownObj.transform.position = pos + self.offsetVec
    self:RefreshUI()
end
function ItemMapThroneUI:RefreshUI()
    local warInfo = _G.RoyalModel.GetKingWarInfo()
    self.nextTime = warInfo.NextTime
    self.inWar = warInfo.InWar
    self.OwnerId = self.item.OwnerId
    self.AllianceId = ""

    local OwerInfo = MapModel.GetMapOwner(self.item.OwnerId)
    local hasUser = _G.RoyalModel.warInfo and _G.RoyalModel.warInfo.KingInfo
    hasUser = hasUser and string.len(_G.RoyalModel.warInfo.KingInfo.PlayerId)>0
    if not hasUser and not warInfo.InWar then
         self._textDesc.text = StringUtil.GetI18n(I18nType.Commmon, "UI_THRONEWAR_BEGIN")
     elseif not hasUser and  warInfo.InWar then
         self._textDesc.text =  StringUtil.GetI18n(I18nType.Commmon, "UI_Warzone_Competing")
     elseif hasUser then
        
        if OwerInfo then
             local str = string.len(OwerInfo.Alliance)>0 and  "[" .. OwerInfo.Alliance .. "]" or ""
             self._textDesc.text = str .. OwerInfo.Name
             self.OwnerId = OwerInfo.UserId
             self.AllianceId = OwerInfo.AllianceId
         else
             local str = string.len(warInfo.KingInfo.AllianceShortName)>0
             and "[" .. warInfo.KingInfo.AllianceShortName .. "]" or ""
             self._textDesc.text = str .. warInfo.KingInfo.Name
             self.OwnerId = warInfo.KingInfo.PlayerId
             self.AllianceId = warInfo.KingInfo.AllianceId
         end
    end
    self._contentFitter:SetLayoutHorizontal()
    self._rectIcon.sizeDelta = CVector2(self._rectTextDesc.rect.width + 15, self._rectIcon.sizeDelta.y)

    self._textTip.text = not self.inWar
    and StringUtil.GetI18n(I18nType.Commmon, "Ui_WarZone_Peace")
    or StringUtil.GetI18n(I18nType.Commmon, "Ui_WarZone_Warfire")
    if not self.refreshTime then
         self.refreshTime = function()
             self._textCountDown.text = TimeUtil.SecondToDHMS(self.nextTime - Tool.Time())
         end
         Scheduler.Schedule(self.refreshTime, 1, true)
    end
    self._contentFitterTips:SetLayoutHorizontal()
    --self._bgRect.sizeDelta = CVector2(self._textRect.rect.width + 30, self._bgRect.sizeDelta.y)
    if(self._textCountDownTransf.rect.width > self._textTipTransf.rect.width) then
        self._bgRect.sizeDelta = CVector2(self._textCountDownTransf.rect.width + 15,self._bgRect.rect.height)
    else
        self._bgRect.sizeDelta = CVector2(self._textTipTransf.rect.width + 15,self._bgRect.rect.height)
    end
    self._bgRect.sizeDelta = CVector2(self._textRect.rect.width + 30, self._bgRect.sizeDelta.y)
    self:RefreshTextColor()
end

function ItemMapThroneUI:RefreshTextColor()
    if self.OwnerId == Model.Account.accountId then
        self._textDesc.color = ColorType.Yellow
    elseif self.AllianceId == Model.Player.AllianceId and string.len(self.AllianceId)>0 then
        self._textDesc.color = ColorType.Blue
    else
        self._textDesc.color = ColorType.White
    end
end

function ItemMapThroneUI:OnClose()
    Scheduler.UnSchedule(self.refreshTime)
    self.refreshTime = nil

    self.tranSprite.position = self.OffsetOut
    self.tranTextName.position = self.OffsetOut
end

return ItemMapThroneUI
