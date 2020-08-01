--[[
    author:{zhanzhang}
    time:2019-07-01 20:23:54
    function:{联盟协作任务奖励item}
]]
local GD = _G.GD
local ItemUnionTaskReward = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionTaskReward", ItemUnionTaskReward)

function ItemUnionTaskReward:ctor()
end

function ItemUnionTaskReward:Init(data)
    local icon = nil
    local color = 0
    local amount = nil
    local mid = nil
    if (data.Category == 1) then
        icon = GD.ResAgent.GetIconInfo(data.ConfId)
        color = GD.ResAgent.GetIconQuality(data.ConfId)
        amount = data.Amount
    elseif (data.Category == 2) then
        --RewardTypeItem
        local cfg = ConfigMgr.GetItem("configItems", data.ConfId)
        icon = cfg.icon
        color = cfg.color
        amount = "x"..data.Amount
        mid = GD.ItemAgent.GetItemInnerContent(data.ConfId)
    else
        self._textNum.text = Tool.FormatAmountUnit(data.Amount)
    end
    self._itemProp:SetShowData(icon,color,nil,amount,mid)
end

-- 设置中间数量是否显示
function ItemUnionTaskReward:SetMiddleActive(flag)
    self._itemProp:SetMiddleActive(flag)
end

return ItemUnionTaskReward
