Net.AllianceTech = {}

-- 请求-联盟科技列表
function Net.AllianceTech.TechList(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceTechsParams", fields, ...)
end

-- 请求-联盟科技详情
function Net.AllianceTech.GetTech(...)
    local fields = {
        "AllianceId", -- string
        "TechId", -- string
    }
    Network.RequestDynamic("AllianceTechInfoParams", fields, ...)
end

-- 请求-联盟科技捐献
function Net.AllianceTech.Contribute(...)
    local fields = {
        "AllianceId", -- string
        "TechId", -- string
        "Cost", -- string
    }
    Network.RequestDynamic("AllianceContributeParams", fields, ...)
end

-- 请求-联盟科技研发
function Net.AllianceTech.Research(...)
    local fields = {
        "AllianceId", -- string
        "TechId", -- string
    }
    Network.RequestDynamic("AllianceTechResearchParam", fields, ...)
end

-- 请求-联盟科技研发完成
function Net.AllianceTech.ResearchFinish(...)
    local fields = {
        "AllianceId", -- string
        "TechId", -- string
    }
    Network.RequestDynamic("AllianceTechResearchFinishParam", fields, ...)
end

-- 请求-联盟科技推荐
function Net.AllianceTech.Recommend(...)
    local fields = {
        "AllianceId", -- string
        "TechId", -- string
    }
    Network.RequestDynamic("AllianceTechRecommendParam", fields, ...)
end

-- 请求-联盟科技取消推荐
function Net.AllianceTech.Unrecommend(...)
    local fields = {
        "AllianceId", -- string
        "TechId", -- string
    }
    Network.RequestDynamic("AllianceTechUnrecommendParam", fields, ...)
end

-- 请求-联盟捐献排行榜
function Net.AllianceTech.ContriRank(...)
    local fields = {
        "AllianceId", -- string
        "Category", -- int32
        "Offset", -- int32
        "Limit", -- int32
    }
    Network.RequestDynamic("AllianceTechContriRankParam", fields, ...)
end

-- 通知-联盟科技一键捐献
function Net.AllianceTech.MultiContribute(...)
    local fields = {
        "TechId", -- string
        "GemContri", -- bool
    }
    Network.RequestDynamic("AllianceTechMutilContributeParams", fields, ...)
end

-- 通知-金币冷却捐献时间
function Net.AllianceTech.PurchaseContriCooldown(...)
    Network.RequestDynamic("AllianceTechBuyContriCoolTimeParams", {}, ...)
end

-- 请求-联盟科技升级通知
function Net.AllianceTech.OnUpgrade(...)
    local fields = {
        "ConfId", -- int32
    }
    Network.RequestDynamic("AllianceTechOnUpgradeParams", fields, ...)
end

-- 请求-联盟科技排行结算
function Net.AllianceTech.RankSum(...)
    Network.RequestDynamic("AllianceContributionRankSumParams", {}, ...)
end

return Net.AllianceTech