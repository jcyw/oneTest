local GMItemBtn = fgui.extension_class(GButton)
fgui.register_extension("ui://GM/Button", GMItemBtn)

function GMItemBtn:ctor()
    self:AddListener(self.onClick,
        function()
            if self.callback then
                self.callback()
            end
        end
    )
end

function GMItemBtn:init(callback)
    self.callback = callback
end

return GMItemBtn
