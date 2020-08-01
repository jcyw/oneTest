--[[
    Author: songzeming
    Function: 举报玩家item
]]
local ItemPlayerComplaintBox = fgui.extension_class(GComponent)
fgui.register_extension("ui://PlayerDetail/itemPlayerComplaintBox", ItemPlayerComplaintBox)

function ItemPlayerComplaintBox:ctor()
    self._check.touchable = false
    self:AddListener(self.onClick,
        function()
            if self:GetChoose() then
                self:SetChoose(false)
            else
                self.cb()
            end
        end
    )
end

function ItemPlayerComplaintBox:Init(title, cb)
    self.cb = cb
    self._title.text = title
    self:SetChoose(false)
end

function ItemPlayerComplaintBox:SetChoose(flag)
    self._check.selected = flag
end

function ItemPlayerComplaintBox:GetChoose()
    return self._check.selected
end

return ItemPlayerComplaintBox
