--[[
    Author:zhangzhichao
    Function:VIP功能
]]
local GD = _G.GD
local VIPMain = UIMgr:NewUI("VIPMain")
local DressUpModel = import("Model/DressUpModel")

local VIPModel = import("Model/VIPModel")
local VIPMainItem = import("UI/VIP/VIPMainItem")
local CommonModel = import("Model/CommonModel")
local Guide = import("UI/Common/Guide")


-- vipInfo.VipIsActivated vip是否激活
-- vipInfo.VipPoints vip点数
-- vipInfo.VipLevel vip等级
-- vipInfo.ExpirationTime vip剩余时间

local conf, level, vipInfo = {}

function VIPMain:OnInit(index)
    local view = self.Controller.contentPane
    --icon
    self._imageIcon = view:GetChild("_icon")
    self._iconVIP = view:GetChild("iconVIP")
    --按钮
    self._btnReturn = view:GetChild("btnReturn")
    self._btnHelp = view:GetChild("btnHelp")
    self._btnStore = view:GetChild("btnStore")
    self._btnGet = view:GetChild("btnGet")
    self._actvityVipBtn = view:GetChild("ActivityVip")
    --控制器
    self._controller = view:GetController("c1")
    self._iconHour = view:GetChild("iconHourglass")
    --self._loopAnim = self._iconHour:GetTransition("Loop")
    self._controllerPage = view:GetController("page")
    --进度条
    self._progressBar2 = view:GetChild("progressBar2")
    self._progressBarText = self._progressBar2:GetChild("title")
    self._progressBar2.max = 100
    -- 文本
    self._textTitle = view:GetChild("textName")
    self._upLevelText = view:GetChild("upLevelText")
    self._textExplain = view:GetChild("textExplain")
    self._textVIPNum = view:GetChild("textVIPNum")
    self._btnGetText = self._btnGet:GetChild("title")
    self._textVIPPoint = view:GetChild("textVIPPoint")
    self._textVIPLevel = view:GetChild("textVIPLevel")
    self._textVIPLevelNum = view:GetChild("textVIPLevelNum")
    self._textVIPNext = view:GetChild("textVIPNext")
    self._textVIPNextNum = view:GetChild("textVIPNextNum")
    self._textVipShopTitle = view:GetChild("textShop")
    --列表
    self._listliebiaoP = view:GetChild("liebiaoPoint")
    self._listliebiaoP.numItems = 9 --最大等级-1
    self._listliebiao = view:GetChild("liebiao")
    self._listliebiao.numItems = 9
    --图片
    self._vipImg2 = view:GetChild("textVIP2")
    self:AddListener(self._listliebiao.scrollPane.onScrollEnd,function()
        self:RefreshPoint(self._controllerPage.selectedIndex + 1)
    end)

    self.btnGetEffectPanel = UIMgr:CreateObject("Common", "Guide")
    self._btnGet:AddChild(self.btnGetEffectPanel)
    self.btnGetEffectPanel:SetPivot(0.5, 0.5)
    self.btnGetEffectPanel:SetXY(-38, -100)
    self.btnGetEffectPanel:SetGuideScale(0.8)
    self.btnGetEffectPanel:PlayLoop()
    self._textVipShopTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Store_Title")
    conf = ConfigMgr.GetList("configVips")
    self:InitEvent()
    self:InitInfo()

    self:AddEvent(
        EventDefines.UIVipInfo,
        function(rsp)
            vipInfo = rsp
        end
    )

    self:AddEvent(
        EventDefines.VipPointsChange,
        function()
            self:RefreshData()
        end
    )

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.VipMain)
end

function VIPMain:goodsInfoAndNum()
    --VIP点数道具
    local AllItems = GD.ItemAgent.GetItemsBysubType(PropType.ALL.Effect, PropType.VIP.Points)
    local haveItems = self:FindHaveItem(AllItems, Model.Items)
    return haveItems, AllItems
end

function VIPMain:FindHaveItem(AllItems, ModelItems)
    local curHaveItem = {}
    local num = 0
    for k, v in pairs(AllItems) do
        for k1, v1 in pairs(ModelItems) do
            if v.id == v1.ConfId then
                table.insert(curHaveItem, v1)
            end
        end
    end
    return curHaveItem
end

function VIPMain:InitInfo()
    for i = 1, 9 do
        self._nextLieBiao = self._listliebiao:GetChildAt(i - 1)
        self._textTagLevelL = self._nextLieBiao:GetChild("textTagLevel")
        self._textTagNextR = self._nextLieBiao:GetChild("textTagNext")
        self._textTagLevelL.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text2", {vip_level = i}) --列表抬头左边等级
        self._textTagNextR.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text2", {vip_level = i + 1}) --列表抬头右边等级
        local levelProp, _ = VIPModel.GetLevelPropByConf(i, conf)
        local levelProp1, _ = VIPModel.GetLevelPropByConf(i + 1, conf)
        levelProp, levelProp1 = VIPModel.SetLevelPropList(levelProp, levelProp1)

        local nextliebiao = self._nextLieBiao:GetChild("nextliebiao")
        nextliebiao.scrollPane:ScrollTop()
        nextliebiao.numItems = #levelProp1 * 2 -- 生成左右两个等级对比的属性
        for i = 1, #levelProp1 do
            self._nextLieBiao.height = self._listliebiao.height
            local leftItem = nextliebiao:GetChildAt((i - 1) * 2)
            local rightItem = nextliebiao:GetChildAt((i - 1) * 2 + 1)
            leftItem:InitEvent(levelProp[i], i, false)
            rightItem:InitEvent(levelProp1[i], i + 1, true)
        end
    end
end

function VIPMain:OnOpen(msg)
    Net.VipShop.GetGoodsList(
        function(msg)
            if next(msg.GoodsList) and msg.NextRefreshAt > 0 then
                self._btnStore.visible = true
                self._textVipShopTitle.visible = true
            elseif not next(msg.GoodsList) or msg.NextRefreshAt <= 0 then
                self._btnStore.visible = false
                self._textVipShopTitle.visible = false
            end
        end
    )
    SdkModel.TrackBreakPoint(10031) --打点
    self._textTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Title")
    -- CommonModel.SetUserAvatar(self._imageIcon) --设置VIP头像
    self._imageIcon:SetAvatar({Avatar = Model.User.Avatar, DressUpUsing = DressUpModel.usingDressUp})
    self._btnGetText.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_POINT")
    vipInfo = msg
    --[[
    if vipInfo.VipIsActivated then
        self._controller.selectedIndex = 0
        self._loopAnim:Play(-1, 0, nil)
    else
        self._controller.selectedIndex = 1
        self._loopAnim:Play(1, 0, 0, 0, nil)
        self._loopAnim:Stop()
    end]]

    self:RefreshData()

    for i = 1, 9 do
        self._nextLieBiao = self._listliebiao:GetChildAt(i - 1)
        self._nextLieBiao.height = self._listliebiao.height
    end
end

function VIPMain:DoOpenAnim(...)
    self:OnOpen(...)
    AnimationLayer.PanelAnim(AnimationType.PanelMovePreDown, self)
end

function VIPMain:RefreshPoint(index)
    if index > self._listliebiaoP.numChildren then
        index = self._listliebiaoP.numChildren
    end
    for i = 1, 9 do
        self._listliebiaoP:GetChildAt(i - 1):SetData(i, index)
    end
end

function VIPMain:RefreshData()
    level = vipInfo.VipLevel
    self._textVIPNum.text = vipInfo.VipLevel --VIP等级
    if vipInfo.VipIsActivated == true then --VIP是否开启
        self._controller.selectedIndex = 0
        self._textExplain.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text1")
        self:Reset(vipInfo.ExpirationTime) --如果开启，显示剩余时间
    else
        self._controller.selectedIndex = 1
        self._textExplain.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text4")
    end
    if VIPModel.ItemEnoughToUpgrade(vipInfo) then --当前积分可提升等级提示
        self._upLevelText.visible = true
        if vipInfo.VipPoints >= 240000 then
            self._upLevelText.visible = false
        else
            self._upLevelText.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text5")
        end
    else
        self._upLevelText.visible = false
    end

    local list, point = VIPModel.GetLevelPropByConf(vipInfo.VipLevel, conf)
    local list1, point1 = VIPModel.GetLevelPropByConf(vipInfo.VipLevel + 1, conf)
    if vipInfo.VipLevel == VIPModel.GetMaxVipLevel() then --等级满级时
        self._progressBar2.value = 100 --积分条比例
        self._progressBarText.text = vipInfo.VipPoints --积分条数值
        if vipInfo.VipPoints > point then
            self._progressBarText.text = point
        end
        local item = self._listliebiao:GetChildAt(vipInfo.VipLevel - 2)
        self._listliebiao.scrollPane:ScrollToView(item)
        self._textVIPLevel.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text2", {vip_level = vipInfo.VipLevel})
        self._textVIPLevelNum.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text3", {vip_upgrade_point = point})
        self._textVIPNext.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text2", {vip_level = nil})
        --self._textVIPNextNum.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text3", {vip_upgrade_point = point})
        self._textVIPNextNum.text = "  " .. StringUtil.GetI18n(I18nType.Commmon, "UI_VIPLEVEL_MAX")
        self._vipImg2.visible = false
        self:RefreshPoint(vipInfo.VipLevel + 1)
    else
        self._progressBar2.value = (vipInfo.VipPoints - point) / (point1 - point) * 100 --积分条比例
        self._progressBarText.text = vipInfo.VipPoints --积分条数值
        local item = self._listliebiao:GetChildAt(vipInfo.VipLevel - 1)
        self._listliebiao.scrollPane:ScrollToView(item)
        self._textVIPLevel.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text2", {vip_level = vipInfo.VipLevel}) --滑动条左端数值
        self._textVIPLevelNum.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text3", {vip_upgrade_point = point}) --滑动条左端积分
        self._textVIPNext.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text2", {vip_level = vipInfo.VipLevel + 1}) --滑动条右端数值
        self._textVIPNextNum.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text3", {vip_upgrade_point = point1}) --滑动条右端积分
        self:RefreshPoint(vipInfo.VipLevel)
    end
    local arrow = self._progressBar2:GetChild("btnGrip")
    local bar = self._progressBar2:GetChild("bar")
    if self._progressBar2.value < 2 then
        arrow.x = -6
    else
        arrow.x = bar.x + bar.width - arrow.width
    end
    self:CheckBtnGetEffectPanel()
end

function VIPMain:InitEvent()
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("VIPMain")
        end
    )
    self:AddListener(self._btnHelp.onClick,
        function()
            UIMgr:Open("VIPTips")
        end
    )
    self:AddListener(self._btnStore.onClick,
        function()
            UIMgr:Open("VIPShopping")
        end
    )
    self:AddListener(self._btnGet.onClick,
        function()
            if VIPModel.ItemEnoughToUpgrade(vipInfo) then
                UIMgr:Open("VIPLevelPopup", vipInfo)
            else
                Net.Vip.GetVipInfo(
                    function(msg)
                        UIMgr:Open("VIPActivation", 2, level, msg)
                    end
                )
            end
        end
    )
    self:AddListener(self._actvityVipBtn.onClick,
        function()
            Net.Vip.GetVipInfo(
                function(msg)
                    UIMgr:Open("VIPActivation", 3, level, msg)
                end
            )
        end
    )
end

function VIPMain:Reset(timeNum)
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
    if timeNum == Tool.Time() then
    end
    local ctime = timeNum - Tool.Time()
    if ctime > 0 then
        local bar_func = function(t)
            self._textVIPPoint.text = Tool.FormatTime(t)
        end
        bar_func(ctime)
        self.cd_func = function()
            ctime = ctime - 1
            if ctime >= 0 then
                bar_func(ctime)
                return
            else
                self:RefreshData()
            end
        end
        self:Schedule(self.cd_func, 1)
    end
end

function VIPMain:isHavePointProp()
    local AllItems = GD.ItemAgent.GetItemsBysubType(PropType.ALL.Effect, PropType.VIP.Points)
    local haveItems = GD.ItemAgent.GetHaveItemsBysubType(PropType.ALL.Effect, PropType.VIP.Points)
    for k, v in pairs(AllItems) do
        for k1, v1 in pairs(haveItems) do
            if v.id == v1.ConfId then
                return true
            end
        end
    end
    return false
end

function VIPMain:CheckBtnGetEffectPanel()
    local show = VIPModel.ItemEnoughToUpgrade(vipInfo)
    local text = show and "BUTTON_UPGRADE_VIP" or "BUTTON_POINT"
    self.btnGetEffectPanel:SetShow(show)
    self._btnGetText.text = StringUtil.GetI18n(I18nType.Commmon, text)
end

return VIPMain
