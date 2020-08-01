--[[
    author:{zhanzhang}
    time:2019-06-26 10:31:22
    function:{雷达界面（攻击预警）}
]]
local Radar = UIMgr:NewUI("Radar")
local RadarModel = import("Model/RadarModel")

function Radar:OnInit()
    -- body
    local view = self.Controller.contentPane
    self._view=view
    self._btnReturn = view:GetChild("btnReturn")
    self._btnIgnore = view:GetChild("btnIgnore")
    self._contentList = view:GetChild("liebiao")
    self._btnHelp = view:GetChild("btnHelp")
    self._controller = view:GetController("c1")

    self:OnRegister()
end

function Radar:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("Radar")
        end
    )
    self:AddListener(self._btnIgnore.onClick,
        function()
            self:IgnoreAll()
        end
    )
    self:AddListener(self._btnHelp.onClick,
        function()
            UIMgr:Open(
                "ConfirmPopupTextList",
                {title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"), info = StringUtil.GetI18n(I18nType.Commmon, "Radar_Explain")}
            )
        end
    )
    ---行军抵达刷新
    self:AddEvent(
        EventDefines.UIOnRadarItemArrived,
        function()
            self:OnOpen()
        end
    )
    --刷新报警状态
    self:AddEvent(
        EventDefines.UIOnRadarTipRefresh,
        function()
            local isWarning = RadarModel.CheckWarning()
            self._controller.selectedIndex = isWarning and 0 or 1
        end
    )
    --刷新事件
    self:AddEvent(
        EventDefines.UIOnRaderEvent,
        function()
            self:OnOpen()
        end
    )
end
function Radar:OnOpen()
    self._contentList:RemoveChildrenToPool()
    local list = RadarModel.GetList()
    local isWarn = false
    for i = 1, #list do
        if list[i].Category ~= Global.MissionAssit and not list[i].Ignore then
            isWarn = true
        end
    end

    local count = #list
    if count == 0 then
        self._controller.selectedIndex = 1
    else
        self._controller.selectedIndex = 0
    end
    for i = 1, count do
        local item = self._contentList:AddItemFromPool()
        item:Init(list[i])
    end
end
--忽略所有预警
function Radar:IgnoreAll()
    Net.Missions.IgnoreAllWarning(
        true,
        function(val)
            RadarModel.IgnoreAll()
            -- self._controller.selectedIndex = 1
        end
    )
end
--检测警报
function Radar:CheckWarning()
    local isWarn = RadarModel.CheckWarning()
    self._btnIgnore.visible = isWarn
    self._mask.visible = isWarn
end

return Radar
