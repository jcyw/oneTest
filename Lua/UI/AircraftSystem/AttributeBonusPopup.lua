--[[
    author:{laofu}
    time:2020-07-17 15:15:33
    function:{属性弹窗}
]]
local AttributeBonusPopup = UIMgr:NewUI("AttributeBonusPopup")
local PlaneModel = import("Model/PlaneModel")

function AttributeBonusPopup:OnInit()
    self._btnStart.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_CHANGE_PLANE")
    self._iconBg.icon = UITool.GetIcon(GlobalBanner.PlaneBanner)
    self:AddListener(
        self._btnClose.onClick,
        function()
            UIMgr:Close("AttributeBonusPopup")
        end
    )
    self:AddListener(
        self._mask.onClick,
        function()
            UIMgr:Close("AttributeBonusPopup")
        end
    )

    self:AddListener(
        self._btnStart.onClick,
        function()
            --跳转飞机列表界面
            UIMgr:Open("AircraftHangar")
            UIMgr:Close("AttributeBonusPopup")
            UIMgr:Close("PlayerDetails")
        end
    )
end

function AttributeBonusPopup:OnOpen()
    if not PlaneModel.GetLuanchPlane() then
        --跳转飞机列表界面
        return
    end
    self.aircraftId = PlaneModel.GetLuanchPlane().Id
    self._addList:SetList(self.aircraftId)
    local planeInfo = PlaneModel.GetPlaneInfoById(self.aircraftId)
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, planeInfo.config.name)
    self._icon.icon = UITool.GetIcon(planeInfo.config.image)
end

return AttributeBonusPopup
