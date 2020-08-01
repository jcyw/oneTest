-- author:{lishu}
-- time:2019-05-27 17:23:04
local GD = _G.GD
local FalconActivitiseSharePopup = UIMgr:NewUI("FalconActivitiseSharePopup")
local WelfareModel = import("Model/WelfareModel")

local  awardList = {}
local  tempAward = {}
local  staticList = {}

function FalconActivitiseSharePopup:OnInit()
    self._view = self.Controller.contentPane

    staticLableList  = {
        ConfigMgr.GetI18n("configI18nCommons", "ACTIVITY_FALCONTIME_Tips7"),
        ConfigMgr.GetI18n("configI18nCommons", "ACTIVITY_FALCONTIME_Tips8"),
        StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_FALCONTIME_Tips15", {monsterName = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_1900001")}),
        StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_FALCONTIME_Tips15", {monsterName = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_1900002")}),
        StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_FALCONTIME_Tips15", {monsterName = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_1900003")})
    }

    self._bgMask = self._view:GetChild("bgMask")
    self._title.text = ConfigMgr.GetI18n("configI18nCommons", "ACTIVITY_FALCONTIME_Tips2")

    self.btnShare = self._Content:GetChild("btnShare")
    self._staticList = self._Content:GetChild("staticList")
    self._awardList = self._Content:GetChild("awardList")
    self._dec = self._Content:GetChild("dec")

    self._dec.text = ConfigMgr.GetI18n("configI18nCommons", "ACTIVITY_FALCONTIME_Tips12")
    self.btnShare.text = ConfigMgr.GetI18n("configI18nCommons", "UI_FALCONTIME_Jump")

    self:AddListener(self.btnShare.onClick,
        function()
            if (Model.isFalconOpen) then
                if Model.Player.Level >= 4 then
                    UIMgr:Close("Chat")
                    UIMgr:Close("FalconActivitiseSharePopup")
                    UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.FALCON_ACTIVITY)
                else
                    --TipUtil.TipByContent(nil, StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FALCONTIPS4"))
                    TipUtil.TipById(50353)
                end
            else
                TipUtil.TipByContentWithWaring(StringUtil.GetI18n(I18nType.Commmon, "UI_Activity_FALCONType"))
            end
        end
    )

    self:AddListener(self._bgMask.onClick,function ()
        UIMgr:Close("FalconActivitiseSharePopup")
    end)

    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("FalconActivitiseSharePopup")
        end
    )

    self._awardList.itemRenderer = function(index, gObject)
        gObject:SetShowData(awardList[index+1].icon, awardList[index+1].color, math.floor(awardList[index+1].itemAmount), nil,awardList[index+1].mid)
    end

    self._staticList.itemRenderer = function(index, gObject)
        self:setStaticListGObject(gObject,staticLableList[index+1],StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_FALCONTIME_Tips13", { num = staticList[index+1]}))
    end
end

function FalconActivitiseSharePopup:setStaticListGObject(gObject,nameText,numText)
    gObject:GetChild("nameText").text = nameText
    gObject:GetChild("numText").text = numText
end

function FalconActivitiseSharePopup:OnOpen(data)
    self.totalInfo = data
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
    staticList[1] = math.floor(self.totalInfo.TotalTime)
    staticList[2] = math.floor(self.totalInfo.TechRewardTime)
    for k, v in pairs(self.totalInfo.MonsInfo) do
        if(v.MonsId == 1900001)then
            staticList[3] = math.floor(v.Time)
        elseif(v.MonsId == 1900002)then
            staticList[4] = math.floor(v.Time)
        elseif(v.MonsId == 1900003)then
            staticList[5] = math.floor(v.Time)
        end
    end
    self._staticList.numItems = 5
    self._awardList.numItems = #awardList
end

function FalconActivitiseSharePopup:OnClose()

end

return FalconActivitiseSharePopup