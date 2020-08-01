local GD = _G.GD
local UITool = _G.UITool

local ItemAccessBackpack = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://AircraftSystem/itemAccessBackpack", ItemAccessBackpack)

local STATUS = {
    Normal = "normal",
    Occupy = "occupy",
    Waitcheck = "waitcheck",
    Check = "check"
}

function ItemAccessBackpack:ctor()
    self._status = self:GetController("status")
    self._iconBg= self:GetChild("iconBg")
    self._icon= self:GetChild("icon")
    self._textOccupy = self:GetChild("textOccupy")

    self.status = nil
    self.index = 1
end
--[[
    data.quality 零件品质
    data.icon 零件icon
    data.status 零件状态
]]
function ItemAccessBackpack:SetData(data)
    self._icon.icon = UITool.GetIcon(data.icon)
    self._iconBg.icon = GD.ItemAgent.GetItmeQualityByColor(data.quality)
    self:SetStatus(data.status)

    self.index = data.index
end
function ItemAccessBackpack:GetIndex()
    return self.index
end
function ItemAccessBackpack:SetWaitcheck()
    if self.status == STATUS.Occupy then
        return
    end
    self:SetStatus(STATUS.Waitcheck)
end
function ItemAccessBackpack:SetCheck()
    if self.status ~= STATUS.Waitcheck then
        return
    end
    self:SetStatus(STATUS.Check)
end
function ItemAccessBackpack:Ischeck()
    return self.status == STATUS.Check
end
function ItemAccessBackpack:IsOccupy()
    return self.status == STATUS.Occupy
end
function ItemAccessBackpack:SetStatus(status)
    if status == nil then
        status = not self.status and STATUS.Normal or self.status
    end
    if self.status == status then
        return
    end
    self.status = status
    self._status.selectedPage = status
end
function ItemAccessBackpack:SetOccupyTxt(txt)
    self._textOccupy.text = txt
end

return ItemAccessBackpack