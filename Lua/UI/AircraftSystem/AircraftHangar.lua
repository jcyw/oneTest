--[[
    author:{laofu}
    time:2020-07-13 16:42:48
    function:{战机系统机库列表}
]]
local StringUtil = _G.StringUtil
local UITool = _G.UITool
local I18nType = _G.I18nType
local UIMgr = _G.UIMgr
local import = _G.import
local EventDefines = _G.EventDefines

local AircraftHangar = UIMgr:NewUI("AircraftHangar")
local PlaneModel = import("Model/PlaneModel")

function AircraftHangar:OnInit()
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_PLANE_TITLE")
    self._bannerIcon = self._banner:GetChild("icon")
    self._bannerTitle = self._banner:GetChild("title")
    self._bannerBg = self._banner:GetChild("iconBg")
    self._bannerBg.icon = UITool.GetIcon(GlobalBanner.PlaneBanner)
    PlaneModel.SetCollectDir()
    self:InitEvent()
end

function AircraftHangar:InitEvent()
    self:AddListener(
        self._btnClose.onClick,
        function()
            if self.triggerFunc then
                self.triggerFunc()
            end
            UIMgr:Close("AircraftHangar")
        end
    )

    self:AddListener(
        self._btnToShop.onClick,
        function()
            UIMgr:Open("AircraftAccessories")
            UIMgr:Close("AircraftHangar")
        end
    )

    self:AddListener(
        self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                info = StringUtil.GetI18n(I18nType.Commmon, "UI_PLANE_INFO")
            }
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )

    self:AddListener(
        self._banner.onClick,
        function()
            local luanchPlane = PlaneModel.GetLuanchPlane()
            if not luanchPlane then
                return
            end
            UIMgr:Open("AircraftDetails", luanchPlane, false)
        end
    )

    self._aircraftList.itemRenderer = function(index, item)
        if index == 0 then
            item:SetData(self.collectPlaneList, true)
        else
            item:SetData(self.planeList[index], false)
        end
    end

    self:AddEvent(
        EventDefines.RefreshHangarContent,
        function()
            self:RefreshContent()
        end
    )
end

function AircraftHangar:OnOpen()
    print("-------------------------------------->>>>打开战机界面")
    self:RefreshContent()
end

function AircraftHangar:RefreshContent()
    --启动飞机设置
    local luanchPlane = PlaneModel.GetLuanchPlane()
    if luanchPlane then
        self._bannerIcon.icon = UITool.GetIcon(luanchPlane.config.image)
        self._bannerTitle.text = StringUtil.GetI18n(I18nType.Commmon, luanchPlane.config.name)
    else
        self._bannerIcon.icon = nil
        self._bannerTitle.text = ""
    end
    --列表设置
    self.planeList = PlaneModel.GetPlaneList()
    self.collectPlaneList = PlaneModel.GetCollectPlaneList()
    self._aircraftList.numItems = #self.planeList + 1
end
function AircraftHangar:OnClose()
    print("-------------------------------------->>>>打开战机界面")
end

function AircraftHangar:TriggerOnclick(callback)
    self.triggerFunc = callback
end

return AircraftHangar
