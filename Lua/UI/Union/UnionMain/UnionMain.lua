--[[
    Author: songzeming
    Function: 联盟主界面
]] local UnionMain = UIMgr:NewUI("UnionMain/UnionMain")

local UnionModel = import("Model/UnionModel")
import("UI/Union/ItemUnionList")
import("UI/Union/UnionMain/ItemUnionInfo")
import("UI/Union/UnionMain/UnionSyncNews")
import("UI/Union/UnionMain/ItemUnionMainSyncNews")
local GuidePanel = import("Model/GuideControllerModel")
local UIType = _G.GD.GameEnum.UIType

--建筑队列控制器
local CONTROLLER = {
    Main = "Main",
    Histroy = "Histroy"
}

function UnionMain:OnInit()
    local view = self.Controller.contentPane
    self._view = view
    self._controller = view:GetController("Controller")
    self._tagDown = view:GetChild("bgTagDown")
    GuidePanel:SetParentUI(self, UIType.UnionUI)
    self:AddListener(self._btnMessage.onClick,
        function()
            UIMgr:Open("Mail_PersonalNews", nil, nil, nil, nil, MAIL_CHATHOME_TYPE.UnionChat, {})
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._btnDetail.onClick,
        function()
            Sdk.AiHelpShowFAQSection("29887")
        end
    )
    self:AddListener(self._btnInvitation.onClick,
        function()
            UIMgr:Open("UnionInvitation")
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._btnMember.onClick,
        function()
            UIMgr:Open("UnionMember/UnionMember")
        end
    )
    self:AddListener(self._btnManager.onClick,
        function()
            UIMgr:Open("UnionManager")
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("UnionMain/UnionMain")
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )

    self:AddEvent(
        EventDefines.UIAllianceInfoExchanged,
        function()
            self._unionInfo:Init()
        end
    )

    self:AddEvent(
        EventDefines.UIAllianceIconExchanged,
        function()
            self._unionInfo:Init()
        end
    )

    self:AddEvent(
        EventDefines.UIAllianceMemberUpdate,
        function()
            self:UpdateSyncNews()
        end
    )

    self:AddEvent(
        EventDefines.UIAllianceNoticeUpdate,
        function()
            self:UpdateSyncNews()
        end
    )
    --联盟列表提示点刷新
    self:AddEvent(
        EventDefines.UIUnionMainList,
        function(key, num)
            for i = 1, self._unionList.numChildren do
                local item = self._unionList:GetChildAt(i - 1)
                local sub = item:GetSub()
                if sub and sub.Key == key then
                    local t = sub.Type
                    local n = sub.Number
                    if n == 0 and sub.TypeWaring then
                        t = sub.TypeWaring
                        n = sub.NumberWaring
                    end
                    CuePointModel:SetSingle(t, n, item, sub.Pos)
                    break
                end
            end
        end
    )
    --联盟成员提示点刷新
    self:AddEvent(
        EventDefines.UIUnionMainMember,
        function()
            local sub = CuePointModel.SubType.Union.UnionMember
            CuePointModel:SetSingle(sub.Type, sub.NumberN, self._btnMember, sub.Pos)
        end
    )
    --联盟管理提示点刷新
    self:AddEvent(
        EventDefines.UIUnionMainManger,
        function()
            local sub = CuePointModel.SubType.Union.UnionManager
            CuePointModel:SetSingle(sub.Type, sub.NumberN, self._btnManager, sub.Pos)
        end
    )
end

function UnionMain:OnOpen()
    --如果是盟主，触发盟主触发引导
    if UnionModel.CheckUnionOwner() then
        local alreadyTrigger = false
        for j = 1, #Model.Player.TriggerGuides do
            if Model.Player.TriggerGuides[j].Id == 15400 or Model.Player.TriggerGuides[j].Id == 12100 or Model.Player.TriggerGuides[j].Id == 15200 then
                alreadyTrigger = true
            end
        end
        if alreadyTrigger == false then
            Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.JoinUnion, 15300, 0)
        end
    else
        local alreadyTrigger = false
        for j = 1, #Model.Player.TriggerGuides do
            if Model.Player.TriggerGuides[j].Id == 15300 then
                alreadyTrigger = true
            end
        end
        if alreadyTrigger == false then 
            --如果不是盟主，并且小于5级
            if Model.Player.Level < 5 then
                Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.JoinUnion, 15400, 0)
            else
                --如果大于5级并且已经出发过联盟引导，那么只触发迁城引导
                local haveSame = false
                for j = 1, #Model.Player.TriggerGuides do
                    if Model.Player.TriggerGuides[j].Id == 15400 then
                        haveSame = true
                    end
                end
                if haveSame == false then
                    Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.JoinUnion, 12100, 0)
                else
                    Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.JoinUnion, 15200, 0)
                end
            end
        end
    end
    self._unionInfo:Init()
    self.itemList = {}
    self:UnionList()
    local isGuide = GuidePanel:IsGuideState(UIType.UnionBtnUI)
    if isGuide then
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.UnionUI)
    end
    self._controller.selectedPage = CONTROLLER.Main
    self:UpdateSyncNews()
    --刷新提示点
    Event.Broadcast(EventDefines.UIUnionMainMember)
    Event.Broadcast(EventDefines.UIUnionMainManger)
end

function UnionMain:DoOpenAnim(...)
    self:OnOpen(...)
    AnimationLayer.PanelAnim(AnimationType.PanelMoveUp, self)
end

function UnionMain:UpdateSyncNews()
    --请求第一条联盟状态
    local sync_news_func = function(rsp)
        local cb_func = function()
            if self._controller.selectedPage == CONTROLLER.Main then
                self._controller.selectedPage = CONTROLLER.Histroy
                self._syncNews:ListViewScrollUp()
            else
                self._controller.selectedPage = CONTROLLER.Main
            end
        end
        local syncCb = function()
            self._controller.selectedPage = CONTROLLER.Main
        end
        self._syncNews:Init(syncCb, rsp)
        -- self._msgBox:Init(cb_func, rsp)
        self._msgBox:SetData(cb_func, UnionModel.GetUnionNotice())
    end
    Net.Alliances.SyncNews(0, 1, sync_news_func)
end

-- 设置联盟列表
function UnionMain:UnionList()
    local conf = ConfigMgr.GetList("configAllianceMains")
    local confData = UnionModel.GetPermissionsByConf(conf)
    local arr = confData[Model.Player.AlliancePos]
    self._unionList.numItems = #arr
    for k, v in ipairs(arr) do
        local confItem = conf[v]
        local item = self._unionList:GetChildAt(k - 1)
        self.itemList[confItem.name] = item
        item:Init(confItem)
    end
    self:AddListener(self._unionList.onClickItem,
        function()
            Event.Broadcast(EventDefines.CloseGuide)
        end
    )
    self._unionList:EnsureBoundsCorrect()
    self._unionList.scrollPane.touchEffect = self._unionList.scrollPane.contentHeight > self._unionList.height
end

--得到相应联盟子项
function UnionMain:GetUnionItem(itemName)
    local conf = ConfigMgr.GetList("configAllianceMains")
    local confData = UnionModel.GetPermissionsByConf(conf)
    local arr = confData[Model.Player.AlliancePos]
    local unionItem = nil
    for i = 1, #arr do
        local item = self._unionList:GetChildAt(i - 1)
        local unionName = item:GetItemName()
        if itemName == unionName then
            unionItem = item
        end
    end
    if unionItem == nil then
        unionItem = self._btnMember
    end
    return unionItem
end

return UnionMain
