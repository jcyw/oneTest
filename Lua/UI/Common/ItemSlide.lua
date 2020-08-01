--[[
    Author: songzeming
    Function: 通用组件 滑动条
]]
local ItemSlide = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemSlide", ItemSlide)

import("UI/Common/ItemKeyboard")

--建筑队列控制器
local CTR = {
    Normal = "Normal", --通用
    Army = "Army", --士兵相关
    CureArmy = "CureArmy", --医院治疗士兵
    Lookup = "Lookup"
}

function ItemSlide:ctor()
    self._controller = self:GetController("Controller")

    local function cb(num)
        if num < self.min then
            num = self.min
        end
        self:SetNumber(num)
        self:OnCallback()
    end
    self:AddListener(self._btnInput.onClick,
        function()
            local _keyboard = UIMgr:CreatePopup("Common", "itemKeyboard")
            _keyboard:Init(self.max, cb)
            UIMgr:ShowPopup("Common", "itemKeyboard", self._btnAdd)
        end
    )
    self:AddListener(self._btnAdd.onClick,
        function()
            self:OnSlide(1)
        end
    )
    self:AddListener(self._btnDel.onClick,
        function()
            self:OnSlide(-1)
        end
    )
    self:AddListener(self._slide.onChanged,
        function()
            self:OnSlide()
        end
    )
    self._slide.value = -1 --防止初始化时设置不了值
end

--[[
    min = 滑动显示最小值 一般为0或1 [必传]
    max = 滑动显示最大值 [必传]
    cb = 滑动条值变化回调 [可不传]
]]
function ItemSlide:Init(type, min, max, cb)
    self.max = max
    self.min = min
    self.cb = cb

    self._controller.selectedPage = type
    -- self._slide.touchable = max > 0
    self:SetNumber(0)
    self:SetInputTouchable(true)
    if type == CTR.CureArmy then
        self._textTotal.text = "/" .. Tool.FormatNumberThousands(self.max)
    elseif type == CTR.Lookup then
        self._textTotal.text = "/" .. self.max
    end
end

--设置滑动提示 [主要用于滑动最大值为0时 操作+-提示]
function ItemSlide:SlideTip(cb)
    self.cbTip = cb
end

--获取滑动数量
function ItemSlide:GetNumber()
    return math.floor(self._text.text)
end

--设置滑动数量
function ItemSlide:SetNumber(number)
    if number < self.min then
        number = self.min
    end
    self._text.text = number
    self._slide.value = number / self.max * 100
end

--设置输入框是否可以点击
function ItemSlide:SetInputTouchable(flag)
    self._btnInput.touchable = flag
end

--滑动条值变化回调
function ItemSlide:OnCallback()
    if not self.cb then
        return
    end
    self.cb()
end

--滑动条最大值设置 并刷新显示
function  ItemSlide:SetMaxNumber(number)
    self.max = number
    self._textTotal.text = "/" .. self.max
end

--兵种数量变化滑动条显示
function ItemSlide:OnSlide(dir)
    if not self.max or self.max == 0 then
        if self.cbTip then
            self.cbTip()
        end
        return
    end
    if dir then
        --点击箭头增减
        local num = self:GetNumber() + dir
        if num < 0 then
            num = 0
        end
        if num > self.max then
            num = self.max
        end
        self:SetNumber(num)
    else
        --手动拖动滑动条
        local num = math.floor(self.max * self._slide.value / 100)
        if num < self.min then
            num = self.min
        end
        self._text.text = num
    end
    self:OnCallback()
end

return ItemSlide
