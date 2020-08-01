local GMItemInput = fgui.extension_class(GButton)
fgui.register_extension('ui://GM/BtnInput', GMItemInput)

function GMItemInput:ctor()
    self._title = self:GetChild('title')
    self._text = self:GetChild('text')

    local _btnSure = self:GetChild('btnSure')
    _btnSure.title = '确定'
    self:AddListener(_btnSure.onClick,
        function()
            if self.callback then
                self.callback(self._text.text)
            end
        end
    )
end

function GMItemInput:init(callback, text)
    self.callback = callback
    self._text.promptText = text
end

return GMItemInput
