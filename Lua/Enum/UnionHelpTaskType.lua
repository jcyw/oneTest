--[[
    author:{zhanzhang}
    time:2019-08-06 11:35:09
    function:{联盟协作任务枚举}
]]
if UnionHelpTaskType then
    return UnionHelpTaskType
end
UnionHelpTaskType = {
    --等待接受
    WaitReceive = "WaitReceive",
    --请求合作
    AskHelp = "AskHelp",
    --不能帮助
    OtherWaitHelp = "OtherWaitHelp",
    --等待帮助(可点击)
    OtherCanHelp = "OtherCanHelp",
    --已经帮助等待完成
    WaitFinish = "WaitFinish",
    --等待加速
    WaitSpeedUp = "WaitSpeedUp",
    --可领取
    CanGet = "CanGet"
}

return UnionHelpTaskType
