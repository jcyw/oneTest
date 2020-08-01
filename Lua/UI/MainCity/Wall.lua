--[[
    author:{zhanzhang}
    time:2019-06-12 16:46:48
    function:{城墙功能}
]]
local GD = _G.GD
local Wall = UIMgr:NewUI("Wall")
local RefreshFunc

local BuildModel = import("Model/BuildModel")

local WallFreeRepairCooldown = 0

function Wall:OnInit()
    -- body
    local view = self.Controller.contentPane
    self._btnReturn = view:GetChild("btnReturn")
    self._btnHelp = view:GetChild("btnHelp")
    self._textState = view:GetChild("textState")
    self._btnRepair = view:GetChild("btnRepair")
    self._btnDurability = view:GetChild("btnDurability")
    self._btnFireFighting = view:GetChild("btnFireFighting")
    self._putFirePrice = view:GetChild("btnFireFightingGray"):GetChild("text")
    self._progressBar = view:GetChild("progressBar")
    self._progressBarGreen = view:GetChild("progressBarGreen")
    self._textDurabilityNum = view:GetChild("textDurabilityNum")
    self._btnAddDefense = view:GetChild("btnAddDefense")

    self._controller = view:GetController("c1")
    self._buyIcon = self._btnRepair:GetChild("icon")
    self._itemNum = self._btnRepair:GetChild("text")
    self._addDenfenseVal = self._btnDurability:GetChild("text")

    WallFreeRepairCooldown = Global.WallFreeRepairCooldown

    self.RefreshFunc = function()
        self:RefreshTime()
    end
    self:OnRegister()
end

function Wall:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("Wall")
        end
    )
    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"), info = StringUtil.GetI18n(I18nType.Commmon, "Wall_Defense_Explain")}
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )
    self:AddListener(self._btnRepair.onClick,
        function()
            UIMgr:Open(
                "ConfirmPopupText",
                {
                    content = StringUtil.GetI18n(I18nType.Commmon, "Confirm_Use_Prop"),
                    titleText = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                    sureCallback = function()
                        self:RepairAll()
                    end
                }
            )
        end
    )
    self:AddListener(self._btnDurability.onClick,
        function()
            self:AddFirm()
        end
    )
    self:AddListener(self._btnFireFighting.onClick,
        function()
            self:OutFire()
        end
    )
    self:AddEvent(
        EventDefines.UIOnRefreshWall,
        function(rsp)
            self:OnRefresh()
        end
    )
    self:AddEvent(
        EventDefines.ItemAmount,
        function(rsp)
            if rsp.ConfId == Global.WallRepairItemId then
                local prop = GD.ItemAgent.GetItemModelById(Global.WallRepairItemId)
                if prop then
                    self._itemNum.text = "x" .. prop.Amount
                else
                    self._itemNum.text = "x0"
                end
            end
        end
    )

    local price = self._btnFireFighting:GetChild("text")
    price.text = Global.WallOutfireFee
    self._btnDurability.title = StringUtil.GetI18n(I18nType.Commmon, "Button_Add_Defense")
    self._putFirePrice.text = Global.WallOutfireFee
    self._addDenfenseVal.text = Global.WallFreeRepairDurable
    self.ItemConfig = ConfigMgr.GetItem("configItems", Global.WallRepairItemId)
end
--[[状态 
0 等待修理
1 等待灭火
2 没着火等待修理
3 没着火等待修理冷却
4 城墙完好
]]
function Wall:OnOpen()
    self._btnFireFighting:GetChild("text").text = Global.WallOutfireFee
    self._addDenfenseVal.text = Global.WallFreeRepairDurable
    self:OnRefresh()
end
function Wall:OnRefresh()
    local price = self._btnFireFighting:GetChild("text")
    price.text = Global.WallOutfireFee
    local info = BuildModel.FindByConfId(Global.BuildingWall)
    self.data = Model.GetMap(ModelType.Wall)
    -- self.configInfo = ConfigMgr.GetItem("configWalls", Global.BuildingWall + info.Level)
    self.BuildingId = info.Id
    local nowDurable = self.data.Durable - math.ceil((Tool.Time() - self.data.RefreshAt) / self.data.FireSpeed)
    if not self.data.IsOnFire then
        nowDurable = self.data.Durable
    end
    self.isDamaged = nowDurable < self.data.MaxDurable
    self._progressBar.max = 100
    self._progressBar.value = nowDurable / self.data.MaxDurable * 100
    self._textDurabilityNum.text = nowDurable .. "/" .. self.data.MaxDurable
    self._btnFireFighting.enabled = self.data.IsOnFire

    local prop = GD.ItemAgent.GetItemModelById(Global.WallRepairItemId)
    if prop then
        self._itemNum.text = "x" .. prop.Amount
    else
        self._itemNum.text = "x0"
    end
    -- local txt = StringUtil.GetI18n(I18nType.Commmon, "Button_Add_Defense")
    -- self._btnDurability.title = StringUtil.GetI18n(I18nType.Commmon, "Button_Add_Defense")

    self._buyIcon.icon = UITool.GetIcon({"icon", "item204028"})

    self:CheckStatus()
end

function Wall:SetController(index)
    self._controller.selectedIndex = index
    --设置Banner
    if index > 1 then
        self._banner.icon = UITool.GetIcon(GlobalBanner.BuildWallNormal)
    else
        --着火
        self._banner.icon = UITool.GetIcon(GlobalBanner.BuildWallFire)
    end
end

function Wall:CheckStatus()
    self:UnSchedule(self.RefreshFunc)
    local isCountDown = (self.data.FreeRepairAt + WallFreeRepairCooldown) < Tool.Time()

    --着火了
    if self.data.IsOnFire then
        self:SetController(isCountDown and 0 or 1)
        self._textLose.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Defense_Lost")
        self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Defense_Lost_Amount", {amount = self.data.FireSpeed})
    else
        self._textLose.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Add_Defense")
        self._textTime.text = ""
        self._textDescribe.text = StringUtil.GetI18n(I18nType.Commmon, "Wall_Defense_Damage")
        --没着火
        if self.isDamaged then
            self:SetController(isCountDown and 2 or 3)
        else
            self:SetController(4)
            self._progressBarGreen.value = 100
            self._progressBarGreen.max = 100
        end
    end
    self._btnAddDefense.enabled = isCountDown
    --按钮状态冷却完毕以及燃烧状态需要计时器
    if self.isDamaged or self.data.IsOnFire then
        self:Schedule(self.RefreshFunc, 1, true)
    end

    if not self.data.IsOnFire and not self.isDamaged then
        self._btnAddDefense.enabled = false
    end
end

--灭火
function Wall:OutFire()
    Net.Walls.Outfire(
        self.BuildingId,
        function(val)
            self.data = val
            Model.InitOtherInfo(ModelType.Wall, val)
            -- self:OnRefresh()
            Event.Broadcast(EventDefines.UIOnRefreshWall)
        end
    )
end

function Wall:RepairAll()
    local prop = GD.ItemAgent.GetItemModelById(Global.WallRepairItemId)
    if not prop or prop.Amount == 0 then
        UIMgr:Open("AccessWay", Global.GetmoreItemWallDefense)
        return
    end

    Net.Walls.RepairByItem(
        self.BuildingId,
        function(val)
            self.data.Durable = val.Durable
            self.data.FreeRepairAt = val.FreeRepairAt
            self.data.RefreshAt = val.RefreshAt
            self:OnRefresh()
        end
    )
end
--加固
function Wall:AddFirm()
    Net.Walls.RepairByFree(
        self.BuildingId,
        function(val)
            self.data.Durable = val.Durable
            self.data.FreeRepairAt = val.FreeRepairAt
            self.data.RefreshAt = val.RefreshAt
            self:OnRefresh()
        end
    )
end

function Wall:RefreshTime()
    --下次免费修复时间
    if (self.data.FreeRepairAt + WallFreeRepairCooldown > Tool.Time()) then
        self._btnAddDefense.title = TimeUtil.SecondToHMS(self.data.FreeRepairAt + WallFreeRepairCooldown - Tool.Time())
    end
    --燃烧时间
    local time = self.data.OnFireAt + self.data.Duration - Tool.Time()
    if (time > 0) and self.data.IsOnFire then
        self._textDescribe.text = StringUtil.GetI18n(I18nType.Commmon, "Wall_Defense_Burning", {Remain_Time = TimeUtil.SecondToHMS(time)})
        local nowDurable = self.data.Durable - math.ceil((Tool.Time() - self.data.RefreshAt) / self.data.FireSpeed)
        if nowDurable < 0 then
            nowDurable = 0
        end

        if self.showDurable ~= nowDurable then
            self.showDurable = nowDurable
            self._progressBar.value = nowDurable
            self._textDurabilityNum.text = nowDurable .. "/" .. self.data.MaxDurable
        end
        return
    end

    self._textDescribe.text = StringUtil.GetI18n(I18nType.Commmon, "Wall_Defense_Damage")
end

function Wall:OnClose()
    self:UnSchedule(self.RefreshFunc)
end

return Wall
