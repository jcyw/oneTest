--author: 	Amu
--time:		2019-08-19 14:31:21
local GD = _G.GD
local VIPModel = import("Model/VIPModel")
local CommonModel = import("Model/CommonModel")
local VIPMainItem = import("UI/VIP/VIPMainItem")
local Guide = import("UI/Common/Guide")
local DressUpModel = import("Model/DressUpModel")

local VIPShopping = UIMgr:NewUI("VIPShopping")
local vipInfo

function VIPShopping.New(controller)
    local ins = new(VIPShopping)
    ins.Controller = controller
    return ins
end

function VIPShopping:OnInit()
    local _view = self.Controller.contentPane
    self._scheduler = false
    self.dt = 0.5
    self._progressBar2.max = 100

    self._textName = _view:GetChild("textName")
    self._textAutomatic = _view:GetChild("textAutomatic")
    self._iconVIP = _view:GetChild("iconVIP")
    self._controller = _view:GetController("c1")
    self._textVIPPoint = _view:GetChild("textVIPPoint")
    self._upLevelText = _view:GetChild("upLevelText")
    self._actvityVipBtn = _view:GetChild("ActivityVip")
    self._btnHelp = _view:GetChild("btnHelp")
    self._btnGet:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_POINT")
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Store_Title")
    self._textAutomatic.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Store_Tips")
    self:AddListener(
        self._btnHelp.onClick,
        function()
            UIMgr:Open("VIPTips", true)
        end
    )
    self:AddListener(
        self._btnGet.onClick,
        function()
            if VIPModel.ItemEnoughToUpgrade(vipInfo) then
                UIMgr:Open("VIPLevelPopup", vipInfo)
            else
                Net.Vip.GetVipInfo(
                    function(msg)
                        UIMgr:Open("VIPActivation", 2, vipInfo.VipLevel, msg)
                    end
                )
            end
        end
    )
    self:AddListener(
        self._actvityVipBtn.onClick,
        function()
            Net.Vip.GetVipInfo(
                function(msg)
                    UIMgr:Open("VIPActivation", 3, vipInfo.VipLevel, msg)
                end
            )
        end
    )

    self.btnGetEffectPanel = UIMgr:CreateObject("Common", "Guide")
    self._btnGet:AddChild(self.btnGetEffectPanel)
    self.btnGetEffectPanel:SetPivot(0.5, 0.5)
    self.btnGetEffectPanel:SetXY(-38, -100)
    self.btnGetEffectPanel:SetGuideScale(0.8)
    self.btnGetEffectPanel:PlayLoop()
    self.btnGetEffectPanel:SetShow(false)
    self:InitEvent()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.VipMain)
end

function VIPShopping:SetDetailItem(item)
    self.detailTipItem = item
end

function VIPShopping:InitEvent()
    self:AddListener(
        self._btnReturn.onClick,
        function()
            self:Close()
        end
    )

    self._listView.itemRenderer = function(index, item)
        if not index then
            return
        end
        item:SetData(self.itemsInfo[index + 1], self)
    end
    self._listView:SetVirtual()

    self:AddListener(
        self._listView.onTouchBegin,
        function()
            self.touchBeginPos = self._listView.scrollPane.posY
        end
    )

    self:AddListener(
        self._listView.onTouchMove,
        function()
            if self.detailTipItem then
                local currPos = self._listView.scrollPane.posY
                if math.abs(currPos - self.touchBeginPos) > 10 then -- 防止手滑
                    self.detailTipItem:HideTip()
                end
            end
        end
    )

    self.callback = function()
        if self.refreshVipItems then
            -- vip升级后刷新道具状态，为了保证Model先更新故放在计时器里刷新
            self:RefreshListView()
            self.refreshVipItems = false
        end
        if not self._endTime then
            return
        end
        local time = self._endTime - Tool.Time()
        if time <= 0 then
            self:UnSchedule(self.callback)
            self:Close()
            Net.Vip.GetVipInfo(
                function(msg)
                    UIMgr:Open("VIPMain", msg)
                end
            )
            return
        end
        self._textTagName.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Store_Time", {countdown_time = TimeUtil.SecondToDHMS(time)})
    end

    self:AddEvent(
        SHOPEVENT.VipBuyEvent,
        function(Id, choiceNum)
            for _, v in ipairs(self.itemsInfo) do
                if v.VipGoods.Id == Id then
                    v.VipGoods.Amount = v.VipGoods.Amount - choiceNum
                    break
                end
            end
            self:RefreshListView()
        end
    )

    self:AddEvent(
        EventDefines.UIVipInfo,
        function(rsp)
            vipInfo = rsp
            self.refreshVipItems = true
        end
    )

    self:AddEvent(
        EventDefines.VipPointsChange,
        function()
            self:RefreshData()
        end
    )
end

function VIPShopping:OnOpen()
    Net.Vip.GetVipInfo(
        function(Info)
            Net.VipShop.GetGoodsList(
                function(msg)
                    SdkModel.TrackBreakPoint(10032) --打点

                    --Vip商城打点
                    Net.UserInfo.RecordLog(
                        4205,
                        "",
                        function(rsp)
                        end
                    )

                    self._endTime = msg.NextRefreshAt
                    self.itemsInfo = msg.GoodsList
                    self:SortItemInfos()
                    self.hasGetGoodsInfo = false
                    -- CommonModel.SetUserAvatar(self._icon) --设置VIP头像
                    self._icon:SetAvatar({Avatar = Model.User.Avatar, DressUpUsing = DressUpModel.usingDressUp})

                    -- self.callback()
                    if not self._scheduler then
                        self:Schedule(self.callback, self.dt)
                        self._scheduler = true
                        self.callback()
                    end

                    self:RefreshListView()
                    self._listView.scrollPane:ScrollTop()

                    vipInfo = Info

                    self:RefreshData()
                end
            )
        end
    )
end

function VIPShopping:RefreshData()
    self._textVIPNum.text = vipInfo.VipLevel --VIP等级
    if vipInfo.VipIsActivated == true then --VIP是否开启
        -- self._iconVIP.grayed = false
        -- self._textVIPNum.grayed = false
        self._controller.selectedIndex = 0
        self._textExplain.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text1")
        self:Reset(vipInfo.ExpirationTime) --如果开启，显示剩余时间
    else
        -- self._iconVIP.grayed = true
        -- self._textVIPNum.grayed = true
        self._controller.selectedIndex = 1
        self._textExplain.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text4")
    end
    if VIPModel.ItemEnoughToUpgrade(vipInfo) then --当前积分可提升等级提示
        if vipInfo.VipPoints >= 240000 then
            self._upLevelText.visible = false
        else
            self._upLevelText.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text5")
        end
    else
        self._upLevelText.visible = false
    end
    local conf = ConfigMgr.GetList("configVips")
    local list, point = VIPModel.GetLevelPropByConf(vipInfo.VipLevel, conf)
    local list1, point1 = VIPModel.GetLevelPropByConf(vipInfo.VipLevel + 1, conf)
    if vipInfo.VipLevel == VIPModel.GetMaxVipLevel() then
        self._progressBar2.value = 100 --积分条比例
        self._progressBar2:GetChild("title").text = vipInfo.VipPoints --积分条数值
        self._textVIPLevel.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text2", {vip_level = vipInfo.VipLevel - 1})
        self._textVIPLevelNum.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text3", {vip_upgrade_point = 120000})
        self._textVIPNext.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text2", {vip_level = vipInfo.VipLevel})
        self._textVIPNextNum.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text3", {vip_upgrade_point = point})
    else
        self._progressBar2.value = (vipInfo.VipPoints - point) / (point1 - point) * 100 --积分条比例
        self._progressBar2:GetChild("title").text = vipInfo.VipPoints --积分条数值
        self._textVIPLevel.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text2", {vip_level = vipInfo.VipLevel}) --滑动条左端数值
        self._textVIPLevelNum.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text3", {vip_upgrade_point = point}) --滑动条左端积分
        self._textVIPNext.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text2", {vip_level = vipInfo.VipLevel + 1}) --滑动条右端数值
        self._textVIPNextNum.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Text3", {vip_upgrade_point = point1}) --滑动条右端积分
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

function VIPShopping:RefreshListView()
    self._listView.numItems = #self.itemsInfo
end

function VIPShopping:Close()
    UIMgr:Close("VIPShopping")
end

function VIPShopping:OnClose()
    self:UnSchedule(self.callback)
    self._scheduler = false
end

function VIPShopping:OnClose()
    self:UnSchedule(self.callback)
    self._scheduler = false
end
function VIPShopping:Reset(timeNum)
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
    -- if timeNum == Tool.Time() then
    --     -- self._textExplain.visible = false
    -- end
    local mCtimeFunc = function()
        return timeNum - Tool.Time()
    end
    local ctime = mCtimeFunc()
    if ctime > 0 then
        -- self._textExplain.visible = true
        local bar_func = function(t)
            self._textVIPPoint.text = Tool.FormatTime(t)
        end
        bar_func(ctime)
        self.cd_func = function()
            ctime = mCtimeFunc()
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

function VIPShopping:isHavePointProp()
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

function VIPShopping:CheckBtnGetEffectPanel()
    local show = VIPModel.ItemEnoughToUpgrade(vipInfo)
    local text = show and "BUTTON_UPGRADE_VIP" or "BUTTON_POINT"
    self.btnGetEffectPanel:SetShow(show)
    self._btnGet:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, text)
end

function VIPShopping:SortItemInfos()
    if not self.itemsInfo then
        return
    end
    table.sort(
        self.itemsInfo,
        function(a, b)
            return a.VipGoods.Id < b.VipGoods.Id
        end
    )
end
return VIPShopping
