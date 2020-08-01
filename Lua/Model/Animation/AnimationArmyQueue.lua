--[[
    Author: songzeming
    Function: 训练士兵队列缓存
]]
local AnimationArmyQueue = {}

local AnimationArmy = import("Model/Animation/AnimationArmy")

local armies = {}

local GlobalVars = GlobalVars

--在队列尾部插入一个元素
function AnimationArmyQueue:Push(args)
    --if not GlobalVars.IsShowEffect() then
    --    --低端机不显示
    --    return
    --end
    local id = args.building.ConfId
    if armies[id] == nil then
        armies[id] = {
            isQueue = false,
            objs = {}
        }
    end
    table.insert(armies[id].objs, args)

    if not armies[id].isQueue then
        self:Pop(id)
    end
end

--将队列中最靠前位置的元素拿掉（剔除）
function AnimationArmyQueue:Pop(id)
    if self:Empty(id) then
        return
    end
    --打开弹窗
    armies[id].isQueue = true
    local objs = armies[id].objs
    local army = objs[1]
    AnimationArmy.PlayTrainCollectAnim(army.building, army.amount, army.confId, function()
        self:PopCb(id)
    end)
    table.remove(armies[id].objs, 1)
end

--收集完成回调
function AnimationArmyQueue:PopCb(id)
    if self:Empty(id) then
        armies[id].isQueue = false
    else
        self:Pop(id)
    end
end

--判断队列是否为空
function AnimationArmyQueue:Empty(id)
    return not armies[id] or next(armies[id].objs) == nil
end

function AnimationArmyQueue:Clear()
    for _, v in pairs(armies) do
        v.isQueue = false
        v.objs = {}
    end
end

return AnimationArmyQueue
