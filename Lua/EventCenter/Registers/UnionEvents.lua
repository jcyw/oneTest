local UnionEvent = {}

local UnionInfoModel = import('Model/Union/UnionInfoModel')
local UnionMemberModel = import('Model/Union/UnionMemberModel')

function UnionEvent.init()
    -- 联盟信息变化通知
    Event.AddListener(
        EventDefines.UIUserAllianceInfo,
        function(rsp)
            --是否加入联盟
            local isJoinNew = false
            local isJoinUnion = Model.Player.AllianceId and Model.Player.AllianceId ~= ''
            if not isJoinUnion and rsp.AllianceId ~= '' then
                --没有加入联盟且联盟信息变为为有联盟 则加入新联盟通知
                if rsp.AlliancePos == Global.AlliancePosR1 then
                    isJoinNew = true
                    local values = {alliance_name = rsp.AllianceName}
                    TipUtil.TipById(50048, values)
                end
                UIMgr:Close("UnionView/UnionView")
            end
            --刷新联盟信息
            Model.Player.AllianceId = rsp.AllianceId
            Model.Player.AllianceName = rsp.AllianceName
            Model.Player.AlliancePos = rsp.AlliancePos
            Model.AppliedAlliance = rsp.AppliedAlliance
            Model.UserAllianceInfo = rsp
            if isJoinNew then
                Event.Broadcast(EventDefines.UIAllianceJoin)
            end
        end
    )
    -- 联盟开除成员
    Event.AddListener(
        EventDefines.UIAllianceFire,
        function(rsp)
            local isSelf = Model.Account.accountId == rsp.MemberId
            if not isSelf then
                UnionMemberModel.DelMember(rsp.MemberId)
                Event.Broadcast(EventDefines.UIAllianceMemberUpdate)
                return
            end
            --Reason 1退出联盟/联盟 2被开除
            if rsp.Reason == 2 then
                UnionInfoModel.ClearInfo()
                UnionMemberModel.ClearMember()
                UIMgr:ClosePopAndTopPanel()
                TipUtil.TipById(50049)
                Event.Broadcast(UNION_EVENT.Exit)
            end
        end
    )
    -- 联盟成员变化
    Event.AddListener(
        EventDefines.UIAllianceMember,
        function(rsp)
            if Model.Account.accountId == rsp.Id then
                --自己联盟职位变动
                Model.Player.AlliancePos = rsp.Position
            end
            if rsp.Position == Global.AlliancePosR5 then
                --会长变动
                local info = UnionInfoModel.GetInfo()
                info.PresidentId = rsp.Id
                info.President = rsp.Name
                Event.Broadcast(EventDefines.UIAllianceInfoExchanged)
            end
            UnionMemberModel.AddMember(rsp)
            Event.Broadcast(EventDefines.UIAllianceMemberUpdate)
        end
    )
    -- 联盟申请信息
    Event.AddListener(
        EventDefines.UIAllianceApplied,
        function(rsp)
            Model.Create(ModelType.AppliedAlliance, rsp.AllianceId, rsp)
        end
    )
end

return UnionEvent
