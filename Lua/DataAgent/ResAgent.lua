local GD = _G.GD
local ResAgent = GD.LVar("ResAgent", {})
local AgentDefine = GD.AgentDefine

local BuildModel = _G.import("Model/BuildModel")
local Model = _G.Model
local ModelType = _G.ModelType
local ConfigMgr = _G.ConfigMgr
local Tool = _G.Tool
local Net = _G.Net
local TipUtil = _G.TipUtil
local UIMgr = _G.UIMgr
local GlobalItem = _G.GlobalItem
local SdkModel = _G.SdkModel
local Event = _G.Event
local EventDefines = _G.EventDefines
local Global = _G.Global
local UITool = _G.UITool
local UIPackage = _G.UIPackage

local GetResOutPut -- 支援总产量
local GetResBasicOutPut -- 基本产量
local Amount -- 根据(category资源类型)获取资源数量 (isFormat是否格式化)
local SafeAmount -- 根据(category资源类型)获取安全资源数量 (isFormat是否格式化)
local GetSourceAmount -- 所有可以获取(category资源类型)消耗的所消耗的资源
local UseAllSource -- 使用所有同类道具
local GetName -- 根据(category资源类型)获取资源名字
local Update -- 刷新资源
local GetResUnlock -- 获取资源解锁显示
local CheckResUnlock -- 检查资源是否解锁
local GetIconUrl -- 获取资源icon的url
local GetIconInfo
local GetDiamondSmallIcon -- 获取按钮上显示的钻石小图标
local Get128IconUrl
local Get128Icon
local GetIconQuality -- 获取资源icon的品质
local GetIcon -- 获取资源icon
local GetEnergy -- 获取当前体力值

--支援总产量
function GetResOutPut(type)
    local resBuildInfo = Model.GetMap(ModelType.ResBuilds)
    local produce = 0

    for _, v in pairs(resBuildInfo) do
        if v.Category == type then
            if v.BuffExpireAt > Tool.Time() then
                produce = produce + v.Produce * 2
            else
                produce = produce + v.Produce
            end
        end
    end
    return math.ceil(produce)
end

--基本产量
function GetResBasicOutPut(type)
    local resBuildInfo = Model.GetMap(ModelType.ResBuilds)
    local produce = 0

    for _, v in pairs(resBuildInfo) do
        local buildInfo = Model.Buildings[v.Id]
        if v.Category == type then
            local confId = buildInfo.ConfId + buildInfo.Level
            produce = produce + ConfigMgr.GetItem("configResBuilds", confId).produce
        end
    end
    return math.ceil(produce)
end

-- 根据(category资源类型)获取资源数量 (isFormat是否格式化)
function Amount(category, isFormat)
    local res = Model.Resources[category]
    if isFormat then
        return Tool.FormatAmountUnit(res.Amount)
    end
    return res.Amount
end

-- 根据(category资源类型)获取安全资源数量 (isFormat是否格式化)
function SafeAmount(category, isFormat)
    local res = Model.Resources[category]
    if isFormat then
        return Tool.FormatAmountUnit(res.SafeAmount)
    end
    return res.SafeAmount
end

-- 所有可以获取(category资源类型)消耗的所消耗的资源
function GetSourceAmount(category)
    local curAllModel = {} -- 玩家拥有的当前类型的所有资源model
    local datas = ConfigMgr.GetList("configItems")
    for _, v in pairs(datas) do
        if v.type == 3 and v.type2 == category then
            local model = GD.ItemAgent.GetItemModelById(v.id)

            -- 显示拥有的和能购买的资源
            if (model ~= nil and model.Amount > 0) then
                table.insert(curAllModel, model)
            end
        end
    end
    local itemAmounts = {}
    local curAmount = 0
    for _, v in pairs(curAllModel) do
        local config = ConfigMgr.GetItem("configItems", v.ConfId)
        curAmount = curAmount + (v.Amount * config.value)
        table.insert(itemAmounts, {ConfId = v.ConfId, Amount = v.Amount})
    end
    return itemAmounts,curAmount
end
-- 使用所有同类道具
function UseAllSource(itemAmounts,curAmount,curResType,contentxt,cb)
    local data = {
        items = {
            [1] = {
                icon = GD.ResAgent.GetIconUrl(curResType, true),
                 amount = "X" .. Tool.FormatAmountUnit(curAmount)
            }
        },
        content = contentxt,
        cbOk = function()
            Net.Items.BatchUse(
                itemAmounts,
                function(rsp)
                    if rsp.Fail then
                        return
                    end

                    TipUtil.TipById(50040, Tool.FormatAmountUnit(curAmount) .. ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_" .. curResType))
                    if cb then
                        cb()
                    end
                end
            )
        end
    }
     UIMgr:Open("BackpackUseDetails", data)
end

-- 根据(category资源类型)获取资源名字
function GetName(category)
    return ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_" .. category)
end

-- 刷新资源
function Update(amounts)
    for _, v in pairs(amounts) do
        Model.Update(ModelType.Resources, v.Category, v)

        if v.Category == GlobalItem.ItemEffectGem then
            if (Model.Player.Gem - v.Amount) > 0 then
                SdkModel.TrackBreakPoint(10022, math.abs(Model.Player.Gem - v.Amount)) --打点
            else
                SdkModel.TrackBreakPoint(10021, math.abs(Model.Player.Gem - v.Amount)) --打点
            end
            Model.Player.Gem = v.Amount
            Event.Broadcast(EventDefines.UIGemAmount, v.Amount)
        end

        if v.Category == Global.UnionHonor then
            Model.Player.Honor = v.Amount
        end
    end
end

-- 获取资源解锁显示
function GetResUnlock()
    local lv = BuildModel.GetCenterLevel()
    local data = {}
    for _, v in ipairs(Global.ResUnlockLevel) do
        if lv >= v.level then
            table.insert(data, v.category)
        end
    end
    return data
end

-- 检查资源是否解锁
function CheckResUnlock(category)
    local lv = BuildModel.GetCenterLevel()
    local needLv
    for _, v in ipairs(Global.ResUnlockLevel) do
        if v.category == category then
            if lv >= v.level then
                return true
            else
                needLv = v.level
            end
        end
    end

    -- 没有配置默认解锁
    if not needLv then
        return true
    end

    return false, needLv
end

-- 获取资源icon的url
function GetIconUrl(category, isSmall)
    local info = GD.ResAgent.GetIconInfo(category, isSmall)
    return UITool.GetIcon(info)
end

function GetIconInfo(category, isSmall)
    local config = ConfigMgr.GetItem("configResourcess", category)
    local _iconInfo = isSmall and config.icon or config.img
    local info = {_iconInfo[1], _iconInfo[2]}
    return info
end

-- 获取按钮上显示的钻石小图标
function GetDiamondSmallIcon()
    return UIPackage.GetItemURL("Common", "icon_diamond_02")
end

function Get128IconUrl(category)
    local _iconInfo = ConfigMgr.GetItem("configResourcess", category).img128
    return UITool.GetIcon(_iconInfo)
end

function Get128Icon(category)
    local _iconInfo = ConfigMgr.GetItem("configResourcess", category).img128
    return _iconInfo
end

-- 获取资源icon的品质
function GetIconQuality(category)
    return ConfigMgr.GetItem("configResourcess", category).color
end

-- 获取资源icon
function GetIcon(category)
    return ConfigMgr.GetItem("configResourcess", category).img
end

--获取当前体力值
function GetEnergy()
    local energy = Model.Player.Energy
    if energy >= 100 then
        return energy
    else
        local duration = Tool.Time() - Model.Player.EnergyRefreshAt
        energy = energy + math.floor(duration / Model.EnergyRecoverTick)
        if energy >= 100 then
            energy = 100
        end
        return energy
    end
end

AgentDefine(ResAgent, "GetResOutPut", GetResOutPut)
AgentDefine(ResAgent, "GetResBasicOutPut", GetResBasicOutPut)
AgentDefine(ResAgent, "Amount", Amount)
AgentDefine(ResAgent, "SafeAmount", SafeAmount)
AgentDefine(ResAgent, "GetSourceAmount", GetSourceAmount)
AgentDefine(ResAgent, "UseAllSource", UseAllSource)
AgentDefine(ResAgent, "GetName", GetName)
AgentDefine(ResAgent, "Update", Update)
AgentDefine(ResAgent, "GetResUnlock", GetResUnlock)
AgentDefine(ResAgent, "CheckResUnlock", CheckResUnlock)
AgentDefine(ResAgent, "GetIconUrl", GetIconUrl)
AgentDefine(ResAgent, "GetIconInfo", GetIconInfo)
AgentDefine(ResAgent, "GetDiamondSmallIcon", GetDiamondSmallIcon)
AgentDefine(ResAgent, "Get128IconUrl", Get128IconUrl)
AgentDefine(ResAgent, "Get128Icon", Get128Icon)
AgentDefine(ResAgent, "GetIconQuality", GetIconQuality)
AgentDefine(ResAgent, "GetIcon", GetIcon)
AgentDefine(ResAgent, "GetEnergy", GetEnergy)

return ResAgent
