--[[
    Author: songzeming
    Function: 靶场翻牌组件
]]
local RangeFlopCmpt = fgui.extension_class(GComponent)
fgui.register_extension('ui://Casino/cmptRangeFlop', RangeFlopCmpt)

import("UI/Casino/RangeFlop/RangeFlopCardBack")
local MAX_CARD = 9 --最多9张牌

function RangeFlopCmpt:ctor()
    self.anim = self:GetTransition("anim")
end

function RangeFlopCmpt:InitContext(ctx)
    self.ctx = ctx
    for i = 1, MAX_CARD do
        self["_card" .. i]:InitContext(self)
    end
    self:SetCardTouchable(true)
end

--未洗牌
function RangeFlopCmpt:InitNotShuffle(data)
    self.isShuffle = false
    for k, v in pairs(data.HyperGamblingInfo) do
        if k > MAX_CARD then
            Log.Error("ERROR 未洗牌 count:", #data.HyperGamblingInfo)
            return
        end
        local item = self["_card" .. k]
        item:InitData(data)
        item:InitFront(v)
    end
end

--洗过牌
function RangeFlopCmpt:InitShuffle(data)
    for k, _ in ipairs(data.HyperGamblingInfo) do
        if k > MAX_CARD then
            Log.Error("ERROR 洗过牌 count:", #data.HyperGamblingInfo)
            return
        end
        local item = self["_card" .. k]
        item:InitData(data)
        item:InitBack(k)
    end
    for _, v in ipairs(data.HyperGamblingInfo) do
        if v.Order > 0 then
            local item = self["_card" .. v.ShowIndex]
            item:InitFront(v)
        end
    end
end

--关闭界面
function RangeFlopCmpt:Close()
    if self.exit_func then
        self:UnSchedule(self.exit_func)
    end
end

--播放洗牌动画
function RangeFlopCmpt:PlayAnim(cb)
    for i = 1, MAX_CARD do
        self["_card" .. i]:SetBackVisible(true)
    end
    self.anim:Play(cb)
end

--暂停洗牌动画
function RangeFlopCmpt:StopAnim()
    self.anim:Stop()
end

--牌是否可触摸
function RangeFlopCmpt:SetCardTouchable(flag)
    for i = 1, MAX_CARD do
        self["_card" .. i].touchable = flag
    end
end

return RangeFlopCmpt
