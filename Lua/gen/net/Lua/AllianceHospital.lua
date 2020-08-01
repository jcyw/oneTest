Net.AllianceHospital = {}

-- 请求-联盟医院信息
function Net.AllianceHospital.Infos(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceHospitalInfoParams", fields, ...)
end

-- 请求-联盟医院我的伤兵信息
function Net.AllianceHospital.MyInfo(...)
    local fields = {
        "AllianceId", -- string
    }
    Network.RequestDynamic("AllianceHospitalMyInfoParams", fields, ...)
end

-- 请求-治疗联盟医院的士兵
function Net.AllianceHospital.Cure(...)
    local fields = {
        "Armies", -- array-Army
        "Instant", -- bool
    }
    Network.RequestDynamic("AllianceHospitalCureParams", fields, ...)
end

return Net.AllianceHospital