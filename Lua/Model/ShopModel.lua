--author: 	Amu
--time:		2019-07-01 14:59:39
local GD = _G.GD
if ShopModel then
    return ShopModel
end

local UnionModel = import("Model/UnionModel")

ShopModel = {}
ShopModel.detailInfo = {}


function ShopModel:Init( )
    self.detailInfo = {}
end

function ShopModel:Check()
    if not SdkModel.getSkuDetailState then
        SdkModel.GetSkuDetail()
    end
end

function ShopModel:InitSkuDetail(detailInfo)
    self.detailInfo = detailInfo
end

--根据商品id获取价格( "53.0" )
function ShopModel:GetPriceByProductId(giftId)
    ShopModel:Check()
    local productId = giftId[1]
    local info = self.detailInfo[productId]
    if info then
        return info.price_amount
    else
        local config = ConfigMgr.GetList("configIapLists")
        for _,v in ipairs(config)do
            if v.googleIap == productId then
                return v.price
            end
        end
    end
end

--根据商品id获取符号+价格( "PHP 53.00" )
function ShopModel:GetCodeAndPriceByProductId(giftId)
    ShopModel:Check()
    local productId = giftId[1]
    local info = self.detailInfo[productId]
    -- return info and info.price_code.." "..info.price_amount or "null"
    if info then
        return info.price_code.." "..string.format("%.2f", info.price_amount)
    else
        local config = ConfigMgr.GetList("configIapLists")
        for _,v in ipairs(config)do
            if v.googleIap == productId then
                return "$"..string.format("%.2f", v.price)
            end
        end
    end
end

--根据商品id获取价格符号
function ShopModel:GetCodeByProductId(giftId)
    ShopModel:Check()
    local productId = giftId[1]
    local info = self.detailInfo[productId]
    return info and info.price_code or "$"
end

function ShopModel:GetShopInfoByType(type)
    
end

function ShopModel:GetConfigById(type, id)--根据类型和商品id  获得商品配置数据
    if type == SHOP_TYPE.UnionShop then
        return ConfigMgr.GetItem("configAllianceShops", id)
    end
end

function ShopModel:GetGoldIconByType(type) -- 获得货币icon
    -- local img = ConfigMgr.GetItem("configResourcess", type).img
    -- return UIPackage.GetItemURL("Common", img)
    return GD.ResAgent.GetIconUrl(type)
end

function ShopModel:GetGoldNameByType(type) -- 获得货币Name
    return ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_"..type)
end

function ShopModel:GetGoldNumByGoldType(type)       --根据货币类型获得个人货币数量
    if type == RES_TYPE.UnionHonor then
        return Model.Find(ModelType.Resources, RES_TYPE.UnionHonor).Amount
    elseif type == RES_TYPE.UnionCredit then
        return UnionModel:GetUnionCredit()
    elseif type == RES_TYPE.Diamond then
        return Model.GetPlayer().Gem
    -- elseif type == RES_TYPE.Wood then
    --     return Model.GetPlayer().Gem
    -- elseif type == RES_TYPE.Stone then
    --     return Model.GetPlayer().Gem
    -- elseif type == RES_TYPE.Iron then
    --     return Model.GetPlayer().Gem
    -- elseif type == RES_TYPE.Food then
    else
        return Model.Find(ModelType.Resources, type).Amount
    end
    return 0
end

--货币不足提示
function ShopModel:GoldNotEnoughTipByType(type)
    local data = {}
    if type == RES_TYPE.UnionHonor then
        data = {
            content = ConfigMgr.GetI18n("configI18nCommons", "Ui_Alliance_ShopNoMoney"),
            sureBtnText = ConfigMgr.GetI18n("configI18nCommons", "Button_Alliance_ShopNoBuy"),
            sureCallback = function()
                UIMgr:OpenHideLastFalse("UnionScienceDonate")
            end
        }
    elseif type == RES_TYPE.UnionCredit then
        data = {
            content = ConfigMgr.GetI18n("configI18nCommons", "Ui_Alliance_ShopNoIntegral"),
            sureBtnText = ConfigMgr.GetI18n("configI18nCommons", "Button_Alliance_ShopNoIntegral"),
            sureCallback = function()
                UIMgr:OpenHideLastFalse("UnionScienceDonate")
            end
        }
    elseif type == RES_TYPE.Diamond then
        data = {
            content = ConfigMgr.GetI18n("configI18nCommons", "Diamond_Not_Enough"),
            sureBtnText = ConfigMgr.GetI18n("configI18nCommons", "Ui_GetRes_Now"),
            sureCallback = function()
                UIMgr:Open("RechargeMain")
            end
        }
    elseif type == RES_TYPE.Wood or type == RES_TYPE.Stone or type == RES_TYPE.Iron or type == RES_TYPE.Food then
        data = {
            content = ConfigMgr.GetI18n("configI18nCommons", "Ui_Res_NoEnough"),
            sureBtnText = ConfigMgr.GetI18n("configI18nCommons", "Ui_GetRes_Now"),
            sureCallback = function()
                UIMgr:Open("ResourceDisplay", type)
            end
        }
    else
        data = {
            content = "货币不足",
            sureBtnText = "确定",
            sureCallback = function()
                UIMgr:ClosePanelsByFUIType(FUIType.Panel_Top)
            end
        }
    end
    UIMgr:Open("ConfirmPopupText", data)
end

return ShopModel