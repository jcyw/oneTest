--[[
    Author: songzeming
    Function: 公用模板 提示红点
]]
if CuePointModel then
    return CuePointModel
end
CuePointModel = {}

--提示点类型
CuePointModel.Type = {
    Red = "Red", --红点
    RedNumber = "RedNumber", --红点 带数字
    GreenNumber = "GreenNumber", --绿色
    Warning = "Warning", --感叹号
    N = "N"
}
CuePointModel.Pos = {
    RightUp = 11, --右上角 前提是锚点在(0,0)
    RightUp10 = 12,
    RightUp12 = 13,
    RightUp15 = 14,
    RightUp20 = 15,
    RightUp2212 = 51,
    RightUp2515 = 52,
    RightUp7015 = 55,
    PlayerDown = 101,
    MainGift = 102,
    Sidebar = 103,
    UnionList = 104,
    MainDown = 105,
    Warning = 121
}
--提示点主类型
local MainType = {
    Player = "Player", --主界面：指挥官详情
    Gift = "Gift", --主界面：礼包
    Welfare = "Welfare", --主界面：福利
    Sidebar = "Sidebar", --主界面：侧边栏
    Task = "Task", --主界面：任务
    Mail = "Mail", --主界面：邮件
    Union = "Union" --主界面：联盟
}
--提示点子类型
CuePointModel.SubType = {
    --主界面：指挥官详情
    Player = {
        --成就墙
        PlayerWall = {
            Main = MainType.Player,
            Key = "PlayerWall",
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        --技能
        PlayerSkill = {
            Main = MainType.Player,
            Key = "PlayerSkill",
            Type = CuePointModel.Type.GreenNumber,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        --设置
        PlayerSet = {
            Main = MainType.Player,
            Key = "PlayerSet",
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        }
    },
    --主界面：礼包
    Gift = {
        --每日小礼包
        DailyGift = {
            Main = MainType.Gift,
            Key = "DailyGift",
            Type = CuePointModel.Type.Warning,
            Pos = CuePointModel.Pos.MainGift,
            Number = 0
        }
    },
    --主界面：福利
    Welfare = {
        --每日签到
        DailySign = {
            Main = MainType.Welfare,
            Key = "DailySign",
            Id = 1900001,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        --日常任务
        DailyTask = {
            Main = MainType.Welfare,
            Key = "DailyTask",
            Id = 1900002,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        --理财基金
        FinancialFund = {
            Main = MainType.Welfare,
            Key = "FinancialFund",
            Id = 1900101,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        --超值好礼（月卡）
        MonthCard = {
            Main = MainType.Welfare,
            Key = "MonthCard",
            Id = 1900201,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        --成长基金
        GrowthFund = {
            Main = MainType.Welfare,
            Key = "GrowthFund",
            Id = 1900203,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        --新手累计签到
        RookieSign = {
            Main = MainType.Welfare,
            Key = "RookieSign",
            Id = 1900502,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        --新手成长之路
        RookieGrowth = {
            Main = MainType.Welfare,
            Key = "RookieGrowth",
            Id = 1900601,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        --赌场集结
        CasionMass = {
            Main = MainType.Welfare,
            Key = "CasionMass",
            Id = 1900701,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        --战时警戒
        DetectActivity = {
            Main = MainType.Welfare,
            Key = "DetectActivity",
            Id = 1900801,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        --猎鹰行动
        FanconActivity = {
            Main = MainType.Welfare,
            Key = "FanconActivity",
            Id = 1900901,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        --长留基金
        GemFundActivity = {
            Main = MainType.Welfare,
            Key = "GemFundActivity",
            Id = 1900902,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        --猎狐犬行动
        HuntFox = {
            Main = MainType.Welfare,
            Key = "HuntFox",
            Id = 1901001,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        --钻石基金
        SuperCheap = {
            Main = MainType.Welfare,
            Key = "SuperCheap",
            Id = 1900903,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        -- 国旗纪念日
        MemorialDay={
            Main = MainType.Welfare,
            Key = "MemorialDay",
            Id = 1900802,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
        -- 国旗纪念日
        Turntable={
            Main = MainType.Welfare,
            Key = "TurnTable",
            Id = 1900406,
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        },
    },
    --主界面：侧边栏
    Sidebar = {
        --侧边栏
        MainSidebar = {
            Main = MainType.Sidebar,
            Key = "MainSidebar",
            Type = CuePointModel.Type.Red,
            Pos = CuePointModel.Pos.RightUp15,
            Number = 0
        }
    },
    --主界面：任务
    Task = {},
    --主界面：背包
    Backpack = {
        BackpackNew = {
            Main = MainType.Player,
            Key = "BackpackNew",
            Type = CuePointModel.Type.GreenNumber,
            Pos = CuePointModel.Pos.PlayerDown,
            Number = 0
        }
    },
    --主界面：邮件
    Mail = {},
    --主界面：联盟
    Union = {
        --联盟战争
        UnionWarfare = {
            Main = MainType.Union,
            Key = "UnionWarfare",
            Type = CuePointModel.Type.GreenNumber,
            Pos = CuePointModel.Pos.UnionList,
            NumberBattles = 0, --联盟集结
            NumberDefences = 0, --联盟防御
            Number = 0
        },
        --联盟合作任务
        UnionTeamTask = {
            Main = MainType.Union,
            Key = "UnionTeamTask",
            TypeWaring = CuePointModel.Type.Warning,
            NumberWaring = 0, --感叹号
            Type = CuePointModel.Type.GreenNumber,
            Pos = CuePointModel.Pos.UnionList,
            NumberMyTask = 0, --我的任务领奖
            NumberHelpTask = 0, --帮助任务领奖
            Number = 0
        },
        --联盟科技捐献
        UnionScience = {
            Main = MainType.Union,
            Key = "UnionScience",
            Type = CuePointModel.Type.Warning,
            Pos = CuePointModel.Pos.UnionList,
            TypeWaring = CuePointModel.Type.Warning,
            NumberWaring = 0,
            Number = 0
        },
        --联盟帮助
        UnionHelp = {
            Main = MainType.Union,
            Key = "UnionHelp",
            Type = CuePointModel.Type.GreenNumber,
            Pos = CuePointModel.Pos.UnionList,
            Number = 0
        },
        --联盟任务
        UnionTask = {
            Main = MainType.Union,
            Key = "UnionTask",
            Type = CuePointModel.Type.GreenNumber,
            Pos = CuePointModel.Pos.UnionList,
            NumberTask = 0, --联盟任务
            NumberOwner = 0, --盟主任务
            Number = 0
        },
        --联盟成员
        UnionMember = {
            Main = MainType.Union,
            Key = "UnionMember",
            Type = CuePointModel.Type.N,
            Pos = CuePointModel.Pos.RightUp15,
            NumberN = 0,
            Number = 0
        },
        --联盟管理
        UnionManager = {
            Main = MainType.Union,
            Key = "UnionManager",
            Type = CuePointModel.Type.N,
            Pos = CuePointModel.Pos.RightUp15,
            TypeVote = CuePointModel.Type.GreenNumber, --联盟投票
            PosVote = CuePointModel.Pos.RightUp7015,
            NumberVote = 0,
            TypeMessage = CuePointModel.Type.GreenNumber, --联盟留言
            PosMessage = CuePointModel.Pos.RightUp7015,
            NumberMessage = 0,
            NumberN = 0,
            Number = 0
        }
    }
}

--[[
    --无关联提示点 [默认位置右上角,返回提示点组件,可自定义提示点属性]
    pointType: 提示点类型
    number: >0 显示数量(或者显示) 否在不显示
            备注：目前红点和感叹号不显示显示数量，显示number传1,不显示则传0
    parent：提示点父对象
    pos：自定义提示点位置，默认父对象右上角(可不传)
]]
function CuePointModel:SetSingle(pointType, number, parent, pos)
    if parent == nil then
        return
    end
    local p = parent:GetChild("nameCuePoint")
    if number <= 0 then
        if p then
            p:RemoveFromParent()
            NodePool.Set(NodePool.KeyType.CuePointCmpt, p)
        end
        return
    end
    if not p then
        NodePool.Init(NodePool.KeyType.CuePointCmpt, "Common", "CuePoint")
        p = NodePool.Get(NodePool.KeyType.CuePointCmpt)
        p.name = "nameCuePoint"
        if not pos or pos == CuePointModel.Pos.RightUp then
            p.xy = Vector2(parent.width, 0)
        elseif pos == CuePointModel.Pos.RightUp10 then
            p.xy = Vector2(parent.width - 10, 10)
        elseif pos == CuePointModel.Pos.RightUp12 then
            p.xy = Vector2(parent.width - 12, 12)
        elseif pos == CuePointModel.Pos.RightUp15 then
            p.xy = Vector2(parent.width - 15, 15)
        elseif pos == CuePointModel.Pos.RightUp20 then
            p.xy = Vector2(parent.width - 20, 20)
        elseif pos == CuePointModel.Pos.MainDown then
            p.xy = Vector2(parent.width - 20, 10)
        elseif pos == CuePointModel.Pos.RightUp2212 then
            p.xy = Vector2(parent.width - 22, 12)
        elseif pos == CuePointModel.Pos.RightUp2515 then
            p.xy = Vector2(parent.width - 25, 15)
        elseif pos == CuePointModel.Pos.RightUp7015 then
            p.xy = Vector2(parent.width - 70, 15)
        elseif pos == CuePointModel.Pos.PlayerDown then
            p.xy = Vector2(parent.width - 50, 10)
        elseif pos == CuePointModel.Pos.MainGift then
            p.xy = Vector2(parent.width - 28, parent.height / 2)
        elseif pos == CuePointModel.Pos.Sidebar then
            p.xy = Vector2(parent.width, 26)
        elseif pos == CuePointModel.Pos.UnionList then
            p.xy = Vector2(112, 20)
        elseif pos == CuePointModel.Pos.Warning then
            p.xy = Vector2(30, 30)
        else
            p.xy = pos
        end
        parent:AddChild(p)
    end
    p.visible = true
    if pointType == CuePointModel.Type.Red then
        --红点
        p:ShowRed()
    elseif pointType == CuePointModel.Type.RedNumber then
        --红点 带数字
        p:ShowRedNumber()
    elseif pointType == CuePointModel.Type.GreenNumber then
        --绿点
        p:ShowGreenNumber(number)
    elseif pointType == CuePointModel.Type.Warning then
        --感叹号
        p:ShowWarning()
    elseif pointType == CuePointModel.Type.N then
        --N
        p:ShowN()
    end
end

--[[
    --有关联提示点（会统计总点数）
    mainType: 提示点功能入口，CuePointModel.MainType.XX
    subType: 子入口，自定义，加前缀PlayerRename，UnionTask，避免重复
]]
function CuePointModel:Set(sub, number, parent, pos)
    CuePointModel:SetSingle(sub.Type, number, parent, pos and pos or sub.Pos)
    local mainType = sub.Main
    CuePointModel.SubType[mainType][sub.Key].Number = number
    if mainType == MainType.Player then
        --指挥官 头像
        self:CheckPlayer()
    elseif mainType == MainType.Gift then
        --礼包
        self:CheckGift()
    elseif mainType == MainType.Welfare then
        --福利
        self:CheckWelfare()
    elseif mainType == MainType.Task then
        --任务
        self:CheckTask()
    end
end

----------------------------------------------------------------------指挥官 提示点
function CuePointModel:CheckPlayer(parent)
    if parent then
        self.playerParent = parent
        --首次登陆需要检查所有情况
        --成就墙
        local PlayerDetailModel = import("Model/PlayerDetailModel")
        PlayerDetailModel.SetAchievementAward()
        --技能点
        local SkillModel = import("Model/SkillModel")
        CuePointModel.SubType.Player.PlayerSkill.Number = SkillModel.GetSkillPoints(SkillModel.GetCurPage())
        --设置
        CuePointModel.SubType.Player.PlayerSet.Number = UserModel:NotReadPlayerNumber()
    end
    local count = 0
    for _, v in pairs(CuePointModel.SubType.Player) do
        if v.Number > 0 then
            if v.Key == CuePointModel.SubType.Player.PlayerSet.Key and PlayerDataModel:GetDayNotTip(PlayerDataEnum.PLAYER_SET) then
                -- Log.Info("--- 指挥官设置今日已打开")
            else
                count = 1
                break
            end
        end
    end
    self:SetSingle(CuePointModel.Type.Red, count, self.playerParent, CuePointModel.Pos.RightUp10)
end
----------------------------------------------------------------------礼包 提示点
function CuePointModel:CheckGift(parent)
    if parent then
        self.giftParent = parent
        --每日小礼包
        local GiftModel = import("Model/GiftModel")
        CuePointModel.SubType.Gift.DailyGift.Number = GiftModel.HasDailyGift() and 1 or 0
    end
    local count = 0
    for _, v in pairs(CuePointModel.SubType.Gift) do
        if v.Number > 0 then
            count = 1
            break
        end
    end
    self:SetSingle(CuePointModel.Type.Warning, count, self.giftParent, CuePointModel.Pos.MainGift)
end
----------------------------------------------------------------------福利 提示点
function CuePointModel:CheckWelfare(parent)
    --  Log.Error("---- >>> 福利 提示点: {0}", table.inspect(CuePointModel.SubType.Welfare))
    if parent then
        self.welfareParent = parent
        local WelfareCuePointModel = import("Model/CuePoint/WelfareCuePointModel")
        WelfareCuePointModel:InitWelfare()
    end
    local count = 0
    for _, v in pairs(CuePointModel.SubType.Welfare) do
        local cfg = ConfigMgr.GetItem("configActivitys", v.Id)
        if v.Number > 0 and cfg.show_set == 2 then
            count = 1
            break
        end
    end
    self:SetSingle(CuePointModel.Type.Red, count, self.welfareParent, CuePointModel.Pos.RightUp15)
end
----------------------------------------------------------------------任务 提示点
function CuePointModel:CheckTask(parent)
    if parent then
        self.taskParent = parent
    end
end
----------------------------------------------------------------------联盟 提示点
local UnionModel = import("Model/UnionModel")
function CuePointModel:CheckUnion(parent)
    if parent then
        self.unionParent = parent
        local UnionCuePointModel = import("Model/CuePoint/UnionCuePointModel")
        UnionCuePointModel:InitUnion()
    end
    if not UnionModel.CheckJoinUnion() then
        self:ResetUnion()
        return
    end
    local countNumber = 0
    local countN = 0
    local countWaring = 0
    for _, v in pairs(CuePointModel.SubType.Union) do
        if v.Number and v.Number > 0 then
            countNumber = countNumber + v.Number
        end
        if countN == 0 and v.NumberN and v.NumberN > 0 then
            countN = 1
        end
        if countWaring == 0 and v.NumberWaring and v.NumberWaring > 0 then
            countWaring = 1
        end
    end
    local pos = CuePointModel.Pos.MainDown
    if countNumber > 0 then
        self:SetSingle(CuePointModel.Type.GreenNumber, countNumber, self.unionParent, pos)
    -- elseif countN > 0 then
    --     self:SetSingle(CuePointModel.Type.N, countN, self.unionParent, pos)
    -- elseif countWaring > 0 then
    --     self:SetSingle(CuePointModel.Type.Warning, countWaring, self.unionParent, pos)
    else
        self:SetSingle(CuePointModel.Type.GreenNumber, 0, self.unionParent, pos)
    end
end
function CuePointModel:ResetUnion()
    for _, v in pairs(CuePointModel.SubType.Union) do
        if v.Number then
            v.Number = 0
        end
        if v.NumberN then
            v.NumberN = 0
        end
        if v.NumberWaring then
            v.NumberWaring = 0
        end
        if v.NumberBattles then
            v.NumberBattles = 0
        end
        if v.NumberDefences then
            v.NumberDefences = 0
        end
        if v.NumberMyTask then
            v.NumberMyTask = 0
        end
        if v.NumberHelpTask then
            v.NumberHelpTask = 0
        end
        if v.NumberTask then
            v.NumberTask = 0
        end
        if v.NumberOwner then
            v.NumberOwner = 0
        end
        if v.NumberVote then
            v.NumberVote = 0
        end
        if v.NumberMessage then
            v.NumberMessage = 0
        end
    end
    if self.unionParent then
        self:SetSingle(CuePointModel.Type.GreenNumber, 0, self.unionParent)
    end
end

--指挥官改名
function CuePointModel.CheckPlayerName(flag)
    if flag then
        --改名成功
        PlayerDataModel:SetData(PlayerDataEnum.PLAYER_RENAMED, true)
        return
    else
        --检查是否改过名
        if PlayerDataModel:GetData(PlayerDataEnum.PLAYER_RENAMED) then
            --指挥官改过名称
            return
        else
            --是否今日不再提示
            return not PlayerDataModel:GetDayNotTip(PlayerDataEnum.PLAYER_RENAME)
        end
    end
end
--指挥官更换形象
function CuePointModel.CheckPlayerCharacter(flag)
    if flag then
        --更换形象成功
        PlayerDataModel:SetData(PlayerDataEnum.PLAYER_RECHARACTERED, true)
        return
    else
        --检查是否改更换形象
        if PlayerDataModel:GetData(PlayerDataEnum.PLAYER_RECHARACTERED) then
            --指挥官更换过形象
            return
        else
            --是否今日不再提示
            return not PlayerDataModel:GetDayNotTip(PlayerDataEnum.PLAYER_RECHARACTER)
        end
    end
end

return CuePointModel
