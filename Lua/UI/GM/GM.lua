--[[
    Author: songzeming
    Function: GM 工具
]]
local GM = UIMgr:NewUI("GM")

import("UI/GM/GMLog")
import("UI/GM/GMItemBtn")
local CustomEventManager = import("GameLogic/CustomEventManager")
local MissionEventModel = import("Model/MissionEventModel")

local CONTROLLER = {
    Open = "Open",
    Close = "Close"
}

-- GM工具添加方法
local GMType = {
    {
        name = GameVersion.GetLocalVersion().String,
        callback = function()
        end
    },
    {
        name = "账号",
        callback = function()
            UIMgr:Open("GMBox", "账号")
        end
    },
    {
        name = "资源和金币",
        callback = function()
            UIMgr:Open("GMBox", "资源和金币")
        end
    },
    {
        name = "道具",
        callback = function()
            UIMgr:Open("GMBox", "道具")
        end
    },
    {
        name = "打印日志",
        callback = function()
            UIMgr:Open("GMBox", "打印日志")
        end
    },
    {
        name = "输入事件",
        callback = function()
            UIMgr:Open("GMInput")
        end
    },
    {
        name = "一键完成",
        callback = function()
            UIMgr:Open("GMBox", "一键完成")
        end
    },
    {
        name = "恢复时间",
        callback = function()
            Net.GM.SetTime(
                0,
                function()
                    Tool.SyncTime()
                end
            )
        end
    },
    {
        name = "士兵",
        callback = function()
            UIMgr:Open("GMBox", "士兵")
        end
    },
    {
        name = "联盟",
        callback = function()
            UIMgr:Open("GMBox", "联盟")
        end
    },
    {
        name = "重置军需站",
        callback = function()
            Net.GM.ResetMS(Model.Account.accountId)
        end
    },
    {
        name = "添加测试邮件",
        callback = function()
            Net.GM.AddMails(Model.Account.accountId)
        end
    },
    {
        name = "删除邮件数据库",
        callback = function()
            MailModel:DeleteDBTable()
        end
    },
    {
        name = "关闭数据库",
        callback = function()
            SqliteHelper:Close(MailModel.mail_db_name)
        end
    },
    {
        name = "结束投票倒计时",
        callback = function()
            Net.GM.CompleteAllianceVote(Model.Player.AllianceId)
        end
    },
    {
        name = "添加雷达警报",
        callback = function()
            Net.GM.AddWarnings(Model.Account.accountId)
        end
    },
    {
        name = "VIP积分",
        callback = function()
            Net.GM.AddVipPoints(1000)
        end
    },
    {
        name = "城墙放火",
        callback = function()
            local params = {
                Model.Account.accountId
            }
            Network.Request("GMWallOnFireParams", params)
        end
    },
    {
        name = "改变用户vip时间",
        callback = function()
            Net.GM.ChangeVipDuration(-1750)
        end
    },
    {
        name = "清空聊天",
        callback = function()
            Net.GM.CleanChat()
        end
    },
    {
        name = "添加各类型通知",
        callback = function()
            Net.GM.SendNotify(1)
        end
    },
    {
        name = "刷新排行榜",
        callback = function()
            Net.GM.RefreshRankList()
        end
    },
    {
        name = "城墙城防降到1",
        callback = function()
            Net.GM.BreakTheWall()
        end
    },
    {
        name = "冷却所有主动技",
        callback = function()
            Net.GM.CooldownSkills()
        end
    },
    {
        name = "断开连接",
        callback = function()
            Network.ManualReconnect()
        end
    },
    {
        name = "结算黑骑士",
        callback = function()
            Net.GM.SumSiege(cb)
        end
    },
    {
        name = "结束新手期",
        callback = function()
            Net.GM.EndNewbiePeriod()
        end
    },
    {
        name = "测试黑骑士进攻",
        callback = function()
            Net.GM.SiegeAttack()
        end
    },
    {
        name = "性能检测工具",
        callback = function()
            UIMgr:Open("GMBox", "性能检测工具")
        end
    },
    {
        name = "地图相关",
        callback = function()
            UIMgr:Open("GMBox", "地图相关")
        end
    },
    {
        name = "增加美女好感度",
        callback = function()
            Net.GM.AddBeautyFavor(10)
        end
    },
    {
        name = "增加玫瑰",
        callback = function()
            Net.GM.AddRose(10)
        end
    },
    {
        name = "转盘礼包购买",
        callback = function()
            UIMgr:Open("GMBox", "转盘礼包购买")
        end
    },
    {
        name = "自定义引导",
        callback = function()
            UIMgr:Open("GMBox", "自定义引导")
        end
    },
    {
        name = "添加地图搜索对象",
        callback = function()
            MissionEventModel.GetFalconMissions()
        end
    },
    {
        name = "打开战机零件界面",
        callback = function()
            UIMgr:Open("AircraftAccessories")
        end
    },
    {
        name = "打开战机机库",
        callback = function()
            UIMgr:Open("AircraftHangar")
        end
    },
    {
        name = "添加升级app奖励邮件",
        callback = function()
            Net.GM.GMAddForceUpdateMails()
        end
    },
    {
        name = "王城战",
        callback = function()
            UIMgr:Open("GMBox", "王城战")
        end
    }
}

function GM:OnInit()
    local view = self.Controller.contentPane
    self._controller = view:GetController("Controller")
    self._controller.selectedPage = CONTROLLER.Close

    local _log = UIMgr:CreateObject("GM", "Log")
    view:AddChild(_log)

    self._btnSwitch:GetChild("title").text = "GM" .. "\n盘它"
    self._btnSwitch.draggable = true
    self:AddListener(
        self._btnSwitch.onDragEnd,
        function()
            if not self.isOpen then
                if self._btnSwitch.x <= GRoot.inst.width / 2 then
                    self._btnSwitch.x = 0
                else
                    self._btnSwitch.x = GRoot.inst.width - self._btnSwitch.width
                end
            end
        end
    )
    self:AddListener(
        self._btnSwitch.onClick,
        function()
            self:ClickSwitch()
        end
    )
    self._btnPrintLog:GetChild("title").text = "输出日志"
    -- self._btnPrintLog:init(
    --     function()
    --         _log:SetLogs()
    --     end
    -- )
    self:AddListener(
        self._btnPrintLog.onClick,
        function()
            _log:SetLogs()
        end
    )
    --初始化Log列表
    self:InitList()
    view.y = 80

    ------------------------------------------- 上线关闭
    --TODO
    --是否开启GM
    view.visible = true
    --是否输出日志
    FUIUtils.StartLogConsole()
end

function GM:OnOpen()
end

function GM:ClickSwitch()
    self.isOpen = not self.isOpen
    self._btnSwitch.draggable = not self.isOpen
    self._controller.selectedPage = self.isOpen and CONTROLLER.Open or CONTROLLER.Close
end

function GM:InitList()
    self._list.numItems = #GMType
    for i = 1, self._list.numChildren do
        local child = self._list:GetChildAt(i - 1)
        child.title = GMType[i].name
        child:init(
            function()
                GMType[i].callback()
            end
        )
    end
end

return GM
