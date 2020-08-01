--[[
    Author: songzeming
    Function: 联盟帮助缓存
]]
local UnionHelpModel = {}

local UnionModel = import("Model/UnionModel")
local TechModel = import("Model/TechModel")
local UnionHelpSelfInfo = {} --联盟自己帮助信息
local UnionHelpOtherInfo = {} --联盟其他人帮助信息
local HelpNumber = 0 --联盟帮助数量

--初始化联盟帮助信息
function UnionHelpModel.Init(ctx)
    UnionHelpModel.InitEvent(ctx)
    if UnionModel.CheckJoinUnion() then
        UnionHelpModel.AskUnionHelpInfo()
    end
end

--获取联盟帮助信息
function UnionHelpModel.AskUnionHelpInfo()
    Net.AllianceHelp.Infos(Model.Player.AllianceId, function(rsp)
        for _, v in pairs(rsp.Helps) do
            if Model.Account.accountId == v.UserId then
                for _, v1 in pairs(UnionHelpSelfInfo) do
                    if v.EventId == v1.EventId then
                        return
                    end
                end
                table.insert(UnionHelpSelfInfo, v)
            else
                for _, v1 in pairs(UnionHelpOtherInfo) do
                    if v.EventId == v1.EventId then
                        return
                    end
                end
                table.insert(UnionHelpOtherInfo, v)
            end
        end
        Event.Broadcast(EventDefines.UIAllianceHelpInfoExg)
    end)
end

--联盟帮助监听事件
function UnionHelpModel.InitEvent(ctx)
    --玩家加入联盟
    Event.AddListener(
        EventDefines.UIAllianceJoin,
        function()
            UnionHelpModel.AskUnionHelpInfo()
        end
    )
    --退出联盟
    Event.AddListener(
        UNION_EVENT.Exit,
        function()
            UnionHelpSelfInfo = {}
            UnionHelpOtherInfo = {}
            UnionHelpModel.SetHelpNumber(0)
        end
    )
    --联盟帮助通知
    Event.AddListener(EventDefines.UIAllianceHelp, function(rsp)
        if Model.Account.accountId == rsp.UserId then
            table.insert(UnionHelpSelfInfo, rsp)
        else
            table.insert(UnionHelpOtherInfo, rsp)
        end
        Event.Broadcast(EventDefines.UIAllianceHelpInfoExg)
    end)
    --联盟已帮助通知
    Event.AddListener(EventDefines.UIAllianceHelped, function(uuid)
        for k, v in pairs(UnionHelpSelfInfo) do
            if v.Uuid == uuid then
                table.remove(UnionHelpSelfInfo, k)
                Event.Broadcast(EventDefines.UIAllianceHelpInfoExg)
                return
            end
        end
        for k, v in pairs(UnionHelpOtherInfo) do
            if v.Uuid == uuid then
                table.remove(UnionHelpOtherInfo, k)
                Event.Broadcast(EventDefines.UIAllianceHelpInfoExg)
                return
            end
        end
    end)
    --联盟帮助之自己被帮助
    Event.AddListener(EventDefines.UIAllianceHelpOnHelp, function(rsp)
        for _, v in pairs(UnionHelpSelfInfo) do
            if v.Uuid == rsp.Help.Uuid then
                v.Helped = rsp.Help.Helped
                break
            end
        end
        Event.Broadcast(EventDefines.UIAllianceHelpInfoExg)

        --提示
        if rsp.Help.Category == Global.EventTypeBuilding then
            --建筑建造、升级
            local data = {
                player_name = rsp.Helper,
                level = rsp.Help.Level,
                build_name = ConfigMgr.GetI18n("configI18nBuildings", rsp.Help.ConfId .. "_NAME")
            }
            TipUtil.TipWithAvatar(50029, rsp.HelperAvatar, rsp.Help.Uuid, data)
        elseif Tool.Equal(rsp.Help.Category, Global.EventTypeTech, Global.EventTypeBeastTech) then
            --科技
            local data = {
                player_name = rsp.Helper,
                level = rsp.Help.Level,
                tech_name = TechModel.GetTechName(rsp.Help.ConfId)
            }
            TipUtil.TipWithAvatar(50030, rsp.HelperAvatar, rsp.Help.Uuid, data)
        elseif rsp.Help.Category == Global.EventTypeCure then
            --治疗
            local data = {
                play_name = rsp.Helper
            }
            TipUtil.TipWithAvatar(30007, rsp.HelperAvatar, rsp.Help.Uuid, data)
        elseif rsp.Help.Category == Global.EventTypeBeastCure then
            --治疗巨兽
            local data = {
                play_name = rsp.Helper,
                beast_name = ConfigMgr.GetI18n(I18nType.Army, rsp.Help.ConfId .. '_NAME')
            }
            TipUtil.TipWithAvatar(30010, rsp.HelperAvatar, rsp.Help.Uuid, data)
        end
    end)
end

--获取联盟自己的帮助信息
function UnionHelpModel.GetUnionHelpSelfInfo()
    return UnionHelpSelfInfo
end

--获取联盟其他人的帮助信息
function UnionHelpModel.GetUnionHelpOtherInfo()
    return UnionHelpOtherInfo
end
--清空联盟其他人的帮助信息
function UnionHelpModel.ClearUnionHelpOtherInfo()
    UnionHelpOtherInfo = {}
    Event.Broadcast(EventDefines.UIAllianceHelpInfoExg)
end

function UnionHelpModel.SetHelpNumber(number)
    HelpNumber = number
end
function UnionHelpModel.GetHelpNumber()
   return HelpNumber
end

return UnionHelpModel
