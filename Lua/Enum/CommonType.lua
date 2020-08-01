if CommonType then
    return CommonType
end

CommonType = {
    LOGIN = false, --是否已登录
    RECONNECT = true, --是否可以断线重连 [被挤下线时不能]
    SORT_RESOURCES = {1, 4, 3, 2,5,0}, --资源顺序
    MAIN_UI_CLICK_JUMP = false, --主界面是否是点击跳转按钮 [队列、任务]
    DAILY_REWARD_CLICK = true, --主界面每日奖励按钮是否能点击
    --赌场普通场牌的类型
    RANGE_NORMAL_CARD_TYPE = {
        Resource = 1, --资源
        Item = 2, --道具
        High = 3 --高级场入场券
    },
    --赌场高级场牌的类型
    RANGE_HIGH_CARD_TYPE = {
        Resource = 1, --资源
        Multiple = 2 --倍数
    },
    --通用组件 道具使用或购买面板
    LONG_ITEM_BOX_DISPLAY = {
        JointCommandUpgrade = 1 --联合指挥部升级
    },
    --通用组件 道具使用或购买 灰色版
    LONG_ITEM_BOX_GRAY_FROM = {
        JointCommandUpgrade = 1 --联合指挥部升级道具
    },
    REWARD_TYPE = {
        OnlineReward = 1, --在线奖励
        GetEquipMaterial = 2, --领取生产完成材料
    },
    SHOP_EFFECT_COLOR = {
        "b", --蓝色光效
        "p", --紫色
        "y" --金色
    },
    --玩家详情 战斗相关国际化
    PLAYER_DETAIL_BATTLE = {
        {
            --战斗胜利次数
            netKey = "BattleVictoryTimes",
            i18n = "Ui_Victory_Frequency"
        },
        {
            --战斗失败次数
            netKey = "BattleDefeatedTimes",
            i18n = "Ui_Fail_Frequency"
        },
        {
            --进攻胜利次数
            netKey = "AttackVictoryTimes",
            i18n = "Ui_Attick_Victory"
        },
        {
            --进攻失败次数
            netKey = "AttackDefeatedTimes",
            i18n = "Ui_Attick_Fail"
        },
        {
            --胜率
            netKey = "Winrate",
            i18n = "Ui_Winning_Probability"
        },
        {
            --侦查次数
            netKey = "SpyTimes",
            i18n = "Ui_Spy_times"
        },
        {
            --消灭部队数量
            netKey = "BeatEnemies",
            i18n = "Ui_Destroy_Number"
        },
        {
            --部队损失数量
            netKey = "ArmiesDead",
            i18n = "Ui_DestroyArmy_Number"
        },
        {
            --部队治疗数量
            netKey = "ArmiesCured",
            i18n = "Ui_CurtArmy_Number"
        }
    }
}

return CommonType
