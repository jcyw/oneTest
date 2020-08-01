--author: 	Amu
--time:		2019-08-23 10:56:21

function split(str, pat)
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t, cap)
        end
        last_end = e + 1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

if TextUtil then
    return
end

TextUtil = {}

--空格替代str 中 max个pat后的pat
function TextUtil:ReplaceMoreBySpace(str, pat, max)
    local strList = split(str, pat)
    local _s = ""
    for k, v in ipairs(strList) do
        if k <= max + 1 then
            _s = _s .. v .. pat
        else
            _s = _s .. v .. " "
        end
    end
    return _s
end

--根据语言对不同折扣进行处理
function TextUtil:GetDisCountText(discount)
    local _language = ConfigMgr:GetLocale()
    if _language == "cn" then
        return StringUtil.GetI18n(I18nType.Commmon, "Vip_Store_Discount", {store_discount = discount})
    else
        local discountText =string.format("%d",discount * 10)  .. "%"
        return discountText
    end
end

function TextUtil.FormatPlayName(info, type)
    local str = ""
    if info.VipLevel and info.VipActive and info.VipLevel > 0 and not info.HideVipInfo then
        str = str .. string.format("[color=#f2c952]VIP%d[/color] ", info.VipLevel)
    end
    if info.Alliance ~= "" and not (type == MSG_TYPE.Chat and info.RoomId ~= "World") then
        str = str .. string.format("\\[%s]",info.Alliance)
    elseif type == MSG_TYPE.Chat then
        local color = Global.AllianceChatColour1
        if info.AlliancePos == 5 then
            color = Global.AllianceChatColour3
        elseif info.AlliancePos > 1 then
            color = Global.AllianceChatColour2
        end
        if info.AllianceTitle == "" and info.AllianceId ~= "" then
            local title = ConfigMgr.GetI18n("configI18nCommons", "Ui_R" .. info.AlliancePos .. "_Name")
            str = str .. string.format("[color=%s][%s][/color] ", color, title)
        elseif info.AllianceTitle ~= "" then
            str = str .. string.format("[color=%s][%s][/color] ", color, info.AllianceTitle)
        end
    end
    return str .. info.Sender
end

function TextUtil.GetFormatPlayName(allianceName, name)
    local str = ""
    if allianceName ~= "" then
        str = str .. string.format("[%s] ", allianceName)
    end
    return str .. name
end

function TextUtil.utf8len(input)
    local len = string.len(input)
    local left = len
    local cnt = 0
    local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function TextUtil.TextWidthAutoSize(text,width,baseAuto,changAuto)
    if text.width >= width then
        text.autoSize = changAuto
        text.width = width
    else
        text.autoSize = baseAuto
    end
end
function TextUtil.TextHightAutoSize(text,height,baseAuto,changAuto)
    if text.height >= height then
        text.autoSize = changAuto
        text.height = height
    else
        text.autoSize = baseAuto
    end
end

function TextUtil.FormatPosHref(str)  -- 坐标转超链接
    str = string.gsub(str, "：", ":")
    local _strList = ""
    local strList = split(str, " ")
    local temp = ""
    for _, _str in ipairs(strList)do
        _strList = split(_str, ":")

        if #_strList == 2 and tonumber(_strList[1]) and tonumber(_strList[2]) 
            and tonumber(_strList[1]) <= 1200 - _G.mapOffset and tonumber(_strList[2]) <= 1200 - _G.mapOffset and 
            tonumber(_strList[1]) >= 0 and tonumber(_strList[2]) >= 0 then
            temp = temp .." ".. string.format("<a href='%s'>%s</a>", _str, 
                StringUtil.GetI18n(I18nType.Commmon, "UI_MARK_JUMP", {num1 = tonumber(_strList[1]), num2 = tonumber(_strList[2])})) .." "
        else
            temp = temp .. _str
        end
    end
    return temp
end

return TextUtil
