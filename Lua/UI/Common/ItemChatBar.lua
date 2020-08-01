--[[
    author:Temmie
    time:2020-01-07 20:33:43
    function:聊天界面弹窗工具气泡
]]
local ItemChatBar = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemChatBar", ItemChatBar)

function ItemChatBar:ctor()
    self._controller = self:GetController("c1")

    self:AddListener(self._btnOne.onClick,function()
        if self.Func1 then
            self.Func1()
        end
    end)

    self:AddListener(self._btnTwo.onClick,function()
        if self.Func2 then
            self.Func2()
        end
    end)
end

function ItemChatBar:Init(type)
    self._controller.selectedIndex = type
    self._Func1 = nil
    self._Func2 = nil
end

function ItemChatBar:SetBtnOne(text, callback)
    self._textOne.text = text
    self._chatBgBox.width = self._btnOne.width + 26
    self.Func1 = callback
end

function ItemChatBar:SetBtnTwo(text, callback)
    self._textTwo.text = text
    self._chatBgBox.width = self._btnOne.width + self._btnTwo.width + 40
    self.Func2 = callback
end

return ItemChatBar
