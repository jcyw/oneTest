if CityType then
    return CityType
end

CityType = {
    --建筑移动提示
    BUILD_MOVE_TIP = false,
    --建筑移动位置
    BUILD_MOVE_POS = nil,
    --建筑移动类型
    BUILD_MOVE_TYPE = nil,
    --侧边栏类型
    SIDEBAR = {
        Build = "Build", --建造
        Train = "Train", --训练
        Research = "Research", --科研
        ActionQueue = "ActionQueue", --行动队列
        Medical = "Medical", --医疗
        AllianceAffairs = "AllianceAffairs", --联盟事务
        WelfareCollection = "WelfareCollection" --福利领取
    },
    --内城地图组件节点
    CITY_MAP_NODE_TYPE = {
        CollectArmy = {
            --收集的士兵
            name = "CollectArmy",
            sortingOrder = 10
        },
        CollectHelicopter = {
            --收集的直升机
            name = "CollectHelicopter",
            sortingOrder = 49
        },
        Soldier = {
            --大兵巡逻
            name = "Soldier",
            sortingOrder = 20
        },
        SoldierOrderUp = {
            --大兵巡逻
            name = "SoldierOrderUp",
            sortingOrder = 31
        },
        Worker = {
            --工程师
            name = "Worker",
            sortingOrder = 20
        },
        Build = {
            --建筑
            name = "Build",
            sortingOrder = 30
        },
        BuildUpgradeAnim = {
            --建筑升级(创建、拆除)动画
            name = "BuildUpgradeAnim",
            sortingOrder = 33
        },
        BuildTrainEffect = {
            --训练完成特效
            name = "BuildTrainEffect",
            sortingOrder = 34
        },
        BuildIdle = {
            --建筑空闲 训练工厂
            name = "BuildIdle",
            sortingOrder = 40
        },
        BuildName = {
            --建筑名称
            name = "BuildName",
            sortingOrder = 40
        },
        BuildLevel = {
            --建筑等级
            name = "BuildLevel",
            sortingOrder = 41
        },
        Dialog = {
            --对话框
            name = "Dialog",
            sortingOrder = 42
        },
        BuildCD = {
            --建筑倒计时
            name = "BuildCD",
            sortingOrder = 45
        },
        BuildBtnComplete = {
            --建筑上 帮助、免费、训练、资源收集动画等
            name = "BuildBtnComplete",
            sortingOrder = 46
        },
        WallFire = {
            --城墙着火
            name = "WallFire",
            sortingOrder = 32
        },
        ParadeSquare = {
            --阅兵广场
            name = "ParadeSquare",
            sortingOrder = 10
        }
    },
    CITY_MAP_SORTINGORDER = {
        Wall = 21, --城墙
        Nest = 32, --巨兽
        Tree = 44, --树
        FunctionList = 50, --功能列表
        EffectClickBlack = 52, --地图点击空白区域特效
        PlaneAnimation = 100, --飞机动画
        Weather = 101 --天气
    }
}

return CityType
