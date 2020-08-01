--[[
    Author: xiaoze
    Function: 对话框
]]
local ItemDialog = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/ItemDialog", ItemDialog)

local Vector2 = _G.Vector2
local Model = _G.Model
local GlobalVars = _G.GlobalVars

function ItemDialog:ctor()
    self:AddListener(self.onClick, function()
        if self.clickCb and Model.Player.GuideFinished and not GlobalVars.IsTriggerStatus then
            self.clickCb()
        end
    end)
end

function ItemDialog:SetContent(text)
    self._text.text = text
end

function ItemDialog:SetVisible(isVisible)
    self.visible = isVisible
end

function ItemDialog:GetVisible()
    return self.visible
end

function ItemDialog:SetClickCb(clickCb)
    self.clickCb = clickCb
end

--大兵对话框
function ItemDialog:ShowSoldierDialog(text, time, soldier, cb)
    if not Model.Player.GuideFinished or GlobalVars.IsTriggerStatus then
        return
    end
    self:SetContent(text)

    self:UnSchedule(self.hideDialog)
    if self.refreshing then
        _G.GameUpdate.Inst():DelUpdate(self.refreshPos)
        self.refreshing = nil
    end
    
    self.refreshPos = function()
        self.xy = Vector2(soldier.x + 10, soldier.y - 10)
        self:SetVisible(true)
    end
    _G.GameUpdate.Inst():AddUpdate(self.refreshPos)
    self.refreshing = true

    self.hideDialog = function()
        _G.GameUpdate.Inst():DelUpdate(self.refreshPos)
        self.refreshing = nil

        self.visible = false
        if cb then
            cb()
        end
    end
    self:ScheduleOnce(self.hideDialog, time or 5)
end

return ItemDialog