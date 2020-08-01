--[[
    Author: songzeming
    Function: 公用组件 提示
]]
if TipUtil then
    return
end
TipUtil = {}

local isFirst = true --是否第一次打开弹窗
local ShowTip = function(showType, content, icon, title, posy, delay, avatar, userId)
    local data = {
        showType = showType,
        content = content,
        icon = icon,
        title = title,
        posy = posy,
        delay = delay,
        avatar = avatar,
        userId = userId
    }
    if isFirst then
        if GlobalVars.IsTriggerStatus or GlobalVars.IsNoviceGuideStatus then
            return
        end
        isFirst = false
        UIMgr:Open('ToolTip', data)
    else
        Event.Broadcast(EventDefines.UIToolTip, data)
    end
end

function TipUtil.GetTipConfig(id)
    return ConfigMgr.GetItem("configBattleTipss", id)
end

-- 根据tip表id弹出提示
--[[
    confId 配置id
    contentData 正文动态文本替换内容
    icon 显示图标
    titleData 标题动态文本替换内容
    extraContent 额外的正文内容
]]
function TipUtil.TipById(confId, contentData, icon, titleData, extraContent)
    local config = ConfigMgr.GetItem("configBattleTipss", confId)
    if config then
        local y = TipUtil.GetPos(config)

        local content = ""
        if contentData and not (type(contentData) == "table") then
            content = StringUtil.GetI18n(I18nType.Commmon, config.key)..contentData
        else
            content = StringUtil.GetI18n(I18nType.Commmon, config.key, contentData)
        end

        if extraContent then
            content = content..extraContent
        end

        if config.title and config.show_tittle then
            local title = ""
            if titleData and not next(titleData) then
                title = StringUtil.GetI18n(I18nType.Commmon, config.title)..titleData
            else
                title = StringUtil.GetI18n(I18nType.Commmon, config.title, titleData)
            end

            ShowTip(
                "Title",
                content,
                UITool.GetIcon(icon and icon or config.icon),
                title,
                y
            )
        elseif config.icon or icon then
            ShowTip(
                "Icon",
                content,
                UITool.GetIcon(icon and icon or config.icon),
                nil,
                y
            )
        else
            ShowTip(
                "Label",
                content,
                nil,
                nil,
                y
            )
        end
    end
end

-- 带玩家头像的弹窗提示
--[[
    confId 配置id
    avatar 玩家头像数据
    userId 玩家uuid
    contentData 正文动态文本替换内容
    titleData 标题动态文本替换内容
]]
function TipUtil.TipWithAvatar(confId, avatar, userId, contentData, titleData)
    local config = ConfigMgr.GetItem("configBattleTipss", confId)
    if config then
        local y = TipUtil.GetPos(config)
            
        if config.title then
            ShowTip(
                "Title", 
                StringUtil.GetI18n(I18nType.Commmon, config.key, contentData), 
                nil,
                StringUtil.GetI18n(I18nType.Commmon, config.title, titleData), 
                y,
                nil,
                avatar,
                userId
            )
        else
            ShowTip(
                "Icon", 
                StringUtil.GetI18n(I18nType.Commmon, config.key, contentData), 
                nil,
                nil, 
                y,
                nil,
                avatar,
                userId
            )
        end
    end
end
-- 直接传入显示内容的弹窗 #带惊叹号
function TipUtil.TipByContentWithWaring(content)
    ShowTip(
        "Warning",
        content
    )
end

-- 直接传入显示内容的弹窗
function TipUtil.TipByContent(title, content, y, icon, userId, avatar)
    if title then
        -- 有title的情况一定有icon
        if avatar then
            ShowTip(
                "Title", 
                content, 
                nil,
                title, 
                y,
                nil,
                avatar,
                userId
            )
        else
            ShowTip(
                "Title",
                content,
                UITool.GetIcon(icon),
                title,
                y
            )
        end
    else
        if avatar then
            ShowTip(
                "Icon", 
                content, 
                nil,
                nil, 
                y,
                nil,
                avatar,
                userId
            )
        elseif icon then
            ShowTip(
                "Icon",
                content,
                UITool.GetIcon(icon),
                nil,
                y
            )
        else
            ShowTip(
                "Label",
                content,
                nil,
                nil,
                y
            )
        end
    end
end

function TipUtil.GetPos(config)
    local offset = 0
    if config.position == 1 then
        offset = GRoot.inst.height / 4
    elseif config.position == 2 then
        offset = 0
    else
        offset = -((GRoot.inst.height / 2) - 384)
    end
    
    return GRoot.inst.height / 2 - offset
end

return TipUtil
