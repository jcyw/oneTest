--[[
    author:{zhanzhang}
    time:2019-06-10 16:56:35
    function:{关系类型}
]]
if RelationEnum then
    return RelationEnum
end

RelationEnum = {
    --中立
    Neutrality = 1,
    --自己
    Oneself = 2,
    --盟友
    Ally = 3,
    --敌人
    Enemy = 4
}

return RelationEnum
