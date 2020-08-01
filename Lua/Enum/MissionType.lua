--[[
    author:{author}
    time:2019-05-31 09:31:20
    function:{function}
]]
if MissionType then
    return MissionType
end

MissionType = {
    --行军侦察
    MissionSpy = "MissionSpy",
    --行军掠夺
    MissionAttack = "MissionAttack",
    --行军采矿
    MissionMining = "MissionMining",
    --行军攻击NPC
    MissionPVE = "MissionPVE",
    --行军返回
    MissionReturn = "MissionReturn",
    --行军交易
    MissionTrade = "MissionTrade",
    --行军集结
    MissionRally = "MissionRally",
    --行军援军
    MissionAssit = "MissionAssit",
}

return MissionType
