Net.AllianceVote = {}

-- 请求联盟投票列表
function Net.AllianceVote.RequestVoteList(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceRequestVoteListParams", fields, ...)
end

-- 发起联盟投票
function Net.AllianceVote.InitiateVote(...)
    local fields = {
        "Vote", -- AllianceVoteItem
        "Member", -- array-AllianceVoteMember
    }
    Network.RequestDynamic("AllianceInitiateVoteParams", fields, ...)
end

-- 请求投票
function Net.AllianceVote.Vote(...)
    local fields = {
        "Vote", -- AllianceVoteMember
    }
    Network.RequestDynamic("AllianceVoteParams", fields, ...)
end

-- 请求删除投票记录
function Net.AllianceVote.DeleteVote(...)
    local fields = {
        "DeleteList", -- array-string
    }
    Network.RequestDynamic("AllianceDeleteVoteParams", fields, ...)
end

-- 请求联盟投票
function Net.AllianceVote.RequestVoteById(...)
    local fields = {
        "VoteId", -- string
    }
    Network.RequestDynamic("AllianceRequestVoteByIdParams", fields, ...)
end

-- 请求-联盟投票结束
function Net.AllianceVote.Expired(...)
    local fields = {
        "Uuid", -- string
    }
    Network.RequestDynamic("AllianceVoteExpired", fields, ...)
end

return Net.AllianceVote