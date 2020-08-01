local GMItemLog = fgui.extension_class(GButton)
fgui.register_extension('ui://GM/textCmpt', GMItemLog)

function GMItemLog:ctor()
    self._title = self:GetChild('title')
    self._title.keyboardInput = false
end

function GMItemLog:Init(log)
    if not log then
        return
    end
    self._title.text = tostring(log)
    if string.find(log, "LuaException") then
        self._title.color = Color.red
    end
end

return GMItemLog
