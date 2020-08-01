--author: 	Amu
--time:		2019-07-18 17:57:42
local GD = _G.GD
local BuildModel = import("Model/BuildModel")
local SpecialBuildModel = import("Model/SpecialBuildModel")
local WorldMap = import("UI/WorldMap/WorldMap")
local ChatBarModel = import("Model/ChatBarModel")

local ChatModel = {}

local radioMsgList = {}
local first_radioMsgList = {}       -- 全服公告喇叭（最优先）
local system_radioMsgList = {}      -- 系统通知列表
local chat_radioMsgList = {}        -- 聊天消息列表
local casino_radioMsgList = {}      -- 赌场列表
local turntable_radioMsgList = {}   -- 转盘列表
local operate_radioMsgList = {}     -- 运营列表
local radioTipsIsShow = false
local _msg = {}
local thumbs_up_list = {}
local GlobalVars = GlobalVars
ChatModel.casinoTipsIsShow = false
ChatModel.trurnTipsIsShow = false

function ChatModel:Init()
    self.chatType = CHAT_TYPE.WorldChat
    self.newWorldMsgs = nil
    self.newUnionMsgs = nil

    self:InitEvent()
end

function ChatModel:InitEvent()
    Event.AddListener(EventDefines.RadioChatEvent, function(msg)
        if msg.Category == RADIO_TYPE.FirstRadio then           --全服公告喇叭（最优先）
            table.insert(first_radioMsgList, msg)
        elseif msg.Category == RADIO_TYPE.SystemRadio then      --系统喇叭
            table.insert(system_radioMsgList, msg)
        elseif msg.Category == RADIO_TYPE.ChatRadio then        --玩家喇叭
            table.insert(chat_radioMsgList, msg)
        elseif msg.Category == RADIO_TYPE.CasinoRadio then      --赌场喇叭
            table.insert(casino_radioMsgList, 1, msg)
        elseif msg.Category == RADIO_TYPE.TurnRadio then        -- 转盘喇叭
            table.insert(turntable_radioMsgList, 1, msg)
            Event.Broadcast(TURNTABLE_EVENT.RadioChange)
            return
        elseif msg.Category == RADIO_TYPE.OperateRadio then     --普通运营喇叭
            table.insert(operate_radioMsgList, msg)
        end

        self:ShowRaiodTips()
     end)

    Event.AddListener(EventDefines.RadioEndChatEvent, function(msg)
        radioTipsIsShow = false
        self:ShowRaiodTips()
    end)
end

function ChatModel:InsertMsgs(msgs)
    for _,msg in pairs(msgs)do
        if msg.Category == RADIO_TYPE.CasinoRadio then        --赌场喇叭
            table.insert(casino_radioMsgList, msg)
        elseif msg.Category == RADIO_TYPE.TurnRadio then        --转盘喇叭
            table.insert(turntable_radioMsgList, msg)
            return
        end
    end
    self:ShowRaiodTips()
end

function ChatModel:OpenCasinoRadio()
    ChatModel.casinoTipsIsShow = true
    Event.Broadcast(EventDefines.OpenCasinoRadioChatEvent)
    self:ShowRaiodTips()
end

function ChatModel:CloseCasinoRadio()
    ChatModel.casinoTipsIsShow = false
    Event.Broadcast(EventDefines.ExitCasinoRadioChatEvent)
    if _msg and _msg.Category == RADIO_TYPE.CasinoRadio then        --赌场喇叭
        self:ShowRaiodTips()
    end
end

function ChatModel:OpenTurnRadio()
    ChatModel.trurnTipsIsShow = true
    Event.Broadcast(EventDefines.OpenTurnRadioChatEvent)
    self:ShowRaiodTips()
end

function ChatModel:CloseTurnRadio()
    ChatModel.trurnTipsIsShow = false
    Event.Broadcast(EventDefines.ExitTurnRadioChatEvent)
    if _msg and _msg.Category == RADIO_TYPE.TurnRadio then        --转盘喇叭
        self:ShowRaiodTips()
    end
end

function ChatModel:ShowRaiodTips()
    if radioTipsIsShow or GlobalVars.IsNoviceGuideStatus then
        return
    end
    _msg = nil
    local type = nil
    if #first_radioMsgList > 0 then
        _msg = table.remove(first_radioMsgList, 1)
        type = RADIO_TYPE.FirstRadio
    elseif #system_radioMsgList > 0 then
        _msg = table.remove(system_radioMsgList, 1)
        type = RADIO_TYPE.SystemRadio
    elseif #chat_radioMsgList > 0 then
        _msg = table.remove(chat_radioMsgList)
        type = RADIO_TYPE.ChatRadio
    elseif #casino_radioMsgList > 0 and ChatModel.casinoTipsIsShow then
        _msg = table.remove(casino_radioMsgList, 1)
        type = RADIO_TYPE.CasinoRadio
        if #casino_radioMsgList < 5 then
            table.insert(casino_radioMsgList, _msg)
        end
    elseif #turntable_radioMsgList > 0 and ChatModel.trurnTipsIsShow then
        _msg = table.remove(turntable_radioMsgList, 1)
        type = RADIO_TYPE.TurnRadio
        if #turntable_radioMsgList < 5 then
            table.insert(turntable_radioMsgList, _msg)
        end
        return
    elseif #operate_radioMsgList > 0 then
        _msg = table.remove(operate_radioMsgList, 1)
        type = RADIO_TYPE.OperateRadio
    end
    if _msg then
        radioTipsIsShow = true
        UIMgr:Open("ChatTips", type, _msg)
        if type == RADIO_TYPE.TurnRadio then
            UIMgr:GetUI("ChatTips").Controller.uiType = FUIType.Panel_Pop
        else
            UIMgr:GetUI("ChatTips").Controller.uiType = FUIType.Panel_Tip
        end
    else
        radioTipsIsShow = false
    end
end

function ChatModel:GetTurntableRadio()
    if #turntable_radioMsgList > 0 then
        local _msg = table.remove(turntable_radioMsgList, 1)
        if #turntable_radioMsgList < 5 then
            table.insert(turntable_radioMsgList, _msg)
        end
        return _msg
    end
    return nil
end

---------------------------------------------------------------------------------------------------

--msg点击跳转
function ChatModel:JumpToByMsgType(type, msg, anchor)
    if type == MSG_TYPE.Chat then
        if msg.RoomId == "World" then --世界频道消息
            if msg.MType == PUBLIC_CHAT_TYPE.Normal then --普通
                local chatBar = ChatBarModel.GetChatBar()
                chatBar:Init(0)
                chatBar:SetBtnOne(StringUtil.GetI18n(I18nType.Commmon, "Chat_Copy"), function()
                    GUIUtility.systemCopyBuffer = msg.Content
                    TipUtil.TipById(50126)
                end)
                UIMgr:ShowPopup("Common", "itemChatBar", anchor, false)
                return
            elseif msg.MType == PUBLIC_CHAT_TYPE.Radio then --广播
                return
            elseif msg.MType == PUBLIC_CHAT_TYPE.RedPacket then --红包
                return
            elseif msg.MType == WORLD_CHAT_TYEP.Lucky then --快来看看我在幸运转盘中获得的超赞奖励
                --TODO
                return
            elseif msg.MType == WORLD_CHAT_TYEP.Gift then --兄弟们，快来抢伴手礼
                --TODO
                return
            elseif msg.MType == WORLD_CHAT_TYEP.Invite then --联盟{alliance_name}招人
                local params = JSON.decode(msg.Params)
                if not params.AllianceId then
                    return
                end
                UIMgr:Open("UnionViewData", params.AllianceId)
                return
            elseif
                msg.MType == PUBLIC_CHAT_TYPE.ChatAttackSuccessShare or --我进攻了{playername}，战斗胜利
                    msg.MType == PUBLIC_CHAT_TYPE.ChatAttackFailShare or --我进攻了{playername}，战斗失败
                    msg.MType == PUBLIC_CHAT_TYPE.ChatDefenceSuccessShare or --我受到了{playername}的攻击，战斗胜利
                    msg.MType == PUBLIC_CHAT_TYPE.ChatDefenceFailShare or     --我受到了{playername}的攻击，战斗失败
                    msg.MType == PUBLIC_CHAT_TYPE.ChatScoutShare or         --我侦察了{playername}
                    msg.MType == PUBLIC_CHAT_TYPE.ChatBescoutShare         --{playername}侦察了我
             then 
                -- elseif msg.MType == PUBLIC_CHAT_TYPE.ChatAttackSuccessShare then--我进攻了{playername}，战斗胜利
                --     --TODO
                --     return
                -- elseif msg.MType == PUBLIC_CHAT_TYPE.ChatAttackFailShare then--我进攻了{playername}，战斗失败
                --     --TODO
                --     return
                -- elseif msg.MType == PUBLIC_CHAT_TYPE.ChatDefenceSuccessShare then--我受到了{playername}的攻击，战斗胜利
                --     --TODO
                --     return
                -- elseif msg.MType == PUBLIC_CHAT_TYPE.ChatDefenceFailShare then--我受到了{playername}的攻击，战斗失败
                --     --TODO
                --     return
                local params = JSON.decode(msg.Params)
                if not params.id then
                    return
                end
                Net.Mails.RequestMailData(msg.SenderId, params.id,function(mailmsg)
                    if mailmsg.MailData.SubCategory == MAIL_SUBTYPE.subScoutReport or mailmsg.MailData.SubCategory == MAIL_SUBTYPE.subBeScoutReport then
                        UIMgr:Open("MailScout", MAIL_TYPE.PVPReport, 0, mailmsg.MailData, nil, MAIL_SHOWTYPE.Shere, msg.SenderId)
                    else
                        UIMgr:Open("MailWarReport", MAIL_TYPE.PVPReport, 0, mailmsg.MailData, nil, MAIL_SHOWTYPE.Shere, msg.SenderId)
                    end
                end)
                return
            elseif msg.MType == WORLD_CHAT_TYEP.GreatAlliance then --我创建了联盟{alliance_name}，大家快来加入联盟一起壮大联盟（系统）
                local params = JSON.decode(msg.Params)
                if not params.AllianceId then
                    return
                end
                Net.Alliances.Exists(params.AllianceId, function(msg)
                    if msg.Exists then
                        UIMgr:Open("UnionViewData", params.AllianceId)
                    else
                        TipUtil.TipById(50051)
                    end
                end)
                
                return
            elseif msg.MType == PUBLIC_CHAT_TYPE.ChatRangeRewardRecordShare then --快来看看我在靶场中获得的超赞奖励
                local params = JSON.decode(msg.Params)
                if not params then
                    return
                end
                UIMgr:Open("RangeRewardRecord", params, "Chat", function()
                    Event.Broadcast(EventDefines.ExitRangeRewardRecord)
                    UIMgr:Close("RangeRewardRecord")
                    TurnModel.Casion()
                end)
                return
            elseif msg.MType == PUBLIC_CHAT_TYPE.OperationFalcon_Share then --我在猎鹰行动中获取到的奖励
                local params = JSON.decode(msg.Params)
                if not params then
                    return
                end
                UIMgr:Open("FalconActivitiseSharePopup", params)
                return
            elseif msg.MType == PUBLIC_CHAT_TYPE.OperationFalcon_Technology then --我在猎鹰行动中获取到的奖励
                local params = JSON.decode(msg.Params)
                if not params then
                    return
                end
                UIMgr:Open("FalconActivitiseTechRecordSharePopup", params)
                --Net.Mails.RequestMailData(msg.SenderId, params,
                --    function(mailmsg)
                --        UIMgr:Open("MailUnion",MAIL_TYPE.Activity, 0, mailmsg.MailData,nil,MAIL_SHOWTYPE.Shere)
                --    end
                --)
                return
            end
        else --联盟频道消息
            if msg.MType == PUBLIC_CHAT_TYPE.Normal then --普通
                local chatBar = ChatBarModel.GetChatBar()
                chatBar:Init(0)
                chatBar:SetBtnOne(StringUtil.GetI18n(I18nType.Commmon, "Chat_Copy"), function()
                    GUIUtility.systemCopyBuffer = msg.Content
                    TipUtil.TipById(50126)
                end)
                UIMgr:ShowPopup("Common", "itemChatBar", anchor, false)
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.ResHelp then --急需{res_name}资源应急，请求盟友支持！
                if msg.SenderId == UserModel.data.accountId then
                    return
                end
                local confId = Global.BuildingTransferStation -- 资源中转站
                if BuildModel.CheckExist(confId) then
                    Net.AllianceAssist.AssistInfo(
                        msg.SenderId,
                        function(rsp)
                            if rsp.Fail then
                                return
                            end
                            UIMgr:Open("UnionWarehouseAccessResources", 1, rsp)
                        end
                    )
                else
                    TipUtil.TipById(50202)
                end
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.Aggregation then --我发起了一次集结，请大家协助
                UIMgr:Open("UnionWarfare")
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.SignShop then --我在联盟商店标记了{item_name}，需要进行货物补充
                --联盟商店
                local params = JSON.decode(msg.Params)
                if not params.ItemId then
                    return
                end
                Net.AllianceShop.Info(
                    Model.Player.AllianceId,
                    function(msg)
                        UIMgr:Open("UnionShop", msg, params.ItemId)
                    end
                )
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.SharePos then --我分享了一个坐标(x,y)
                local params = JSON.decode(msg.Params)
                TurnModel.WorldPos(params.X, params.Y)
                return
            elseif
                msg.MType == PUBLIC_CHAT_TYPE.ChatAttackSuccessShare or --我进攻了{playername}，战斗胜利
                    msg.MType == PUBLIC_CHAT_TYPE.ChatAttackFailShare or --我进攻了{playername}，战斗失败
                    msg.MType == PUBLIC_CHAT_TYPE.ChatDefenceSuccessShare or --我受到了{playername}的攻击，战斗胜利
                    msg.MType == PUBLIC_CHAT_TYPE.ChatDefenceFailShare or --我受到了{playername}的攻击，战斗失败
                    msg.MType == PUBLIC_CHAT_TYPE.ChatScoutShare or         --我侦察了{playername}
                    msg.MType == PUBLIC_CHAT_TYPE.ChatBescoutShare         --{playername}侦察了我
             then 
                local params = JSON.decode(msg.Params)
                if not params.id then
                    return
                end
                Net.Mails.RequestMailData(
                    msg.SenderId,
                    params.id,
                    Net.Mails.RequestMailData(msg.SenderId, params.id,function(mailmsg)
                        if mailmsg.MailData.SubCategory == MAIL_SUBTYPE.subScoutReport or mailmsg.MailData.SubCategory == MAIL_SUBTYPE.subBeScoutReport then
                            UIMgr:Open("MailScout", MAIL_TYPE.PVPReport, 0, mailmsg.MailData, nil, MAIL_SHOWTYPE.Shere, msg.SenderId)
                        else
                            UIMgr:Open("MailWarReport", MAIL_TYPE.PVPReport, 0, mailmsg.MailData, nil, MAIL_SHOWTYPE.Shere, msg.SenderId)
                        end
                    end)
                )
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.Voting then --我分享了投票
                if msg.Params == "" then
                    return
                end
                local params = JSON.decode(msg.Params)
                if not params.id then
                    return
                end
                Net.AllianceVote.RequestVoteById(
                    params.id,
                    function(msg)
                        local vote = msg.Vote
                        vote.members = msg.Members
                        UIMgr:Open("UnionVoteing", vote)
                    end
                )
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.ArmyHelp then --我正在遭受敌人的攻击，请求盟友援助
                --TODO
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.Likes then --{playername}的基地等级达到了{number}级，，实力更上一层楼，大家一起来为他点赞吧
                local msgId = msg.MessageId
                if thumbs_up_list[msgId] then
                    TipUtil.TipById(50351)
                elseif msg.SenderId ~= UserModel.data.accountId then
                    Net.Alliances.ThumbUpMemberLevelUp(msg.SenderId, msg.MessageId, function(msg)
                        if msg.Result == 0 then     --success
                            UITool.ShowReward(msg.Rewards)
                            thumbs_up_list[msgId] = true
                        elseif msg.Result == 1 then --self
                            TipUtil.TipById(50352)
                        elseif msg.Result == 2 then --thumben
                            TipUtil.TipById(50351)
                            thumbs_up_list[msgId] = true
                        end
                    end)
                else
                    TipUtil.TipById(50352)
                end
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.ShopSupplement then --{playername}为联盟商店补充了{item_name}
                --TODO
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.TaskHelp then --我正在执行{task_name}，请协助我完成
                if UnionModel.CheckOpenCondition(102) then
                    UIMgr:Open("UnionTask", 3)
                end
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.Exit then --我退出了联盟，我会想念大家的
                --TODO
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.Join then --{playernam}前来报到，我将和大家一起建设联盟
                --TODO
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.BePromoted then --我将{playername}的权限等级由{rank1}调整为{rank2}，希望他能为联盟做更多的贡献
                --TODO
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.Expel then --{playernama}已经被移出联盟。
                --TODO
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.Bossreplace then --我将盟主转让给了{playname}，希望在他的带领下联盟更加强大
                --TODO
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.HelpDefence then --派遣部队帮助你的盟友守卫他们的基地。
                --TODO
                return
            elseif msg.MType == ALLIANCE_CHAT_TYEP.BePromotedDown then --我将{playername}的权限等级由{rank1}调整为{rank2}，希望他不要气馁，再接再厉继续为联盟做出更多贡献
                --TODO
                return
            elseif msg.MType == PUBLIC_CHAT_TYPE.ChatRangeRewardRecordShare then --快来看看我在靶场中获得的超赞奖励
                local params = JSON.decode(msg.Params)
                if not params then
                    return
                end
                UIMgr:Open("RangeRewardRecord", params, "Chat", function()
                    Event.Broadcast(EventDefines.ExitRangeRewardRecord)
                    UIMgr:Close("RangeRewardRecord")
                    TurnModel.Casion()
                end)
                return
            elseif msg.MType == PUBLIC_CHAT_TYPE.Alliance_OperationFalcon_Share then --我在猎鹰行动中获取到的奖励
                local params = JSON.decode(msg.Params)
                if not params then
                    return
                end
                UIMgr:Open("FalconActivitiseSharePopup", params)
                return
            elseif msg.MType == PUBLIC_CHAT_TYPE.Alliance_OperationFalcon_Technology then --我在猎鹰行动中获取到的奖励
                local params = JSON.decode(msg.Params)
                if not params then
                    return
                end
                UIMgr:Open("FalconActivitiseTechRecordSharePopup", params)
                --Net.Mails.RequestMailData(msg.SenderId, params,
                --    function(mailmsg)
                --        UIMgr:Open("MailUnion",MAIL_TYPE.Activity, 0, mailmsg.MailData,nil,MAIL_SHOWTYPE.Shere)
                --    end
                --)
                return
            end
        end
    elseif type == MSG_TYPE.Mail then

    elseif type == MSG_TYPE.RMsg then   --跑马灯
        if msg.NotifyId == 30001 then   --赌场喇叭
            local params = JSON.decode(msg.Params)
            if not params then
                return
            end
            UIMgr:Open("RangeRewardRecord", params, "Chat", function()
                Event.Broadcast(EventDefines.ExitRangeRewardRecord)
                UIMgr:Close("RangeRewardRecord")
                if not UIMgr:GetUIOpen("RangeFlop/RangeFlop") then
                    TurnModel.Casion()
                end
            end)
            return
        end
    end
end

--msg文本嵌入
function ChatModel:SetMsgTemplateByType(lable, type, msg)
    if type == MSG_TYPE.Chat then --普通聊天（包括联盟聊天）
        if msg.RoomId == "World" then --世界频道消息
            if msg.MType >= WORLD_CHAT_TYEP.Lucky then
                local str = ConfigMgr.GetI18n("configI18nCommons", "world_chat_" .. msg.MType)
                lable.text = str
                if msg.MType == WORLD_CHAT_TYEP.Lucky then --快来看看我在幸运转盘中获得的超赞奖励
                    --TODO
                    return
                elseif msg.MType == WORLD_CHAT_TYEP.Gift then --兄弟们，快来抢伴手礼
                    --TODO
                    return
                elseif msg.MType == WORLD_CHAT_TYEP.Invite then --联盟{alliance_name}招人
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.AllianceId then
                        return
                    end
                    if params.str then
                        lable.text = params.str
                    else
                        lable:SetVar("alliance_name", params.AllianceName):FlushVars()
                    end
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.ChatAttackSuccessShare then --我进攻了{playername}，战斗胜利
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.name then
                        return
                    end
                    lable:SetVar("playername", params.name):FlushVars()
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.ChatAttackFailShare then --我进攻了{playername}，战斗失败
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.name then
                        return
                    end
                    lable:SetVar("playername", params.name):FlushVars()
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.ChatDefenceSuccessShare then --我受到了{playername}的攻击，战斗胜利
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.name then
                        return
                    end
                    lable:SetVar("playername", params.name):FlushVars()
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.ChatDefenceFailShare then --我受到了{playername}的攻击，战斗失败
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.name then
                        return
                    end
                    lable:SetVar("playername", params.name):FlushVars()
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.ChatScoutShare then --我侦察了{playername}
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.name then
                        return
                    end
                    lable:SetVar("playername", params.name):FlushVars()
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.ChatBescoutShare then --{playername}侦察了我
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.name then
                        return
                    end
                    lable:SetVar("playername", params.name):FlushVars()
                    return
                elseif msg.MType == WORLD_CHAT_TYEP.GreatAlliance then --我创建了联盟{alliance_name}，大家快来加入联盟一起壮大联盟（系统）
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.AllianceId then
                        return
                    end
                    if params.str then
                        lable.text = params.str
                    else
                        lable:SetVar("alliance_name", params.AllianceName):FlushVars()
                    end
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.ChatRangeRewardRecordShare then --快来看看我在靶场中获得的超赞奖励
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.OperationFalcon_Share then --我在猎鹰行动中获取到的奖励
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.OperationFalcon_Technology then --快来看看我在猎鹰行动中获取的科技奖励
                    return
                end
            -- else
            --     return msg.Content
            end
        else --联盟频道消息
            if msg.MType >= ALLIANCE_CHAT_TYEP.ResHelp then
                local str = ConfigMgr.GetI18n("configI18nCommons", "Alliance_chat_" .. msg.MType)
                lable.text = str
                if msg.MType == ALLIANCE_CHAT_TYEP.ResHelp then --急需{res_name}资源应急，请求盟友支持！
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.ResId then
                        return
                    end
                    lable:SetVar("res_name", ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_" .. math.ceil(params.ResId))):FlushVars()
                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.Aggregation then --我发起了一次集结，请大家协助
                    --TODO

                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.SignShop then --我在联盟商店标记了{item_name}，需要进行货物补充
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.ItemId then
                        return
                    end
                    lable:SetVar("item_name", GD.ItemAgent.GetItemNameByConfId(math.ceil(params.ItemId))):FlushVars()
                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.SharePos then --我分享了一个坐标(x,y)
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.Category then
                        return
                    end
                    lable.text = ConfigMgr.GetI18n("configI18nCommons", "COORDINATE_SHARE_TEXT_" .. math.ceil(params.Category))
                    if params.Category == Global.CoordinateShareMonster then
                        lable:SetVar("monster_name", ConfigMgr.GetI18n("configI18nCommons", "MAP_MONTSTER_" .. math.floor(params.ConfId)))
                    end
                    lable:SetVar("x", math.ceil(params.X))
                    lable:SetVar("y", math.ceil(params.Y)):FlushVars()
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.ChatAttackSuccessShare then --我进攻了{playername}，战斗胜利
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.name then
                        return
                    end
                    lable:SetVar("playername", params.name):FlushVars()
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.ChatAttackFailShare then --我进攻了{playername}，战斗失败
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.name then
                        return
                    end
                    lable:SetVar("playername", params.name):FlushVars()
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.ChatDefenceSuccessShare then --我受到了{playername}的攻击，战斗胜利
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.name then
                        return
                    end
                    lable:SetVar("playername", params.name):FlushVars()
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.ChatDefenceFailShare then --我受到了{playername}的攻击，战斗失败
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.name then
                        return
                    end
                    lable:SetVar("playername", params.name):FlushVars()
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.ChatScoutShare then --我侦察了{playername}
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.name then
                        return
                    end
                    lable:SetVar("playername", params.name):FlushVars()
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.ChatBescoutShare then --{playername}侦察了我
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.name then
                        return
                    end
                    lable:SetVar("playername", params.name):FlushVars()
                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.Voting then --我分享了投票
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.id then
                        return
                    end
                    lable.text = params.title
                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.ArmyHelp then --我正在遭受敌人的攻击，请求盟友援助
                    --TODO

                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.Likes then --{playername}的基地等级达到了{number}级，，实力更上一层楼，大家一起来为他点赞吧
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.UserName then
                        return
                    end
                    lable:SetVar("playername", params.UserName):SetVar("number", math.ceil(params.Level)):FlushVars()
                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.ShopSupplement then --{playername}为联盟商店补充了{item_name}
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.ItemId then
                        return
                    end
                    local playerStr = ""
                    for _,v in pairs(params.UserNames)do
                        playerStr = playerStr.."@"..v.." "
                    end
                    lable:SetVar("playername", msg.Sender)
                    :SetVar("item_name", GD.ItemAgent.GetItemNameByConfId(math.ceil(params.ItemId)))
                    :SetVar("playername1", playerStr)
                    :FlushVars()
                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.TaskHelp then --我正在执行[color={color}]{task_name}[/color]，请协助我完成
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.Task then
                        return
                    end
                    local configTask = ConfigMgr.GetItem("configAllianceTasks", params.Task.ConfId)
                    lable:SetVar("color", Global.Colour[configTask.grade + 1])
                    lable:SetVar("task_name", ConfigMgr.GetI18n("configI18nCommons", configTask.name)):FlushVars()
                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.Exit then --我退出了联盟，我会想念大家的
                    --TODO
                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.Join then --{playernam}前来报到，我将和大家一起建设联盟
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.UserName then
                        return
                    end
                    lable:SetVar("playernam", params.UserName):FlushVars()
                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.BePromoted then --我将{playername}的权限等级由{rank1}调整为{rank2}，希望他能为联盟做更多的贡献
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.UserName then
                        return
                    end
                    lable:SetVar("playername", params.UserName)
                    lable:SetVar("rank1", ConfigMgr.GetI18n("configI18nCommons", "Ui_Class_R" .. math.ceil(params.OldPos)))
                    lable:SetVar("rank2", ConfigMgr.GetI18n("configI18nCommons", "Ui_Class_R" .. math.ceil(params.NowPos))):FlushVars()
                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.Expel then --{playernama}已经被移出联盟。
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.UserName then
                        return
                    end
                    lable:SetVar("playernama", params.UserName):FlushVars()
                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.Bossreplace then --我将盟主转让给了{playname}，希望在他的带领下联盟更加强大
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.UserName then
                        return
                    end
                    lable:SetVar("playname", params.UserName):FlushVars()
                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.HelpDefence then --派遣部队帮助你的盟友守卫他们的基地。
                    --TODO

                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.BePromotedDown then --我将{playername}的权限等级由{rank1}调整为{rank2}，希望他不要气馁，再接再厉继续为联盟做出更多贡献
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.UserName then
                        return
                    end
                    lable:SetVar("playername", params.UserName)
                    lable:SetVar("rank1", ConfigMgr.GetI18n("configI18nCommons", "Ui_Class_R" .. math.ceil(params.OldPos)))
                    lable:SetVar("rank2", ConfigMgr.GetI18n("configI18nCommons", "Ui_Class_R" .. math.ceil(params.NowPos))):FlushVars()
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.ChatRangeRewardRecordShare then --快来看看我在靶场中获得的超赞奖励
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.Alliance_OperationFalcon_Share then --我在猎鹰行动中获取到的奖励
                    return
                elseif msg.MType == PUBLIC_CHAT_TYPE.Alliance_OperationFalcon_Technology then --快来看看我在猎鹰行动中获取的科技奖励
                    return
                elseif msg.MType == ALLIANCE_CHAT_TYEP.Bossdisplacement then --我已经取代{play_name}成为新的盟主，我将会带领联盟变得更加强大
                    if msg.Params == "" then
                        return
                    end
                    local params = JSON.decode(msg.Params)
                    if not params.OldPresident then
                        return
                    end
                    lable:SetVar("play_name", params.OldPresident):FlushVars()
                    return
                end
                return
            -- else
            --     return msg.Content
            end
        end
    elseif type == MSG_TYPE.Mail then  --邮件聊天
        if msg.Category >= MAIL_CHAT_TYPE.Invite then
            local str = ConfigMgr.GetI18n("configI18nCommons", "MailGroup"..math.ceil(msg.Category))
            lable.text = str
            if msg.Category == MAIL_CHAT_TYPE.Invite then   --{playername}邀请{playername}加入了聊天
                if msg.Content == "" then
                    return
                end
                local params = JSON.decode(msg.Content)
                if not params.Inviter then
                    return
                end
                if params.Inviter == Model.Player.Name then
                    lable.text = ConfigMgr.GetI18n("configI18nCommons", "MailGroup2011")
                    local Invitees = split(params.Invitees, ",")
                    local str = ""
                    for _,v in pairs(Invitees)do
                        if v ~= params.Inviter then
                            str = str..v..","
                        end
                    end
                    str = string.sub(str, 1, str.len(str)-1)
                    lable:SetVar("playername", str):FlushVars()
                else
                    lable:SetVar("playername1", params.Inviter)
                    local Invitees = split(params.Invitees, ",")
                    local str = ""
                    for _,v in pairs(Invitees)do
                        if v ~= params.Inviter then
                            str = str..v..","
                        end
                    end
                    str = string.sub(str, 1, str.len(str)-1)
                    lable:SetVar("playername2", str):FlushVars()
                end
                return
            elseif msg.Category == MAIL_CHAT_TYPE.Remove then   --{playername}被移出聊天室
                if msg.Content == "" then
                    return
                end
                local params = JSON.decode(msg.Content)
                if not params.Player then
                    return
                end
                lable:SetVar("playername", params.Player):FlushVars()
                return
            elseif msg.Category == MAIL_CHAT_TYPE.Leave then    --{playername}离开了聊天室
                if msg.Content == "" then
                    return
                end
                local params = JSON.decode(msg.Content)
                if not params.Player then
                    return
                end
                lable:SetVar("playername", params.Player):FlushVars()
                return
            end
        end
    end
    lable.text = TextUtil.FormatPosHref(msg.Content)
end

return ChatModel
