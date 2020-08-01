--[[
    Author: Baggio-Wang
    Function: UI界面基类
    Date: 2019-12-26 20:45:36
]]
local Register = import("Common/Register")
local BaseUI = setmetatable({}, {__index = Register})

function BaseUI:OnInit()
    self:InitRegister(self.name)
end

function BaseUI:OnOpen()
end

function BaseUI:OnClose()
end

function BaseUI:OnDispose()
    self:DisposeRegister()
end

return BaseUI