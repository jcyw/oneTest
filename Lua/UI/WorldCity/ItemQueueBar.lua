--[[
    author:{zhanzhang}
    time:2019-06-14 20:56:10
    function:{行军队列}
]]
local ItemQueueBar = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/worldQueueBar", ItemQueueBar)

import("Utils/Scheduler")
import("Utils/TimeUtil")
local WorldMap = import("UI/WorldMap/WorldMap")
local MissionEventModel = import("Model/MissionEventModel")
local MapModel = import("Model/MapModel")
local UnionWarfareModel = import("Model/Union/UnionWarfareModel")
local UnionInfoModel = import("Model/Union/UnionInfoModel")
local UnionModel = import("Model/UnionModel")

function ItemQueueBar:ctor()
    self._progressBar = self:GetChild("progressBar")
    self._desc = self:GetChild("titleName")
    self._icon = self:GetChild("iconMarch")
    self._btnRecall = self:GetChild("btnRecall")
    self._btnAccelerate = self:GetChild("btnAccelerate")
    self._btnTouch = self:GetChild("Touch")
    self._controller = self:GetController("c1")
    self:AddListener(
        self._btnRecall.onClick,
        function()
            -- if self.data.Status == Global.MissionStatusRally then
            --
            -- else
            --     local data = {
            --         content = StringUtil.GetI18n(I18nType.Commmon, "Confirm_Army_Return"),
            --         sureCallback = function()
            --             self:OnBtnBackClick()
            --         end,
            --         buttonType = "double"
            --     }
            --     UIMgr:Open("ConfirmPopupText", data)
            -- end
            self:OnBtnBackClick()
        end
    )
    self:AddListener(
        self._btnAccelerate.onClick,
        function()
            UIMgr:Open("MarchAcceleration", self.data)
        end
    )
    self:AddListener(
        self._btnTouch.onClick,
        function()
            self:OnGotoRoute()
        end
    )
    self.calTimeFunc = {}
end

function ItemQueueBar:init(data)
    self:UnSchedule(self.calTimeFunc)
    self.data = data
    --集结返回后属于自身加速，不属于联盟加速
    if data.Category == Global.MissionRally and not data.IsReturn then
        data.marchType = MarchType.Union
    end

    self.countDownTime = data.Duration

    self.calTimeFunc = function()
        self:OnCalTime()
    end
    self.remainTimePoint = 0
    --category为行军目的
    local queueId = data.Category * 100 + data.Status + 10000
    local info = ConfigMgr.GetItem("configMapQueues", queueId)
    if data.IsReturn then
        self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "MAP_RETURN_BUTTON")
    else
        self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, info.statusText, {number_x = data.StopX, number_y = data.StopY})
    end
    self._icon.icon = info.statusIcon and UITool.GetIcon(info.statusIcon) or ""

    --行军状态中
    if data.Status == Global.MissionStatusMarch or data.Status == Global.MissionStatusRallyMarch then
        -- 行军中
        self._btnAccelerate.title = StringUtil.GetI18n(I18nType.Commmon, info.buttonText)
        self._controller.selectedIndex = 2
        -- self.isMining = false
        self.remainTimePoint = data.FinishAt
        self._progressBar.max = 100
        --data.Duration
        self.countDownTime = data.Duration

        if data.Status == Global.MissionStatusRallyMarch then
            self.data.isRallyMarch = true
        end
    elseif data.Status == Global.MissionStatusExploring then
        -- 探索中
        self._btnRecall.title = StringUtil.GetI18n(I18nType.Commmon, info.buttonText)
        self._controller.selectedIndex = 0
        self.remainTimePoint = data.MineFinishAt
        self._progressBar.max = 100
        self.countDownTime = Global.SecretBaseExploreTime[tonumber(data.Params) + 1]
    elseif data.Status == Global.MissionStatusRally then
        -- 集结中
        self._btnRecall.title = StringUtil.GetI18n(I18nType.Commmon, info.buttonText)
        self._controller.selectedIndex = 0
        self.remainTimePoint = data.RallyTill
        self._progressBar.max = 100
        self.countDownTime = data.RallyTill - data.RallyCreateAt
    elseif data.Status == Global.MissionStatusMining then
        --采集状态
        self._btnRecall.title = StringUtil.GetI18n(I18nType.Commmon, info.buttonText)
        -- self.isMining = true
        self._controller.selectedIndex = 0
        self.remainTimePoint = data.MineFinishAt
        self._progressBar.max = 100
        --data.MineFinishAt - data.FinishAt
        self.countDownTime = data.MineFinishAt - data.FinishAt
        --采集状态按照自愿图标特殊处理
        if data.Category == 3 then
            local confId = tonumber(data.Params)
            if confId > 0 then
                local mineInfo = ConfigMgr.GetItem("configMines", confId)
                local icon = ConfigMgr.GetItem("configResourcess", mineInfo.category).img
                self._icon.icon = UITool.GetIcon(icon)
            end
        end
    else
        self._btnRecall.title = StringUtil.GetI18n(I18nType.Commmon, info.buttonText)
        self._controller.selectedIndex = 1
        self._titleCoordinate.text = "(X:" .. data.StopX .. ", Y:" .. data.StopY .. ")"
    end
    self:Schedule(self.calTimeFunc, 1, true, 0)
end
--队伍时间列表item 点击返回事件
function ItemQueueBar:OnBtnBackClick()
    if self.data.Status ~= Global.MissionStatusRally then
        self:UnSchedule(self.calTimeFunc)
    end
    if self.data.Category == Global.MissionExplore then
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "TIPS_EARLY_LEAVE"),
            sureCallback = function()
                Net.Missions.Cancel(self.data.Uuid)
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
        return
    end
    if
        self.data.Status == Global.MissionStatusMining or self.data.Status == Global.MissionStatusCamp or self.data.Status == Global.MissionStatusAssist or
            self.data.Status == Global.MissionStatusGarrison or
            self.data.Status == Global.MissionStatusBuilding or
            self.data.Status == Global.MissionStatusDestroying or
            self.data.Status == Global.MissionStatusExploring or 
            self.data.Status == Global.MissionStatusRepair
     then
        --采集、扎营、士兵援助手动返回
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Confirm_Army_Return"),
            sureCallback = function()
                Net.Missions.Cancel(self.data.Uuid)
                Event.Broadcast(EventDefines.UIOffAnim)
            end,
            buttonType = "double"
        }
        UIMgr:Open("ConfirmPopupText", data)
    elseif self.data.Status == Global.MissionStatusRally then
        --联盟集结查看
        local id = Model.Player.AllianceId
        UnionModel.RequestAllianceBattle(
            id,
            function(rsp)
                if rsp.Fail then
                    return
                end

                UnionWarfareModel.SetUnionWarfareInfo(rsp)
                local list = rsp.Battles
                for _, v in pairs(list) do
                    if v.Uuid == self.data.AllianceBattleId then
                        UIMgr:Open("UnionAggregation", v)
                        break
                    end
                end
            end
        )
    else
        UIMgr:Open("MarchAcceleration", self.data)
    end
end
--打开行军加速界面
function ItemQueueBar:OnBtnSpeedUp()
end

--前往路线所在位置
function ItemQueueBar:OnGotoRoute()
    if not (self.data.Status == Global.MissionStatusMarch or self.data.Status == Global.MissionStatusRallyMarch) then
        Event.Broadcast(EventDefines.UICloseMapDetail)
        WorldMap.Instance():GotoPoint(self.data.StopX, self.data.StopY)
        Net.MapInfos.PointInfo(
            UserModel.SceneId(),
            self.data.StopX,
            self.data.StopY,
            function(val)
                MapModel.RefreshMap(val)
                if self.data.Category == Global.MissionExplore then
                    return
                end
                -- MoveToPoint
                -- WorldMap.Instance():MoveToPoint(self.data.StopX, self.data.StopY, false)
                WorldMap.Instance():ChooseLogicPos(self.data.StopX * 10000 + self.data.StopY, true)
            end
        )
    else
        if self.data.Category == Global.MissionRally and self.data.Status == Global.MissionStatusRallyMarch then
            Net.Missions.GetRallyCaptainMission(
                self.data.Uuid,
                function(rsp)
                    WorldMap.Instance():GotoClickMarchUnit(rsp.Mission)
                end
            )
        else
            WorldMap.Instance():GotoClickMarchUnit(self.data)
        end
    end
end

--计算任务倒计时时间
function ItemQueueBar:OnCalTime()
    local remainTime = self.remainTimePoint - Tool.Time()
    if (remainTime <= 0) then
        self:UnSchedule(self.calTimeFunc)
        return
    end
    if self.data.Status == Global.MissionStatusMining or self.data.Status == Global.MissionStatusRally or self.data.Status == Global.MissionStatusExploring then
        self._progressBar.value = (self.countDownTime - remainTime) / self.countDownTime * 100
    else
        self._progressBar.value = GameUtil.CalTimeSilderVal(self.data) * 100
    end
    self._progressTime.text = TimeUtil.SecondToDHMS(remainTime)
end

return ItemQueueBar
