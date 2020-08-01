local GMBox = UIMgr:NewUI("GMBox")

import("UI/GM/GMItemBtn")
local CustomEventManager = import("GameLogic/CustomEventManager")
function GMBox:OnInit()
    local view = self.Controller.contentPane
    self._list = view:GetChild("list")

    local _btnClose = view:GetChild("btnClose")
    _btnClose.title = "X"
    self:AddListener(
        _btnClose.onClick,
        function()
            UIMgr:Close("GMBox")
        end
    )
    local _mask = view:GetChild("mask")
    self:AddListener(
        _mask.onClick,
        function()
            UIMgr:Close("GMBox")
        end
    )
end

function GMBox:OnOpen(type)
    if type == "账号" then
        self:Account()
        return
    end
    if type == "道具" then
        self:Prop()
        return
    end
    if type == "资源和金币" then
        self:ResAndGem()
        return
    end
    if type == "打印日志" then
        self:PrintLog()
        return
    end
    if type == "士兵" then
        self:Army()
        return
    end
    if type == "联盟" then
        self:Union()
        return
    end
    if type == "联盟建筑" then
        self:UnionBuilding()
        return
    end
    if type == "一键完成" then
        self:OneClickOompletion()
        return
    end
    if type == "性能检测工具" then
        self:Performance()
        return
    end
    if type == "地图相关" then
        self:AboutMap()
        return
    end
    if type == "转盘礼包购买" then
        self:TurnplateGiftBuy()
        return
    end
    if type == "自定义引导" then
        self:CustomEvent()
        return
    end
    if type == "王城战" then
        self:RoyalBattle()
        return
    end

    self._list.numItems = 0
end

-- 重置
function GMBox:Account()
    local normal = {
        {
            name = "重置账号",
            callback = function()
                Net.GM.CleanAccount(
                    Model.Account.accountId,
                    function()
                        FUIUtils.QuitGame()
                    end
                )
            end
        },
        {
            name = "清除本地缓存",
            callback = function()
                Util.CleanPlayerData()
            end
        },
        {
            name = "取消指挥中心升级弹窗",
            callback = function()
                PlayerDataModel:SetData(PlayerDataEnum.CENTER_UPGRADE_OPEN, true)
            end
        },
        {
            name = "开启指挥中心升级弹窗",
            callback = function()
                PlayerDataModel:SetData(PlayerDataEnum.CENTER_UPGRADE_OPEN, false)
            end
        },
        {
            name = "模拟掉线重启",
            callback = function()
                LoginModel.ExitLogin()
            end
        }
    }
    self._list.numItems = #normal
    for k, v in pairs(normal) do
        local child = self._list:GetChildAt(k - 1)
        child.title = v.name
        child:init(v.callback)
    end
end

-- 添加单个道具
function GMBox:Prop()
    local special = {
        {
            name = "每个道具100",
            callback = function()
                Net.GM.AddItems(Model.Account.accountId)
            end
        },
        {
            name = "清空道具",
            callback = function()
                Net.GM.ClearItems(
                    Model.Account.accountId,
                    function()
                        Model.Items = {}
                    end
                )
            end
        }
    }
    local normal = {
        {name = "通用 加速1m", confId = 202000, amount = 1},
        {name = "通用 1m-10", confId = 202000, amount = 10},
        {name = "通用 加速5m", confId = 202001, amount = 1},
        {name = "通用 加速1h", confId = 202002, amount = 1},
        {name = "通用 加速8h", confId = 202003, amount = 1},
        {name = "通用 加速24h", confId = 202004, amount = 1},
        {name = "建筑 加速5m", confId = 202017, amount = 1},
        {name = "建筑 加速2h", confId = 202018, amount = 1},
        {name = "建筑 加速8h", confId = 202019, amount = 1},
        {name = "建筑 加速24h", confId = 202020, amount = 1},
        {name = "科技 加速5m", confId = 202009, amount = 1},
        {name = "科技 加速2h", confId = 202010, amount = 1},
        {name = "科技 加速8h", confId = 202011, amount = 1},
        {name = "科技 加速24h", confId = 202012, amount = 1},
        {name = "治疗 加速5m", confId = 202013, amount = 1},
        {name = "治疗 加速2h", confId = 202014, amount = 1},
        {name = "治疗 加速8h", confId = 202015, amount = 1},
        {name = "治疗 加速24h", confId = 202016, amount = 1},
        {name = "训练 加速5m", confId = 202005, amount = 1},
        {name = "训练 加速2h", confId = 202006, amount = 1},
        {name = "训练 加速8h", confId = 202007, amount = 1},
        {name = "训练 加速24h", confId = 202008, amount = 1},
        {name = "安保 加速5m", confId = 202021, amount = 1},
        {name = "安保 加速2h", confId = 202022, amount = 1},
        {name = "安保 加速8h", confId = 202023, amount = 1},
        {name = "安保 加速24h", confId = 202024, amount = 1},
        {name = "建筑移动", confId = 204027, amount = 1},
        {name = "建筑队列8h", confId = 204120, amount = 1},
        {name = "建筑队列24h", confId = 204121, amount = 1},
        {name = "指挥官改名", confId = 204033, amount = 1},
        {name = "玫瑰10", confId = 204406, amount = 10}
    }
    local kinds = {
        {
            name = "玩家经验x1",
            confId = {
                200141, --10经验
                200142, --100经验
                200143, --500经验
                200144, --5k经验
                200145, --20k经验
                200146 --100k经验
            },
            amount = 1
        },
        {
            name = "玩家经验x100",
            confId = {
                200146 --100k经验
            },
            amount = 100
        },
        {
            name = "玩家经验x10k",
            confId = {
                200146 --100k经验
            },
            amount = 10000
        },
        {
            name = "玩家体力",
            confId = {
                200130, --体力药剂（小）-10
                200131, --体力药剂（中）-50
                200132 --体力药剂（大）-100
            },
            amount = 1
        },
        {
            name = "联盟徽章",
            confId = {
                204030, --十字徽章
                204031, --银星徽章
                204032 --英勇勋章
            },
            amount = 1
        },
        {
            name = "资源建筑增产",
            confId = {
                204022, --食品产量翻倍24小时
                204023, --石油产量翻倍24小时
                204024, --钢铁产量翻倍24小时
                204025 --稀土产量翻倍24小时
            },
            amount = 1
        },
        {
            name = "幸运币",
            confId = {
                300900, --500幸运币
                300901, --1000幸运币
                300902, --1500幸运币
                300903, --4000幸运币
                300904, --8000幸运币
                300905, --10000幸运币
                300906, --15000幸运币
                300907 --100000幸运币
            },
            amount = 1
        },
        {
            name = "高级幸运币",
            confId = {
                301000, --1高级幸运币
                301001, --3高级幸运币
                301002, --5高级幸运币
                301003, --6高级幸运币
                301004, --10高级幸运币
                301005, --15高级幸运币
                301006, --50高级幸运币
                301007, --100高级幸运币
                301008 --1000高级幸运币
            },
            amount = 1
        }
    }
    self._list.numItems = #normal + #special + #kinds
    for k, v in pairs(special) do
        local child = self._list:GetChildAt(k - 1)
        child.title = v.name
        child:init(v.callback)
    end
    for k, v in pairs(normal) do
        local child = self._list:GetChildAt(k - 1 + #special)
        child.title = v.name
        child:init(
            function()
                Net.GM.AddItem(v.confId, v.amount)
            end
        )
    end
    for k, v in pairs(kinds) do
        local child = self._list:GetChildAt(k - 1 + #special + #normal)
        child.title = v.name
        child:init(
            function()
                for _, id in pairs(v.confId) do
                    Net.GM.AddItem(id, v.amount)
                end
            end
        )
    end
end

-- 添加金币和资源
function GMBox:ResAndGem()
    local gem = {
        {name = "加100万金币", amount = 1000000},
        {name = "加1万金币", amount = 10000},
        {name = "加100金币", amount = 100},
        {name = "加10金币", amount = 10},
        {name = "金币置为0", amount = -Model.Player.Gem}
    }
    local res = {
        {name = "加100M资源", amount = 100000000},
        {name = "加1M资源", amount = 1000000},
        {name = "加10K资源", amount = 10000},
        {name = "加1K资源", amount = 1000},
        {name = "减100M资源", amount = -100000000},
        {name = "减10M资源", amount = -10000000},
        {name = "减1M资源", amount = -1000000},
        {name = "减10K资源", amount = -10000},
        {name = "减1K资源", amount = -1000},
        {name = "减100资源", amount = -100}
    }
    self._list.numItems = #gem + #res
    for k, v in pairs(gem) do
        local child = self._list:GetChildAt(k - 1)
        child.title = v.name
        child:init(
            function()
                Net.GM.AddGem(v.amount)
            end
        )
    end
    for k, v in pairs(res) do
        local child = self._list:GetChildAt(k - 1 + #gem)
        child.title = v.name
        child:init(
            function()
                Net.GM.AddAllRes(v.amount)
            end
        )
    end
end

-- 打印日志
function GMBox:PrintLog()
    local log = {
        {
            name = "打开通讯日志",
            callback = function()
                PlayerDataModel.SetLocalData("LOG_SERVER", true)
            end
        },
        {
            name = "关闭通讯日志",
            callback = function()
                PlayerDataModel.SetLocalData("LOG_SERVER", false)
            end
        },
        {
            name = "所有信息",
            callback = function()
                print("GM Model: " .. table.inspect(Model))
            end
        },
        {
            name = "玩家信息",
            callback = function()
                print("GM Model.User: " .. table.inspect(Model.User))
            end
        },
        {
            name = "建筑",
            callback = function()
                print("GM Model.Buildings: " .. table.inspect(Model.Buildings))
            end
        },
        {
            name = "资源",
            callback = function()
                print("GM Model.Resources: " .. table.inspect(Model.Resources))
            end
        },
        {
            name = "资源建筑",
            callback = function()
                print("GM Model.ResBuilds: " .. table.inspect(Model.ResBuilds))
            end
        },
        {
            name = "道具",
            callback = function()
                print("GM Model.Items: " .. table.inspect(Model.Items))
            end
        },
        {
            name = "军队",
            callback = function()
                print("GM Model.Armies: " .. table.inspect(Model.Armies))
            end
        },
        {
            name = "伤兵",
            callback = function()
                print("GM Model.InjuredArmies: " .. table.inspect(Model.InjuredArmies))
            end
        },
        {
            name = "Buffs",
            callback = function()
                print("GM Model.Buffs: " .. table.inspect(Model.Buffs))
            end
        },
        {
            name = "当前时间戳",
            callback = function()
                print("GM 当前时间戳: " .. Tool.Time())
            end
        }
    }
    self._list.numItems = #log
    for k, v in pairs(log) do
        local child = self._list:GetChildAt(k - 1)
        child.title = v.name
        child:init(v.callback)
    end
end

-- 士兵
function GMBox:Army()
    local special = {
        {
            name = "添加士兵",
            callback = function()
                Net.GM.AddArmies(0, 0)
            end
        },
        {
            name = "添加伤兵",
            callback = function()
                Net.GM.AddInjured(0, 100)
            end
        },
        {
            name = "防御武器",
            callback = function()
                Net.GM.AddDefenceWeaponsToLimit()
            end
        }
    }
    self._list.numItems = #special
    for k, v in pairs(special) do
        local child = self._list:GetChildAt(k - 1)
        child.title = v.name
        child:init(v.callback)
    end
end

-- 联盟
function GMBox:Union()
    local special = {
        {
            name = "重置联盟",
            callback = function()
                Net.GM.ResetAllianceDaily(Model.Account.accountId)
            end
        },
        {
            name = "添加联盟动态",
            callback = function()
                Net.GM.AddAllianceNews()
            end
        },
        {
            name = "联盟科技升满",
            callback = function()
                Net.GM.AllianceTechLevelUp(nil, true)
            end
        },
        {
            name = "添加联盟活跃",
            callback = function()
                Net.GM.AddAllianceActive(10)
            end
        },
        {
            name = "添加联盟贡献",
            callback = function()
                Net.GM.AddAllianceContribution(1000)
            end
        },
        {
            name = "添加联盟贡献10000",
            callback = function()
                Net.GM.AddAllianceHonor(10000)
            end
        },
        {
            name = "添加联盟礼包",
            callback = function()
                Net.GM.AddAllianceItems(Model.Account.accountId)
            end
        },
        {
            name = "加入联盟排行榜",
            callback = function()
                Net.GM.JoinAllianceContriRank(1000)
            end
        },
        {
            name = "联盟建筑",
            callback = function()
                UIMgr:Open("GMBox", "联盟建筑")
            end
        },
        {
            name = "请求联盟战争记录",
            callback = function()
                Net.GM.AddBattleLog(100)
            end
        }
    }
    local score = {
        {
            name = "加1000积分",
            value = 1000
        },
        {
            name = "加10万积分",
            value = 100000
        },
        {
            name = "减1000积分",
            value = -1000
        }
    }
    local honor = {
        {
            name = "加1000荣誉",
            value = 1000
        },
        {
            name = "加10万荣誉",
            value = 100000
        },
        {
            name = "减1000荣誉",
            value = -1000
        }
    }
    local member = {
        {
            name = "加1名成员",
            value = 1
        },
        {
            name = "加10名成员",
            value = 10
        }
    }
    local power = {
        {
            name = "加10k战斗力",
            value = 10000
        },
        {
            name = "加100k战斗力",
            value = 100000
        },
        {
            name = "减10k战斗力",
            value = -10000
        },
        {
            name = "减100k战斗力",
            value = -100000
        }
    }
    self._list.numItems = #special + #score + #honor + #member + #power
    for k, v in pairs(special) do
        local child = self._list:GetChildAt(k - 1)
        child.title = v.name
        child:init(v.callback)
    end
    for k, v in pairs(score) do
        local child = self._list:GetChildAt(k - 1 + #special)
        child.title = v.name
        child:init(
            function()
                Net.GM.AddAllianceHonorScore(v.value)
            end
        )
    end
    for k, v in pairs(honor) do
        local child = self._list:GetChildAt(k - 1 + #special + #score)
        child.title = v.name
        child:init(
            function()
                Net.GM.AddAllianceHonor(v.value)
            end
        )
    end
    for k, v in pairs(member) do
        local child = self._list:GetChildAt(k - 1 + #special + #score + #honor)
        child.title = v.name
        child:init(
            function()
                Net.GM.AddAllianceMembers(v.value)
            end
        )
    end
    for k, v in pairs(power) do
        local child = self._list:GetChildAt(k - 1 + #special + #score + #honor + #member)
        child.title = v.name
        child:init(
            function()
                Net.GM.AddAlliancePower(v.value)
            end
        )
    end
end
--联盟建筑
function GMBox:UnionBuilding()
    local buildings = {
        {
            name = "修建堡垒",
            callback = function()
                Net.GM.CompleteAllianceBuilding(610000)
            end
        },
        {
            name = "修建粮食矿",
            callback = function()
                Net.GM.CompleteAllianceBuilding(610007)
            end
        },
        {
            name = "修建钢铁矿",
            callback = function()
                Net.GM.CompleteAllianceBuilding(610008)
            end
        },
        {
            name = "修建石油矿",
            callback = function()
                Net.GM.CompleteAllianceBuilding(610009)
            end
        },
        {
            name = "修建稀土矿",
            callback = function()
                Net.GM.CompleteAllianceBuilding(610010)
            end
        },
        {
            name = "修建防御塔",
            callback = function()
                Net.GM.CompleteAllianceBuilding(610011)
            end
        },
        {
            name = "修建联盟医院",
            callback = function()
                Net.GM.CompleteAllianceBuilding(610005)
            end
        }
    }

    self._list.numItems = #buildings
    for k, v in pairs(buildings) do
        local child = self._list:GetChildAt(k - 1)
        child.title = v.name
        child:init(v.callback)
    end
end

--[[
    --一键完成
    --任务
    category有0-3共4个值
    0代表指定任务，要输入任务id
    1-3分别代表全部每日任务、全部成就和全部主线任务，不需要id
]]
function GMBox:OneClickOompletion()
    local normal = {
        {
            name = "每日任务",
            callback = function()
                Net.GM.FinishTask(1)
            end
        },
        {
            name = "全部成就",
            callback = function()
                Net.GM.FinishTask(2)
            end
        },
        {
            name = "全部主线任务",
            callback = function()
                Net.GM.FinishTask(
                    3,
                    function()
                        FUIUtils.QuitGame()
                    end
                )
            end
        },
        {
            name = "刷新每日任务",
            callback = function()
                Net.GM.RefreshDailyTasks()
            end
        },
        {
            name = "建筑升满",
            callback = function()
                PlayerDataModel:SetData(PlayerDataEnum.CENTER_UPGRADE_OPEN, true)
                Net.GM.AddAllBuilding(
                    Model.Account.accountId,
                    30,
                    function()
                        FUIUtils.QuitGame()
                    end
                )
            end
        },
        {
            name = "破除玩家的保护罩",
            callback = function()
                Net.GM.BreakShield()
            end
        },
        {
            name = "全服保护罩",
            callback = function()
                Net.GM.AddServerShield()
            end
        },
        {
            name = "移除全服保护罩",
            callback = function()
                Net.GM.RemoveServerShield()
            end
        },
        {
            name = "升级所有科技",
            callback = function()
                Net.GM.AddAllTechs(
                    function()
                        FUIUtils.QuitGame()
                    end
                )
            end
        },
        {
            name = "技能升满",
            callback = function()
                Net.GM.UnlockSkill(
                    function()
                        FUIUtils.QuitGame()
                    end
                )
            end
        },
        {
            name = "解锁成长基金",
            callback = function()
                Net.GM.UnlockGrowthFund(
                    function()
                    end
                )
            end
        },
        {
            name = "完成章节任务",
            callback = function()
                Net.GM.FinishCurChapterTasks()
            end
        },
        {
            name = "测试按钮",
            callback = function()
                local mainUI = UIMgr:GetUI("MainUIPanel")
                mainUI._testBtn.visible = true
                mainUI._testIcon.visible = true
            end
        },
        {
            name = "触发充值任务",
            callback = function()
                Net.GM.TriggerRechargeTask()
            end
        },
        {
            name = "增加10次侦查",
            callback = function()
                Net.GM.InvestigationAddProcess(10)
            end
        }
    }

    self._list.numItems = #normal
    for k, v in pairs(normal) do
        local child = self._list:GetChildAt(k - 1)
        child.title = v.name
        child:init(v.callback)
    end
end
--性能测试工具
function GMBox:Performance()
    local normal = {
        {
            name = "抓起from内存数据",
            callback = function()
                KSUtil.GetStartMemoryLeakCheck()
            end
        },
        {
            name = "抓起to内存数据",
            callback = function()
                KSUtil.GetCurrentMemoryLeakCheck()
            end
        },
        {
            name = "对比内存数据",
            callback = function()
                KSUtil.GetConpareMemoryLeakCheck()
            end
        },
        {
            name = "lua 垃圾回收",
            callback = function()
                print(collectgarbage("count"))
            end
        },
        {
            name = "c# 垃圾回收",
            callback = function()
                KSUtil.MonoGc()
            end
        },
        {
            name = "c# 释放无用的资源",
            callback = function()
                KSUtil.ResourcesUnloadUnusedAssets()
            end
        }
    }
    self._list.numItems = #normal
    for k, v in pairs(normal) do
        local child = self._list:GetChildAt(k - 1)
        child.title = v.name
        child:init(v.callback)
    end
end
--大地图相关
function GMBox:AboutMap()
    local normal = {
        {
            name = "全服保护罩",
            callback = function()
                Net.GM.AddServerShield()
            end
        },
        {
            name = "移除全服保护罩",
            callback = function()
                Net.GM.RemoveServerShield()
            end
        },
        {
            name = "请求回收自己基地",
            callback = function()
                Net.GM.RecoverBase()
                self:ScheduleOnce(
                    function()
                        FUIUtils.QuitGame()
                    end,
                    1
                )
            end
        }
    }
    self._list.numItems = #normal
    for k, v in pairs(normal) do
        local child = self._list:GetChildAt(k - 1)
        child.title = v.name
        child:init(v.callback)
    end
end

function GMBox:TurnplateGiftBuy()
    local list = {
            name = "转盘礼包购买1",
            callback = function()
                Net.GM.PurchaseSuccess(90003001, 2)
            end
        },
        {
            name = "转盘礼包购买2",
            callback = function()
                Net.GM.PurchaseSuccess(90003002, 2)
            end
        },
        {
            name = "转盘礼包购买3",
            callback = function()
                Net.GM.PurchaseSuccess(90003003, 2)
            end
        },
        {
            name = "转盘礼包购买4",
            callback = function()
                Net.GM.PurchaseSuccess(90003004, 2)
            end
        },
        {
            name = "转盘礼包购买5",
            callback = function()
                Net.GM.PurchaseSuccess(90003005, 2)
            end
        },
        {
            name = "转盘礼包购买6",
            callback = function()
                Net.GM.PurchaseSuccess(90003006, 2)
            end
        },
        {
            name = "转盘礼包购买7",
            callback = function()
                Net.GM.PurchaseSuccess(90003007, 2)
            end
        }
    self._list.numItems = #list
    for k, v in pairs(list) do
        local child = self._list:GetChildAt(k - 1)
        child.title = v.name
        child:init(v.callback)
    end
end

function GMBox:CustomEvent()
    local list = {
        {
            name = "创建防御引导",
            callback = function()
                Event.Broadcast(EventDefines.DefenceCenterTrigger)
            end
        },
        {
            name = "创建援兵引导",
            callback = function()
                Event.Broadcast(EventDefines.TwelveHourTrigger)
            end
        },
        {
            name = "创建金刚引导",
            callback = function()
                Event.Broadcast(EventDefines.KingkongTrigger)
            end
        },
        {
            name = "10秒内完成自定义引导",
            callback = function()
                CustomEventManager.GMToFinishGuide()
            end
        }
    }
    self._list.numItems = #list
    for k, v in pairs(list) do
        local child = self._list:GetChildAt(k - 1)
        child.title = v.name
        child:init(v.callback)
    end
end

function GMBox:RoyalBattle()
    local list = {
        {
            name = "导弹发射测试",
            callback = function()
                Event.Broadcast(EventDefines.RoyalDartFly, {X = 605, Y = 605})
            end
        },
        {
            name = "成为国王",
            callback = function()
                Net.GM.BecomeKing()
            end
        },
        {
            name = "王位战占领结束",
            callback = function()
                Net.GM.PeaceContract()
            end
        },
        {
            name = "王城战重置",
            callback = function()
                Net.GM.ResetKingdomEvent()
            end
        }
    }
    self._list.numItems = #list
    for k, v in pairs(list) do
        local child = self._list:GetChildAt(k - 1)
        child.title = v.name
        child:init(v.callback)
    end
end

return GMBox
