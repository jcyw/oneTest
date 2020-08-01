--[[
    author:{laofu}
    time:2020-07-14 21:08:35
    function:{机库列表下拉框}
]]
local ItemAircraftComboBox = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://AircraftSystem/itemAircraftComboBox", ItemAircraftComboBox)

local BUTTONTYPE = {
    UP = 0,
    DOWN = 1
}

function ItemAircraftComboBox:ctor()
    self.c1 = self:GetController("c1")
    self._list = self:GetChild("list")
    self._bgBar = self:GetChild("tagBg")
    self._title = self:GetChild("title")
    self._btnArrow = self:GetChild("btnArrow")
    self.c1.selectedIndex = BUTTONTYPE.UP
    self:InitEvent()
end

function ItemAircraftComboBox:BtnOnClick()
    if not next(self.planeList) then
        TipUtil.TipById(50359)
        self.c1.selectedIndex = BUTTONTYPE.UP
        return
    end
    local buttonType = self.c1.selectedIndex == BUTTONTYPE.UP and BUTTONTYPE.DOWN or BUTTONTYPE.UP
    self:SetController(buttonType)
end

function ItemAircraftComboBox:InitEvent()
    self:AddListener(
        self._bgBar.onClick,
        function()
            self:BtnOnClick()
        end
    )

    self:AddListener(
        self._btnArrow.onClick,
        function()
            self:BtnOnClick()
        end
    )

    self._list.itemRenderer = function(index, item)
        item:SetData(self.planeList[index + 1], self.isCollect)
    end
end

function ItemAircraftComboBox:SetData(planeList, isCollect)
    if isCollect then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_PLANE_USUAL")
    else
        local planeInfo = planeList[#planeList]
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_PLANE_RANK_" .. (planeInfo.config.level - 1))
    end
    self.isCollect = isCollect
    self.planeList = planeList
    self:SetController(self.c1.selectedIndex)
end

--设置列表展开或者关闭
function ItemAircraftComboBox:SetController(buttonType)
    self.c1.selectedIndex = buttonType
    if buttonType == BUTTONTYPE.UP then
        self._list.alpha = 0
        self._list:ResizeToFit(0)
    elseif buttonType == BUTTONTYPE.DOWN then
        self._list.alpha = 1
        self._list.numItems = #self.planeList
        self._list:ResizeToFit(self._list.numItems)
    end
end

return ItemAircraftComboBox
