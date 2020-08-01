if ActivityType then
    return ActivityType
end
ActivityType = {
    InvestType = {
        --查看
        ToView = 1,
        --投资
        Invest = 2,
        --解锁
        Lock = 3
    }
}
return ActivityType
