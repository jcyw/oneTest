-- 物品Model
local GD = _G.GD
local ItemAgent = GD.LVar("ItemAgent", {})
local AgentDefine = GD.AgentDefine

local BuffItemModel = _G.import("Model/BuffItemModel")
local MissionEventModel = _G.import("Model/MissionEventModel")
local WallModel = _G.import("Model/WallModel")
local ParadeSquareModel = _G.import("Model/Animation/ParadeSquareModel")
local DressUpModel = _G.import("Model/DressUpModel")

local Model = _G.Model
local ModelType = _G.ModelType
local ConfigMgr = _G.ConfigMgr
local UIPackage = _G.UIPackage
local StringUtil = _G.StringUtil
local I18nType = _G.I18nType
local Util = _G.Util
local JSON = _G.JSON
local Event = _G.Event
local EventDefines = _G.EventDefines
local Net = _G.Net
local PropType = _G.PropType
local TurnModel = _G.TurnModel
local UIMgr = _G.UIMgr
local WORLD_CHAT_EVENT = _G.WORLD_CHAT_EVENT
local Global = _G.Global
local UnionModel = _G.UnionModel
local TipUtil = _G.TipUtil
local WorldBuildType = _G.WorldBuildType
local WorldMap = _G.WorldMap
local SdkModel = _G.SdkModel
local Tool = _G.Tool
local MILITARY_SUPPLY = _G.MILITARY_SUPPLY
local CommonModel = _G.CommonModel
local BuildModel = _G.BuildModel
local UITool = _G.UITool
local REWARD_TYPE = _G.REWARD_TYPE

GD.LVar("ItemPage", nil, true)
GD.LVar("backpackItemPanes", {}, true)
GD.LVar("backpackItemBoxPane", nil, true)
GD.LVar("ResConfig", {}, true) --资源类型道具数据表
GD.LVar("NewItems", {}, true)

local GetItemModel
local GetItemModelById
local GetItemQualityByConfId -- 按配置id获取物品品质框
local GetItmeQualityByColor -- 按配置color获取物品品质框
local GetItemNameByConfId -- 按配置id获取物品名字
local GetItemDescByConfId -- 按配置id获取物品描述
local GetItemType2 -- 按配置id获取物体的道具子类型
local GetItemModelByCategory
local GetItemsBysubType
local GetHaveItemsBysubType
local GetItemModelByConfId
local GetItemListByPage -- 根据页面获取道具列表
local SaveItemPane -- 保存背包界面物品item面板
local GetItemPane -- 获取背包界面物品item面板
local CleanItemPanes
local SetItemBoxPane -- 保存物品点击下拉框面板
local GetItemBoxPane -- 获取物品点击下拉框面板
local InitCacheNewItemsStatus -- 初始化缓存的新获取物品数据
local HandleOldCacheNewItemDatas -- 处理旧的新获得物品缓存数据，旧数据里只存了物品配置id
local SaveNewItemsStatus -- 保存新获得物品状态
local RemoveNewItemsStatus -- 删除新获得物品状态
local CheckNewItem -- 检查是否新获得物品
local GetNewItemAmount -- 获取新物品总数
local ClearNewItem -- 清除所有新获得物品状态
local UseItem -- 使用物品
local ResUpItemUse -- 使用资源建筑产量翻倍道具
local GetItemInnerContent -- 获取物品图标上的标签显示内容
local SetMiddleBg -- 设置物品标签底框
local ItemUsedTip -- 物品使用后tip提示
local CheckItemLimit -- 判断物品使用条件
local GetResBackPackItemList -- 按资源类型获得背包内道具
local CanBackPackItemFillResNeed -- 背包内某类型资源总值，是否够填满差值，返回bool+仍然差值
local GetUseResMininum -- 获得最低使用数量资源道具的数据
local RecursionGetProportion -- 递归获得比例
local GetShowRewardInfo
local RequireActivityExchangeInfo
local UseCDKEY -- 兑换码

function GetItemModel()
    return Model.GetMap(ModelType.Items)
end

function GetItemModelById(id)
    return Model.Find(ModelType.Items, id)
end

-- 按配置id获取物品品质框
function GetItemQualityByConfId(id)
    local config = ConfigMgr.GetItem("configItems", id)
    return UIPackage.GetItemURL("Common", "com_case_quality_" .. (config.color == nil and 1 or config.color))
end

-- 按配置color获取物品品质框
function GetItmeQualityByColor(color)
    return UIPackage.GetItemURL("Common", "com_case_quality_" .. (color == nil and 1 or color))
end

-- 按配置id获取物品名字
function GetItemNameByConfId(id)
    return StringUtil.GetI18n(I18nType.Item, "ITEM_NAME_" .. id)
end

-- 按配置id获取物品描述
function GetItemDescByConfId(id)
    return StringUtil.GetI18n(I18nType.Item, "ITEM_DESC_" .. id)
end

--按配置id获取物体的道具子类型
function GetItemType2(id)
    local config = ConfigMgr.GetItem("configItems", id)
    return config.type2
end

function GetItemModelByCategory(category)
    local result = {}
    local models = ItemAgent.GetItemModel()
    for _, v in pairs(models) do
        local config = ConfigMgr.GetItem("configItems", v.ConfId)
        if config.type == category then
            table.insert(result, v)
        end
    end

    return result
end

function GetItemsBysubType(type, subType)
    local list = {}
    local config = ConfigMgr.GetList("configItems")
    for _, v in pairs(config) do
        if v.type == type and v.type2 == subType then
            table.insert(list, v)
        end
    end
    return list
end

function GetHaveItemsBysubType(type, subType)
    local list = {}
    local models = ItemAgent.GetItemModel()
    for _, v in pairs(models) do
        local config = ConfigMgr.GetItem("configItems", v.ConfId)
        if config.type == type and config.type2 == subType then
            table.insert(list, v)
        end
    end
    return list
end

function GetItemModelByConfId(confId)
    return ConfigMgr.GetItem("configItems", confId)
end

--根据页面获取道具列表
function GetItemListByPage(pageIndex)
    if not GD.ItemPage then
        GD.ItemPage = {}
        local list = ConfigMgr.GetList("configMainbuffs")
        for i = 1, #list do
            for j = 1, #list[i].page do
                if not GD.ItemPage[list[i].page[j]] then
                    GD.ItemPage[list[i].page[j]] = {}
                end
                table.insert(GD.ItemPage[list[i].page[j]], list[i])
            end
        end
    end
    return GD.ItemPage[pageIndex]
end

--保存背包界面物品item面板
function SaveItemPane(id, item)
    GD.backpackItemPanes[id] = item
end

--获取背包界面物品item面板
function GetItemPane(id)
    return GD.backpackItemPanes[id]
end

function CleanItemPanes()
    GD.backpackItemPanes = {}
end

--保存物品点击下拉框面板
function SetItemBoxPane(pane)
    GD.backpackItemBoxPane = pane
end

--获取物品点击下拉框面板
function GetItemBoxPane()
    return GD.backpackItemBoxPane
end

--初始化缓存的新获取物品数据
function InitCacheNewItemsStatus()
    local cacheData = Util.GetPlayerData("NewItems")
    if cacheData ~= "" then
        local datas = JSON.decode(cacheData)

        --兼容旧数据
        local newDatas = ItemAgent.HandleOldCacheNewItemDatas(datas)

        GD.NewItems = next(newDatas) and newDatas or datas
    else
        GD.NewItems = {}
    end
end

--处理旧的新获得物品缓存数据，旧数据里只存了物品配置id
function HandleOldCacheNewItemDatas(datas)
    local newDatas = {}
    for k,curDatas in pairs(datas) do
        for _,v in pairs(curDatas) do
            if type(v) ~= "table" then
                newDatas[k] = newDatas[k] or {}
                table.insert(newDatas[k], {id = v, Amount = 1})
            elseif not v.Amount then
                newDatas[k] = newDatas[k] or {}
                table.insert(newDatas[k], {id = v, Amount = 1})
            end
        end
    end

    return newDatas
end

--[[保存新获得物品状态
    data:
        ConfId,
        Amount,
]]
function SaveNewItemsStatus(datas)
    local data = GD.NewItems

    data[Model.Account.accountId] = data[Model.Account.accountId] or {}
    for _, v in pairs(datas) do
        local confId = v.ConfId
        local add = true
        for _, v1 in pairs(data[Model.Account.accountId]) do
            if tostring(v1.ConfId) == tostring(confId) then
                add = false
                v1.Amount = v1.Amount + v.Amount
                break
            end
        end
        if add then
            table.insert(data[Model.Account.accountId], {ConfId = tostring(confId), Amount = v.Amount})
        end
    end

    local json = JSON.encode(data)
    Util.SetPlayerData("NewItems", json)
end

--删除新获得物品状态
function RemoveNewItemsStatus(confIds)
    local data = GD.NewItems

    if not data[Model.Account.accountId] then
        return
    end

    -- data[Model.Account.accountId] = data[Model.Account.accountId] or {}
    for _, v in pairs(confIds) do
        local confId = v
        for k1, v1 in pairs(data[Model.Account.accountId]) do
            if v1.ConfId == tostring(confId) then
                table.remove(data[Model.Account.accountId], k1)
                break
            end
        end
    end
    local json = JSON.encode(data)
    Util.SetPlayerData("NewItems", json)
    Event.Broadcast(EventDefines.UIRefreshBackpackRedPoint)
end

--检查是否新获得物品
function CheckNewItem(confId)
    local items = GD.NewItems[Model.Account.accountId]
    if not items then
        return false
    end
    for _, v in pairs(items) do
        if v.ConfId == tostring(confId) then
            return true
        end
    end

    return false
end

--获取新物品总数
function GetNewItemAmount()
    local items = GD.NewItems[Model.Account.accountId]
    local Amount = 0
    if not items then
        return Amount
    end

    for _,_ in pairs(items) do
        Amount = Amount + 1
    end

    return math.floor(Amount)
end

--清除所有新获得物品状态
function ClearNewItem()
    local data = GD.NewItems
    data[Model.Account.accountId] = {}
    local json = JSON.encode(data)
    Util.SetPlayerData("NewItems", json)
    Event.Broadcast(EventDefines.UIRefreshBackpackRedPoint)
end

--使用物品
function UseItem(confId, num, callback)
    local count = num and num or 1
    local config = ConfigMgr.GetItem("configItems", confId)

    local canUse, tip = ItemAgent.CheckItemLimit(confId)
    if not canUse then
        if tip then
            tip()
        end
        return
    end

    local sureCallback = function()
        Net.Items.Use(
            confId,
            count,
            nil,
            function(rsp)
                if rsp.Fail then
                    return
                end

                ItemAgent.ItemUsedTip(config, count)

                if config.type == PropType.ALL.AddSoldiers then
                    --阅兵广场部队变化
                    ParadeSquareModel.ParadeSquareShow()
                end

                if rsp.Rewards and #rsp.Rewards > 0 then
                    UIMgr:Open("BackpackPopup", rsp.Rewards, true)
                end
                if callback then
                    callback()
                end
            end
        )
    end
    if config.type == PropType.ALL.Sundries and config.type2 == PropType.SUBTYPE.BuildingMove then
        -- 内城迁城
        TurnModel.BuildExgPos()
    elseif config.type == PropType.ALL.Sundries and config.type2 == PropType.SUBTYPE.Horn then
        -- 喇叭
        UIMgr:Open("Chat")
        Event.Broadcast(WORLD_CHAT_EVENT.Radio, confId)
    elseif config.type == PropType.ALL.Sundries and config.type2 == PropType.SUBTYPE.PlayerNameChange then
        -- 改名
        TurnModel.PlayerRename()
    elseif config.type == PropType.ALL.Sundries and config.type2 == PropType.SUBTYPE.AvatarChange then
        -- 改形象
        UIMgr:Open("BackpackImageModification", _G.BackpackImageModificationType.AvatarAndHead, callback)
    elseif config.type == PropType.ALL.Sundries and config.type2 == PropType.SUBTYPE.BaseMove then
        --迁城
        if confId == Global.AllianceFlyCityItemID then
            if UnionModel.CheckUnionOwner() then
                TipUtil.TipById(50272)
            else
                Net.Items.GetAllianceFlyCityPos(
                    function(rsp)
                        UIMgr:ClosePopAndTopPanel()
                        local data = {}
                        data.ConfId = Global.AllianceFlyCityItemID
                        data.BuildType = WorldBuildType.UnionGoLeader
                        data.posNum = rsp.X * 10000 + rsp.Y
                        WorldMap.AddEventAfterMap(
                            function()
                                -- WorldMap.Instance():MoveToPoint(val.X, val.Y, true, true, true, isRes)
                                Event.Broadcast(EventDefines.BeginBuildingMove, data)
                            end
                            -- ,
                            -- rsp.X,
                            -- rsp.Y
                        )
                        Event.Broadcast(EventDefines.OpenWorldMap, rsp.X, rsp.Y)
                        UIMgr:Close("Backpack")
                    end
                )
            end
        elseif confId == Global.RandFlyCityItemID then
            local list = MissionEventModel.GetList()
            if next(list) then
                TipUtil.TipById(10401)
                return
            end
            sureCallback()
            UIMgr:Close("Backpack")
        elseif confId == Global.NewbieFlyCityItemID then
            Net.CrossServer.GetServerList(
                function(data)
                    UIMgr:Open("BackpackMoveNewCity", data)
                    UIMgr:Close("Backpack")
                end
            )
        else
            sureCallback()
            UIMgr:Close("Backpack")
        end
    elseif config.type == PropType.ALL.Status and config.type2 == PropType.SUBTYPE.CityProtect then
        --防护罩
        local curBuff = Model.Find(ModelType.Buffs, config.type2)
        if curBuff and curBuff.Value > 0 then
            --判断是否防护罩未完结
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Base_Buff_Useing"),
                sureCallback = sureCallback
            }
            UIMgr:Open("ConfirmPopupText", data)
        else
            SdkModel.TrackBreakPoint(10071) --打点
            sureCallback()
        end
    elseif config.type == PropType.ALL.SpecialResUp then
        --资源建筑产量提升道具
        ItemAgent.ResUpItemUse(confId)
    elseif config.type == PropType.ALL.Sundries and config.type2 == PropType.SUBTYPE.CallRallyMonster then
        --刷怪道具
        Net.Items.CallRallyMonster(
            confId,
            function(rsp)
                if rsp.Fail then
                    return
                end
            end
        )
    elseif config.type == PropType.ALL.Status then
        --buff道具检查是否已激活相同buff
        local buff = BuffItemModel.GetModelByIdType(config.type2, Global.TypedBuffItem)
        if buff and buff.Source == Global.TypedBuffItem and buff.ExpireAt > Tool.Time() then
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Base_Buff_Useing"),
                sureCallback = function()
                    sureCallback()
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        else
            sureCallback()
        end
    elseif config.type == PropType.ALL.DressUp then
        local curTip;
        local curName = ItemAgent.GetItemNameByConfId(config.id)
        local info = DressUpModel.GetIsUsingByType(config.value)
        if info then
            local tipData = {dressup_name = curName, time = TimeUtil.SecondToDHMS(info.ExpireAt - Tool.Time())}
            curTip = StringUtil.GetI18n(I18nType.Commmon, "UI_Dressup_Tips2", tipData)
            local data = {
                content = curTip,
                sureCallback = function()
                    sureCallback()
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        else
            sureCallback()
        end

    elseif config.id == MILITARY_SUPPLY.MSItemConfId then
        --补给券使用
        -- local build = BuildModel.FindByConfId(Global.BuildingMilitarySupply)
        Net.MilitarySupplies.AddChance(
            count,
            function()
                local msInfos = Model.GetMap(ModelType.MSInfos)
                msInfos.FreeTimes = msInfos.FreeTimes + count
                Model.InitOtherInfo(ModelType.MSInfos, msInfos)
                TipUtil.TipById(50225)
                if callback ~= nil then
                    callback()
                end
            end
        )
    elseif config.id == Global.WallRepairItemId then
        if WallModel.IsDurableMax() then
            TipUtil.TipById(50281)
        else
            sureCallback()
        end
    elseif config.id == 204601 then
        --数据碎片合成
        local data = ConfigMgr.GetItem("ConfigFusions", config.id)
        if count < data.item_id[1].num then
            --弹出提示
            TipUtil.TipById(50312)
        else
            sureCallback()
        end
    else
        sureCallback()
    end
    SdkModel.TrackBreakPoint(10070) --打点
end

--使用资源建筑产量翻倍道具
function ResUpItemUse(confId)
    local buildingConfid = CommonModel.GetBuildingConfIdByResUpItem(confId)
    local isFull, building = BuildModel.GetMaxNoBuffResBuildingById(buildingConfid)
    if isFull and building then
        -- 还有资源建筑没buff
        local contentData = {number = building.Level, building_name = BuildModel.GetName(building.ConfId)}
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Ui_USEBUFF", contentData),
            sureCallback = function()
                Net.ResBuilds.UseBuffItem(
                    building.Id,
                    1,
                    function()
                        local params = {
                            number = building.Level,
                            building_name = BuildModel.GetName(building.ConfId),
                            item_name = ItemAgent.GetItemNameByConfId(confId)
                        }
                        TipUtil.TipById(50056, params)
                    end
                )
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        if building then
            -- 资源建筑都有buff
            local contentData = {building_name = BuildModel.GetName(building.ConfId)}
            local data = {
                content = StringUtil.GetI18n(I18nType.Commmon, "Ui_USEBUFF_Cover", contentData),
                sureCallback = function()
                    Net.ResBuilds.UseBuffItem(
                        building.Id,
                        1,
                        function()
                            local params = {
                                number = building.Level,
                                building_name = BuildModel.GetName(building.ConfId),
                                item_name = ItemAgent.GetItemNameByConfId(confId)
                            }
                            TipUtil.TipById(50056, params)
                        end
                    )
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        else
            -- 没有资源建筑
            local curBuildingConfid = CommonModel.GetBuildingConfIdByResUpItem(confId)
            local data = {
                building_name = BuildModel.GetName(curBuildingConfid),
                item_name = ItemAgent.GetItemNameByConfId(confId)
            }
            TipUtil.TipById(50057, data)
        end
    end
end

--获取物品图标上的标签显示内容
function GetItemInnerContent(confId)
    local config = ConfigMgr.GetItem("configItems", confId)
    if not config or config.show_num == nil or config.show_num == 0 then
        return nil
    elseif config.show_num == 1 then
        return Tool.FormatAmountUnit(config.value)
    elseif config.show_num == 2 then
        return Tool.FormatShortTimeOfSecond(config.value)
    elseif config.show_num == 3 then
        return math.ceil(config.value / 100) .. "%"
    end
end

--设置物品标签底框
function SetMiddleBg(ui, quality)
    ui.url = UITool.GetIcon({"Common", "com_case_quality_num_" .. quality})
end

--物品使用后tip提示
function ItemUsedTip(config, count)
    if config.type == PropType.ALL.Effect and config.type2 == 5 then
        -- 钻石
        local data = {
            number = Tool.FormatNumberThousands(config.value * count)
        }
        TipUtil.TipById(20001, data)
    elseif config.type == PropType.ALL.SpecialResUp then
        -- 产量翻倍
        TipUtil.TipById(20002)
    elseif config.type == PropType.ALL.Status and config.type2 == 16012 then
        -- 保护罩
        local data = {
            number = math.floor(config.buff_expire / 3600)
        }
        TipUtil.TipById(20003, data)
    elseif config.type == PropType.ALL.Effect and config.type2 == 4 then
        -- 食物
        local data = {
            number = Tool.FormatNumberThousands(config.value * count)
        }
        TipUtil.TipById(20005, data)
    elseif config.type == PropType.ALL.Effect and config.type2 == 1 then
        -- 钢铁
        local data = {
            number = Tool.FormatNumberThousands(config.value * count)
        }
        TipUtil.TipById(20006, data)
    elseif config.type == PropType.ALL.Effect and config.type2 == 3 then
        -- 石油
        local data = {
            number = Tool.FormatNumberThousands(config.value * count)
        }
        TipUtil.TipById(20007, data)
    elseif config.type == PropType.ALL.Effect and config.type2 == 2 then
        -- 稀土
        local data = {
            number = Tool.FormatNumberThousands(config.value * count)
        }
        TipUtil.TipById(20008, data)
    elseif config.type == PropType.ALL.Sundries and config.type2 == 1005 then
        -- 补给券
        TipUtil.TipById(20011)
    elseif config.type == PropType.ALL.Status and config.type2 == 11800 then
        -- 攻击加成
        local data = {
            number1 = math.floor(config.buff_expire / 3600),
            number2 = math.floor(config.value / 100)
        }
        TipUtil.TipById(20012, data)
    elseif config.type == PropType.ALL.Status and config.type2 == 16013 then
        -- 反侦察
        local data = {
            number = math.floor(config.buff_expire / 3600)
        }
        TipUtil.TipById(20022, data)
    elseif config.type == PropType.ALL.Status and config.type2 == 16005 then
        -- 维护费降低
        local data = {
            number = math.floor(config.buff_expire / 3600)
        }
        TipUtil.TipById(20023, data)
    elseif config.type == PropType.ALL.Status and config.type2 == 16103 then
        -- 虚假情报
        local data = {
            number = math.floor(config.buff_expire / 3600)
        }
        TipUtil.TipById(20024, data)
    elseif config.type == PropType.ALL.Queue and config.type2 == 2 then
        -- 建筑队列
        local data = {
            number = math.floor(config.value / 3600)
        }
        TipUtil.TipById(20029, data)
    elseif config.type == PropType.ALL.Effect and config.type2 == 9 then
        -- vip点数
        local data = {
            number = Tool.FormatNumberThousands(config.value * count)
        }
        TipUtil.TipById(20031, data)
    elseif config.type == PropType.ALL.Effect and config.type2 == 102 then
        -- 体力药
        local data = {
            number = Tool.FormatNumberThousands(config.value * count)
        }
        TipUtil.TipById(20032, data)
    elseif config.type == PropType.ALL.Effect and config.type2 == 6 then
        -- 经验
        local data = {
            number = Tool.FormatNumberThousands(config.value * count)
        }
        TipUtil.TipById(20033, data)
    elseif config.type == PropType.ALL.Effect and config.type2 == 12 then
        -- 幸运币
        local data = {
            number = Tool.FormatNumberThousands(config.value * count)
        }
        TipUtil.TipById(20035, data)
    elseif config.type == PropType.ALL.Effect and config.type2 == 13 then
        -- 高级幸运币
        local data = {
            number = Tool.FormatNumberThousands(config.value * count)
        }
        TipUtil.TipById(20036, data)
    else
        local data = {
            item_name = ItemAgent.GetItemNameByConfId(config.id)
        }
        TipUtil.TipById(20037, data)
    end
end

-- 判断物品使用条件
function CheckItemLimit(confId)
    local config = ConfigMgr.GetItem("configItems", confId)
    if config.base_lv_limit > BuildModel.GetCenterLevel() then
        -- 基地等级判断
        local tip = function()
            TipUtil.TipById(50077)
        end
        return false, tip, StringUtil.GetI18n(I18nType.Commmon, "Ui_ItemUse_Limit", {num = config.base_lv_limit})
    end
    if config.id == MILITARY_SUPPLY.MSItemConfId then
        -- 礼品券使用条件
        local tip = function()
            TipUtil.TipById(50280, {build_name = BuildModel.GetName(Global.BuildingMilitarySupply)})
        end
        local build = BuildModel.FindByConfId(Global.BuildingMilitarySupply)
        if not build then
            return false, tip, StringUtil.GetI18n(I18nType.Commmon, "Ui_Supply_UseTips")
        end

        tip = function()
            TipUtil.TipById(50111)
        end
        local canUseNum = BuildModel.GetMilitarySuppliesCanAddTime()
        if canUseNum <= 0 then
            return false, tip, StringUtil.GetI18n(I18nType.Commmon, "Ui_Supply_UseTips")
        end
    end

    return true
end

--ComfirmPopupUseRes页面使用

--按资源类型获得背包内道具
function GetResBackPackItemList(resType)
    --资源数据表是否是空
    if not next(GD.ResConfig) then
        local datas = ConfigMgr.GetList("configItems")
        for _, v in pairs(datas) do
            if v.type == 3 then
                table.insert(GD.ResConfig, v)
            end
        end
    end
    local typeResInfo = {}
    for _, v in pairs(GD.ResConfig) do
        if v.type2 == resType then
            local model = ItemAgent.GetItemModelById(v.id)
            if model then
                local data = {
                    configId = v.id,
                    amount = model.Amount,
                    value = v.value
                }
                table.insert(typeResInfo, data)
            end
        end
    end
    return typeResInfo
end

--背包内某类型资源总值，是否够填满差值，返回bool+仍然差值
function CanBackPackItemFillResNeed(resType,needCount)
    local typeResInfo = ItemAgent.GetResBackPackItemList(resType)
    local allCount = 0
    for k,v in pairs(typeResInfo) do
        allCount = v.amount * v.value + allCount
    end
    return allCount >= needCount , needCount - allCount
end

--获得最低使用数量资源道具的数据
function GetUseResMininum(resType, diffResCount)
    --资源数据表是否是空
    if not next(GD.ResConfig) then
        local datas = ConfigMgr.GetList("configItems")
        for _, v in pairs(datas) do
            if v.type == 3 then
                table.insert(GD.ResConfig, v)
            end
        end
    end
    --得到对应资源类型的数据，包括id,数量,数值
    local typeResInfo = ItemAgent.GetResBackPackItemList(resType)
    --按数值从小到大排序
    table.sort(
        typeResInfo,
        function(a, b)
            return a.value > b.value
        end
    )
    local resProp = ItemAgent.RecursionGetProportion(typeResInfo, 1, diffResCount, {}, false)
    return resProp
end

--递归获得比例
function RecursionGetProportion(typeResInfo, index, diffResCount, propTable, isContrary)
    if not typeResInfo[index] or diffResCount < 0 then
        if diffResCount > 0 then
            ItemAgent.RecursionGetProportion(typeResInfo, index - 1, diffResCount, propTable, true)
        else
            table.sort(
                propTable,
                function(a, b)
                    return a.value < b.value
                end
            )
            local diffNum = -diffResCount
            for key, propInfo in pairs(propTable) do
                local count = math.modf(diffNum / propInfo.value)
                if diffNum >= 0 and count > 0 then
                    if count >= propInfo.num then
                        diffNum = diffNum - propInfo.value * propInfo.num
                        propTable[key] = nil
                    else
                        propInfo.num = propInfo.num - count
                    end
                end
            end
        end
        return propTable
    end
    if typeResInfo[index].amount == 0 then
        local temp = isContrary and index - 1 or index + 1
        ItemAgent.RecursionGetProportion(typeResInfo, temp, diffResCount, propTable, isContrary)
        return propTable
    end
    local num = isContrary and 1 or math.modf(diffResCount / typeResInfo[index].value)
    local useNum = 0
    if num > typeResInfo[index].amount then
        useNum = typeResInfo[index].amount
    else
        useNum = num
    end
    local diffCount = diffResCount - useNum * typeResInfo[index].value
    typeResInfo[index].amount = typeResInfo[index].amount - useNum
    if useNum > 0 then
        if propTable[typeResInfo[index].configId] then
            local oldNum = propTable[typeResInfo[index].configId].num
            propTable[typeResInfo[index].configId].num = oldNum + useNum
        else
            propTable[typeResInfo[index].configId] = {num = useNum, value = typeResInfo[index].value,configId = typeResInfo[index].configId}
        end
    end
    local temp = isContrary and index - 1 or index + 1
    ItemAgent.RecursionGetProportion(typeResInfo, temp, diffCount, propTable, isContrary)
    return propTable
end
function GetShowRewardInfo(data)
    local confId =  math.ceil(data.ConfId)
    local mid = ItemAgent.GetItemInnerContent(data.ConfId)
    if data.Category == REWARD_TYPE.Res then
        local resConfigInfo = ConfigMgr.GetItem("configResourcess", confId)
        local _iconInfo = resConfigInfo.img
        local icon = {_iconInfo[1], _iconInfo[2]}
        local color = resConfigInfo.color
        return icon,color,mid
    else
        local itemConfigInfo = ItemAgent.GetItemModelByConfId(confId)
        local icon = itemConfigInfo.icon
        local color =itemConfigInfo.color
        return icon,color,mid
    end
end

function RequireActivityExchangeInfo(id, cb)
    Net.Activity.ActivityExchangeInfo(id, cb)
end

--兑换码
function UseCDKEY(key,cb)
    Net.Items.UseCDKEY(
        key,
        function(rsp)
            if cb then
                cb(rsp)
            end
        end
    )
end

AgentDefine(ItemAgent, "GetItemModel", GetItemModel)
AgentDefine(ItemAgent, "GetItemModelById", GetItemModelById)
AgentDefine(ItemAgent, "GetItemQualityByConfId", GetItemQualityByConfId)
AgentDefine(ItemAgent, "GetItmeQualityByColor", GetItmeQualityByColor)
AgentDefine(ItemAgent, "GetItemNameByConfId", GetItemNameByConfId)
AgentDefine(ItemAgent, "GetItemDescByConfId", GetItemDescByConfId)
AgentDefine(ItemAgent, "GetItemType2", GetItemType2)
AgentDefine(ItemAgent, "GetItemModelByCategory", GetItemModelByCategory)
AgentDefine(ItemAgent, "GetItemsBysubType", GetItemsBysubType)
AgentDefine(ItemAgent, "GetHaveItemsBysubType", GetHaveItemsBysubType)
AgentDefine(ItemAgent, "GetItemModelByConfId", GetItemModelByConfId)
AgentDefine(ItemAgent, "GetItemListByPage", GetItemListByPage)
AgentDefine(ItemAgent, "SaveItemPane", SaveItemPane)
AgentDefine(ItemAgent, "GetItemPane", GetItemPane)
AgentDefine(ItemAgent, "CleanItemPanes", CleanItemPanes)
AgentDefine(ItemAgent, "SetItemBoxPane", SetItemBoxPane)
AgentDefine(ItemAgent, "GetItemBoxPane", GetItemBoxPane)
AgentDefine(ItemAgent, "InitCacheNewItemsStatus", InitCacheNewItemsStatus)
AgentDefine(ItemAgent, "HandleOldCacheNewItemDatas", HandleOldCacheNewItemDatas)
AgentDefine(ItemAgent, "SaveNewItemsStatus", SaveNewItemsStatus)
AgentDefine(ItemAgent, "RemoveNewItemsStatus", RemoveNewItemsStatus)
AgentDefine(ItemAgent, "CheckNewItem", CheckNewItem)
AgentDefine(ItemAgent, "GetNewItemAmount", GetNewItemAmount)
AgentDefine(ItemAgent, "ClearNewItem", ClearNewItem)
AgentDefine(ItemAgent, "UseItem", UseItem)
AgentDefine(ItemAgent, "ResUpItemUse", ResUpItemUse)
AgentDefine(ItemAgent, "GetItemInnerContent", GetItemInnerContent)
AgentDefine(ItemAgent, "SetMiddleBg", SetMiddleBg)
AgentDefine(ItemAgent, "ItemUsedTip", ItemUsedTip)
AgentDefine(ItemAgent, "CheckItemLimit", CheckItemLimit)
AgentDefine(ItemAgent, "GetResBackPackItemList", GetResBackPackItemList)
AgentDefine(ItemAgent, "CanBackPackItemFillResNeed", CanBackPackItemFillResNeed)
AgentDefine(ItemAgent, "GetUseResMininum", GetUseResMininum)
AgentDefine(ItemAgent, "RecursionGetProportion", RecursionGetProportion)
AgentDefine(ItemAgent, "GetShowRewardInfo", GetShowRewardInfo)
AgentDefine(ItemAgent, "RequireActivityExchangeInfo", RequireActivityExchangeInfo)
AgentDefine(ItemAgent, "UseCDKEY", UseCDKEY)

return ItemAgent
