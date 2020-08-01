--[[
    Author: songzeming
    Function: 兵种动画
]]
--数值
local ParadeSquareModel = {}

local ArmyPool = import("Model/Animation/ArmyPool")

local ArmyId = {
    107000,
    107100,
    107200,
    107300
}
local ParadeSquareNode = nil
local ParadeSquareSubAmount = {0, 0, 0, 0}
local ShowState = false
local GlobalVars = GlobalVars

function ParadeSquareModel.InitParadeSquare(ctx)
    --if not GlobalVars.IsShowEffect() then
    --    --低端机不显示
    --    return
    --end
    --初始化士兵父节点
    ParadeSquareNode = ctx[CityType.CITY_MAP_NODE_TYPE.ParadeSquare.name]
    for _, v in pairs(ArmyId) do
        local node = UIMgr:CreateObject("Common", "blankNode")
        node.name = "army" .. v
        node.xy = Vector2.zero
        ParadeSquareNode:AddChild(node)
    end
    --阅兵广场士兵显示
    CSCoroutine.Start(function()
        coroutine.yield(UIMgr:AddPackage("MarchAnimation"))
        ShowState = true
        ParadeSquareModel.ParadeSquareShow()
    end)

    Event.AddListener(
        EventDefines.UIArmiesRefresh,
        function()
            ParadeSquareModel.ParadeSquareShow()
        end
    )
end

-- 士兵显示
function ParadeSquareModel.ArmyShow(node, index, id, amount)
    local conf = ConfigMgr.GetItem("configParadePositions", index)
    local pos = conf.pos
    local preNumber = ParadeSquareSubAmount[index]
    local afterNumber = preNumber + amount
    ParadeSquareSubAmount[index] = afterNumber
    if amount > 0 then
        --增加士兵
        for i = preNumber + 1, afterNumber do
            local image = ArmyPool.GetSquare()
            if image then
                image:DefaultTypeset()
                node:AddChild(image)
                local rowAngel  = math.rad(62)
                local colAngel  = math.rad(30)
                if index == Global.ArmyTypeHelicopter then
                    local disCol = Vector2(-110*math.cos(colAngel),-110*math.sin(colAngel))
                    local disRow = Vector2(110*math.sin(rowAngel),-110*math.cos(rowAngel))
                    image.sortingOrder = 10000-i
                    --直升机
                    local imgName = "army_" .. id .. "_park"
                    image.scaleX = -1
                    image:SetImage(UIPackage.GetItemURL("MarchAnimation", imgName))
                    local row = math.floor((i-1) / 3)
                    local col = (i-1) % 3
                    image.xy = pos + disCol*col - disRow*row
                else
                    local disCol = Vector2(-60*math.cos(colAngel),-60*math.sin(colAngel))
                    local disRow = Vector2(110*math.sin(rowAngel),-110*math.cos(rowAngel))
                    local imgName = "army_" .. id .. "_right_down"
                    image:SetImage(UIPackage.GetItemURL("MarchAnimation", imgName))
                    local row = math.floor((i-1) / 8)
                    local col = (i-1) % 8
                    if index == Global.ArmyTypeTank then
                        image.sortingOrder = 10000-i
                        if col % 2 == 0 then
                            image.xy = pos + disCol*col + disRow*row
                        else
                            image.xy = pos + (disCol*(col-1) + disRow*(row+0.4))
                        end
                    elseif index == Global.ArmyTypeCombatVehicle  then
                        image.sortingOrder = 10000-i
                        if col % 2 == 0 then
                            image.xy = pos - disCol*col + disRow*row
                        else
                            image.xy = pos - (disCol*(col-1) - disRow*(row+0.4))
                        end
                    elseif index == Global.ArmyTypeHeavyVehicle  then
                        image.sortingOrder = i
                        if col % 2 == 0 then
                            image.xy = pos - disCol*col - disRow*row
                        else
                            image.xy = pos - (disCol*(col-1) + disRow*(row+0.4))
                        end
                    end
                end
            end
        end
    else
        --减少士兵
        for i = preNumber, afterNumber + 1, -1 do
            if i <= node.numChildren then --容错处理
                ArmyPool.SetSquare(node:GetChildAt(i - 1))
            end
        end
    end
end
-- 阅兵广场士兵显示
function ParadeSquareModel.ParadeSquareShow()
    if not ShowState then
        return
    end
    --if not GlobalVars.IsShowEffect() then
    --    --低端机不显示
    --    return
    --end
    local armyArr = {}
    for _, v in pairs(ArmyId) do
        table.insert(armyArr, { id = v, amount = 0 })
    end
    for _, v in pairs(Model.Armies) do
        local conf = ConfigMgr.GetItem("configArmys", v.ConfId)
        local index = conf.army_type
        if index <= 4 then
            armyArr[index].amount = armyArr[index].amount + v.Amount
        end
    end
    for i = 1, ParadeSquareNode.numChildren do
        local item = ParadeSquareNode:GetChildAt(i - 1)
        local army = armyArr[i]
        local max = i == Global.ArmyTypeHelicopter and 9 or 24
        local num = math.ceil(army.amount / Global.ParadeSquareArmyShowAdd)
        local amount = num > max and max or num
        local c = amount - ParadeSquareSubAmount[i]
        if c ~= 0 then
            ParadeSquareModel.ArmyShow(item, i, army.id, c)
        end
    end
end

return ParadeSquareModel
