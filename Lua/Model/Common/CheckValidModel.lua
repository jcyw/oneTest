--[[
    Author: songzeming
    Function: 检测是否合法
]]
local CheckValidModel = {}

--检测类型
CheckValidModel.From = {
    PlayerRename = 1, --玩家改名
    PlayerRedesc = 2, --玩家修改宣言
    BeautyRename = 3, --美女修改名称
    CDKey= 4 --兑换码
}
--检测不合法的类型
CheckValidModel.Invalid = {
    Normal = 1, --[eg:必须由字符、数字或空格组成]
    Short = 2, --字符长过短
    Long = 3, --字符串过长
    Sensitive = 4, --包含敏感字符
    Exist = 5 --名称已存在
}
--待检测文本
local WaitCheck = {}
local IsWaiting = false

--本地检测名称是否合法 字符串长度
local function CheckValidLenght(textNode, min, max, cb)
    --去掉空格回车
    local text = string.gsub(textNode.text, "[\t\n\r[%]]+", "")
    textNode.text = text
    local gbLen = Util.GetGBLength(text)
    if gbLen < min then
        cb(text, false, CheckValidModel.Invalid.Short)
        return text, false
    end
    if gbLen > max then
        cb(text, false, CheckValidModel.Invalid.Long)
        return text, false
    end
    return text, true
end

--先服务器发送请求 检测名称是否合法
local function CheckValidNet(type, text, cb)
    if type == CheckValidModel.From.PlayerRename then
        --玩家改名
        Net.UserInfo.IsUserNameValid(text, cb)
    elseif type == CheckValidModel.From.PlayerRedesc then
        --玩家修改宣言
        Net.UserInfo.IsUserDeclarationValid(text, cb)
    elseif type == CheckValidModel.From.BeautyRename then
        --美女修改名称
        Net.UserInfo.IsNameValidSensitive(text, cb)
    end
end

--[[
    检查名称是否合法
    text 待检测的文本 (string)
    min 文本合法最小长度 (int)
    max 文本合法最大长度 (int)
    sensitive 是否检测敏感字符 (bool)
    cb 回调:
        1.返回正确输入字符串(去掉空格回车)
        2.返回名称是否合法
        3.返回不合法类型
]]
function CheckValidModel.CheckName(from, textNode, min, max, sensitive, cb)
    -- Log.Info("检查名称是否合法")
    local text, valid = CheckValidLenght(textNode, min, max, cb)
    if not valid then
        return
    end
    if sensitive then
        --敏感字符检测
        if IsWaiting then
            --短时间内只能请求一次
            -- Log.Info("短时间内只能请求一次")
            WaitCheck = {
                waitFrom = from,
                waitTextNode = textNode,
                waitMin = min,
                waitMax = max,
                waitSensitive = sensitive,
                waitCb = cb
            }
            return
        end
        IsWaiting = true
        Scheduler.ScheduleOnceFast(function()
            IsWaiting = false
            if next(WaitCheck) then
                CheckValidModel.CheckName(WaitCheck.waitFrom, WaitCheck.waitTextNode, WaitCheck.waitMin, WaitCheck.waitMax, WaitCheck.waitSensitive, WaitCheck.waitCb)
                WaitCheck = {}
            end
        end, 0.5)
        -- Log.Info("向服务器请求检测是否合法")
        CheckValidNet(from, text, function(rsp)
            -- Log.Debug("检测名称是否合法 rsp: {0}", table.inspect(rsp))
            --检测敏感字符后 再次检测长度 (防止消息延迟后又输入错误的字符串导致匹配正确)
            local textNet, validNet = CheckValidLenght(textNode, min, max, cb)
            if not validNet then
                return
            end
            --服务器检测是否合法
            if rsp.IsValid then
                cb(textNet, true)
            else
                if rsp.Reason == "error_invalid_name_character" then
                    cb(textNet, false, CheckValidModel.Invalid.Sensitive)
                elseif rsp.Reason == "error_invalid_name_exists" then
                    cb(textNet, false, CheckValidModel.Invalid.Exist)
                else
                    cb(textNet, false, CheckValidModel.Invalid.Normal)
                end
            end
        end)
    else
        cb(text, true)
    end
end
--本地检测兑换码 是否是非字母非数字字符 长度是否符合
function CheckValidModel.CheckValidCDKey(text, min, max)
    local bl = true
    if string.find(text,"%W") then
        bl = false
    end
    local gbLen = Util.GetGBLength(text)
    if gbLen < min then
        bl = false
    end
    if gbLen > max then
        bl = false
    end
    return bl
end

_G.CheckValidModel = CheckValidModel
return CheckValidModel
