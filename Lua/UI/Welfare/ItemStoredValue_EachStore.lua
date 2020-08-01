--[[
    author:{maxiaolong}
    time:2019-10-19 11:46:28
    function:{活动宝箱}
]]
local ItemStoredValue_EachStore = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemStoredValue_EachStore", ItemStoredValue_EachStore)
local WelfareModel = import("Model/WelfareModel")
local cellWidth = 225
local boxEntityPool = {}
local progressMax = 200
function ItemStoredValue_EachStore:ctor()
    self._progressBar = self:GetChild("progressBar")
    self.InitPosX = self._progressBar.x
    self.InitPosY = self._progressBar.y
    self:InitPool()
    self.disWidth = boxEntityPool[1].size.x / 2
end

function ItemStoredValue_EachStore:GetBoxInPool(num)
    local activityPool = {}

    if #boxEntityPool >= num then
        for i = 1, num, 1 do
            table.insert(activityPool, boxEntityPool[i])
        end
    else
        local difValue = math.abs(#boxEntityPool - num)
        for i = 1, difValue do
            self:AddInPool()
        end
        activityPool = self:GetBoxInPool(num)
    end
    return activityPool
end

function ItemStoredValue_EachStore:InitPool()
    for i = 1, 10 do
        self:AddInPool()
    end
end

function ItemStoredValue_EachStore:SetBoxsHidden()
    for key, v in pairs(boxEntityPool) do
        v:SetShow(false)
        v:SetXY(0, v.y)
    end
end

function ItemStoredValue_EachStore:ClearInPool()
    self:RemoveChildren()
    boxEntityPool = {}
end

function ItemStoredValue_EachStore:AddInPool()
    local node = UIMgr:CreateObject("Welfare", "itemStoredValueBox")
    node.sortingOrder = 3
    self:AddChild(node)
    node:SetShow(false)
    table.insert(boxEntityPool, node)
end

function ItemStoredValue_EachStore:SetData(awardTable, finishTable, progress, boxList)
    local amount = #awardTable
    if amount == 0 or amount == nil then
        return
    end
    local progressNum = tonumber(progress)
    table.insert(finishTable, 1, 0)
    local cellNum = #finishTable - 1
    local reallyCell = math.floor(progressMax / cellNum)
    progressNum = progressNum >= finishTable[#finishTable] and finishTable[#finishTable] or progressNum
    if progressNum <= 0 then
        progressNum = 0
    end
    local valueProgress = WelfareModel:GetProgressValue(progressNum, finishTable, reallyCell)
    self._progressBar.width = amount * cellWidth
    self._progressBar.x = 0
    valueProgress = math.floor(valueProgress)
    self._progressBar.max = progressMax
    self._progressBar.value = valueProgress
    self._progressBar.x = 0
    self:SetBoxsHidden()
    local boxs = self:GetBoxInPool(amount)
    for i = 1, #boxs do
        boxs[i]:SetShow(true)
        local posX = (cellWidth * i) - self.disWidth
        boxs[i]:SetXY(posX, 0)
        boxs[i]:SetData(awardTable[i], finishTable[i + 1])
    end
end

return ItemStoredValue_EachStore
