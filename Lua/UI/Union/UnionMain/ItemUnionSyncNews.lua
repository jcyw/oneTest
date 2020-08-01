--[[
    Author: songzeming
    Function: 联盟动态消息
]]
local ItemUnionSyncNews = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionSyncNews", ItemUnionSyncNews)

local WorldMap = import("UI/WorldMap/WorldMap")

function ItemUnionSyncNews:ctor()
    self:AddListener(self:GetChild("touch").onClick,
        function()
            self:OnBtnClick()
        end
    )
    self:AddListener(self:GetChild("arrow").onClick,
        function()
            self:OnBtnClick()
        end
    )
end

function ItemUnionSyncNews:Init(data)
    self.data = data
    self:ShowDesc()
end

function ItemUnionSyncNews:ShowDesc()
    local c = self.data.Category
    local ct = JSON.decode(self.data.Content)
    local desc = ""
    local textColor = Color.white
    if c == GlobalAlliance.ANTAddMember then
        --成员加入
        local values = {
            player_name = ct.PlayerName
        }
        desc = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceDynamic_Join", values)
    elseif c == GlobalAlliance.ANTDelMember then
        --成员离开
        local values = {
            player_name = ct.PlayerName
        }
        desc = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceDynamic_Exit", values)
    elseif c == GlobalAlliance.ANTTech then
        --联盟科技研发
        local confId = tostring(ct.ConfId)
        local techId = string.sub(confId, 1, #confId - 2) .. "00"
        local conf = ConfigMgr.GetItem("configAllanceTechDisplays", tonumber(techId))
        local values = {
            player_name = ct.PlayerName,
            tech_name = StringUtil.GetI18n(I18nType.Commmon, conf.name_id)
        }
        textColor = Color.green
        desc = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceDynamic_Tech", values)
    elseif c == GlobalAlliance.ANTMine then
        --成员野矿被攻破
        local confId = tostring(ct.MineConfId)
        local title = "MAP_RESOURCETYPE_" .. string.sub(confId, 1, 3)
        local lv = math.floor(string.sub(confId, #confId - 2, #confId))
        local values = {
            defplayer_name = ct.Defender,
            resbuild_name = StringUtil.GetI18n(I18nType.Commmon, title, {level = lv}),
            x = ct.X,
            y = ct.Y,
            attplayer_name = ct.Attacker
        }
        textColor = Color.red
        desc = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceDynamic_RESDefense", values)
    elseif c == GlobalAlliance.ANTUnderAttack then
        --成员城池被攻破
        local values = {
            defplayer_name = ct.Defender,
            x = ct.X,
            y = ct.Y,
            attplayer_name = ct.Attacker
        }
        textColor = Color.red
        desc = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceDynamic_HQDefense", values)
    elseif c == GlobalAlliance.ANTReplacePresident then
        --转让盟主
        local values = {
            player_name1 = ct.player_name1,
            player_name2 = ct.player_name2
        }
        desc = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceDynamic_Succession", values)
    elseif c == GlobalAlliance.ANTAbdicationPresident then
        --取代盟主
        local values = {
            player_name1 = ct.player_name1,
            play_name2 = ct.player_name2
        }
        desc = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceDynamic_Abdication", values)
    end
    self._desc.text = desc
    self._desc.color = textColor
end

function ItemUnionSyncNews:OnBtnClick()
    local c = self.data.Category
    local ct = JSON.decode(self.data.Content)
    if c == GlobalAlliance.ANTAddMember then
        TurnModel.UnionMember()
    elseif c == GlobalAlliance.ANTTech then
        TurnModel.UnionTeck()
    elseif c == GlobalAlliance.ANTMine then
        TurnModel.WorldPos(ct.X, ct.Y)
    elseif c == GlobalAlliance.ANTUnderAttack then
        TurnModel.WorldPos(ct.X, ct.Y)
    end
end

return ItemUnionSyncNews
