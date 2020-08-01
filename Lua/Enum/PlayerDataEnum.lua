--[[
    author:{zhanzhang}
    time:2019-06-10 16:56:35
    function:{存入本地数据key}
]]
if PlayerDataEnum then
    return PlayerDataEnum
end

PlayerDataEnum = {
    --地图搜索功能key
    MapSearchData = "MapSearchData",
    --今日不再提示 [弹窗/队列总览红点]
    TIPDATA = "TIPDATA",
    --队列总览提示[设置]
    QUEUEOVERVIEW = "QUEUEOVERVIEW",
    --联盟名称免费修改
    UNIONFREENAME = "UNIONFREENAME",
    --联盟简称免费修改
    UNIONFREESHORTNAME = "UNIONFREESHORTNAME",
    --玩家形象免费修改
    PLAYER_FREE_BUST = "PLAYER_FREE_BUST",
    --训练界面兵种选中记录
    TRAIN_RECORD = "TRAIN_RECORD",
    TRAIN_UNLOCK = "TRAIN_UNLOCK",
    --建筑建造记录
    BUILD_CREATE = "BUILD_CREATE",
    --靶场 是否指引玩家投镖
    RANGE_GUIDE_SHOOTING = "RANGE_GUIDE_SHOOTING",
    --靶场 是否洗过牌
    RANGE_SHUFFLE = "RANGE_SHUFFLE",
    UnionMsgId = "UnionMsgId",
    UnionInviteMsg = "UnionInviteMsg",
    ChatUsedEmojies = "ChatUsedEmojies",
    MailsUpdateData = "MailsUpdateData",
    SpecialShowTime = "SpecialShowTime",
    --地图缩略图选择项
    MapThumbnailSelect = "MapThumbnailSelect",
    LoginTime = "loginTime",
    LoginLine = "LoginLine",
    ActivityView = "ActivityView",
    AddedUnion = "AddedUnion",
    --已读联盟集结进攻信息
    ReadUnionAttackIds = "ReadUnionAttackIds",
    ---------------------------------------------------指示点提示
    PLAYER_RENAMED = "PLAYER_RENAMED", --指挥官是否改过名
    PLAYER_RENAME = "PLAYER_RENAME", --指挥官改名
    PLAYER_RECHARACTERED = "PLAYER_RECHARACTERED", --指挥官是否更改过形象
    PLAYER_RECHARACTER = "PLAYER_RECHARACTER", --指挥官更改形象
    PLAYER_SET = "PLAYER_SET", --玩家设置
    SIDEBAR = "SIDEBAR", --侧边栏
    ---------------------------------------------------GM相关
    --是否开启指挥中心升级弹窗
    CENTER_UPGRADE_OPEN = "CENTER_UPGRADE_OPEN",
    --地图收藏夹新标记
    MapFavorite_New = "MapFavorite_New",
    --指引免费引导
    FreeGuideData = "FreeGuideData",
    --打点记录
    BREAKPOINT = "BREAKPOINT",
    ---------------------------------------------------气泡提示
    DAY_GROWTHFUND = "DAY_GROWTHFUND", --今日是否显示成长基金气泡
    DAY_MONTHCARD = "DAY_MONTHCARD", --今日是否显示月卡气泡
    ---------------------------------------------------发送账号绑定奖励
    BindReward="BindReward"
}

return PlayerDataEnum
