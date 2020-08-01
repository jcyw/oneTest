local GD = _G.GD
local BackpackBox = _G.fgui.extension_class(_G.GButton)
_G.fgui.register_extension("ui://Common/itemBackpackPopupBox", BackpackBox)

local Tool = _G.Tool
local StringUtil = _G.StringUtil
local I18nType = _G.I18nType
local Event = _G.Event
local EventDefines = _G.EventDefines
local Global = _G.Global
local Model = _G.Model

function BackpackBox:ctor()
    self._arrow = self:GetChild("boxArrow")
    self._title = self:GetChild("title")
    self._text = self:GetChild("text")
    self._btnUse = self:GetChild("btnUse")
    self._btnDetails = self:GetChild("btnDetails")
    self._btnControl = self:GetController("btnControl")

    self.finishAt = 0
    self.title_timer_func = function()
        local time = self.finishAt - Tool.Time()
        if time > 0 then
            self._title.text = string.format("%s%s", self.titleName, StringUtil.GetI18n(I18nType.Commmon, "UI_TIME_CD_TEXT", {time = TimeUtil.SecondToDHMS(time)}))
        end
    end

    self:AddListener(self._btnUse.onClick,
        function()
            self._btnUseClick(self, self._data.id)
            Event.Broadcast(EventDefines.NextNoviceStep,1012)
            if self.triggerFunc then
                self.triggerFunc()
            end
        end
    )

    self:AddListener(self._btnDetails.onClick,
        function()
            self._btnDetailClick(self._config)
        end
    )
end

function BackpackBox:Init(data, parent, onUseBtnClick, onDetailBtnClick)
    self._data = data
    self._parent = parent
    self._btnUseClick = onUseBtnClick
    self._btnDetailClick = onDetailBtnClick
    self._config = data.config

    self.titleName = GD.ItemAgent.GetItemNameByConfId(data.id)
    self._text.text = GD.ItemAgent.GetItemDescByConfId(data.id)
    self._title.text = self.titleName

    local canUse, _, content = GD.ItemAgent.CheckItemLimit(self._config.id)
    if not canUse then
        self._title.text = self.titleName .. content
    end

    self:UnSchedule(self.title_timer_func)
    if data.config.id == Global.NewbieFlyCityItemID then
        self.finishAt = Model.Player.RookieExpireAt
        self.title_timer_func()
        self:Schedule(self.title_timer_func, 1)
    end

    if data.config.use ~= 0 then
        self._btnUse.visible = true
        --使用类型不同按钮标题不同
        if data.config.use == 1 then
            self._btnUse.title=StringUtil.GetI18n(I18nType.Commmon,"BUTTON_USE_ITEM")
        elseif data.config.use == 2 then
            self._btnUse.title=StringUtil.GetI18n(I18nType.Commmon,"Ui_Exchange")
        elseif data.config.use == 3 then
            self._btnUse.title=StringUtil.GetI18n(I18nType.Commmon,"BUTTON_MYITEM_COMPOSE")
        end
    else
        self._btnUse.visible = false
    end

    self._btnControl.selectedPage = "one"

    local curRow = parent.curData.index % parent.row
    if curRow == 1 then
        self._arrow:SetXY(94, 1)
    elseif curRow == 2 then
        self._arrow:SetXY(273, 1)
    elseif curRow == 3 then
        self._arrow:SetXY(455, 1)
    else
        self._arrow:SetXY(636, 1)
    end
end

-- --触发引导
function BackpackBox:TriggerOnclick(callback)
    self.triggerFunc = callback
end

return BackpackBox
