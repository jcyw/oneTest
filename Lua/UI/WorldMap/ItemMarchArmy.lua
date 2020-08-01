--[[
    author:{zhanzahng}
    time:2020-01-05 16:12:38
]]
local ItemMarchArmy = {}

--
function ItemMarchArmy:CreateMarchArmy() --
    --[[ 
        流程
        1判断行军类型决定排列方式
        2从对象池取出spine对象
        3按照预定规则排列播放动画
        4动画状态切换的时候进行淡出

            ]]
    local category = Global.MissionAttack
    local armyType = {1, 2, 3, 4, 5}
    local config = ConfigMgr.GetList("configArmyQueue")
    local num = 10000
    local nowConfig
    for i, v in ipairs(config) do
        if v.range >= num then
            nowConfig = v
            break
        end
    end
    for k, v in ipairs(config.number) do
        local itemSpine = ObjectPoolManager.Instance:GetPool("")
    end
    if category == Global.MissionAttack then
    elseif category == Global.MissionRally then
    end
end

return ItemMarchArmy
