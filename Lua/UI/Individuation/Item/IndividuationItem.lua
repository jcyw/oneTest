--author: 	Amu
--time:		2020-07-10 15:07:30

local DressUpModel = import("Model/DressUpModel")

local IndividuationItem = fgui.extension_class(GButton)
fgui.register_extension("ui://Individuation/IndividuationItem", IndividuationItem)

function IndividuationItem:ctor()

    self._choseCtrView = self:GetController("button")
    self._nweCtrView = self:GetController("c1")
    self._hotCtrView = self:GetController("c2")
    self._useCtrView = self:GetController("c3")

    self:InitEvent()
end

function IndividuationItem:InitEvent()
    self:AddListener(self.onClick,function()
        if DressUpModel.curSubSelect ~= self._dressUpId then
            DressUpModel.curSubSelect = self._dressUpId
            Event.Broadcast(DRESSUP_EVENT.SubChoseChange, self._dressUpId)
        end

        Event.Broadcast(DRESSUP_EVENT.Chose, self._dressUpList)
    end)

    self:AddEvent(DRESSUP_EVENT.SubChoseChange, function(dressUpId)
        if dressUpId == self._dressUpId then
            self._choseCtrView.selectedIndex = 1
        else
            self._choseCtrView.selectedIndex = 0
        end
    end)

    self:AddEvent(DRESSUP_EVENT.Close, function()
        self:EndCountDown()
    end)

    self.callback = function()
        if not self._endTime then
            return
        end
        local time = self._endTime - Tool.Time()
        if time <= 0 then
            self:UnSchedule(self.callback)
            self._scheduler = false
            self._numText.text = ""
            return
        end
        self._numText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Time_Later_Dressup", {time = TimeUtil.SecondToDHMS(time)})
    end
end

function IndividuationItem:SetData(info)
    self._dressUpId = info.config.id
    self._icon.icon = UITool.GetIcon(info.config.style)
    self._dressUpList = DressUpModel.GetSelectDressUp(self._dressUpId)
    if info.config.default == 0 then
        self._numText.text = StringUtil.GetI18n(I18nType.Commmon, info.config.i18n_name)
    else
        self._numText.text = ""
    end

    -- if DressUpModel.curSubSelect == self._dressUpId then
    --     self._choseCtrView.selectedIndex = 1
    -- else
    --     self._choseCtrView.selectedIndex = 0
    -- end

    local using = false
    local _amount = 0
    local _isForever = false
    if self._scheduler then
        self:EndCountDown()
    else
        self._scheduler = false
    end
    for _,v in ipairs(self._dressUpList)do
        _amount = _amount + v.Amount
        if v.DressUpConId == DressUpModel.usingDressUp[DressUpModel.curSelect].DressUpConId then
            using = true
            DressUpModel.curSubSelect = self._dressUpId
        end

        print("================ ExpireAt: " .. v.ExpireAt)

        self._endTime = v.ExpireAt
        local time = v.ExpireAt - Tool.Time()
        if time > 0 and time < 622080000 then
            self:StartCountDown()
        elseif time > 622080000 and info.config.default ~= 0 then
            _isForever = true
            self._numText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Dressup_Permanent")
        end
    end
    if info.config.default ~= 0 and not self._scheduler and not _isForever then
        self._numText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Dressup_Remaining", {num = math.ceil(_amount)})
    end
    if using then
        self._useCtrView.selectedIndex = 1
        self._choseCtrView.selectedIndex = 1
    else
        self._useCtrView.selectedIndex = 0
        self._choseCtrView.selectedIndex = 0
    end
end

function IndividuationItem:StartCountDown( )
    if not self._scheduler then
        self.callback()
        self:Schedule(self.callback, 1)
        self._scheduler = true
    end
end

function IndividuationItem:EndCountDown( )
    self:UnSchedule(self.callback)
    self._scheduler = false
end

return IndividuationItem