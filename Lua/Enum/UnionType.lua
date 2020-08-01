if UnionType then
    return UnionType
end

ALLIANCEPOS = {}
ALLIANCEPOS.R1 = ConfigMgr.GetVar("AlliancePosR1")  --一阶成员
ALLIANCEPOS.R2 = ConfigMgr.GetVar("AlliancePosR2")  --二阶成员
ALLIANCEPOS.R3 = ConfigMgr.GetVar("AlliancePosR3")  --三阶成员
ALLIANCEPOS.R4 = ConfigMgr.GetVar("AlliancePosR4")  --四阶成员
ALLIANCEPOS.R5 = ConfigMgr.GetVar("AlliancePosR5")  --联盟盟主


UnionType = {
    --查看所有联盟默认请求数量
    VIEW_UNION_COUNT = 10,
    --联盟官员数量
    MEMBER_POST_COUNT = 4,
    --联盟成员等级数量
    MEMBER_SORT_COUNT = 6,
    --联盟社交信息
    SOCIAL_INFO = {
        "BUTTON_Social_Line",
        "BUTTON_Social_Facebook",
        "BUTTON_Social_Twitter"
    },
}

return UnionType
