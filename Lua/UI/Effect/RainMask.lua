--[[
    Author: songzeming
    Function: 雨天遮罩
]]
local RainMask = fgui.extension_class(GComponent)
fgui.register_extension("ui://Effect/RainMask", RainMask)

function RainMask:ctor()
    self.sortingOrder = 2
    self.x = -50
    self.width = GRoot.inst.width + 100
    self.height = GRoot.inst.height
    self.alpha = 0
end

function RainMask:Show(time)
    self:GtweenOnComplete(self:TweenFade(0.3, 1), function()
        self:GtweenOnComplete(self:TweenFade(0.3, time - 2), function()
            self:TweenFade(0, 1)
        end)
    end)
end

return RainMask
