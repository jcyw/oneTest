--[[
    author:{author}
    time:2020-02-19 11:09:59
    function:{desc}
]]
local GuideLayer = UIMgr:NewUI("GuideLayer")
local NoviceModel = import("Model/NoviceModel")
function GuideLayer:OnInit()
    self._guide = UIMgr:CreateObject("Common", "Guide")
    self._view = self.Controller.contentPane
    self._view:AddChild(self._guide)
    self._view.sortingOrder = 9999
    self._arrowTop = self._guide:GetChild("arrowTop")
    self._c1 = self._view:GetController("c1")
    self._c1.selectedIndex = 0
    self._guideText.visible = false
    self._tipText.visible = false
    self._guideText:GetChild("text").text = StringUtil.GetI18n(I18nType.Commmon, "TIPS_OVERVIEW_OPEN")

    self:AddListener(
        self._touch.onTouchEnd,
        function()
            if Stage.inst.touchCount > 1 then
                return
            end
            if self.touchFunc and GlobalVars.IsNoviceGuideStatus == true and NoviceModel.GetCanSkipNovice() == true then
                self.touchFunc()
                NoviceModel.SetCanSkipNovice(false)
            end
        end
    )

    self:AddEvent(
        EventDefines.BuildingCenterUpgradeNovice,
        function()
            self.touchFunc()
            NoviceModel.SetCanSkipNovice(false)
        end
    )

    self:AddListener(
        self._box.onClick,
        function()
            if self.mTriggerFunc then
                self.mTriggerFunc()
            end
        end
    )
end

function GuideLayer:OnOpen(pos)
    self._c1.selectedIndex = 0
    self:SetTip(false)
    self._tipText.visible = false
    if not pos then
        return
    end
    self._guide:SetXY(pos.x, pos.y)
end

function GuideLayer:SetPos(pos)
    self._guide:SetXY(pos.x, pos.y)
end

function GuideLayer:SetTochView(callback)
    self._c1.selectedIndex = 1
    if callback then
        self.touchFunc = callback
    end
end

function GuideLayer:SetScale(scale)
    self._guide:SetScale(scale[1], scale[2])
    self._guide:SetArrowSize(1)
    self._guide:SetXY(self._guide.x + 25, self._guide.y + 25)
end

function GuideLayer:SetPointerScale(offset)
    self._guide:SetPointerScale(offset)
end

function GuideLayer:TriggerOnclick(callback)
    self.mTriggerFunc = callback
end

function GuideLayer:SetTip(isShow)
    self._guideText.visible = isShow
    if isShow then
        self._guideText.xy = Vector2(self._guide.x + self._guide.width / 2 + 40, self._guide.y + self._guide.height / 2)
    end
end

return GuideLayer
