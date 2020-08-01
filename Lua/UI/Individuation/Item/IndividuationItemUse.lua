--author: 	Amu
--time:		2020-07-17 19:11:24
local GD = _G.GD
local DressUpModel = import("Model/DressUpModel")

local IndividuationItemUse = fgui.extension_class(GComponent)
fgui.register_extension("ui://Individuation/IndividuationItemUse", IndividuationItemUse)

function IndividuationItemUse:ctor()
    self._ctrView = self:GetController("c1")
    self._scheduler = false
    self:InitEvent()
end

function IndividuationItemUse:InitEvent()
    self:AddListener(self._btnUse.onClick,function()
        local curDressUp = DressUpModel.GetIsUsingByType(self.dressUpInfo.DressUpConId)
        if curDressUp then
            local curName = GD.ItemAgent.GetItemNameByConfId(self.dressUpInfo.ConfId)
            local info = DressUpModel.GetIsUsingByType(self.dressUpInfo.DressUpConId)
            local tip = StringUtil.GetI18n(I18nType.Commmon, "UI_Dressup_Tips2", 
                {dressup_name = curName, time = Tool.FormatTimeOfSecond(curDressUp.ExpireAt - Tool.Time())})
            local data = {
                content = tip,
                sureCallback = function()
                    DressUpModel.UseDressUp(self.dressUpInfo.ConfId, function(msg)
                    end)
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        else
            local config = ConfigMgr.GetItem("configItems", self.dressUpInfo.ConfId)
            local dressUpConfig = ConfigMgr.GetItem("configDressups", self.dressUpInfo.DressUpConId)
            local name = StringUtil.GetI18n(I18nType.Commmon, dressUpConfig.i18n_name)
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "UI_Dressup_Tips", 
                    {dressup_name = name, time = math.ceil(config.buff_expire/86400)}),
                sureCallback = function()
                    DressUpModel.UseDressUp(self.dressUpInfo.ConfId, function(msg)
                    end)
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
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
            self._timeText.text = ""
            return
        end
        self._timeText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Time_Later_Dressup", {time = TimeUtil.SecondToDHMS(time)})
    end
end


-- DressUpConId:80002599
-- ConfId:402199
-- Amount:0
-- ExpireAt:1595658005
-- Using:true
function IndividuationItemUse:SetData(dressUpInfo, index)
    self.dressUpInfo = dressUpInfo
    self._num.text = index
    if dressUpInfo.Amount <= 0 then
        self._textDec.text = GD.ItemAgent.GetItemNameByConfId(dressUpInfo.ConfId)
    else
        self._textDec.text = GD.ItemAgent.GetItemNameByConfId(dressUpInfo.ConfId).." x"..dressUpInfo.Amount
    end
    if dressUpInfo.DressUpConId == DressUpModel.usingDressUp[DressUpModel.curSelect].DressUpConId then
        self._ctrView.selectedIndex = 1
        self._endTime = dressUpInfo.ExpireAt
        self:StartCountDown()
    else
        self._ctrView.selectedIndex = 0
    end
end


function IndividuationItemUse:StartCountDown( )
    if not self._scheduler then
        self.callback()
        self:Schedule(self.callback, 1)
        self._scheduler = true
    end
end

function IndividuationItemUse:EndCountDown( )
    self:UnSchedule(self.callback)
    self._scheduler = false
end

return IndividuationItemUse