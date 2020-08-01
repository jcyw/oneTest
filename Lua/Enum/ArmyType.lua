if ArmyType then
    return ArmyType
end

ArmyType = {
    --兵种大类型
    BIG = {
        Infantry = 1, --步兵兵营类
        Cavalry = 2, --骑兵兵营类
        BowSoldier = 3, --弓兵兵营类
        Carsoldier = 4, --车兵兵营类
        Defense = 5, --安保工厂类
        Beast = 6 --大怪兽
    },
    --兵种小类型
    SMALL = {
        MainBattleTank = 1, --主战坦克 (步兵)
        AntiTankChariot = 2, --反坦克战车 (枪兵)
        WheeledChariot = 3, --轮式战车 (骑兵)
        ArmoredFightingVehicle = 4, --装甲战车 (骑射兵)
        CommonHelicopter = 5, --通用直升机 (弓兵)
        MilitaryHelicopter = 6, --武装直升机 (弩兵)
        SelfPropelledArtillery = 7, --自行火炮 (步兵投石车)
        ConstructionVehicle = 8, --工程车 (冲车（采矿）)
        AntiTankMissile = 9, --反坦克导弹 (滚石)
        AntiCombatRocket = 10, --反战车火箭 (火箭)
        AirDefenseMissile = 11, --防空导弹 (滚木)
        Godzilla = 20, --哥斯拉
        KingKong = 21 --金刚
    },
    MARCHANIM = {
        Tank = 1,           --坦克动画
        Chariot = 2  ,      --战车动画
        Helicopter = 3,     --直升机动画

    }
}

return ArmyType
