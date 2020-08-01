if TipType then
    return TipType
end

TipType = {
    --队列总览提示
    QUEUEOVERVIEW = {
        No = 0, --不提醒
        EveryDay = 1, --每日提醒一次
        Idel = 2 --有空闲就提醒
    },
    --本次在线不在提示 / 今日登录不在提示
    NOTREMIND = {
        --[G_使用金币提示框 今日登录不在提示]
        ---每次上线弹窗提示
        OnlineSpecialShop = "OnlineSpecialShop", --特价商城
        OnlineSupply = "OnlineSupply", --均需站（补给）
        --满足条件弹窗提示
        ConditionUpgrade = "ConditionUpgrade", --建造升级
        ConditionDestroy = "ConditionDestroy", --建筑移除
        ConditionTrain = "ConditionTrain", --训练
        ConditionAdvance = "ConditionAdvance", --士兵进阶
        ConditionTech = "ConditionTech", --科研
        ConditionCure = "ConditionCure", --治疗
        ConditionBeastTech = "ConditionBeastTech", --巨兽科研
        ConditionBeastCure = "ConditionBeastCure", --巨兽治疗
        G_BuildOnline = "G_BuildOnline", --在线提示，建筑基础功能队列（建造、升级、训练、科研、治疗）
        --[T_使用带标签的提示框]
        T_TipVipActive = "T_TipVipActive", --提示VIP到期是否重新激活
        --[今日登录不在提示]
        DayVipActive = "DayVipActive" --Vip激活
    },
    --弹窗提示类型
    TYPE = {
        ---每次上线弹窗提示
        OnlineSpecialShop = "OnlineSpecialShop", --特价商城
        OnlineSupply = "OnlineSupply", --均需站（补给）
        --满足条件弹窗提示
        ConditionUpgrade = "ConditionUpgrade", --建造升级
        ConditionDestroy = "ConditionDestroy", --建筑移除
        ConditionTrain = "ConditionTrain", --训练
        ConditionAdvance = "ConditionAdvance", --士兵进阶
        ConditionTech = "ConditionTech", --科研
        ConditionCure = "ConditionCure", --治疗
        ConditionBeastTech = "ConditionBeastTech", --巨兽科研
        ConditionBeastCure = "ConditionBeastCure" --巨兽治疗
    }
}

return TipType
