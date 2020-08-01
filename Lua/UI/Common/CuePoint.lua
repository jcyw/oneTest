--[[
    Author: songzeming
    Function: 红点提示
]]
local CuePoint = fgui.extension_class(GComponent)
fgui.register_extension('ui://Common/CuePoint', CuePoint)

local CTR = {
    Red = "Red", --红点
    RedNumber = "RedNumber", --红点 带数字
    GreenNumber = "GreenNumber", --绿色
    Warning = "Warning", --感叹号
    N = "N"
}
local function get_number(n)
    if not n or n <= 0 then
        return ""
    end
    return n > 99 and "99+" or n
end

function CuePoint:ctor()
    self._ctr = self:GetController("Ctr")
    self.pivotAsAnchor = true
    self.pivot = Vector2(0.5, 0.5)

    --TODO 临时
    self:GetChild("Warning").text = "!"
    --self:GetChild("N").text = "N"
end

--显示红点
function CuePoint:ShowRed()
    self._ctr.selectedPage = CTR.Red
end

--显示红点 带数字
function CuePoint:ShowRedNumber(number)
    self._ctr.selectedPage = CTR.RedNumber
    self._numberGreen.text = get_number(number)
end

--显示绿点
function CuePoint:ShowGreenNumber(number)
    self._ctr.selectedPage = CTR.GreenNumber
    self._numberGreen.text = get_number(number)
end

--显示感叹号
function CuePoint:ShowWarning()
    self._ctr.selectedPage = CTR.Warning
end

--显示N
function CuePoint:ShowN()
    self._ctr.selectedPage = CTR.N
end

return CuePoint