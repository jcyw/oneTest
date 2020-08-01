--[[
    author:{maxiaolong}
    time:2019-09-23 19:22:01
    function:{停机坪时间显示按钮}
]]
local ItemReadBar = fgui.extension_class(GComponent)
fgui.register_extension("ui://Build/itemReadBar", ItemReadBar)

function ItemReadBar:OpenMainOnlineGift()
    if not self._lineBonusList then
        return
    end
    UIMgr:Open("MainOnlineCheckInAward", self._lineBonusList)
end

function ItemReadBar:ctor()
    self._timerText = self:GetChild("_textTime")
    self._lineBonusList = Model.GetMap(ModelType.OnlineBonusList)
    self.bounsCount = not self._lineBonusList and 0 or #self._lineBonusList
    self:AddEvent(
        EventDefines.OnlineGiftOpen,
        function()
            self:OpenMainOnlineGift()
        end
    )
    self:AddListener(self.onClick,
        function()
            self:OpenMainOnlineGift()
        end
    )
end

--设置计时器时间以及显隐
function ItemReadBar:SetTimerValue(data)
    self:UnSchedule(self.timeFunc)
    self.nextTime =  Model.NextBonusTime
    local function get_time()
        if self.bounsCount>Model.OnlineBonusTime then
            return self.nextTime - Tool.Time()
        else
            local resetTime = Tool.Time() - Tool.Time()%86400 + 86400
            return resetTime - Tool.Time()
        end
    end
    Event.Broadcast(EventDefines.UIOnLineIcon, get_time())
    if get_time() > 0 then
        self:SetShow(true)
        local barFunc = function()
            local t = get_time()
            self.curTime = t
            self._timerText.text = Tool.FormatTime(t)
            Event.Broadcast(EventDefines.UIOnLineIcon, self.curTime)
        end
        barFunc()
        self.timeFunc = function()
            if get_time() >= 0 then
                barFunc()
                return
            else
                barFunc(0)
                Event.Broadcast(EventDefines.UIGiftFinish,true)
            end
        end
        self:Schedule(self.timeFunc, 1)
    end
end

function ItemReadBar:SetShow(isShow)
    self.visible = isShow
    if isShow then
        return
    end
    if self.timeFunc then
        self:UnSchedule(self.timeFunc)
    end
end

return ItemReadBar
