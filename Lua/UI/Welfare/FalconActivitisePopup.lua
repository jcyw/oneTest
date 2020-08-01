-- author:{lishu}
-- time:2019-05-27 17:23:04
local GD = _G.GD
local FalconActivitisePopup = UIMgr:NewUI("FalconActivitisePopup")
local TechModel = import("Model/TechModel")

local  selectType = 0
local  itemData
local  awardList = {}
local  tempAward = {}
local  staticList = {}
local  staticLableList = {}
function FalconActivitisePopup:OnInit()
    -- 水星ui拼成列表的特殊处理
    staticLableList  = {
        ConfigMgr.GetI18n("configI18nCommons", "ACTIVITY_FALCONTIME_Tips7"),
        ConfigMgr.GetI18n("configI18nCommons", "ACTIVITY_FALCONTIME_Tips8"),
        StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_FALCONTIME_Tips15", {monsterName = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_1900001")}),
        StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_FALCONTIME_Tips15", {monsterName = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_1900002")}),
        StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_FALCONTIME_Tips15", {monsterName = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_1900003")})
    }
    self._view = self.Controller.contentPane
    self._bgMask = self._view:GetChild("bgMask")
    self._title.text = ConfigMgr.GetI18n("configI18nCommons", "ACTIVITY_FALCONTIME_Tips2")

    self._btnRecorde = self._RecordPanel:GetChild("_btnRecorde")
    self._btnStatic = self._RecordPanel:GetChild("_btnStatic")

    self.btnShare = self._RecordPanel:GetChild("_total"):GetChild("btnShare")

    self._recordList = self._RecordPanel:GetChild("_record"):GetChild("list")

    self._recordbtnShare = self._RecordPanel:GetChild("_record"):GetChild("btnShare")

    self._staticList = self._RecordPanel:GetChild("_total"):GetChild("staticList")
    self._awardList = self._RecordPanel:GetChild("_total"):GetChild("awardList")
    self._dec = self._RecordPanel:GetChild("_total"):GetChild("dec")

    self.panelController = self._RecordPanel:GetController("panel")

    self._dec.text = ConfigMgr.GetI18n("configI18nCommons", "ACTIVITY_FALCONTIME_Tips12")
    self._btnRecorde.text = ConfigMgr.GetI18n("configI18nCommons", "ACTIVITY_FALCONTIME_Tips3")
    self._btnStatic.text = ConfigMgr.GetI18n("configI18nCommons", "ACTIVITY_FALCONTIME_Tips4")
    self.btnShare.text = ConfigMgr.GetI18n("configI18nCommons", "ACTIVITY_FALCONTIME_Tips6")
    self._recordbtnShare.text = ConfigMgr.GetI18n("configI18nCommons", "ACTIVITY_FALCONTIME_Tips6")

    self:AddListener(self._bgMask.onClick,function ()
        UIMgr:Close("FalconActivitisePopup")
    end)

    self:AddListener(self.btnShare.onClick,
        function()
            if(not self.totalInfo and #self.totalInfo<=0)then
                return
            end

            local share_city_func = function()
                Net.Chat.SendChat("World", Model.Account.accountId, "", PUBLIC_CHAT_TYPE.OperationFalcon_Share, JSON.encode(self.totalInfo), function()
                    TipUtil.TipById(50065)
                end)
            end
            local share_union_func = function()
                if Model.Player.AllianceId == "" then
                    local data = {
                        content = StringUtil.GetI18n(I18nType.Commmon, "ConfirmJionAlliance"),
                        sureCallback = function()
                            UIMgr:Close("ConfirmPopupDouble")
                            UIMgr:Close("RangeRewardRecord")
                            UIMgr:Open("UnionView/UnionView")
                        end
                    }
                    UIMgr:Open("ConfirmPopupText", data)
                    return
                end
                Net.Chat.SendChat(Model.Player.AllianceId, Model.Account.accountId, "", PUBLIC_CHAT_TYPE.Alliance_OperationFalcon_Share, JSON.encode(self.totalInfo), function()
                    TipUtil.TipById(50065)
                end)
            end
            local data = {
                textContent = StringUtil.GetI18n(I18nType.Commmon, 'ShootingReward_36'),
                textTitle = StringUtil.GetI18n(I18nType.Commmon, 'ShootingReward_23'),
                textBtnLeft = StringUtil.GetI18n(I18nType.Commmon, 'ShootingReward_37'),
                textBtnRight = StringUtil.GetI18n(I18nType.Commmon, 'ShootingReward_38'),
                cbBtnLeft = share_city_func,
                cbBtnRight = share_union_func
            }
            UIMgr:Open("ConfirmPopupDouble", data)
        end
    )

    self:AddListener(self._recordbtnShare.onClick,
        function()
            local share_city_func = function()
                Net.Chat.SendChat("World", Model.Account.accountId, "", PUBLIC_CHAT_TYPE.OperationFalcon_Technology, JSON.encode(self.recordInfo), function()
                    TipUtil.TipById(50065)
                end)
            end
            local share_union_func = function()
                if Model.Player.AllianceId == "" then
                    local data = {
                        content = StringUtil.GetI18n(I18nType.Commmon, "ConfirmJionAlliance"),
                        sureCallback = function()
                            UIMgr:Close("ConfirmPopupDouble")
                            UIMgr:Close("RangeRewardRecord")
                            UIMgr:Open("UnionView/UnionView")
                        end
                    }
                    UIMgr:Open("ConfirmPopupText", data)
                    return
                end
                Net.Chat.SendChat(Model.Player.AllianceId, Model.Account.accountId, "", PUBLIC_CHAT_TYPE.Alliance_OperationFalcon_Technology, JSON.encode(self.recordInfo), function()
                    TipUtil.TipById(50065)
                end)
            end
            local data = {
                textContent = StringUtil.GetI18n(I18nType.Commmon, 'ShootingReward_36'),
                textTitle = StringUtil.GetI18n(I18nType.Commmon, 'ShootingReward_23'),
                textBtnLeft = StringUtil.GetI18n(I18nType.Commmon, 'ShootingReward_37'),
                textBtnRight = StringUtil.GetI18n(I18nType.Commmon, 'ShootingReward_38'),
                cbBtnLeft = share_city_func,
                cbBtnRight = share_union_func
            }
            UIMgr:Open("ConfirmPopupDouble", data)
        end
    )

    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_FALCONTIME_Tips4"),
                info = StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_FALCONTIME_Tips14")
            }
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )

    self:AddListener(self._btnRecorde.onClick,
        function()
            if(selectType == 1)then
                return
            end

            if( not self.recordInfo) then
                self:openRecords()
            else
                selectType = 1
                self.panelController.selectedIndex = selectType
            end
        end
    )

    self:AddListener(self._btnStatic.onClick,
        function()
            if(selectType == 0)then
                return
            end

            if( not self.totalInfo) then
                self:openTatal()
            else
                selectType = 0
                self.panelController.selectedIndex = selectType
            end
        end
    )

    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("FalconActivitisePopup")
        end
    )

    self._recordList.itemRenderer = function(index, gObject)
        itemData = self.recordInfo[index + 1]
        gObject:SetData(itemData.Uuid,
                itemData.MailId,
                index + 1,
                StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_FALCONTIME_Tips5", {monster_name = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_" .. itemData.Params[1]), technology_name = TechModel.GetTechName(itemData.Params[2])}),
                _G.TimeUtil.StampTimeToYMD(itemData.CreateAt)
        )
    end

    self._awardList.itemRenderer = function(index, gObject)
        gObject:SetShowData(awardList[index+1].icon, awardList[index+1].color, awardList[index+1].itemAmount, nil,awardList[index+1].mid)
    end

    self._staticList.itemRenderer = function(index, gObject)
        self:setStaticListGObject(gObject,staticLableList[index+1],StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_FALCONTIME_Tips13", { num = math.floor(staticList[index+1])}))
    end
end


function FalconActivitisePopup:setStaticListGObject(gObject,nameText,numText)
    gObject:GetChild("nameText").text = nameText
    gObject:GetChild("numText").text = numText
end

function FalconActivitisePopup:OnOpen()
    selectType =  0
    self:openTatal()
end

function FalconActivitisePopup:openRecords()
    selectType = 1
    self.panelController.selectedIndex = selectType
    Net.EagleHunt.RecentRecord(
        function(rsp)
            print("Net.EagleHunt.RecentRecordParams rsp ======================" .. table.inspect(rsp))
            --if rsp.Fail then
            --    return
            --end

            self.recordInfo = rsp.Records
            if(self.recordInfo == {})then
                self._recordList.numItems = 0
                return
            end

            table.sort(self.recordInfo, function(a, b)
                return a.CreateAt > b.CreateAt
            end)

            self._recordList.numItems = #self.recordInfo
        end
    )
end

function FalconActivitisePopup:openTatal()
    selectType = 0
    self.panelController.selectedIndex = selectType
    Net.EagleHunt.AllRecord(
        function(rsp)
            print("Net.EagleHunt.RecentRecordParams rsp ======================" .. table.inspect(rsp))
            --if rsp.Fail then
            --    return
            --end
            self.totalInfo = rsp

            if(not self.totalInfo.TotalTime) then
                awardList = {}
                staticList = {0,0,0,0,0}
                self._staticList.numItems = 5
                self._awardList.numItems = 0
                return
            end

            awardList = {}
            for k, v in pairs(self.totalInfo.AllReward) do
                if v.Category == Global.RewardTypeRes then
                    tempAward ={}
                    --资源
                    local conf = ConfigMgr.GetItem("configResourcess", v.ConfId)
                    tempAward.icon = conf.icon
                    tempAward.color = conf.color
                    tempAward.itemAmount = v.Amount
                    tempAward.mid = GD.ItemAgent.GetItemInnerContent(v.ConfId)
                    table.insert(awardList,tempAward)
                elseif v.Category == Global.RewardTypeItem then
                    --道具
                    tempAward ={}
                    local conf = ConfigMgr.GetItem("configItems", v.ConfId)
                    tempAward.icon = conf.icon
                    tempAward.color = conf.color
                    tempAward.itemAmount = v.Amount
                    tempAward.mid = GD.ItemAgent.GetItemInnerContent(v.ConfId)
                    table.insert(awardList,tempAward)
                end
            end

            staticList = {0,0,0,0,0}
            staticList[1] = self.totalInfo.TotalTime
            staticList[2] = self.totalInfo.TechRewardTime
            for k, v in pairs(self.totalInfo.MonsInfo) do
                if(v.MonsId == 1900001)then
                    staticList[3] = v.Time
                elseif(v.MonsId == 1900002)then
                    staticList[4] = v.Time
                elseif(v.MonsId == 1900003)then
                    staticList[5] = v.Time
                end
            end
            self._staticList.numItems = 5
            self._awardList.numItems = #awardList
        end
    )
end

function FalconActivitisePopup:OnClose()
    self.recordInfo = nil
    self.totalInfo = nil
end

return FalconActivitisePopup