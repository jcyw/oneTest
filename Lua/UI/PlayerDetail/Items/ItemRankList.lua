--[[
    Author: songzeming
    Function: 排行榜界面item
]]
local ItemRankList = fgui.extension_class(GComponent)
fgui.register_extension("ui://PlayerDetail/itemRankList", ItemRankList)

ItemRankList.tempList = {}

local CommonModel = import("Model/CommonModel")
local UnionModel = import("Model/UnionModel")

function ItemRankList:ctor()
    self._rankControl = self:GetController("rankControl")
    self._highLight = self:GetController("highlight")
    self._phototype = self:GetController("phototype")
    self:InitEvent()
end

function ItemRankList:InitEvent()
end

function ItemRankList:SetData(type, info)
    if not info then
        return
    end
    self.info = info
    self._rankControl.selectedIndex = (info.Rank - 1) > 3 and 3 or (info.Rank - 1)
    self._level.text = info.Rank
    self._power.text = Tool.FormatNumberThousands(info.Value)
    if type == Global.RankOfAllianceType then
        self._phototype.selectedIndex = 0
        local prefix = info.AllianceShortName == "" and "" or "(" .. info.AllianceShortName .. ")"
        self._name.text = prefix .. info.AllianceName
        self._union.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Rank_Alliance") .. info.UserName
        self._icon.url = UnionModel.GetUnionBadgeIcon(info.AllianceAvatar)

        if info.AllianceId == Model.GetMap(ModelType.UserAllianceInfo).AllianceId then
            self._highLight.selectedIndex = 1
        else
            self._highLight.selectedIndex = 0
        end
    else
        self._phototype.selectedIndex = 1
        local prefix = info.AllianceShortName == "" and "" or "(" .. info.AllianceShortName .. ")"
        self._name.text = info.UserName
        self._union.text = info.AllianceName ~= "" and prefix .. info.AllianceName or ""
        --CommonModel.SetUserAvatar(self._icon, info.UserAvatar, info.UserId)
        if  not info.Avatar then
            info.Avatar = info.UserAvatar
        end
        self._head:SetAvatar(info, nil, info.UserId)

        if info.UserName == Model.Player.Name then
            self._highLight.selectedIndex = 1
        else
            self._highLight.selectedIndex = 0
        end
    end
    
end

function ItemRankList:GetData()
    return self.info
end

return ItemRankList
