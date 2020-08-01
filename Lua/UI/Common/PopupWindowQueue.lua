--[[
    Author: songzeming
    Function: 弹窗队列缓存
]]
if PopupWindowQueue then
    return PopupWindowQueue
end
PopupWindowQueue = {}

local wins = {}
local CENTER_UPGRADE = nil
local GlobalVars = GlobalVars

--是否时指挥中中心升级
local function CheckCenterUpgrade(name)
    return name == "BuildCenterUpgrade"
end

--在队列尾部插入一个元素
function PopupWindowQueue:Push(name, args)
    if CheckCenterUpgrade(name) and PlayerDataModel:GetData(PlayerDataEnum.CENTER_UPGRADE_OPEN) then
        --GM取消指挥中心升级弹窗
        return
    end

    local uiInfo = ConfigMgr.GetItem("configUIs", name)
    if not uiInfo then
        Log.Warning("ui not exist : ", name)
        return
    end

    if CheckCenterUpgrade(name) then
        if CENTER_UPGRADE then
            CENTER_UPGRADE.args.times = CENTER_UPGRADE.args.times + 1
            self:CheckPop()
        else
            local win = {
                name = name,
                order = uiInfo.order and uiInfo.order or 0,
                args = {level = args, times = 1},
            }
            CENTER_UPGRADE = win
            table.insert(wins, win)
            table.sort(wins, function(a, b) return a.order < b.order end)
            self:CheckPop()
        end
    else
        local win = {
            name = name,
            order = uiInfo.order and uiInfo.order or 0,
            args = args
        }
        table.insert(wins, win)
        table.sort(wins, function(a, b) return a.order < b.order end)
        self:CheckPop()
    end
end

--关闭定时器
function PopupWindowQueue:CloseScheduler()
    if self.pop_func then
        Scheduler.UnScheduleFast(self.pop_func)
    end
end
--检测是否可以弹窗
function PopupWindowQueue:CheckPop(isDelay)
    if not GlobalVars.IsInCity then
        return
    end
    if GlobalVars.IsNoviceGuideStatus then
        return 
    end
    if GlobalVars.IsTriggerStatus then
        return
    end
    if isDelay then
        if not GlobalVars.IsAllowPopWindow then
            return
        end
    end
    if self:Empty() then
        return
    end
    if UIMgr:GetShowPanelCount() > 0 then
        return
    end
    if UIMgr:GetWindowCount() > 0 then
        return
    end

    self:CloseScheduler()
    if isDelay then
        self:Pop()
    else
        self.pop_func = function()
            self:CheckPop(true)
        end
        Scheduler.ScheduleOnceFast(self.pop_func, 1.1)
    end
end

--将队列中最靠前位置的元素拿掉（剔除）
function PopupWindowQueue:Pop()
    local win = wins[1]
    table.remove(wins, 1)
    UIMgr:Open(win.name, win.args)
    if CheckCenterUpgrade(win.name) then
        CENTER_UPGRADE = nil
    end
end

--判断队列是否为空
function PopupWindowQueue:Empty()
    return next(wins) == nil
end

return PopupWindowQueue
