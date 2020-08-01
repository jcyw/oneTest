--[[
    Author: songzeming
    Function: 触摸提示 按下显示 松开关闭
]]
local LongPressPopupIcon = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/LongPressPopupIcon", LongPressPopupIcon)

function LongPressPopupIcon:ctor()
end

function LongPressPopupIcon:InitIcon(icon, title, content)
    self.visible = true

    self._icon.icon = icon
    self._title.text = title
    self._content.text = content
end

function LongPressPopupIcon:SetArrowPosX(posx)
    self._arrow.x = posx
end

function LongPressPopupIcon:SetPos(posx, posy)
    if posx then
        self.x = posx
    end
    if posy then
        self.y = posy
    end
end

function LongPressPopupIcon:SetVisible(flag)
    self.visible = flag
end

return LongPressPopupIcon