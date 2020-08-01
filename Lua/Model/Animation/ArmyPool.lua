--[[
    Author: songzeming
    Function: 兵种对象池
]]
--数值
local ArmyPool = {}

import("UI/Common/ItemImage")

----------------------------------------------------- 收集士兵
local ArmyCollectObject = {}
function ArmyPool.GetCollect()
    if next(ArmyCollectObject) then
        local node = ArmyCollectObject[1]
        node:DefaultTypeset()
        table.remove(ArmyCollectObject, 1)
        return node
    end
    return UIMgr:CreateObject("Common", "itemImage")
end

function ArmyPool.SetCollect(node)
    node.visible = false
    table.insert(ArmyCollectObject, node)
end

function ArmyPool.ClearCollect()
    for _, v in pairs(ArmyCollectObject) do
        v:Dispose()
    end
    ArmyCollectObject = {}
end

----------------------------------------------------- 阅兵广场
local ArmySquareObject = {}
function ArmyPool.GetSquare()
    if next(ArmySquareObject) then
        local node = ArmySquareObject[1]
        node:DefaultTypeset()
        table.remove(ArmySquareObject, 1)
        return node
    end
    return UIMgr:CreateObject("Common", "itemImage")
end

function ArmyPool.SetSquare(node)
    node.visible = false
    table.insert(ArmySquareObject, node)
end

return ArmyPool
