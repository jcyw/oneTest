Net.UserInfo = {}

-- 请求-获取玩家信息
function Net.UserInfo.GetUserInfo(...)
    local fields = {
        "UserId", -- string
    }
    Network.RequestDynamic("GetUserInfoParams", fields, ...)
end

-- 请求-修改玩家昵称
function Net.UserInfo.ModifyUserName(...)
    local fields = {
        "Name", -- string
    }
    Network.RequestDynamic("ModifyUserNameParams", fields, ...)
end

-- 修改玩家聊天时是否显示vip信息
function Net.UserInfo.ModifyHideVipInfo(...)
    local fields = {
        "Status", -- bool
    }
    Network.RequestDynamic("ModifyHideVipInfoParams", fields, ...)
end

-- 请求-判断玩家昵称是否合法
function Net.UserInfo.IsUserNameValid(...)
    local fields = {
        "Name", -- string
    }
    Network.RequestDynamic("IsUserNameValidParams", fields, ...)
end

-- 请求-判断玩家宣言是否合法
function Net.UserInfo.IsUserDeclarationValid(...)
    local fields = {
        "Declaration", -- string
    }
    Network.RequestDynamic("IsUserDeclarationValidParams", fields, ...)
end

-- 请求-判断昵称是否敏感
function Net.UserInfo.IsNameValidSensitive(...)
    local fields = {
        "Name", -- string
    }
    Network.RequestDynamic("IsNameValidSensitiveParams", fields, ...)
end

-- 请求-修改玩家宣言
function Net.UserInfo.ModifyUserDeclaration(...)
    local fields = {
        "Declaration", -- string
    }
    Network.RequestDynamic("ModifyUserDeclarationParams", fields, ...)
end

-- 请求-修改玩家旗帜
function Net.UserInfo.ModifyUserFlag(...)
    local fields = {
        "Flag", -- int32
    }
    Network.RequestDynamic("ModifyUserFlagParams", fields, ...)
end

-- 请求-获取玩家当前语言
function Net.UserInfo.GetUserLanguage(...)
    Network.RequestDynamic("GetUserLanguageParams", {}, ...)
end

-- 请求-设置玩家语言
function Net.UserInfo.SetUserLanguage(...)
    local fields = {
        "Language", -- int32
    }
    Network.RequestDynamic("SetUserLanguageParams", fields, ...)
end

-- 请求-搜索玩家
function Net.UserInfo.Search(...)
    local fields = {
        "Pattern", -- string
        "Limit", -- int32
    }
    Network.RequestDynamic("UserInfoSearchParams", fields, ...)
end

-- 请求-上传修改玩家头像
function Net.UserInfo.UploadUserAvatar(...)
    local fields = {
        "Avatar", -- string
    }
    Network.RequestDynamic("UploadUserAvatarParams", fields, ...)
end

-- 请求-修改玩家头像以及半身像
function Net.UserInfo.ModifyUserAvatarAndBust(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("ModifyUserAvatarAndBustParams", fields, ...)
end

-- 请求-修改玩家头像至系统头像
function Net.UserInfo.ModifyUserAvatarToSystemAvatar(...)
    local fields = {
        "Id", -- int32
    }
    Network.RequestDynamic("ModifyUserAvatarToSystemAvatarParams", fields, ...)
end

-- 请求-获取玩家战斗力详细信息
function Net.UserInfo.GetUserDetailedPowerInfo(...)
    Network.RequestDynamic("GetUserDetailedPowerInfoParams", {}, ...)
end

-- 请求-获取玩家战斗统计详细信息
function Net.UserInfo.GetUserDetailedBattleInfo(...)
    local fields = {
        "UserId", -- string
    }
    Network.RequestDynamic("GetUserDetailedBattleInfoParams", fields, ...)
end

-- 请求-获得保护罩
function Net.UserInfo.GetProtect(...)
    local fields = {
        "ProtectDuration", -- int32
        "Source", -- int32
    }
    Network.RequestDynamic("UserGetProtectParams", fields, ...)
end

-- 请求-开始新游戏
function Net.UserInfo.StartNewGame(...)
    Network.RequestDynamic("UserStartNewGameParams", {}, ...)
end

-- 请求-切换角色
function Net.UserInfo.SwitchRole(...)
    local fields = {
        "RoleId", -- string
    }
    Network.RequestDynamic("UserSwitchRoleParams", fields, ...)
end

-- 请求-获取所有角色
function Net.UserInfo.GetRoles(...)
    Network.RequestDynamic("UserGetRolesParams", {}, ...)
end

-- 请求-获取玩家属性汇总的信息
function Net.UserInfo.GetAllUserDetailedInfo(...)
    Network.RequestDynamic("GetAllUserDetailedInfoParams", {}, ...)
end

-- 请求-清除玩家推荐联盟加入标记
function Net.UserInfo.CleanJoinUnionRecommend(...)
    Network.RequestDynamic("CleanJoinUnionRecommendParams", {}, ...)
end

-- 请求-获取是否可以上传自定义头像
function Net.UserInfo.CanUploadAvatar(...)
    Network.RequestDynamic("CanUploadAvatarParams", {}, ...)
end

-- 请求-设置推送消息屏蔽
function Net.UserInfo.SetNotifyBlock(...)
    local fields = {
        "Id", -- int32
        "Open", -- bool
    }
    Network.RequestDynamic("SetNotifyBlockParams", fields, ...)
end

-- 请求-玩家上传自定义头像冷却信息
function Net.UserInfo.ModifyAvatarCoolInfo(...)
    Network.RequestDynamic("ModifyAvatarCoolInfoParams", {}, ...)
end

-- 请求-玩家评价游戏
function Net.UserInfo.EvaluateGame(...)
    Network.RequestDynamic("EvaluateGameParams", {}, ...)
end

-- 请求-记录前往日志
function Net.UserInfo.RecordLog(...)
    local fields = {
        "Category", -- int32
        "Value", -- string
    }
    Network.RequestDynamic("RecordLogParams", fields, ...)
end

-- 请求-指定服务器是否有同名玩家
function Net.UserInfo.FindSameName(...)
    local fields = {
        "ServerId", -- string
    }
    Network.RequestDynamic("FindSameNameParams", fields, ...)
end

-- 请求-设置系统设置
function Net.UserInfo.SetSystemSettings(...)
    local fields = {
        "Id", -- int32
        "Status", -- int32
    }
    Network.RequestDynamic("SetSystemSettings", fields, ...)
end

-- 请求-绑定账号
function Net.UserInfo.AccountBind(...)
    Network.RequestDynamic("AccountBindParams", {}, ...)
end

-- 请求-检查绑定账号奖励
function Net.UserInfo.CheckAccountBindRewards(...)
    Network.RequestDynamic("CheckAccountBindRewardsParams", {}, ...)
end

-- 请求-修改名字
function Net.UserInfo.ChangePlayerName(...)
    local fields = {
        "PlayerId", -- string
        "NewName", -- string
    }
    Network.RequestDynamic("BackstageChangePlayerNameParams", fields, ...)
end

-- 请求-玩家信息查询
function Net.UserInfo.UserCheckInfo(...)
    Network.RequestDynamic("UserCheckInfoParams", {}, ...)
end

-- 请求-玩家体力变更
function Net.UserInfo.UserRpcChangeEnergy(...)
    local fields = {
        "Energy", -- int32
    }
    Network.RequestDynamic("UserRpcChangeEnergyParams", fields, ...)
end

-- 请求-回收基地
function Net.UserInfo.RecoverBase(...)
    Network.RequestDynamic("RecoverBaseParams", {}, ...)
end

-- 请求-玩家获得全服保护罩刷新
function Net.UserInfo.PushPlayerServerShield(...)
    local fields = {
        "ProtectedAt", -- int64
    }
    Network.RequestDynamic("PushPlayerServerShieldParams", fields, ...)
end

-- 请求-重置玩家击杀数
function Net.UserInfo.ResetPlayerBeat(...)
    local fields = {
        "PlayerId", -- string
    }
    Network.RequestDynamic("ResetPlayerBeatNumParams", fields, ...)
end

-- 请求-重置玩家联盟信息
function Net.UserInfo.CleanPlayerAllianceInfo(...)
    Network.RequestDynamic("CleanPlayerAllianceInfoParams", {}, ...)
end

return Net.UserInfo