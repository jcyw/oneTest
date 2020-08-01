--[[
    Author: songzeming
    Function: 玩家详情
]]
local GD = _G.GD
local PlayerDetails = UIMgr:NewUI("PlayerDetails")

local UnionModel = import("Model/UnionModel")
local BlockListModel = import("Model/BlockListModel")
local BuildModel = import("Model/BuildModel")
local SkillModel = import("Model/SkillModel")
local PlayerDetailModel = import("Model/PlayerDetailModel")
local GuideModel = import("Model/GuideControllerModel")
local SpineCharacter = import("Model/Animation/SpineCharacter")
local CheckValidModel = import("Model/Common/CheckValidModel")
local UIType = _G.GD.GameEnum.UIType
local GlobalVars = GlobalVars
local EquipModel = _G.EquipModel
local PlaneModel = _G.PlaneModel
local TipUtil = _G.TipUtil
local CONTROLLER = {
    Mine = "Mine",
    Other = "Other"
}
local UNION_BTN_TYPE =
{
    APPLY = "APPLY",
    INVITE = "INVITE",
    DETAILS = "DETAILS",
    ENABLED = "ENABLED"
}

local _longPressLabel = nil

local longPressLabelTrue = function()
    if _longPressLabel then
        _longPressLabel.visible = true
    end
end

local longPressLabelFalse = function()
    if _longPressLabel then
        _longPressLabel.visible = false
    end
end

function PlayerDetails:OnInit()
    local view = self.Controller.contentPane
    self._view = view
    self._controller = view:GetController("Controller")

    self._centerList = view:GetChild("_centerList")
    self._centerItem = self._centerList:GetChildAt(0)
    self._btnTranslate = self._centerItem:GetChild("btnTranslate")
    self._itemController = self._centerItem:GetController("Controller")
    self._flag = self._centerItem:GetChild("_flag")
    self._bust = self._centerItem:GetChild("_bust")
    self._textSpeak = self._centerItem:GetChild("_textSpeak")
    self._btnEditDesc = self._centerItem:GetChild("_btnEditDesc")
    self._btnCharacter = self._centerItem:GetChild("_btnCharacter")
    self._barExp = self._centerItem:GetChild("_barExp")
    self._expText = self._centerItem:GetChild("_expText")
    self._btnAddExp = self._centerItem:GetChild("_btnAddExp")
    self._barHp = self._centerItem:GetChild("_barHp")
    self._barHp:GetChild("title").visible = false
    self._hpText = self._centerItem:GetChild("_hpText")
    self._btnAddHp = self._centerItem:GetChild("_btnAddHp")
    _longPressLabel = self._centerItem:GetChild("_longPressLabel")
    -- self._textLevel = self._centerItem:GetChild("_textLevel")
    self._btnPower = self._centerItem:GetChild("_btnPower")
    self._btnKill = self._centerItem:GetChild("_btnKill")
    self._btnAchievement = self._centerItem:GetChild("_btnAchievement")
    self._itemBgBar = self._centerItem:GetChild("bgBar")
    --获取装备列表组件
    self._btnWear = {}
    for i = 1,8 do
        self._btnWear[i] = self._centerItem:GetChild("_btnWear"..i)
    end

    self._centerList.scrollPane:ScrollTop()

    self:AddListener(self._btnReturn.onClick,
        function()
            self:Close()
            if self.triggerFunc then
                self.triggerFunc()
            end
        end
    )
    ------------------------------------------- 最上排按钮
    --领主信息
    self:AddListener(self._btnHelp.onClick,
        function()
            if self.isSelf then
                UIMgr:Open(
                    "PlayerInfo/PlayerInfo",
                    function()
                        SpineCharacter.ShowBust(self._bust, self.bust)
                    end
                )
            else
                UIMgr:Open("PlayerInfo/PlayerInfoOther", self.playerId, self.info)
            end
        end
    )
    --旗帜
    self:AddListener(self._flag.onClick,
        function()
            UIMgr:Open("PlayerFlag", FLAG_TYPE.Player)
        end
    )
    --修改名称
    self:AddListener(self._btnEditName.onClick,
        function()
            TurnModel.PlayerRename()
        end
    )
    --修改个人宣言
    self:AddListener(self._btnEditDesc.onClick,
        function()
            UIMgr:Open("Rename", CheckValidModel.From.PlayerRedesc)
        end
    )
    --复制玩家昵称
    self:AddListener(self._btnCopyName.onClick,
        function()
            self:OnCopyNameClick()
        end
    )
    --形象选择
    self:AddListener(self._btnCharacter.onClick,
        function()
            UIMgr:Open(
                "PlayerCharacter/PlayerCharacter",
                function()
                    SpineCharacter.ShowBust(self._bust, self.bust)
                end
            )
            PlayerDataModel:SetDayNotTip(PlayerDataEnum.PLAYER_RECHARACTER)
            self:CheckExgCharacterPoint()
        end
    )
    ------------------------------------------- 中下排按钮
    --战斗力
    self._textPower = self._btnPower:GetChild("text")
    self:AddListener(self._btnPower.onClick,
        function()
            UIMgr:Open("PlayerPower/PlayerPowerBox")
        end
    )
    --击杀敌人
    self._textKill = self._btnKill:GetChild("text")
    self:AddListener(self._btnKill.onClick,
        function()
            UIMgr:Open("PlayerKill/PlayerKillBox")
        end
    )
    --获得成就
    self._textAchievement = self._btnAchievement:GetChild("text")
    self:AddListener(self._btnAchievement.onClick,
        function()
            if UnlockModel:UnlockCenter(UnlockModel.Center.Achievement) then
                self:OnBtnAchievementTipClick()
            else
                TipUtil.TipById(50284)
            end
        end
    )
    ------------------------------------------- 最下排按钮
    --排行榜
    self:AddListener(self._btnRank.onClick,
        function()
            if BuildModel.GetCenterLevel() < Global.RankOpenLevel then
                TipUtil.TipById(50004)
            else
                Net.Rank.RankInfo(
                    Global.RankByAlliancePower,
                    1,
                    0,
                    function(rsp)
                        if rsp.Fail then
                            return
                        end

                        UIMgr:Open("RankMain", rsp, true)
                    end
                )
            end
        end
    )
    --成就墙
    self:AddListener(self._btnAchievementWall.onClick,
        function()
            if UnlockModel:UnlockCenter(UnlockModel.Center.Achievement) then
                self:OnBtnAchievementWallClick()
            else
                TipUtil.TipById(50284)
            end
        end
    )
    --指挥官技能
    self:AddListener(self._btnSkill.onClick,
        function()
            if self.triggerFunc then
                self.triggerFunc()
            end
            UIMgr:Open("PlayerSkill")
        end
    )
    --设置
    self:AddListener(self._btnSet.onClick,
        function()
            PlayerDataModel:SetDayNotTip(PlayerDataEnum.PLAYER_SET)
            if self.triggerFunc then
                self.triggerFunc()
            end
            UIMgr:Open(
                "PlayerSetup",
                function()
                    self:CheckSetPoint()
                end
            )
        end
    )
    --帮会
    self:AddListener(self._btnUnion.onClick,
        function()
            self:OnBtnUnionClick()
        end
    )
    --发送信件
    self:AddListener(self._btnSendLetter.onClick,
        function()
            self:OnBtnSendLetterClick()
        end
    )
    --黑名单
    self:AddListener(self._btnBlacklist.onClick,
        function()
            self:OnBtnBlacklistClick()
        end
    )

    --玩家信息变化通知
    self:AddEvent(
        EventDefines.UIPlayerInfoExchange,
        function()
            if UIMgr:GetUIOpen("PlayerDetails") then
                if self.isSelf then
                    self:ShowPlayerInfo(Model.Player)
                    self:CheckSkillPoint()
                else
                    return
                end
            end
        end
    )
    self:AddEvent(
        EventDefines.RefreshEquipInfo,
        function()
            self:ShowEquipInfo(self.isSelf)
        end
    )

    self:AddEvent(
        EventDefines.AchievementRewardChange,
        function()
            self:UpdateAchivementNum()
            self:CheckWallPoint()
        end
    )

    --经验等级
    self:AddListener(self._btnAddExp.onClick,
        function()
            self:OnBtnAddExpClick()
        end
    )
    --体力
    self:AddListener(self._btnAddHp.onClick,
        function()
            UIMgr:Open("PlayerItem/PlayerItem", "Hp")
        end
    )
    self:AddListener(self._btnTranslate.onClick,
        function()
            self:OnBtnTranslateClick()
        end
    )
    self:ShowHpLongPress()
    self:CheckEditNameCuePoint()
    self:CheckExgCharacterPoint()
end

function PlayerDetails:ShowButton(level)
    local isShowButton = level >= Global.PlayerDetailShowButton
    self._btnPower.visible = isShowButton
    self._btnKill.visible = isShowButton
    self._btnAchievement.visible = isShowButton
end

function PlayerDetails:DoOpenAnim(...)
    self:OnOpen(...)
    AnimationLayer.PanelAnim(AnimationType.PanelMovePreDown, self)
end
function PlayerDetails:OnOpen(playerId, closeCb)
    self._closeCb = closeCb
    --长按提示框显示
    self:LongPressShow()

    if GuideModel.isBeginGuide then
        if GuideModel.uiType == UIType.PlayerDetailsUI then
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.PlayerDetailsAddUI)
        elseif GuideModel.uiType == UIType.PlayerDetailSkillUI then
            Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.SkillBtnUI)
        end
    end

    local building = BuildModel.FindByConfId(Global.BuildingCenter)
    if building.Level >= 2 and GlobalVars.NowTriggerId == 0 and playerId == nil then
        Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.OpenUI, 13100, 0)
    end
    self.isTranslated = false
    self.transText = ""
    self.playerId = playerId
    self.isSelf = not playerId or playerId == Model.Account.accountId
    if self.isSelf then
        --玩家自己
        self:Schedule(self._cb, 1)
        self._controller.selectedPage = CONTROLLER.Mine
        self._itemController.selectedPage = CONTROLLER.Mine
        self:ShowPlayerInfo(Model.Player)
        self:CheckPlayerCuePoint()
        self:UpdateAchivementNum()
    else
        --其他玩家
        self._controller.selectedPage = CONTROLLER.Other
        self._itemController.selectedPage = CONTROLLER.Other
        Net.UserInfo.GetUserInfo(
            playerId,
            function(msg)
                self:ShowPlayerInfo(msg)
                self:ShowUnionButton(msg)
                self:ShowEquipInfo(self.isSelf)
            end
        )
        self.isBlocklist = BlockListModel.IsInBlockList(self.playerId)
        self._btnBlacklist.title = StringUtil.GetI18n(I18nType.Commmon, self.isBlocklist and "System_Banlist_Button" or "Button_Banlist")

        if GuidedModel._changeNameFlag and GuidedModel._changeNameStep == 1 and GuidedModel._changeNamePlayerId == playerId then
            if not self.guideItem then
                self.guideItem = UIMgr:CreateObject("Common", "Guide")
                self.guideItem:SetXY((self._btnSendLetter.width - self.guideItem.width)/2, 
                        (self._btnSendLetter.height - self.guideItem.height)/2)
                self._btnSendLetter:AddChild(self.guideItem)
            end
        end
    end
    --显示装备信息
    if self.isSelf then
        self:ShowEquipInfo(true)
    end

    self._flag.touchable = self.isSelf
    self._btnPower.touchable = self.isSelf
    self._btnKill.touchable = self.isSelf
    self._btnAchievement.touchable = self.isSelf

    if GRoot.inst.height / 1334 > 1 then
        self._centerItem.height = self._centerList.scrollPane.viewHeight
    elseif GRoot.inst.height / 1334 < 0.9 then
        self._centerItem.height = self._centerItem.height - 50
    end
end
--显示装备信息
function PlayerDetails:ShowEquipInfo(isSelf)
    local equipPartInfos = {}
    if isSelf then
        equipPartInfos = EquipModel.GetEquipPart()
        local LuanchPlane = PlaneModel.GetLuanchPlane()
        if LuanchPlane and LuanchPlane.IsLaunch then
            equipPartInfos[7] = {
                EquipId =  LuanchPlane.Id,
                EquipUuid = "",
                Pos = 7
            }
        else
            equipPartInfos[7] = {
                EquipId =  0,
                EquipUuid = "",
                Pos = 7
            }
        end
    else
        equipPartInfos = self.info.PublicEquipSlot
    end
    local lockIndex = 8 --因为判断条件不足，这里写死了第8个装备未开放
    for index, v in pairs(self._btnWear) do
        if lockIndex == index then
            v:SetData(nil,6,nil)
            v:SetLock1(false)
            v:SetSmallAdd(false)
            v:SetLock2(true)
            v:SetClickItem(function ()
                 TipUtil.TipById(50223)
            end)
        elseif index == 7 then
            self.SetPlaneParts(v,index,equipPartInfos[index],isSelf)
        else
            self.SetEquipParts(v,index,equipPartInfos[index],isSelf)
        end
    end
end
--设置装备槽信息
function PlayerDetails.SetEquipParts(item,index,info,isself)
    if not info or info.EquipId == 0 then
        local equipAdd = false
        local qualityValue = info and 6 or 7
        if isself then
            equipAdd = EquipModel.IsEquipOfPart(index)
        end
        local icon = {"Common","equipment_part_"..index}
        item:SetData(icon,qualityValue,nil)
        item:SetLock1(false)
        item:SetLock2(false)
        item:SetSmallAdd(equipAdd)
    else
        local equipLock = false
        if isself then
            local equipUuid = info.EquipUuid
            equipLock = EquipModel.GetEquipModelByUuid(equipUuid).IsLock
        end
        local equipType = EquipModel.GetEquipTypeByEquipQualityID(info.EquipId)
        local equipQuality = EquipModel.GetEquipQualityById(info.EquipId)
        item:SetData(equipType.icon,equipQuality.quality-1,string.format("Lv.%d",equipType.equip_level))
        item:SetLock1(equipLock)
        item:SetLock2(false)
        item:SetSmallAdd(false)
    end

    if isself then
        local clickcb = function (pos)
            _G.UIMgr:Open("EquipmentAssembly",pos)
            _G.UIMgr:Close("PlayerDetails")
        end
        item:SetClickItem(clickcb, info.Pos)
    elseif not info then
        item:SetClickItem(function ()
            TipUtil.TipById(50325)
        end)
    else
        item:SetClickItem(nil)
    end
end
--设置战机槽信息
function PlayerDetails.SetPlaneParts(item,index,info,isself)
    local building = BuildModel.FindByConfId(Global.BuildingCenter)
    if not info or info.EquipId == 0 then
        local qualityValue = info and 6 or 7
        local icon = {"Common","equipment_part_"..index}
        local equipAdd = false
        if isself and building.Level >= Global.PlaneSystemUnlockLevel then
            equipAdd = true
        end
        item:SetData(icon,qualityValue,nil)
        item:SetLock1(false)
        item:SetLock2(false)
        item:SetSmallAdd(equipAdd)
    else
        local Launplane = PlaneModel.GetPlaneInfoById(info.EquipId)
        item:SetData(Launplane.config.equip_image,3,string.format("Lv.%d",Launplane.config.level))
        item:SetLock1(false)
        item:SetLock2(false)
        item:SetSmallAdd(false)
    end

    if isself then
        if info.EquipId ~= 0 then
            item:SetClickItem(function ()
                if building.Level < Global.PlaneSystemUnlockLevel then
                    local data = {
                        base_name = BuildModel.GetName(Global.BuildingCenter),
                        base_level = Global.PlaneSystemUnlockLevel
                    }
                    TipUtil.TipById(30602, data)
                    return
                end
                _G.UIMgr:Open("AttributeBonusPopup")
            end)
        else
            item:SetClickItem(function ()
                if building.Level < Global.PlaneSystemUnlockLevel then
                    local data = {
                        base_name = BuildModel.GetName(Global.BuildingCenter),
                        base_level = Global.PlaneSystemUnlockLevel
                    }
                    TipUtil.TipById(30602, data)
                    return
                end
                _G.UIMgr:Close("PlayerDetails")
                _G.UIMgr:Open("AircraftHangar")
            end)
        end

    elseif not info then
        item:SetClickItem(function ()
            TipUtil.TipById(50325)
        end)
    else
        item:SetClickItem(nil)
    end
end
--显示玩家信息
function PlayerDetails:ShowPlayerInfo(info)
    self.info = info
    self._baseEnergy = self.info.Energy
    local level = info.HeroLevel
    local exp = info.HeroExp
    local name = info.Name
    local power = info.Power
    local kill = info.Kills
    local flag = info.Flag
    self.desc = info.Declaration
    local hp = info.Energy
    self.bust = info.Bust

    self:ShowButton(level)
    self._name.text = name
    if self.desc == "" then
        self._textSpeak.text = StringUtil.GetI18n(I18nType.Commmon, "Button_CommanderTips_Default")
    else
        self._textSpeak.text = self.desc
    end
    self._flag.icon = UITool.GetIcon(ConfigMgr.GetItem("configFlags", flag).icon)
    self._textPower.text = Tool.FormatNumberThousands(power)
    self._textKill.text = kill
    self._textAchievement.text = info.AchievementNum
    --经验
    if level >= Global.MaxPlayerLevel then
        local conf = ConfigMgr.GetItem("configPlayerUpgrades", Global.MaxPlayerLevel)
        -- self._textLevel.text = Global.MaxPlayerLevel
        self._expText.text = Tool.FormatNumberThousands(conf.exp) .. "/" .. Tool.FormatNumberThousands(conf.exp)
        self._barExp.value = 100
        if self.isSelf then
            self._btnAddExp.visible = false
        else
            self._btnAddExp.visible = true
        end
    else
        local conf = ConfigMgr.GetItem("configPlayerUpgrades", level + 1)
        -- self._textLevel.text = level
        self._expText.text = Tool.FormatNumberThousands(exp) .. "/" .. Tool.FormatNumberThousands(conf.exp)
        self._barExp.value = exp / conf.exp * 100
    end
    if self.isSelf then
        self._energy = GD.ResAgent.GetEnergy()
        self._hpText.text = self._energy .. "/" .. 100
        self._barHp.value = self._energy
        self._btnAddHp.visible = self._energy < 50
        -- self._textLevel.text = "EXP"
    end
    -- self._textLevel.text = "EXP"

    if self.Controller.visible then
        SpineCharacter.Hide()
        SpineCharacter.ShowBust(self._bust, self.bust)
    end
end

--长按提示框显示
function PlayerDetails:LongPressShow()
    _longPressLabel.visible = false
    self.hp = UIMgr:GetLongPressGesture(self._barHp)
    self.hp.trigger = 0
    self:AddListener(self.hp.onBegin,longPressLabelTrue)
    self:AddListener(self.hp.onEnd,longPressLabelFalse)
    --self:AddListener(self.hp.onAction,longPressLabelFalse)
end

--点击显示成就
function PlayerDetails:OnBtnAchievementWallClick()
    Net.Achievement.GetAchievementsInfo(
        function(rsp)
            UIMgr:Open("PlayerAchievementWall", rsp)
        end
    )
end

--点击显示成就确定提示框
function PlayerDetails:OnBtnAchievementTipClick()
    local values = {
        number = self._textAchievement.text
    }
    local data = {
        titleText = StringUtil.GetI18n(I18nType.Commmon, "Ui_Commander_achievement"),
        content = StringUtil.GetI18n(I18nType.Commmon, "Ui_Commander_Nowachievement", values),
        sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO"),
        sureCallback = function()
            if UnlockModel:UnlockCenter(UnlockModel.Center.Achievement) then
                self:OnBtnAchievementWallClick()
            else
                TipUtil.TipById(50284)
            end
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

--点击发送信件
function PlayerDetails:OnBtnSendLetterClick()
    if GuidedModel._changeNameFlag and GuidedModel._changeNameStep == 1 then
        GuidedModel._changeNameStep = 2
        if self.guideItem then
            self.guideItem:RemoveFromParent()
        end
    end
    local info = {}
    info.subject = self.playerId
    info.subCategory = MAIL_SUBTYPE.subPersonalMsg
    info.Receiver = self.info.Name
    UIMgr:Open("Mail_PersonalNews", nil, nil, nil, nil, MAIL_CHATHOME_TYPE.TempChat, info)
end

--显示联盟图标
function PlayerDetails:ShowUnionButton(info)
    --查看玩家拥有联盟
    if info.AllianceName and info.AllianceName ~= "" then
        local condLevel = BuildModel.GetCenterLevel() >= info.AllianceJoinLevel
        local condPower = Model.Player.Power >= info.AllianceJoinPower
        local canJoin = condLevel and condPower
        canJoin = canJoin or info.AllianceFreeJoin
        --满足加入条件可申请 不满足加入条件可查看
        if canJoin and not UnionModel.CheckJoinUnion() then
            self.UnionType = UNION_BTN_TYPE.APPLY
            self._btnUnion.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ALLIANCE_APPLY")
        else
            self.UnionType = UNION_BTN_TYPE.DETAILS
            self._btnUnion.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ALLIANCE_DETAILS")
        end
        self._btnUnion.enabled = true
    else
        --查看玩家玩家没有联盟 自己有联盟
        if UnionModel.CheckJoinUnion() then
            --是否有邀请玩家加入联盟的权限
            local hasPower = UnionModel.CheckPermission(GlobalAlliance.APInviteJoin)
            self.UnionType = hasPower and UNION_BTN_TYPE.INVITE or UNION_BTN_TYPE.ENABLED
            self._btnUnion.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ALLIANCE_INVITE")
            self._btnUnion.enabled = hasPower
        else
            --两个人都没有联盟
            self.UnionType = UNION_BTN_TYPE.DETAILS
            self._btnUnion.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ALLIANCE_DETAILS")
            self._btnUnion.enabled = false
        end
    end
end
--点击邀请入盟/查看联盟
function PlayerDetails:OnBtnUnionClick()
    if self.UnionType == UNION_BTN_TYPE.DETAILS then
        UIMgr:ReOpen("UnionViewData", self.info.AllianceId)
    elseif self.UnionType == UNION_BTN_TYPE.APPLY then
        self:OnBtnApplyClick()
    else
        Net.Alliances.InvitePlayer(
            self.playerId,
            function()
                TipUtil.TipById(50215)
            end
        )
    end
end

-- 点击申请入盟
function PlayerDetails:OnBtnApplyClick()
    UIMgr:Open(
        "UnionApplyPopup",
        self.info.AllianceId,
        function()
            TipUtil.TipById(50074)
        end
    )
end

--点击黑名单
function PlayerDetails:OnBtnBlacklistClick()
    if self.isBlocklist then
        BlockListModel.RemoveFromBlockList(
            self.playerId,
            function(...)
                self.isBlocklist = false
                self._btnBlacklist.title = StringUtil.GetI18n(I18nType.Commmon, "Button_Banlist")
                TipUtil.TipById(50121, {name = self.info.Name})
            end
        )
        return
    end
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "System_Banlist_Tips"),
        sureCallback = function()
            BlockListModel.AddToBlocklist(
                self.playerId,
                function(...)
                    Event.Broadcast(WORLD_CHAT_EVENT.BanRefresh)
                    self.isBlocklist = true
                    self._btnBlacklist.title = StringUtil.GetI18n(I18nType.Commmon, "System_Banlist_Button")
                    TipUtil.TipById(50125, {name = self.info.Name})
                end
            )
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

function PlayerDetails:UpdateAchivementNum()
    local achievements = Model.GetMap(ModelType.AccomplishedAchievement)
    local num = 0
    local existAward = false
    for _, achievement in pairs(achievements) do
        if achievement.AwardTaken then
            num = num + 1
        else
            if not existAward then
                local item = ConfigMgr.GetItem("configAchievementTasks", achievement.Id)
                local items = ConfigMgr.GetListBySearchKeyValue("configAchievementTasks", "type", item.type)
                table.sort(
                    items,
                    function(a, b)
                        return a.id < b.id
                    end
                )
                for _, v in ipairs(items) do
                    if v.id == achievement.Id then
                        existAward = true
                        break
                    else
                        if not achievements[v.id] then
                            break
                        end
                    end
                end
            end
        end
    end
    self._textAchievement.text = num
end

--点击增加经验按钮
function PlayerDetails:OnBtnAddExpClick()
    local items = GD.ItemAgent.GetItemsBysubType(PropType.ALL.Effect, Global.ResPlayerExp)
    for _, v in ipairs(items) do
        if Model.Items[v.id] then
            --有经验道具 进入使用经验道具界面
            UIMgr:Open("PlayerItem/PlayerItem", "Exp")
            return
        end
    end
    --没有经验道具 弹出获取获取途径界面
    UIMgr:Open(
        "AccessWay",
        Global.GetmoreItemPlayerExp,
        function()
            self:Close()
        end
    )
end

function PlayerDetails:OnBtnTranslateClick()
    if self.desc == "" then
        self._textSpeak.text = StringUtil.GetI18n(I18nType.Commmon, "Button_CommanderTips_Default")
    else
        if self.isTranslated then
            self.isTranslated = false
            self._textSpeak.text = self.desc
        else
            self.isTranslated = true
            if self.transText == "" then
                Net.Chat.Translate(
                    2,
                    self.playerId,
                    {self.desc},
                    function(msg)
                        self.transText = msg.Content[1]
                        self._textSpeak.text = self.transText
                    end
                )
            else
                self._textSpeak.text = self.transText
            end
        end
    end
end

function PlayerDetails:ShowHpLongPress()
    self._cb = function()
        if not self._energy then
            return
        end
        local title = ""
        if self._energy >= 100 then
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_AP_MAX")
        else
            local _time = Model.EnergyRecoverTick - math.fmod(Tool.Time() - Model.Player.EnergyRefreshAt, Model.EnergyRecoverTick)
            local _add = math.modf((Tool.Time() - Model.Player.EnergyRefreshAt) / Model.EnergyRecoverTick)
            local min = math.floor(_time / 60)
            local second = math.fmod(_time, 60)
            if second < 10 then
                second = "0" .. second
            end
            title = min and min .. ":" .. second or second
            if _time == 1 and self._energy <= 100 then
                self._energy = self._baseEnergy + 1
                self._hpText.text = self._energy .. "/" .. 100
                self._barHp.value = self._energy
                self._btnAddHp.visible = self._energy < 50
            end
        end
        local content = StringUtil.GetI18n(I18nType.Commmon, "UI_AP_TIPS", {number = Model.EnergyRecoverTick})
        _longPressLabel:InitLabel(title, content)
        _longPressLabel:SetArrowActive(false)
    end
end

--点击复制玩家昵称按钮
function PlayerDetails:OnCopyNameClick()
    --TODO 复制粘贴功能
    GUIUtility.systemCopyBuffer = self.info.Name
    TipUtil.TipById(50126)
end
--检查修改名称按钮红点显示
function PlayerDetails:CheckEditNameCuePoint()
    CuePointModel:SetSingle(CuePointModel.Type.Red, CuePointModel.CheckPlayerName() and 1 or 0, self._btnEditName)
end
--检测修改形象按钮红点显示
function PlayerDetails:CheckExgCharacterPoint()
    CuePointModel:SetSingle(CuePointModel.Type.Red, CuePointModel.CheckPlayerCharacter() and 1 or 0, self._btnCharacter)
end
--检查指挥官提示点显示
function PlayerDetails:CheckPlayerCuePoint()
    local pos = CuePointModel.Pos.PlayerDown
    local cpPlayer = CuePointModel.SubType.Player
    for _, v in pairs(cpPlayer) do
        if v.Key == cpPlayer.PlayerWall.Key then
            --成就墙
            self:CheckWallPoint()
            CuePointModel:SetSingle(v.Type, v.Number, self._btnAchievementWall, pos)
        elseif v.Key == cpPlayer.PlayerSkill.Key then
            --技能点
            self:CheckSkillPoint() --先刷新下技能点缓存数据
            CuePointModel:SetSingle(v.Type, v.Number, self._btnSkill, pos)
        elseif v.Key == cpPlayer.PlayerSet.Key then
            --设置
            self:CheckSetPoint()
            CuePointModel:SetSingle(v.Type, v.Number, self._btnSet, pos)
        end
    end
end
--刷新成就墙提示点
function PlayerDetails:CheckWallPoint()
    local number = PlayerDetailModel.CheckNoAwardTaken() and 1 or 0
    CuePointModel:Set(CuePointModel.SubType.Player.PlayerWall, number, self._btnAchievementWall)
end
--刷新技能提示点
function PlayerDetails:CheckSkillPoint()
    local number = SkillModel.GetSkillPoints(SkillModel.GetCurPage())
    CuePointModel:Set(CuePointModel.SubType.Player.PlayerSkill, number, self._btnSkill)
end
--刷新设置技能点
function PlayerDetails:CheckSetPoint()
    local number = UserModel:NotReadPlayerNumber()
    CuePointModel:Set(CuePointModel.SubType.Player.PlayerSet, number, self._btnSet)
end

function PlayerDetails:OnClose()
    self:UnSchedule(self._cb)
    Event.Broadcast(EventDefines.HeadPlayerRedPointCheck)
    SpineCharacter.Clear()
    self:RemoveListener(self.hp.onBegin, longPressLabelTrue)
    self:RemoveListener(self.hp.onEnd, longPressLabelFalse)
    --self:RemoveListener(self.hp.onAction, longPressLabelFalse)
end

function PlayerDetails:Close()
    UIMgr:Close("PlayerDetails")
end

function PlayerDetails:TriggerOnclick(callback)
    self.triggerFunc = callback
end

function PlayerDetails:OnClose()
    if self._closeCb then
        self._closeCb()
    end
end

return PlayerDetails
