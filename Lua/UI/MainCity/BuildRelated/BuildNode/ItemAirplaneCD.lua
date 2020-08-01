--[[
    Author: songzeming
    Function: 建筑 倒计时显示
]]
local ItemAirplaneCD = fgui.extension_class(GComponent)
fgui.register_extension("ui://Build/ItemAirplaneCD", ItemAirplaneCD)



function ItemAirplaneCD:ctor()
    self.SecondRefresh = function()
        if(self.overtimer)then
            if(self.overtimer >= Tool.Time()) then
                self._textTime.text = TimeUtil.SecondToHMS(self.overtimer - Tool.Time())
            else
                self.overtimer= nil
                --Event.Broadcast(EventDefines.SetFalconAirPlaneVisible,self.key)
                self.visible = false
            end
        end
    end
    self:Schedule(self.SecondRefresh , 1, true)
end

function ItemAirplaneCD:RefreshCD(overTimer)
    --print("RefreshCD overTimer " .. overTimer .."RefreshCD Tool.Time() " .. Tool.Time())
    self.overtimer = overTimer
    self.SecondRefresh()
end

function ItemAirplaneCD:setIndex(key)
    self.key = key
end

return ItemAirplaneCD
