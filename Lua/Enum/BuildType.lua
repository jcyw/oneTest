if BuildType then
    return BuildType
end

BuildType = {
    OFFSET_CENTER = Vector2(170, -250), --指挥中心偏移
    OFFSET_WALL = Vector2(-50, -100), --城墙偏移
    OFFSET_BRIDGE = Vector2(-10, -220), --桥头建筑（在线领奖）偏移
    OFFSET_GODZILLA = Vector2(-20, -240), --巢穴 哥斯拉
    OFFSET_KINGKONG = Vector2(-20, -140), --巢穴 金刚
    OFFSET_BUILD_GODZILLA = Vector2(7484, 2247), --巢穴建筑点 哥斯拉
    OFFSET_BUILD_KINGKONG = Vector2(7892, 3014), --巢穴建筑点 金刚
    OFFSET_BUILD_FUNC_Y = 100, --建筑在有事件的时候,功能列表位置偏移
    OFFSET_BUILD_CD_Y = 90, --建筑在有事件的时候,建筑倒计时位置偏移
    NAME_SHOW_TIME = 0.8, --建筑名称显示时间
    --功能列表类型
    FUNCTIONS = {
        Never = -1, --不显示
        Forever = 0, --永久存在
        Normal = 1, --普通状态：建筑静态，没有任何其他操作状态
        Build = 2, --建筑升级状态
        Train = 3, --士兵训练中状态
        ResUp = 4, --资源田提升状态
        Cure = 5, --治疗中状态
        Tech = 6, --研究中状态
        OutUnionNormal = 7, --未加入联盟情况下的普通状态（只作用于联盟建筑）
        InUnionOver = 8, --加入联盟，且联盟医院建造完毕
        Forge = 9, --锻造中状态
        UnionNormal = 10, --加入联盟永久存在（只作用于联盟建筑）
        BeastCure = 12, --巨兽治疗中状态
        BeastTech = 13, --巨兽研究中状态
    },
    --动画类型
    ANIMATION = {
        Normal = 1,
        Help = 2, --帮助
        Free = 3, --免费
        Train = 4, --训练
        Harest = 5, --资源收集
        Gift = 6, --礼物
        Special = 7, --特价
        ScienceAward = 8, --科技研究完成奖励
        Gm = 9, --客服
        Beauty = 10, --美女约会
        Range = 11, --靶场飞镖免费
        MilitarySupply = 12, --军需站免费
        UnionWarfare = 13, --联盟战争
        ActivityCenter = 14, --活动中心
        FalconActivity = 15, --猎鹰行动
        Welfare = 16, --福利中心
        EquipMake = 17, --装备制造
        EquipMaterialMake = 18, --装备材料生产
        DressUp = 19, --装扮
    },
    --建筑层级显示(父节点map)
    SORTINGORDER = {
        EffectResBuildSpeed = 1, --资源建筑提速特效
        BuildIcon = 2, --建筑图片
        TrainCollectLight = 3, --训练工厂建筑收集士兵特效
        BuildingEffect = 4, --建筑建造特效
    },
    --建筑是否可移动
    BUILD_MOVEABLE = {
        No = 0,
        Yes = 1
    },
    --建筑升级条件不满足时类型
    CONDITION = {
        Turn = "Turn", --跳转
        Accelerate = "Accelerate", --加速
        Free = "Free", --免费
        ResObtain = "ResObtain", --资源获取
        ItemObtain = "ItemObtain" --道具获取
    },
    --建筑队列
    QUEUE = {
        Free = 1, --免费队列
        Charge = 2 --收费队列
    },
    --队列总览提醒
    QUEUEOVERVIEW = {
        NoRemind = "NoRemind", --不提醒
        EveryDayRemind = "EveryDayRemind", --每日提醒一次
        IdleRemind = "IdleRemind" --有空闲就提醒
    },
    --治疗士兵类型
    CUREARMY = {
        Build = "Build", --城外建筑治疗士兵
        Union = "Union" --世界联盟领地医院治疗士兵
    },
    --建筑移动类型
    MOVE = {
        Reset = 1, --重置地图按钮
        Move = 2, --建筑移动
        Item = 3 --使用道具移动
    },
    --建筑打开界面地图缩放
    SCALELAYER = {
        Create = 1, --建筑建造
        Upgrade = 2, --建筑升级
        Detail = 3 --建筑详情
    },
    -- 详情类型
    DETAIL = {
        List = {
            {
                Col = 2,
                ConfIds = {
                    "BuildingScience", -- 科研中心
                    "BuildingBeastBase", --巨兽基地
                    "BuildingBeastScience" --巨兽研究院
                },
                Title = {
                    {"UI_Details_Level", "UI_Details_Power"}, -- 科研中心
                    {"UI_Details_Level", "UI_Details_Power"}, -- 巨兽基地
                    {"UI_Details_Level", "UI_Details_Power"} -- 巨兽研究院
                }
            },
            {
                Col = 3,
                ConfIds = {
                    "BuildingRadar", -- 雷达
                    "BuildingTankFactory", -- 坦克工厂(步)
                    "BuildingWarFactory", -- 战车工厂(骑)
                    "BuildingHelicopterFactory", -- 直升机工厂(弓)
                    "BuildingVehicleFactory", -- 重型载具工厂(车)
                    "BuildingSecurityFactory", -- 安保工厂
                    "BuildingHospital", -- 战区医院
                    "BuildingDillGround", -- 作战指挥部
                    "BuildingJointCommand", --联合指挥部
                    "BuildingBeastHospital", --巨兽医院
                    "BuildingGodzilla", --哥斯拉巢穴
                    "BuildingKingkong" --金刚巢穴
                },
                Title = {
                    {"UI_Details_Level", "UI_Details_Effect", "UI_Details_Power"}, -- 雷达
                    {"UI_Details_Level", "UI_Details_Effect", "UI_Details_Power"}, -- 坦克工厂(步)
                    {"UI_Details_Level", "UI_Details_Effect", "UI_Details_Power"}, -- 战车工厂(骑)
                    {"UI_Details_Level", "UI_Details_Effect", "UI_Details_Power"}, -- 直升机工厂(弓)
                    {"UI_Details_Level", "UI_Details_Effect", "UI_Details_Power"}, -- 重型载具工厂(车)
                    {"UI_Details_Level", "UI_Details_Effect", "UI_Details_Power"}, -- 安保工厂
                    {"UI_Details_Level", "UI_Details_Wounded", "UI_Details_Power"}, -- 战区医院
                    {"UI_Details_Level", "UI_Details_Expedition", "UI_Details_Power"}, -- 作战指挥部
                    {"UI_Details_Level", "UI_Details_Expedition", "UI_Details_Power"}, -- 联合指挥部
                    {"UI_Details_Level", "UI_TREAT_BEAST", "UI_Details_Power"}, -- 巨兽医院
                    {"UI_Details_Level", "UI_Details_Effect", "UI_Details_Power"}, --哥斯拉巢穴
                    {"UI_Details_Level", "UI_Details_Effect", "UI_Details_Power"} --金刚巢穴
                }
            },
            {
                Col = 4,
                ConfIds = {
                    "BuildingCenter", -- 指挥中心
                    "BuildingTransferStation", -- 物流中转站
                    "BuildingStone", -- 稀土工厂
                    "BuildingWood", -- 钢铁厂
                    "BuildingIron", -- 炼制工厂
                    "BuildingFood", -- 食品厂
                    "BuildingTower", -- 警戒塔
                    "BuildingWall", -- 城墙
                    "BuildingMarchTent", -- 营房
                    "BuildingEquipFactory" -- 装备制造厂
                },
                Title = {
                    {"UI_Details_Level", "UI_COOLLET_SPEED_IRON", "UI_COOLLET_SPEED_FOOD", "UI_Details_Power"}, -- 指挥中心
                    {"UI_Details_Level", "UI_Details_Resource", "UI_Details_Tax", "UI_Details_Power"}, -- 物流中转站
                    {"UI_Details_Level", "UI_Details_Yield", "UI_Details_Volume", "UI_Details_Power"}, -- 稀土工厂
                    {"UI_Details_Level", "UI_Details_Yield", "UI_Details_Volume", "UI_Details_Power"}, -- 钢铁厂
                    {"UI_Details_Level", "UI_Details_Yield", "UI_Details_Volume", "UI_Details_Power"}, -- 炼制工厂
                    {"UI_Details_Level", "UI_Details_Yield", "UI_Details_Volume", "UI_Details_Power"}, -- 食品厂
                    {"UI_Details_Level", "UI_Details_Attack", "UI_Details_AttackSpeed", "UI_Details_Power"}, -- 警戒塔
                    {"UI_Details_Level", "UI_Details_Weapons", "UI_Details_Defense", "UI_Details_Power"}, -- 城墙
                    {"UI_Details_Level", "UI_Details_TrainSpeed", "UI_Details_Train", "UI_Details_Power"}, -- 营房
                    {"UI_Details_Level", "equip_building_1", "equip_building_2", "UI_Details_Power"} -- 装备制造厂
                }
            },
            {
                Col = 5,
                ConfIds = {
                    "BuildingUnionBuilding" -- 联盟大厦
                },
                Title = {
                    {
                        "UI_Details_Level",
                        "UI_Details_HelpTime",
                        "UI_Details_HelpTimes",
                        "UI_Details_HelpArmy",
                        "UI_Details_Power"
                    } -- 联盟大厦
                }
            },
            {
                Col = 6,
                ConfIds = {
                    "BuildingVault" -- 物资仓库
                },
                Title = {
                    {
                        "UI_Details_Level",
                        "UI_Details_Wood",
                        "UI_Details_Stone",
                        "UI_Details_Iron",
                        "UI_Details_Food",
                        "UI_Details_Power"
                    } -- 物资仓库
                }
            },
            {
                Col = 7,
                ConfIds = {
                    "BuildingMilitarySupply" -- 军需站
                },
                Title = {
                    {
                        "UI_Details_Level",
                        "UI_Details_Supply",
                        "UI_Details_Wood",
                        "UI_Details_Food",
                        "UI_Details_Iron",
                        "UI_Details_Stone",
                        "UI_Details_Power"
                    } -- 军需站
                }
            }
        }
    }
}

return BuildType
