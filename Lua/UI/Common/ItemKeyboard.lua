--[[
    Author: songzeming
    Function: 数字键盘弹窗
]]
local ItemKeyboard = fgui.extension_class(GComponent)
fgui.register_extension('ui://Common/itemKeyboard', ItemKeyboard)

function ItemKeyboard:ctor()
    for i = 0, 9 do
        self:AddListener(self["_btn" .. i].onClick,
            function()
                self.num = self.num * 10 + i
                self.num = self.num > self.max and self.max or self.num
                self._textNum.text = self.num
                if self.cbClick then
                    self.cbClick(self.num)
                end
            end
        )
    end
    self:AddListener(self._btnDelete.onClick,
        function()
            self.num = math.floor(self.num / 10)
            self._textNum.text = self.num
        end
    )
    self:AddListener(self._btnOK.onClick,
        function()
            if self.cb and self._textNum.text ~= "" then
                self.cb(self.num)
            end
            GRoot.inst:HidePopup()
        end
    )

    self:ResetData()
end

function ItemKeyboard:ResetData()
    self.max = 0
    self.num = 0
    self._textNum.text = ""
end

--max可以输入的最大值, 点击确定后的回调, 传回输入数字
function ItemKeyboard:Init(max, cb)
    self:ResetData()
    self.max = max
    self.cb = cb
end

--max可以输入的最大值, 点击数字时，刷新文本显示
function ItemKeyboard:InitClick(max, cb)
    self:ResetData()
    self.max = max
    self.cbClick = cb
end

return ItemKeyboard
