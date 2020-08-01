Net.Beauties = {}

-- 请求-请求美女信息
function Net.Beauties.GetBeautiesInfo(...)
    Network.RequestDynamic("GetBeautiesInfoParams", {}, ...)
end

-- 请求-约会
function Net.Beauties.Date(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("BeautyDateParams", fields, ...)
end

-- 请求-游戏开始
function Net.Beauties.GameStart(...)
    local fields = {
        "Id", -- int32
        "Hyper", -- bool
    }
    Network.RequestDynamic("BeautyGameStartParams", fields, ...)
end

-- 请求-玩游戏
function Net.Beauties.PlayGame(...)
    local fields = {
        "Id", -- int32
        "Selection", -- int32
    }
    Network.RequestDynamic("BeautyPlayGameParams", fields, ...)
end

-- 请求-升星
function Net.Beauties.StarUp(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("BeautyStarUpParams", fields, ...)
end

-- 请求-技能升级
function Net.Beauties.SkillUp(...)
    local fields = {
        "BeautyId", -- int32
        "SkillId", -- int32
    }
    Network.RequestDynamic("BeautySkillUpParams", fields, ...)
end

-- 请求-赠送礼物
function Net.Beauties.Gift(...)
    local fields = {
        "BeautyId", -- int32
        "GiftPos", -- int32
        "GiftId", -- int32
    }
    Network.RequestDynamic("BeautyGiftParams", fields, ...)
end

-- 请求-更改着装
function Net.Beauties.ChangeCostume(...)
    local fields = {
        "BeautyId", -- int32
        "Costume", -- int32
    }
    Network.RequestDynamic("BeautyChangeCostumeParams", fields, ...)
end

-- 请求-改名
function Net.Beauties.ChangeName(...)
    local fields = {
        "BeautyId", -- int32
        "Name", -- string
    }
    Network.RequestDynamic("BeautyChangeNameParams", fields, ...)
end

-- 请求-购买换装冷却
function Net.Beauties.BuyChangeCostumeCool(...)
    Network.RequestDynamic("PurchaseCostumeCoolParams", {}, ...)
end

-- 请求-美女在线奖励信息
function Net.Beauties.OnlineBonusInfo(...)
    Network.RequestDynamic("BeautyOnlineBonusInfoParams", {}, ...)
end

-- 请求-领取美女在线奖励
function Net.Beauties.GetOnlineBonus(...)
    local fields = {
        "Index", -- int32
    }
    Network.RequestDynamic("GetBeautyOnlineBonusParams", fields, ...)
end

return Net.Beauties