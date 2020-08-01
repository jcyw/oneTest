--[[
    author:{laofu}
    time:2020-07-29 14:04:15
    function:{美女在线奖励数据模块}
]]
local GD = _G.GD
local BeautyAgent = GD.LVar("BeautyAgent", {})
local AgentDefine = GD.AgentDefine

local BeautyGirlModel = _G.import("Model/BeautyGirlModel")

local UITool = _G.UITool
local GlobalMisc = _G.GlobalMisc
local ConfigMgr = _G.ConfigMgr

local girlsInfo = ConfigMgr.GetList("configGirls")

local GetBeautyIconForIndex  --通过美女ID获得美女立绘
local GetMaxFavor  --通过ID获得美女最大好感度
local GetSkillTableForIndex  --通过ID获得美女技能列表，拷贝版
local GetSkillTable  --通过ID获得美女技能列表
local GetAwardTable  --获得奖励列表
local GetTimeTable  --获得在线时间列表

--通过美女ID获得美女立绘
function GetBeautyIconForIndex(index)
    local resource = girlsInfo[index].resource
    local url = UITool.GetIcon({resource[1], resource[2]})
    return url
end

function GetMaxFavor(index)
    return girlsInfo[index].totalfavor
end

--通过美女ID获得美女的技能列表
function GetSkillTableForIndex(index)
    local skillTab = {}
    table.deepCopy(girlsInfo[index].skill, skillTab)
    --if Model.Player.CreatedAt > 1594869000 then
    if BeautyGirlModel.Shield then
        for key, value in pairs(skillTab) do
            if value.favor == 290 then
                table.remove(skillTab, key)
            end
        end
    end
    return skillTab
end

--通过美女ID获得美女的技能列表
function GetSkillTable(index)
    local skillTab = girlsInfo[index].skill
    return skillTab
end

--获得奖励列表
function GetAwardTable()
    local award = GlobalMisc.GirlOnlineReward3
    return award
end

--获得在线时间列表
function GetTimeTable()
    local timeTab = GlobalMisc.GirlOnlineReward2
    return timeTab
end

AgentDefine(BeautyAgent, "GetBeautyIconForIndex", GetBeautyIconForIndex)
AgentDefine(BeautyAgent, "GetMaxFavor", GetMaxFavor)
AgentDefine(BeautyAgent, "GetSkillTableForIndex", GetSkillTableForIndex)
AgentDefine(BeautyAgent, "GetSkillTable", GetSkillTable)
AgentDefine(BeautyAgent, "GetAwardTable", GetAwardTable)
AgentDefine(BeautyAgent, "GetTimeTable", GetTimeTable)

return BeautyAgent
