--[[
    Author:zhangzhichao
    Function:VIP配置数据
]]
local GD = _G.GD
local VIPModel={}

--通过vip配置表获取相应等级属性
function VIPModel.GetLevelPropByConf(level,conf)
    local list = {}
    local num=0
    local point=0
    for k,v in pairs(conf)do
        if v.id==level then
            point=v.vip_score
            for k1,v1 in pairs(v.vip_function) do
                num=num+1
                if not list[num] then
                    list[num]={}
                end
                list[num] =v1
            end
            return list,point
        end
    end
end

--通过配置表获取每一个属性对应的icon，类型
function VIPModel.GetInfoByProp(conf,prop)
    for k,v in pairs(conf) do
        if prop==v.id then
            return v.icon,v.format,v.color
        end
    end
end

--通过积分值获得配置表等级值
function VIPModel.GetInfoByPiont(point)
    local conf=ConfigMgr.GetList("configVips")
    for k,v in pairs(conf) do
        if v.vip_score>point then
            return v.id,v.vip_score
        end
    end
end

--根据等级属性对显示的属性进行排序
function VIPModel.SetOrder(table1,table2)
    for k,v in pairs(table1) do
        v.sort = 3
        for k1,v1 in pairs(table2) do
            if v.vip_right == v1.vip_right  then
                v.sort = v.num == v1.num and 1 or 2
                break
            end
        end
    end
    return table1
end

--低等级的list按照高等级的list排序
function VIPModel.SetLevelPropList(list1, list2)
    for _, v1 in ipairs(list2) do
        local newData = true
        v1.sort = 3
        for _, v in ipairs(list1) do
            if v.vip_right == v1.vip_right then
                v1.sort = v1.num == v.num and 1 or 2
                v.sort = v1.sort
                newData = false
                break
            end
        end
        if newData then
            table.insert(list1, {sort = 3, vip_right = v1.vip_right})
        end
    end

    table.sort( list2,function(a,b)
        return a.sort > b.sort
    end)

    table.sort( list1,function(a,b)
        return a.sort > b.sort
    end)
    return list1, list2
end

--获取当前vip等级指定的属性内容
function VIPModel.GetCurLevelProByAttr(attrId)
    local list = VIPModel.GetLevelPropByConf(VIPModel.GetVipLevel(), ConfigMgr.GetList("configVips"))
    for _,v in pairs(list) do
        if v.vip_right == attrId then
            return v.num
        end
    end
end

--获取指定属性的属性值和所在vip等级
function VIPModel.GetProListByAttr(attrId)
    local result = {}
    local config = ConfigMgr.GetList("configVips")
    for _,v in pairs(config) do
        for _,v1 in pairs(v.vip_function) do
            if v1.vip_right == attrId then
                table.insert(result, {vip = v.id, value = v1.num})
                break
            end
        end
    end

    return result
end

--获取激活指定属性的最低vip等级
function VIPModel.GetMinLevelForAttr(attrId)
    local config = ConfigMgr.GetList("configVips")
    for _,v in pairs(config) do
        for _,v1 in pairs(v.vip_function) do
            if v1.vip_right == attrId and v1.num > 0 then
                return v.id
            end
        end
    end
end

--获取玩家VIP等级
function VIPModel.GetVipLevel()
    return Model.Player.VipLevel
end

--获取玩家VIP是否激活
function VIPModel.GetVipActivated()
    return Model.Player.VipActivated
end

--获取玩家的道具是否可以使VIP升级
function VIPModel.ItemEnoughToUpgrade(vipInfo)
    local AllItems = GD.ItemAgent.GetItemsBysubType(PropType.ALL.Effect,PropType.VIP.Points)
    local haveItems = GD.ItemAgent.GetHaveItemsBysubType(PropType.ALL.Effect,PropType.VIP.Points)

    local conf = ConfigMgr.GetList("configVips")
    local _, p = VIPModel.GetLevelPropByConf(vipInfo.VipLevel+1,conf)
    if not p then
        return false
    end
    local needPoint = p - vipInfo.VipPoints
    for _, item in ipairs(AllItems) do
        local amount = 0
        for _, v in ipairs(haveItems) do
            if v.ConfId == item.id then
                amount = v.Amount
                break
            end
        end
        local point = amount * item.value
        needPoint = needPoint - point
        if needPoint <= 0 then
            return true
        end
    end
    return false
end

function VIPModel.GetValueByType(num, type)
    local value
    if type == 1 then       --属性为时间的
        value = StringUtil.GetI18n(I18nType.Commmon, "Vip_Desc_Val5",{vip_value = string.format("%.0f",(num+Global.FreeBuildTime)/60)}) 
    elseif type == 2 then   --属性为百分比
        value = StringUtil.GetI18n(I18nType.Commmon, "Vip_Desc_Val4",{vip_value = string.format("%.0f",num*0.01)}) 
    elseif type == 3 then   --属性为个数
        value = StringUtil.GetI18n(I18nType.Commmon, "Vip_Desc_Val3",{vip_value = num})
    elseif type == 4 then   --Value属性为开启或关闭
        local I18Value = num == 0 and "Vip_Desc_Val1" or "Vip_Desc_Val2"
        value = StringUtil.GetI18n(I18nType.Commmon, I18Value)
    end 
    return value
end

function VIPModel.GetMaxVipLevel()
    return 10
end

return VIPModel