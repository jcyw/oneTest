--[[
    author:{zhanzhang}
    time:2019-07-09 09:29:47
    function:{出征类型}
]]
if ExpeditionType then
    return ExpeditionType
end
--出征类型
ExpeditionType = {
    AttackPlayer = 1, --进攻玩家
    Mining = 2, --采矿
    None = 3, --驻扎
    Pve = 4, --攻击野怪
    UnionAttack = 5, --发起集结进攻
    JoinUnionAttack = 6, --加入集结进攻
    JoinUnionDefense = 7, --加入集结防御
    UnionBuildingStation = 8, --联盟建筑驻军
    UnionBuildingBuild = 9, --联盟建筑建造
    SearchPrison = 10 --搜索秘密基地
}

return ExpeditionType
