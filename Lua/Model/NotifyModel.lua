--author: 	Amu
--time:		2019-12-17 21:04:42

if NotifyModel then
    return NotifyModel
end

local BuildModel = import("Model/BuildModel")
local WelfareModel = import("Model/WelfareModel")

NotifyModel = {}
local notifyList = {}
local _scheduler = false
local _len = 0

function NotifyModel.Init()
    XLuaEvent.AddEvent("ClickNotify", NotifyModel.ClickNotify)
    XLuaEvent.AddEvent("SetToken", NotifyModel.SetToken)
end

-- function NotifyModel.SendNotify(notyifyId)
--     local title = "title"
--     local content = "这是一个长文本,表情:&#x1F602,这是一个长文本,表情:&#x1F602."
--     local subtitle = "<b>SubTitle</b><br/>"
--     NotifyMgr.Instance:SendNotify(0, title, content,subtitle..subtitle, Color.red, "notify_icon_big", "OpenMail")
-- end

function NotifyModel.RefreshNotifyList()
    if not UserModel._init then
        return
    end
    notifyList = {}
    local id = 0
    local _upgradeList = {70300001, 70300002, 70300004}
    if type(Model.UpgradeEvents) == "table" then
        for _,v in pairs(Model.UpgradeEvents) do--建造升级
            id = id + 1
            if v.Category == Global.EventTypeBuilding and Model.Find(ModelType.NotifySettings, 10001).Open then  -- 建筑事件
                local confId = BuildModel.FindById(v.TargetId).ConfId
                local data = {
                    building_lv = v.UpgradeTo,
                    building_name = BuildModel.GetName(confId)
                }
                -- NotifyModel.AddNotify(id, _upgradeList[math.random(#_upgradeList)], v.FinishAt-Tool.Time(), data)
                if v.UpgradeTo == 1 then
                    NotifyModel.AddNotify(id, 70300001, v.FinishAt-Tool.Time(), data)
                else
                    NotifyModel.AddNotify(id, 70300002, v.FinishAt-Tool.Time(), data)
                end
            elseif v.Category == Global.EventTypeTech and Model.Find(ModelType.NotifySettings, 10001).Open then    --科技事件
                NotifyModel.AddNotify(id, 70300003, v.FinishAt-Tool.Time())
            -- elseif v.Category == Global.EventTypeWeapon then    --拆除建筑
            --     NotifyModel.AddNotify(id, 70300005, v.FinishAt-Tool.Time())
            end
        end
    end

    if Model.Find(ModelType.NotifySettings, 10001).Open then
        if type(Model.TrainEvents) == "table" then
            for _,v in pairs(Model.TrainEvents) do--造兵
                id = id + 1
                local data = {
                    army_name = ConfigMgr.GetI18n("configI18nArmys", v.ConfId.."_NAME")
                }
                NotifyModel.AddNotify(v.BuildingId, 70300005, v.FinishAt-Tool.Time(), data)
            end
        end
    end

    if type(Model.MissionEvents) == "table" then
        for _,v in pairs(Model.MissionEvents) do--行军
            id = id + 1
            if v.Category == Global.MissionReturn and Model.Find(ModelType.NotifySettings, 10009).Open then  -- 行军-返回
                NotifyModel.AddNotify(id, 70300016, v.FinishAt-Tool.Time())
            end
        end
    end

    if type(Model.CureEvents) then
        for _,v in pairs(Model.CureEvents) do--治疗
            id = id + 1
            NotifyModel.AddNotify(id, 70400034, v.FinishAt-Tool.Time())
        end
    end
    local vipTime = Model.Player.VipExpiration - Tool.Time()
    if vipTime > 0 and Model.Find(ModelType.NotifySettings, 10011).Open then         -- vip到期
        id = id + 1
        local data = {
            player_name = Model.Player.Name
        }
        NotifyModel.AddNotify(id, 70300065, vipTime, data)
    end

    local createTime = Model.Player.CreatedAt


    local _list = {70300050,70300051,70300052,70300053,70300054,70300055,70300056}
    for d,v in ipairs(_list)do  --創建第d天
        local _data = {
            year= os.date("%Y", createTime), 
            month= os.date("%m", createTime), 
            day= os.date("%d", createTime), 
            hour=5,
            minute=0, 
            second=0}
        local time = os.time(_data) + d*24*60*60
        local _t = time - os.time()
        if _t > 0 then
            id = id + 1
            local data = {
                player_name = Model.Player.Name
            }
            NotifyModel.AddNotify(id, v, _t, data)
        end
    end


    id = id + 1
    NotifyModel.AddNotify(id, 70300083, 3*24*60*60) --3天未登錄
    id = id + 1
    NotifyModel.AddNotify(id, 70300084, 7*24*60*60) --7天未登錄

    id = id + 1
    local time = WelfareModel.getFalconRestoreFillTimer()   -- 猎鹰活动推送
    if  time > 0 then
        NotifyModel.AddNotify(id, 70300085, time)
    end
end

-- id           事件唯一id
-- notyifyId    通知id
-- delay        通知延时
-- data         需要填充内容的多语言
function NotifyModel.AddNotify(id, notyifyId, delay, data)
    local config = ConfigMgr.GetItem("configNotifys", notyifyId)
    if not config then
        Log.Warning("=============== "..notyifyId.."  not find =============")
        return
    end

    local notify = {}
    notify.id = id
    notify.notyifyId = notyifyId
    notify.delay = delay
    notify.title = StringUtil.GetI18n("configI18nNotifys", config.title)
    notify.content = StringUtil.GetI18n("configI18nNotifys", config.content, data)
    notify.subtitle = StringUtil.GetI18n("configI18nNotifys", config.subtitle)
    notify.bigIcon = "notify_icon_big"
    notify.smallIcon = "notify_icon_small"
    notify.soundName = config.sound

    notifyList[id] = notify
    _len = _len + 1
end

function NotifyModel:DelNotify(id)
    table.remove(notifyList, id)
    _len = _len + 1
end

function NotifyModel.StartNotify()
    NotifyModel.RefreshNotifyList()
    for _,notify in pairs(notifyList)do
        if notify.delay > 0 then
            NotifyMgr.Instance:SendNotify(notify.id, math.ceil(notify.delay)*1000, notify.title, notify.content, notify.subtitle.."<br/>"..notify.content, 
                    Color.black, notify.bigIcon, notify.smallIcon, notify.soundName, notify.notyifyId)
        end
    end
end

function NotifyModel.ClearNotify()
    for _,notify in pairs(notifyList)do
        NotifyMgr.Instance:StopNotify(notify.id)
    end
    notifyList = {}
end

function NotifyModel.SetToken(token)
    Log.Info("============SetToken============" .. token)
    Net.Logins.SetDeviceToken(token)
end

-----------------------本地通知点击回调-----------------------

function NotifyModel.ClickNotify(info)
    if info == 70300016 then
        TurnModel.WorldMap()
    else
        UIMgr:ClosePopAndTopPanel()
    end
end

----------------------服务器通知点击回调----------------------

return NotifyModel