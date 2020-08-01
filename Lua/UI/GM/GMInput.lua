local GMInput = UIMgr:NewUI("GMInput")

import("UI/GM/GMItemInput")

function GMInput:OnInit()
    local view = self.Controller.contentPane
    self._list = view:GetChild("list")

    local _btnClose = view:GetChild("btnClose")
    _btnClose.title = "X"
    self:AddListener(_btnClose.onClick,
        function()
            UIMgr:Close("GMInput")
        end
    )
    local _mask = view:GetChild("mask")
    self:AddListener(_mask.onClick,
        function()
            UIMgr:Close("GMInput")
        end
    )
end

function GMInput:OnOpen()
    local normal = {
        {
            name = "修改服务器时间",
            prompt = "eg: 2019/09/12 08:08",
            callback = function(text)
                self:SetServerTime(text)
            end
        },
        {
            name = "时间戳修改服务器时间",
            prompt = "eg: 1568625206",
            callback = function(text)
                self:SetServerTimeByTimestamp(text)
            end
        },
        {
            name = "修改服务器时间：秒",
            prompt = "eg: 60",
            callback = function(text)
                self:SetServerTimeBySecond(text)
            end
        },
        {
            name = "修改服务器时间：分",
            prompt = "eg: 10",
            callback = function(text)
                self:SetServerTimeByMinute(text)
            end
        },
        {
            name = "修改服务器时间：小时",
            prompt = "eg: 2",
            callback = function(text)
                self:SetServerTimeByHour(text)
            end
        },
        {
            name = "修改服务器时间：天",
            prompt = "eg: 1",
            callback = function(text)
                self:SetServerTimeByDay(text)
            end
        },
        {
            name = "添加道具",
            prompt = "eg: 202000,1",
            callback = function(text)
                self:AddItem(text)
            end
        },
        {
            name = "增加伤兵",
            prompt = "eg: 107000,10",
            callback = function(text)
                self:AddCureArmy(text)
            end
        },
        {
            name = "增加士兵",
            prompt = "eg: 107000,10",
            callback = function(text)
                self:AddArmy(text)
            end
        },
        {
            name = "所有建筑升至指定等级",
            prompt = "eg:30",
            callback = function(level)
                self:AddAllBuildingLevel(level)
            end
        },
        {
            name = "将指定建筑升至指定等级",
            prompt = "eg:400000,10",
            callback = function(content)
                local list = StringUtil.Split(content, ",")
                self:AddBuildingLevel(tonumber(list[1]), tonumber(list[2]))
            end
        },
        {
            name = "联盟科技捐献值最大",
            prompt = "eg: 250000",
            callback = function(text)
                self:AddUnionTech(text)
            end
        },
        {
            name = "联盟科技升级",
            prompt = "eg: 250000",
            callback = function(text)
                self:UpdateUnionTech(text)
            end
        },
        {
            name = "联盟建筑修建",
            prompt = "eg:610000,1,1",
            callback = function(text)
                self:BuildUnionFortress(text)
            end
        },
        {
            name = "联盟建筑建好",
            prompt = "eg:610000,1,1",
            callback = function(text)
                self:CompleteBuildUnionFortress(text)
            end
        },
        {
            name = "修改充值人民币",
            prompt = "eg:100",
            callback = function(text)
                self:AddRMB(text)
            end
        },
        {
            name = "修改活动时间",
            prompt = "eg:1,开始时间,结束时间",
            callback = function(text)
                self:SetChangeActivityTime(text)
            end
        },
        {
            name = "设置城墙耐久",
            prompt = "10",
            callback = function(text)
                self:SetDurable(text)
            end
        },
        {
            name = "完成指定任务",
            prompt = "输入任务Id",
            callback = function(text)
                self:OnTask(text)
            end
        },
        {
            name = "完成指定区间任务按ID",
            prompt = "输入任务StartId,EndId",
            callback = function(text)
                self:OnTaskGroup(text)
            end
        },
        {
            name = "完成任务区间按推荐任务顺序",
            prompt = "输入任务EndId",
            callback = function(text)
                self:OnTaskGroupByOrder(text)
            end
        },
        {
            name = "完成普通任务按任务顺序",
            prompt = "输入任务EndId",
            callback = function(text)
                self:OnCommonTaskByOrder(text)
            end
        },
        {
            name = "开服并切服：输入服务器Id和名称",
            prompt = "eg: 12345,服务器01",
            callback = function(text)
                self:AddSever(text)
            end
        },
        {
            name = "切换服务器：输入服务器Id",
            prompt = "eg: 12345",
            callback = function(text)
                self:EnterSever(text)
            end
        },
        {
            name = "减少巨兽的生命值",
            prompt = "eg: 108000,80",
            callback = function(text)
                self:ReduceBeastHP(text)
            end
        },
        {
            name = "发送订单购买成功",
            prompt = "eg:99000006,3",
            callback = function(text)
                self:PurchaseSuccess(text)
            end
        },
        {
            name = "清除月卡信息",
            prompt = "eg:99000006",
            callback = function(text)
                self:DeleteCard(text)
            end
        },
        {
            name = "添加指挥官技能点",
            prompt = "eg:10",
            callback = function(text)
                self:AddHeroSkillPoints(text)
            end
        },
        {
            name = "完成指定赌场集结任务",
            prompt = "eg:1",
            callback = function(text)
                self:AddActivityTaskParams(text)
            end
        },
        {
            name = "增加限时比赛阶段积分",
            prompt = "eg:30",
            callback = function(text)
                self:AddActivityNum(text)
            end
        },
        {
            name = "添加礼包组",
            prompt = "eg:900000",
            callback = function(text)
                self:AddGiftGroup(text)
            end
        },
        {
            name = "关闭礼包组",
            prompt = "eg:900000",
            callback = function(text)
                self:CloseGiftGroup(text)
            end
        },
        {
            name = "增减体力",
            prompt = "eg:10",
            callback = function(text)
                self:ChangeEnergy(text)
            end
        },
        {
            name = "单人活动排名奖励：指定玩家排名,排行榜玩家数量",
            prompt = "eg:1,100",
            callback = function(text)
                self:GetSingleRankAward(text)
            end
        },
        {
            name = "添加宝石",
            prompt = "eg:1,1",
            callback = function(text)
                self:GetEquipMaterialById(text)
            end
        },
        {
            name = "添加所有宝石",
            prompt = "eg:4",
            callback = function(text)
                self:GetAllEquipMaterial(text)
            end
        },
        {
            name = "添加装备",
            prompt = "eg:110101,1",
            callback = function(text)
                self:GetEquipById(text)
            end
        },
        {
            name = "添加所有装备",
            prompt = "eg:2",
            callback = function(text)
                self:GetAllEquip(text)
            end
        },
        {
            name = "新城竞赛排名奖励：阶段,type,排名",
            prompt = "eg:1,0,1",
            callback = function(text)
                self:GetNewWarRankAward(text)
            end
        },
        {
            name = "竞技场获取指定排名奖励",
            prompt = "",
            callback = function(text)
                Net.GM.GetArenRankAwards(text)
            end
        },
        {
            name = "请求添加战争券",
            prompt = "",
            callback = function(text)
                Net.GM.GMAddWarRoll(text)
            end
        }
    }
    self._list.numItems = #normal
    for k, v in pairs(normal) do
        local child = self._list:GetChildAt(k - 1)
        child.title = v.name
        child:init(v.callback, v.prompt)
    end
end

--修改服务器时间
function GMInput:SetServerTime(time)
    local year = string.sub(time, 1, 4)
    local month = string.sub(time, 6, 7)
    local day = string.sub(time, 9, 10)
    local hour = string.sub(time, 12, 13)
    local minute = string.sub(time, 15, 16)
    if year == "" or month == "" or day == "" or hour == "" or minute == "" then
        TipUtil.TipById(50216)
        return
    end
    local date = {
        year = year,
        month = month,
        day = day,
        hour = hour,
        min = minute,
        sec = 0
    }
    local timestamp = os.time(date)
    Net.GM.SetTime(
        timestamp - Tool.Time(),
        function()
            Tool.SyncTime()
        end
    )
end

--时间戳修改服务器时间
function GMInput:SetServerTimeByTimestamp(timestamp)
    Net.GM.SetTime(
        tonumber(timestamp) - Tool.Time(),
        function()
            Tool.SyncTime()
        end
    )
end

--修改服务器时间：秒
function GMInput:SetServerTimeBySecond(second)
    Net.GM.SetTime(
        second,
        function()
            Tool.SyncTime()
        end
    )
end
--修改服务器时间：分
function GMInput:SetServerTimeByMinute(minute)
    Net.GM.SetTime(
        minute * 60,
        function()
            Tool.SyncTime()
        end
    )
end
--修改服务器时间：时
function GMInput:SetServerTimeByHour(hour)
    Net.GM.SetTime(
        hour * 3600,
        function()
            Tool.SyncTime()
        end
    )
end
--修改服务器时间：天
function GMInput:SetServerTimeByDay(day)
    Net.GM.SetTime(
        day * 3600 * 24,
        function()
            Tool.SyncTime()
        end
    )
end

--增加道具
function GMInput:AddItem(content)
    local index = string.find(content, ",")
    local confId = tonumber(string.sub(content, 1, index - 1))
    local amount = tonumber(string.sub(content, index + 1, #content))
    Net.GM.AddItem(confId, amount)
end

--增加伤兵
function GMInput:AddCureArmy(content)
    local index = string.find(content, ",")
    local armyId = tonumber(string.sub(content, 1, index - 1))
    local amount = tonumber(string.sub(content, index + 1, #content))
    Net.GM.AddInjured(armyId, amount)
end

--增加士兵
function GMInput:AddArmy(content)
    local index = string.find(content, ",")
    local armyId = tonumber(string.sub(content, 1, index - 1))
    local amount = tonumber(string.sub(content, index + 1, #content))
    Net.GM.AddArmies(armyId, amount)
end

--联盟科技捐献值最大
function GMInput:AddUnionTech(techId)
    Net.GM.AllianceTechContriMax(techId)
end

--联盟科技升级
function GMInput:UpdateUnionTech(techId)
    Net.GM.AllianceTechLevelUp(techId, false)
end

--联盟堡垒修建
function GMInput:BuildUnionFortress(content)
    local contents = StringUtil.Split(content, ",")
    local confId = contents[1] and contents[1] or 0
    local x = contents[2] and contents[2] or 0
    local y = contents[3] and contents[3] or 0
    Net.GM.BuildAllianceBuilding(confId, x, y)
end

--联盟堡垒建好
function GMInput:CompleteBuildUnionFortress(content)
    local contents = StringUtil.Split(content, ",")
    local confId = contents[1] and contents[1] or 0
    local x = contents[2] and contents[2] or 0
    local y = contents[3] and contents[3] or 0
    Net.GM.CompleteAllianceBuilding(confId, x, y)
end

--充值RMB
function GMInput:AddRMB(amount)
    Net.GM.GMChargeMoney(amount)
end

--改变活动时间
function GMInput:SetChangeActivityTime(text)
    local splitTab = split(text, ",")
    local id = tonumber(splitTab[1])
    local startTime = tonumber(splitTab[2])
    local endTime = tonumber(splitTab[3])
    Net.GM.GMChangeActivityTime(id, startTime, endTime)
end

--升级所有建筑
function GMInput:AddAllBuildingLevel(level)
    Net.GM.AddAllBuilding(Model.Account.accountId, level)
end

--设置城墙耐久
function GMInput:SetDurable(amount)
    Net.GM.SetDurable(tonumber(amount))
end
--设置单个指定建筑升至指定等级
function GMInput:AddBuildingLevel(buildingId, level)
    Net.GM.AddBuilding(buildingId, level)
end

--完成指定任务
function GMInput:OnTask(id)
    Net.GM.FinishTask(0, tonumber(id))
end

--完成推荐任务区间顺序按id排序
function GMInput:OnTaskGroup(text)
    local splitTab = split(text, ",")
    local startId = tonumber(splitTab[1])
    local EndId = tonumber(splitTab[2])
    Net.GM.FinishTasksInSection(startId, EndId)
    self:ScheduleOnce(
        function()
            FUIUtils.QuitGame()
        end,
        0.5
    )
end

--完成推荐任务区间顺序按推荐顺序
function GMInput:OnTaskGroupByOrder(text)
    local endId = tonumber(text)
    Net.GM.FinishRecommendedMainTasks(endId)
    self:ScheduleOnce(
        function()
            Net.GM.GetAllMainTaskAwards()
            FUIUtils.QuitGame()
        end,
        0.5
    )
end

--按任务顺序完成普通主线任务
function GMInput:OnCommonTaskByOrder(text)
    local endId = tonumber(text)
    Net.GM.FinishCommonMainTasks(endId)
    self:ScheduleOnce(
        function()
            Net.GM.GetAllMainTaskAwards()
            FUIUtils.QuitGame()
        end,
        0.5
    )
end

--开服并切服
function GMInput:AddSever(content)
    local index = string.find(content, ",")
    local id = string.sub(content, 1, index - 1)
    local name = string.sub(content, index + 1, #content)
    Net.GM.AddServer(
        id,
        name,
        function()
            FUIUtils.QuitGame()
        end
    )
end
--切换服务器
function GMInput:EnterSever(id)
    Net.GM.EnterServer(
        id,
        function()
            FUIUtils.QuitGame()
        end
    )
end
--减少巨兽的生命值
function GMInput:ReduceBeastHP(content)
    local index = string.find(content, ",")
    local id = tonumber(string.sub(content, 1, index - 1))
    local hp = tonumber(string.sub(content, index + 1, #content))
    Net.GM.ReduceBeastHealth(id, hp)
end

--订单购买成功
function GMInput:PurchaseSuccess(content)
    local index = string.find(content, ",")
    local id = tonumber(string.sub(content, 1, index - 1))
    local categroy = tonumber(string.sub(content, index + 1, #content))
    Net.GM.PurchaseSuccess(id, categroy)
end

--清除月卡信息
function GMInput:DeleteCard(content)
    local id = tonumber(content)
    Net.GM.DeleteCard(id)
end

--添加指挥官技能点
function GMInput:AddHeroSkillPoints(content)
    local points = tonumber(content)
    Net.GM.AddHeroSkillPoints(
        points,
        function()
            for _, v in pairs(Model.PlayerSkills) do
                v.Points = v.Points + points
            end
        end
    )
end

-- 请求-完成指定赌场集结任务
function GMInput:AddActivityTaskParams(text)
    local id = tonumber(text)
    Net.GM.FinishActivityTask(id)
end


-- 增加限时活动积分
function GMInput:AddActivityNum(text)
    local count = tonumber(text)
    Net.GM.AddLimitTimesMatchScore(count)
end

-- 添加礼包组
function GMInput:AddGiftGroup(text)
    local id = tonumber(text)
    Net.GM.SetGiftGroupInfo(id, 1)
end

-- 关闭礼包组
function GMInput:CloseGiftGroup(text)
    local id = tonumber(text)
    Net.GM.CloseGiftGroup(id)
end

--增减体力
function GMInput:ChangeEnergy(text)
    local id = tonumber(text)
    Net.GM.ChangeEnergy(id)
end

--发送单人活动排名奖励
function GMInput:GetSingleRankAward(text)
    local splitTab = split(text, ",")
    local rank = tonumber(splitTab[1])
    local rankNum = tonumber(splitTab[2])
    Net.GM.PlayerIndiEventStageRankSum(rank,rankNum)
end

--获取指定装备制造材料
function GMInput:GetEquipMaterialById(text)
    local splitTab = split(text, ",")
    local id = tonumber(splitTab[1])
    local num = tonumber(splitTab[2])
    Net.GM.GMAddJewel(id, num)
end

--获取所有装备制造材料
function GMInput:GetAllEquipMaterial(text)
    local num = tonumber(text)
    Net.GM.GMAddAllJewel(num)
end

--获取指定装备
function GMInput:GetEquipById(text)
    local splitTab = split(text, ",")
    local id = tonumber(splitTab[1])
    local num = tonumber(splitTab[2])
    Net.GM.GMAddEquip(id, num)
end

--获取所有装备
function GMInput:GetAllEquip(text)
    local num = tonumber(text)
    Net.GM.GMAddAllEquip(num)
end

--发送新城竞赛活动排名奖励
function GMInput:GetNewWarRankAward(text)
    local splitTab = split(text, ",")
    local period = tonumber(splitTab[1])
    local type = tonumber(splitTab[2])
    local rank = tonumber(splitTab[3])
    Net.GM.GMSendNewWarZoneRankEmail(period,type,rank)
end

return GMInput
