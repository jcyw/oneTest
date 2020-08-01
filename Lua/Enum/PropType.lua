if PropType then
    return PropType
end

PropType = {
    -- 远大于时间界限 单位秒:10分钟
    FARTIME = 10 * 60,
    -- 道具所有类型
    ALL = {
        Sundries = 0, -- 杂物道具
        Queue = 1, -- 队列道具
        Accelerate = 2, -- 加速道具
        Effect = 3, -- 作用效果道具
        Status = 4, -- 状态效果道具
        Gift = 5, -- 礼包
        AutomaticGenerated = 6, -- 自动生成道具
        EquipmentMaterial = 7, -- 装备材料
        AddSoldiers = 8, -- 加兵道具
        ResourcePoint = 9, -- 资源点道具
        Monster = 10, -- 怪物道具
        ExchangeGoods = 11, -- 物品兑换道具
        Trumpet = 12, -- 喇叭
        StoredValue = 13, -- 储值 
        SpecialResUp = 14, -- 特殊资源产量翻倍BUFF
        DressUp = 18, -- 装扮道具
    },
    SUBTYPE = {
        Horn = 1001, --喇叭
        BaseMove = 1002, --基地迁移
        AvatarChange = 1004, --更改形象
        BuildingMove = 1006, --建筑交换
        PlayerNameChange = 1008, --改名
        CityProtect = 16012,     -- 防护罩
        ResEarthUp = 10102, --稀土产量翻倍
        ResIronUp = 10101,  --钢铁产量翻倍
        ResOilUp = 10103,   --石油产量翻倍
        ResFoodUp = 10104,  --食品产量翻倍
        CallRallyMonster = 4001,  --地图刷怪道具
    },
    -- 道具加速类型
    ACCELERATE = {
        Common = 0, -- 通用加速
        Build = 1, -- 建筑加速
        Army = 2, -- 造兵加速
        Technology = 3, -- 科技加速
        Injured = 4, -- 伤兵加速
        Trap = 5, -- 陷阱加速
        Forge = 6, -- 锻造加速
        BeastCure = 8, -- 巨兽治疗
        BeastTech = 9, -- 巨兽科技
        EquipMake = 10, -- 装备制造
    },
    VIP = {
        Points = 9, ---点数
        Day = 101 ---天数
    }
}

return PropType
