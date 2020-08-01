--[[
    Author: songzeming
    Function: 建筑 倒计时显示
]]
local AirplainFuelCD = fgui.extension_class(GComponent)
fgui.register_extension("ui://Build/AirplainFuelCD", AirplainFuelCD)
local  FuelNum = {"Zreo","One","Two","Three"}


function AirplainFuelCD:ctor()
   -- local view = self.Controller.contentPane
    self._Controller = self:GetController("NunController")
    self.SecondRefresh = function()
        if(Model.isFalconOpen)then
            if(Model.EagleHuntInfos.Fuel < 3) then
                self._text.text = TimeUtil.SecondToHMS(Model.EagleHuntInfos.FuelAddAt - Tool.Time())
            end
            self._title.text =StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FALCONCONSUME", {num = Model.EagleHuntInfos.Fuel})
            self._Controller.selectedPage = FuelNum[Model.EagleHuntInfos.Fuel+1]
            if(self.parentNote)then
                if Model.EagleHuntInfos.Fuel > 0 then
                    self.parentNote:AirplainAnim(true)
                else
                    self.parentNote:AirplainAnim(false)
                end
            end
        end
    end

    self:Schedule(self.SecondRefresh , 1, true)

    self:AddEvent(
        EventDefines.UIFalconDetectActvity,
        function()
            self.SecondRefresh()
        end
    )
end

function AirplainFuelCD:OnOpen()
    self.SecondRefresh()
end

function AirplainFuelCD:setParent(parent)
    self.parentNote = parent
end

return AirplainFuelCD
