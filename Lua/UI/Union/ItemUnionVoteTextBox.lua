--author: 	Amu
--time:		2019-07-04 20:03:35

local ItemUnionVoteTextBox = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionVoteTextBox", ItemUnionVoteTextBox)

function ItemUnionVoteTextBox:ctor()
    self._textInput = self:GetChild("textInput")
    self._iconNo = self:GetChild("iconNo")
    self:AddListener(self._textInput.onChanged,function()
        self._textInput.text = string.gsub(self._textInput.text, "[\t\n\r[%]]+", "")
    end)

    -- self._textInput.restrict = '[A-Za-z0-9]'  --输入限制的正则表达式
    self:InitEvent()
end

function ItemUnionVoteTextBox:InitEvent()
    self:AddListener(self._iconNo.onClick,function()
        self._panel:DelItemText(self.index)
    end)
end

function ItemUnionVoteTextBox:SetData(index, panel)
    self.index = index
    self._panel = panel
end

function ItemUnionVoteTextBox:ShowX(flag)
    self._iconNo.visible = flag
end

function ItemUnionVoteTextBox:SetText(str)
    self._textInput.text = str
end

function ItemUnionVoteTextBox:GetText()
    return self._textInput.text
end

return ItemUnionVoteTextBox