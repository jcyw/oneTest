--[[
    Author: songzeming
    Function: 联盟详情信息
]]
local ItemUnionInfo = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionDynamicTag", ItemUnionInfo)

local UnionInfoModel = import("Model/Union/UnionInfoModel")

function ItemUnionInfo:ctor()
    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.UnionMain)
end

function ItemUnionInfo:Init()
    local info = UnionInfoModel.GetInfo()
    self._name.text = string.format("(%s)%s", info.ShortName, info.Name)
    self._owner.text = info.President
    self._member.text = string.format("%d/%d", info.Member, info.MemberLimit)
    self._force.text = Tool.FormatNumberThousands(info.Power)
    local language = ConfigMgr.GetItem("configAllianceLanguages", info.Language).local_text
    self._language.text = StringUtil.GetI18n(I18nType.Commmon, language)
    self._icon.icon = UnionModel.GetUnionBadgeIcon()
    self._medal:SetMedal(nil, Vector3(100, 100, 100))
    --self._flag.icon = UITool.GetIcon(ConfigMgr.GetItem("configFlags", info.Flag).icon)

    if info.SocialType == 0 then
        local values = {
            line = info.SocialId
        }
        self._line.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Alliance_Line", values)
        self._socialIcon.icon = UITool.GetIcon({"Union", "icon_alliance_58"})
    elseif info.SocialType == 1 then
        local values = {
            fb = info.SocialId
        }
        self._line.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Alliance_FB", values)
        self._socialIcon.icon = UITool.GetIcon({"Union", "icon_fb_58"})
    elseif info.SocialType == 2 then
        local values = {
            twitter = info.SocialId
        }
        self._line.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Alliance_Twitter", values)
        self._socialIcon.icon = UITool.GetIcon({"Union", "icon_twitter_58"})
    end
end

return ItemUnionInfo
