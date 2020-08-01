--author: 	Amu
--time:		2020-07-07 16:14:45

local DressUpModel = {}
DressUpModel._init = false

DressUpModel.curSelect = DRESSUP_TYPE.Nameplate
DressUpModel.curSubSelect = 0
DressUpModel.dressUpInfo = {}
DressUpModel.usingDressUp = {}
DressUpModel.dressUpItemInfo = {}
DressUpModel.defaultDressUpUrl = {}

-- DressType:80001
-- DressUpConId:80001399
-- ConfId:401199
-- ExpireAt:1595298756
function DressUpModel.InitUser(info)
    for _,v in ipairs(info)do
        DressUpModel.usingDressUp[v.DressType] = v
    end
end

function DressUpModel.Init()
    if DressUpModel._init then
        return
    end
    DressUpModel._init = true

    local config = ConfigMgr.GetList("configDressups")
    for _,v in ipairs(config)do
        if not DressUpModel.dressUpInfo[v.type] then
            DressUpModel.dressUpInfo[v.type] = {}
        end
        if v.is_show == 1 then
            table.insert(DressUpModel.dressUpInfo[v.type], {config = v})
        end
    end

    DressUpModel.InitEvent()
end

function DressUpModel.InitEvent()
end

function DressUpModel.RefreshUsingDressUp(info)
    for k,v in pairs(DressUpModel.usingDressUp)do
        if v.DressType == info.DressType then
            DressUpModel.usingDressUp[k] = info
            break
        end
    end
end

function DressUpModel.GetIsUsingByType(dressUpId)
    for _,v in pairs(DressUpModel.usingDressUp)do
        if v.DressUpConId == dressUpId then
            return v
        end
    end
    return nil
end

function DressUpModel.GetDressUpInfo()
    DressUpModel.Init()
    return DressUpModel.dressUpInfo
end

function DressUpModel.GetCurSelectDressUpInfo()
    return DressUpModel.GetDressUpInfoByType(DressUpModel.curSelect)
end

function DressUpModel.GetDressUpInfoByType(dressUpType)
    DressUpModel.Init()
    return DressUpModel.dressUpInfo[dressUpType] and DressUpModel.dressUpInfo[dressUpType] or nil
end

function DressUpModel.GetDressUpInfoById(dressUpId)
    DressUpModel.Init()
    for _,v in pairs(DressUpModel.dressUpInfo[DressUpModel.curSelect])do
        if v.config.id == dressUpId then
            return v
        end
    end
    return nil
end

function DressUpModel.GetDressUpInfoByTypeAndId(dressUpType, dressUpId)
    DressUpModel.Init()
    for _,v in pairs(DressUpModel.dressUpInfo[dressUpType])do
        if v.config.id == dressUpId then
            return v
        end
    end
    return nil
end

function DressUpModel.RevertDefaultDressUp(dressUpType)
    local info = DressUpModel.GetDressUpInfoByType(dressUpType)
    for _,v in pairs(info)do
        if v.config.default == 0 then
            DressUpModel.curSubSelect = v.config.id
            break
        end
    end
end

function DressUpModel.GetDefaultDressUpUrl(dressUpType)
    if not DressUpModel.defaultDressUpUrl[dressUpType] then
        local info = DressUpModel.GetDressUpInfoByType(dressUpType)
        for _,v in pairs(info)do
            if v.config.default == 0 then
                DressUpModel.defaultDressUpUrl[dressUpType] = v.config.style
                break
            end
        end
    end
    return DressUpModel.defaultDressUpUrl[dressUpType]
end

function DressUpModel.GetDefaultDressUp(dressUpType)
    local info = DressUpModel.GetDressUpInfoByType(dressUpType)
    for _,v in pairs(info)do
        if v.config.default == 0 then
            return v.config
        end
    end
    return nil
end

function DressUpModel.GetSelectDressUp(dressUpId)
    local dressUpList = {}
    for _,v in ipairs(DressUpModel.dressUpItemInfo[DressUpModel.curSelect].Hold) do
        if v.DressUpConId == dressUpId then
            table.insert(dressUpList, v)
        end
    end
    return dressUpList
end


function DressUpModel.ClearDressUpItemInfo(dressUpType)
    DressUpModel.dressUpItemInfo[dressUpType] = nil
end

function DressUpModel.ClearAllDressUpItemInfo()
    DressUpModel.dressUpItemInfo = {}
end


-------------------------------------------

-- ExpireAt:1626519107
-- Amount:0
-- ConfId:402001
-- DressUpConId:80002001
-- Using:true
function DressUpModel.GetDressUpType(dressUpType, cb)
    DressUpModel.Init()
    if not DressUpModel.dressUpItemInfo[dressUpType] then
        Net.DressUp.GetDressUpType(dressUpType, function(msg)
            DressUpModel.dressUpItemInfo[dressUpType] = msg
            -- for _,v in pairs(DressUpModel.dressUpInfo[dressUpType])do
            --     if v.config.id == msg.Using.DressUpConId then
            --         v.isUsed = true
            --     else
            --         v.isUsed = false
            --     end
            -- end
            cb()
        end)
    else
        cb()
    end
end

function DressUpModel.UseDressUp(configId, cb)
    Net.DressUp.UseDressUp(configId, function(msg)
        if cb then
            TipUtil.TipById(50355, {dressup_name = StringUtil.GetI18n(I18nType.Item, "ITEM_NAME_"..configId)})
            cb()
        end
    end)
end

return DressUpModel