--[[
    Author: 站长
    Function: 建筑功能列表 图标按钮
]]
local ItemDetailBtn = fgui.extension_class(GButton)
fgui.register_extension("ui://WorldCity/btnBuildIcon", ItemDetailBtn)

function ItemDetailBtn:ctor()
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")
    self._num = self:GetChild("num")

    self:AddListener(self.onClick,
        function()
            self.callback()
        end
    )
end

function ItemDetailBtn:Init(name, img, callback)
    self.callback = callback
    self._title.text = name
    self._icon.icon = UITool.GetIcon(img)
    self._num.visible = false
end

function ItemDetailBtn:SetNumber(num)
    self._num.text = UITool.UBBTipGoldText(num)
    self._num.visible = true
end

function ItemDetailBtn:SetGray()
    self.grayed = true
end

function ItemDetailBtn:SetNormal()
    self.grayed = false
end

function ItemDetailBtn:GetText()
    return self._title.text
end

return ItemDetailBtn
