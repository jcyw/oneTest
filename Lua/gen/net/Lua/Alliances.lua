Net.Alliances = {}

-- 请求-创建联盟
function Net.Alliances.Create(...)
    local fields = {
        "Name", -- string
        "Desc", -- string
        "IsGodLike", -- bool
    }
    Network.RequestDynamic("AllianceCreateParams", fields, ...)
end

-- 请求-修改介绍
function Net.Alliances.ChangeDesc(...)
    local fields = {
        "Desc", -- string
    }
    Network.RequestDynamic("AllianceChangeDescParams", fields, ...)
end

-- 请求-修改名称
function Net.Alliances.ChangeName(...)
    local fields = {
        "Name", -- string
    }
    Network.RequestDynamic("AllianceChangeNameParams", fields, ...)
end

-- 请求-修改简称
function Net.Alliances.ChangeShortName(...)
    local fields = {
        "ShortName", -- string
    }
    Network.RequestDynamic("AllianceChangeShortNameParams", fields, ...)
end

-- 请求-退出联盟
function Net.Alliances.Quit(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceQuitParams", fields, ...)
end

-- 请求-开除联盟成员
function Net.Alliances.Fire(...)
    local fields = {
        "MemberId", -- string
    }
    Network.RequestDynamic("AllianceFireParams", fields, ...)
end

-- 请求-获取联盟成员
function Net.Alliances.Members(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceMembersParams", fields, ...)
end

-- 请求-顶替会长
function Net.Alliances.ReplacePresident(...)
    local fields = {
        "PresidentId", -- string
    }
    Network.RequestDynamic("AllianceReplacePresidentParams", fields, ...)
end

-- 请求-获取联盟信息
function Net.Alliances.Info(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceInfoParams", fields, ...)
end

-- 请求-搜索联盟
function Net.Alliances.Search(...)
    local fields = {
        "Name", -- string
    }
    Network.RequestDynamic("AllianceSearchParams", fields, ...)
end

-- 请求-获取联盟列表
function Net.Alliances.GetPage(...)
    local fields = {
        "Offset", -- int32
        "Limit", -- int32
    }
    Network.RequestDynamic("AllianceGetPageParams", fields, ...)
end

-- 请求-直接加入联盟
function Net.Alliances.Join(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceJoinParams", fields, ...)
end

-- 请求-快速加入联盟
function Net.Alliances.FastJoin(...)
    Network.RequestDynamic("AllianceFastJoinParams", {}, ...)
end

-- 请求-申请加入联盟
function Net.Alliances.ApplyJoin(...)
    local fields = {
        "AllianceId", -- string
        "Msg", -- string
    }
    Network.RequestDynamic("AllianceApplyJoinParams", fields, ...)
end

-- 请求-批准入盟申请
function Net.Alliances.AcceptApply(...)
    local fields = {
        "ApplyId", -- string
    }
    Network.RequestDynamic("AllianceAcceptApplyParams", fields, ...)
end

-- 请求-拒绝入盟申请
function Net.Alliances.RefuseApply(...)
    local fields = {
        "ApplyId", -- string
    }
    Network.RequestDynamic("AllianceRefuseApplyParams", fields, ...)
end

-- 请求-取消入盟申请
function Net.Alliances.CancelApply(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceCancelApplyParams", fields, ...)
end

-- 请求-获取所有入盟申请
function Net.Alliances.GetAllApplies(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceGetAllAppliesParams", fields, ...)
end

-- 请求-设置联盟职位
function Net.Alliances.ChangePos(...)
    local fields = {
        "MemberId", -- string
        "Pos", -- int32
    }
    Network.RequestDynamic("AllianceChangePosParams", fields, ...)
end

-- 请求-联盟名字是否合法
function Net.Alliances.NameValid(...)
    local fields = {
        "Name", -- string
    }
    Network.RequestDynamic("AllianceNameValidParams", fields, ...)
end

-- 请求-邀请玩家
function Net.Alliances.InvitePlayer(...)
    local fields = {
        "UserId", -- string
    }
    Network.RequestDynamic("AllianceInvitePlayerParams", fields, ...)
end

-- 请求-搜索玩家
function Net.Alliances.SearchPlayer(...)
    local fields = {
        "Name", -- string
    }
    Network.RequestDynamic("AllianceSearchPlayerParams", fields, ...)
end

-- 请求-接受邀请
function Net.Alliances.AcceptInvitation(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceAcceptInviteParams", fields, ...)
end

-- 请求-拒绝邀请
function Net.Alliances.RefuseInvitation(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceRefuseInviteParams", fields, ...)
end

-- 请求-修改旗帜
function Net.Alliances.ChangeFlag(...)
    local fields = {
        "Flag", -- int32
    }
    Network.RequestDynamic("AllianceChangeFlagParams", fields, ...)
end

-- 请求-修改语言
function Net.Alliances.ChangeLanguage(...)
    local fields = {
        "Language", -- int32
    }
    Network.RequestDynamic("AllianceChangeLanguageParams", fields, ...)
end

-- 请求-修改招募
function Net.Alliances.ChangeFreeJoin(...)
    local fields = {
        "FreeJoin", -- bool
        "FreeJoinLevel", -- int32
        "FreeJoinPower", -- int64
    }
    Network.RequestDynamic("AllianceChangeFreeJoinParams", fields, ...)
end

-- 请求-联盟名字是否合法
function Net.Alliances.ShortNameValid(...)
    local fields = {
        "ShortName", -- string
    }
    Network.RequestDynamic("AllianceShortNameValidParams", fields, ...)
end

-- 请求-公开招募玩家
function Net.Alliances.Wanted(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceMemberWantedParams", fields, ...)
end

-- 请求-修改社交信息
function Net.Alliances.ChangeSocial(...)
    local fields = {
        "SocialType", -- int32
        "SocialId", -- string
    }
    Network.RequestDynamic("AllianceChangeSocialParams", fields, ...)
end

-- 请求-修改职位简称
function Net.Alliances.ChangePosName(...)
    local fields = {
        "Pos", -- int32
        "Name", -- string
    }
    Network.RequestDynamic("AllianceChangePosNameParams", fields, ...)
end

-- 请求-修改上线提示
function Net.Alliances.ChangeOnlineNotice(...)
    local fields = {
        "Add", -- array-string
        "Del", -- array-string
    }
    Network.RequestDynamic("AllianceChangeOnlineNoticeParams", fields, ...)
end

-- 请求-联盟上线提示信息
function Net.Alliances.GetNoticeMembers(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceGetOnlineNoticeMembersParams", fields, ...)
end

-- 请求-获取当日招募次数
function Net.Alliances.GetWantedTimes(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceTodayWantedTimesParams", fields, ...)
end

-- 请求-转让盟主职位
function Net.Alliances.Abdicate(...)
    local fields = {
        "UserId", -- string
    }
    Network.RequestDynamic("AllianceAbdicateParams", fields, ...)
end

-- 请求-设置官员
function Net.Alliances.SetOfficer(...)
    local fields = {
        "UserId", -- string
        "Officer", -- int32
    }
    Network.RequestDynamic("AllianceSetOfficerParams", fields, ...)
end

-- 请求-申请官员
function Net.Alliances.ApplyOfficer(...)
    local fields = {
        "UserId", -- string
        "Officer", -- int32
    }
    Network.RequestDynamic("AllianceApplyOfficerParams", fields, ...)
end

-- 请求-获取申请官员列表
function Net.Alliances.GetApplyOfficers(...)
    Network.RequestDynamic("AllianceGetApplyOfficersParams", {}, ...)
end

-- 请求-修改徽章
function Net.Alliances.ChangeEmblem(...)
    local fields = {
        "Emblem", -- int32
    }
    Network.RequestDynamic("AllianceChangeEmblemParams", fields, ...)
end

-- 请求-同步联盟动态
function Net.Alliances.SyncNews(...)
    local fields = {
        "Offset", -- int32
        "Limit", -- int32
    }
    Network.RequestDynamic("AllianceSyncNewsParams", fields, ...)
end

-- 请求-设置联盟权限
function Net.Alliances.SetPermission(...)
    local fields = {
        "Permissions", -- array-Permission
    }
    Network.RequestDynamic("AllianceSetPermissionParams", fields, ...)
end

-- 请求-获取联盟简要信息
function Net.Alliances.PublicInfo(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AlliancePublicInfoParams", fields, ...)
end

-- 请求-发送联盟指令
function Net.Alliances.AllianceOrder(...)
    local fields = {
        "TargetId", -- string
        "OrderId", -- int32
    }
    Network.RequestDynamic("AllianceOrderParams", fields, ...)
end

-- 请求-联盟是否存在
function Net.Alliances.Exists(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceExistsParams", fields, ...)
end

-- 请求-推荐联盟
function Net.Alliances.Recommend(...)
    Network.RequestDynamic("AllianceRecommendParams", {}, ...)
end

-- 请求-联盟名字是否合法
function Net.Alliances.TitleValid(...)
    local fields = {
        "Name", -- string
    }
    Network.RequestDynamic("AllianceTitleValidParams", fields, ...)
end

-- 请求-修改联盟公告
function Net.Alliances.ChangeAnnouncement(...)
    local fields = {
        "Content", -- string
    }
    Network.RequestDynamic("ChangeAllianceAnnouncementParams", fields, ...)
end

-- 请求-盟友升级消息点赞
function Net.Alliances.ThumbUpMemberLevelUp(...)
    local fields = {
        "Target", -- string
        "MessageId", -- string
    }
    Network.RequestDynamic("ThumbUpMemberLevelUpParams", fields, ...)
end

-- 请求-退出联盟
function Net.Alliances.OnQuit(...)
    local fields = {
        "AllianceId", -- string
        "AllianceDeleted", -- bool
    }
    Network.RequestDynamic("AllianceOnQuitParams", fields, ...)
end

-- 请求-入盟申请被同意
function Net.Alliances.OnAcceptApply(...)
    local fields = {
        "ApplyId", -- string
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceOnAcceptApplyParams", fields, ...)
end

-- 请求-入盟申请被拒绝
function Net.Alliances.OnRefuseApply(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceOnRefuseApplyParams", fields, ...)
end

-- 请求-被设置联盟职位
function Net.Alliances.OnChangePos(...)
    local fields = {
        "AllianceId", -- string
        "Pos", -- int32
    }
    Network.RequestDynamic("AllianceOnChangePosParams", fields, ...)
end

-- 请求-是否在集结战争
function Net.Alliances.IsMemberRally(...)
    Network.RequestDynamic("AllianceIsMemberRallyParams", {}, ...)
end

-- 请求-联盟徽章过期
function Net.Alliances.EmblemExpire(...)
    local fields = {
        "Emblem", -- int32
    }
    Network.RequestDynamic("AllianceEmblemExpireParams", fields, ...)
end

-- 请求-获得徽章buff通知
function Net.Alliances.OnEmblemBuff(...)
    local fields = {
        "ConfId", -- int32
    }
    Network.RequestDynamic("AllianceOnEmblemBuffParams", fields, ...)
end

-- 请求-移除联盟官职
function Net.Alliances.TitleRemoved(...)
    local fields = {
        "TitleId", -- int32
    }
    Network.RequestDynamic("AllianceRpcTitleRemovedParams", fields, ...)
end

-- 请求-设置联盟官职
function Net.Alliances.TitleGiven(...)
    local fields = {
        "TitleId", -- int32
    }
    Network.RequestDynamic("AllianceRpcTitleGivenParams", fields, ...)
end

return Net.Alliances