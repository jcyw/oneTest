Net.AllianceHelp = {}

-- 请求-联盟帮助信息
function Net.AllianceHelp.Infos(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceHelpInfosParams", fields, ...)
end

-- 请求-联盟帮助单个
function Net.AllianceHelp.Single(...)
    local fields = {
        "AllianceId", -- string
        "AllianceHelpId", -- string
    }
    Network.RequestDynamic("AllianceHelpSingleParams", fields, ...)
end

-- 请求-联盟帮助全部
function Net.AllianceHelp.All(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceHelpAllParams", fields, ...)
end

-- 请求-请求盟友帮助
function Net.AllianceHelp.AskHelp(...)
    local fields = {
        "Category", -- int32
        "EventId", -- string
    }
    Network.RequestDynamic("AllianceHelpAskHelpParams", fields, ...)
end

-- 请求-联盟帮助被帮助
function Net.AllianceHelp.OnHelp(...)
    local fields = {
        "UserId", -- string
        "UserName", -- string
        "Category", -- int32
        "EventId", -- string
        "Help", -- AllianceHelp
        "Avatar", -- string
    }
    Network.RequestDynamic("AllianceHelpOnHelpParams", fields, ...)
end

return Net.AllianceHelp