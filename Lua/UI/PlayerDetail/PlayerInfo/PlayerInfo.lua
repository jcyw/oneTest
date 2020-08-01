--[[
    Author: songzeming
    Function: 玩家信息
]]
local PlayerInfo = UIMgr:NewUI("PlayerInfo/PlayerInfo")

local CheckValidModel = import("Model/Common/CheckValidModel")
import("UI/PlayerDetail/PlayerInfo/ItemPlayerInfoAttribute")
import("UI/PlayerDetail/PlayerInfo/ItemPlayerAttributeList")

function PlayerInfo:OnInit()
    local view = self.Controller.contentPane
    self._ctr = view:GetController("c1")

    self:AddListener(self._btnEditName.onClick,
        function()
            TurnModel.PlayerRename()
        end
    )
    self:AddListener(self._btnEditDesc.onClick,
        function()
            UIMgr:Open("Rename", CheckValidModel.From.PlayerRedesc)
        end
    )
    self:AddListener(self._flag.onClick,
        function()
            UIMgr:Open("PlayerFlag", FLAG_TYPE.Player)
        end
    )
    self:AddListener(self._btnHeadReplace.onClick,
        function()
            UIMgr:Open("PlayerCharacter/PlayerCharacter")
        end
    )
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("PlayerInfo/PlayerInfo")
        end
    )
    self:AddEvent(
        EventDefines.UIPlayerInfoExchange,
        function()
            self:ShowPlayerInfo(Model.Player)
        end
    )

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.PlayerInfo)
end

function PlayerInfo:DoOpenAnim(...)
    self:OnOpen(...)
    AnimationLayer.PanelAnim(AnimationType.PanelMovePreDown, self)
end

function PlayerInfo:OnOpen(cb)
    self:ShowPlayerInfo(Model.Player)
    self.cb = cb

    Net.UserInfo.GetAllUserDetailedInfo(
        function(rsp)
            self:UpdateAttributeInfo(rsp.Infos)
        end
    )
end

function PlayerInfo:OnClose()
    if self.cb then
        self.cb()
    end
end

--显示玩家信息
function PlayerInfo:ShowPlayerInfo(info)
    -- CommonModel.SetUserAvatar(self._icon, info.Avatar, self.playerId)
    self._icon:SetAvatar(info, nil, self.playerId)
    if info.AllianceName and info.AllianceName ~= "" then
        self._name.text = "(" .. info.AllianceName .. ")" .. info.Name
    else
        self._name.text = info.Name
    end
    TextUtil.TextWidthAutoSize(self._name,424,1,3)
    self._flag.icon = UITool.GetIcon(ConfigMgr.GetItem("configFlags", info.Flag).icon)
    if info.Declaration == "" then
        self._textSpeak.text = StringUtil.GetI18n(I18nType.Commmon, "Button_CommanderTips_Default")
    else
        self._textSpeak.text = info.Declaration
    end
    self._textSpeak.autoSize = 1
    TextUtil.TextWidthAutoSize(self._textSpeak,490,1,2)
    if self._textSpeak.height >= 83 then
        TextUtil.TextHightAutoSize(self._textSpeak,83,2,3)
    end
    self._city.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Commander_Server") .. ": " .. info.Server
    --self._city.text = "暂无数据" --TODO
    self._level.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Level") .. ": " .. UITool.GetTextColor(GlobalColor.White, info.HeroLevel)
    self._power.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Power") .. ": " .. UITool.GetTextColor(GlobalColor.White, Tool.FormatNumberThousands(info.Power))
    self._kill.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Destroy_Number") .. ": " .. UITool.GetTextColor(GlobalColor.White, info.Kills)
end

--刷新属性信息
function PlayerInfo:UpdateAttributeInfo(data)
    self.parentArr = {}
    for _, v in pairs(data) do
        local conf = ConfigMgr.GetItem("ConfigPlayerSubTypes", v.Category)
        conf.value = v.Value
        local t = conf.ascription_type
        if not self.parentArr[t] then
            self.parentArr[t] = {}
        end
        table.insert(self.parentArr[t], conf)
    end
    --初始化列表
    local conf = ConfigMgr.GetList("ConfigPlayerAttributeAlls")
    self._list.numItems = #conf
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local title = StringUtil.GetI18n(I18nType.Commmon, conf[i].name)
        local cb_func = function()
            --点击刷新
            for j = 1, self._list.numChildren do
                self._list:GetChildAt(j - 1):SetChoose(false)
            end
            item:SetChoose(true)
            self:ShowAttributeInfo(i)
        end
        item:Init(title, cb_func)
        if i == 1 then
            --设置默认值
            item:SetChoose(true)
            self:ShowAttributeInfo(i)
        end
    end
    self._list:EnsureBoundsCorrect()
    self._list.scrollPane.touchEffect = self._list.scrollPane.contentHeight > self._list.height
end

--显示属性信息
function PlayerInfo:ShowAttributeInfo(index)
    self._chooseIndex = index
    local keyIndex = index * 1000
    self._listAtt.scrollPane:ScrollTop()
    local conf = ConfigMgr.GetItem("ConfigPlayerAttributeAlls", keyIndex)
    self._descTitle.text = StringUtil.GetI18n(I18nType.Commmon, conf.name)
    local big = conf.Inclusion_types

    self._listAtt:RemoveChildrenToPool()
    for _, v in pairs(big) do
        local item = self._listAtt:AddItemFromPool()
        local parentConf = ConfigMgr.GetItem("ConfigPlayerParentTypes", v)
        local name = StringUtil.GetI18n(I18nType.Commmon, parentConf.name)
        item:InitMine(keyIndex, name, self.parentArr[parentConf.id])
    end
    if self._listAtt.numChildren == 0 then
        self._ctr.selectedIndex = 1
        if index == 2 then
            --指挥官技能
            self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_PlayerInfo_Skill_Null")
        elseif index == 3 then
            --科技研发
            self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_PlayerInfo_Tech_Null")
        elseif index == 4 then
            --联盟科技
            self._textState.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_PlayerInfo_Alliance_Null")
        end
    else
        self._ctr.selectedIndex = 0
    end

    self._listAtt:EnsureBoundsCorrect()
    self._listAtt.scrollPane.touchEffect = self._listAtt.scrollPane.contentHeight > self._listAtt.height
end

return PlayerInfo
