--[[
    Author: songzeming
    Function: 确认弹窗 一键使用道具 通用
]]
local GD = _G.GD
local ConfirmPopup = UIMgr:NewUI("ConfirmPopup")

local BuildModel = import("Model/BuildModel")
local CommonModel = import("Model/CommonModel")
local PropModel = import("Model/PropModel")
local CONTROLLER = {Single = "Single", Double = "Double"}
local RowController = {"Three", "Six", "Nine"}
function ConfirmPopup:OnInit()
    local view = self.Controller.contentPane
    self._controller = view:GetController("Controller")
    self._rowController = view:GetController("RowController")
    self:AddListener(self._btnSureSingle.onClick,
        function()
            self:OnBtnSureClick()
        end
    )
    self:AddListener(self._btnSureDouble.onClick,
        function()
            self:OnBtnSureClick()
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnCancel.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
end

--[[
    data = {
        type = "Single" / "Double" 默认"Single" 可不传
        from = "PropDirUse"道具一键加速 其他自定义
    }
]]
function ConfirmPopup:OnOpen(data)
    self.from = data.from or nil
    if data.type and data.type == "Double" then
        self._controller.selectedPage = CONTROLLER.Double
    else
        self._controller.selectedPage = CONTROLLER.Single
    end

    if self.from == "PropDirUse" then
        self:OnPropDirUse(data)
    end
end

function ConfirmPopup:Close()
    UIMgr:Close("ConfirmPopup")
end

--点击确定按钮
function ConfirmPopup:OnBtnSureClick()
    if self.from == "PropDirUse" then
        self:ClickUse()
    end
end

------------------------------------------------------ 道具一键加速
function ConfirmPopup:OnPropDirUse(data)
    self.cb = data.callback
    self.event = data.event

    self.goalItem = PropModel.GetAccItemsByCategory(self.event.Category, data.confId)
    self.commonItem = PropModel.GetCommonAccItems()

    self._list.numItems = 0
    self.isMore = false --道具时间是否远大于加速时间
    self.isNotEnough = false --道具时间是否不足完成加速时间
    self._text.text = StringUtil.GetI18n(I18nType.Commmon, "Speedup_Prop")
    self:Recommend()
end

function ConfirmPopup:CloseFunc(data)
    UIMgr:Close("ConfirmPopup")
    if self.cb then
        self.cb(data)
    end
end

function ConfirmPopup:useDataHandle(data,RecommendTable)
    local use
    local tempObj
    for k, v in pairs(data) do
        tempObj = RecommendTable[v.value]
        if(tempObj)then
            if(v.Amount >= tempObj)then
                use = {ConfId = v.ConfId, Amount = tempObj, value = v.value}
                table.insert(self.uses, use)
                RecommendTable[v.value] =  nil
            else
                use = {ConfId = v.ConfId, Amount = v.Amount, value = v.value}
                tempObj = tempObj - v.Amount
                table.insert(self.uses, use)
                RecommendTable[v.value] =  tempObj
            end
        end
    end
end

-- 根据时间推荐道具
function ConfirmPopup:Recommend()
    local accTime = self.event.FinishAt - Tool.Time()
    if BuildModel.FreeState(self.event.Category) then
        accTime = accTime - CommonModel.FreeTime()
    end
    self.uses ={}
    self.items = Tool.MergeTables(self.commonItem,self.goalItem)
    table.sort(
            self.items,
        function(a, b)
            return a.value*a.ConfId > b.value*b.ConfId
        end
    )
    local RecommendTable = PropModel.OnPropDirUseRecommend(self.items,accTime)
    self.accTime = accTime
    self:useDataHandle(self.items,RecommendTable)
    
    self:Show()
    ---- [小于]目标道具单独使用
    --local gLessItem = {} -- 道具时间 [小于] 需要加速的时间
    --local gMoreItem = {} -- 道具时间 [大于] 需要加速的时间
    --for _, v in ipairs(self.goalItem) do
    --    local isLess = v.value <= 5 * 60 or v.value <= accTime
    --    table.insert(isLess and gLessItem or gMoreItem, v)
    --end
    --table.sort(
    --    gLessItem,
    --    function(a, b)
    --        return a.value > b.value
    --    end
    --)
    --local glData = self:CheckItems(gLessItem, accTime)
    --if glData.SyTime == 0 then
    --    self.uses = glData.Uses
    --    self:Show()
    --    return
    --end
    ---- [小于]目标道具和通用道具组合使用(包括目标道具没有的情况)
    --local gcLessItem = {} -- 道具时间 [小于] 需要加速的时间
    --local gcMoreItem = {} -- 道具时间 [大于] 需要加速的时间
    --for _, v in ipairs(self.commonItem) do
    --    local isLess = v.value <= 5 * 60 or v.value <= glData.SyTime
    --    table.insert(isLess and gcLessItem or gcMoreItem, v)
    --end
    --table.sort(
    --    gcLessItem,
    --    function(a, b)
    --        return a.value > b.value
    --    end
    --)
    --local gclData = self:CheckItems(gcLessItem, glData.SyTime)
    --if gclData.SyTime == 0 then
    --    self.uses = Tool.MergeTables(glData.Uses, gclData.Uses)
    --    self:Show()
    --    return
    --end
    ---- [大于]目标道具和通用道具都不满足条件
    ---- [大于]目标道具单独使用
    --local gAllItem = Tool.MergeTables(gMoreItem, gLessItem)
    --table.sort(
    --    gAllItem,
    --    function(a, b)
    --        return a.value > b.value
    --    end
    --)
    --local gmData = self:CheckItems(gAllItem, accTime, true)
    --if gmData.SyTime == 0 then
    --    if PropModel.CheckFarTime(gmData.SyTime, accTime) then
    --        self:FarTip()
    --        return
    --    else
    --        self.uses = gmData.Uses
    --        self:Show()
    --        self.accTime = accTime
    --        self.isMore = true
    --        return
    --    end
    --end
    ---- [大于]目标道具和通用道具组合使用(包括目标道具没有的情况)
    --local gcAllItem = Tool.MergeTables(gcMoreItem, gcLessItem)
    --table.sort(
    --    gcAllItem,
    --    function(a, b)
    --        return a.value > b.value
    --    end
    --)
    --local gcmData = self:CheckItems(gcAllItem, gmData.SyTime, true)
    --if gcmData.SyTime == 0 then
    --    if PropModel.CheckFarTime(gcmData.SyTime, gmData.SyTime) then
    --        self:FarTip()
    --        return
    --    else
    --        self.uses = Tool.MergeTables(gmData.Uses, gcmData.Uses)
    --        self:Show()
    --        self.accTime = gmData.SyTime
    --        self.isMore = true
    --        return
    --    end
    --end
    --
    ---- [不足]道具时间不足完成加速时间
    --self:SortAmount()
    --self.uses = Tool.MergeTables(self.goalItem, self.commonItem)
    --local delTime = 0
    --for _, v in pairs(self.uses) do
    --    delTime = delTime + v.value * v.Amount
    --end
    --self.isNotEnough = true
    --self.resetTime = accTime - delTime
    --local values = {
    --    rest_time = Tool.FormatTimeCN(self.resetTime)
    --}
    --self._text.text = StringUtil.GetI18n(I18nType.Commmon, "Time_Not_Enough", values)
    --self:Show()
end

function ConfirmPopup:SortAmount()
    table.sort(
        self.goalItem,
        function(a, b)
            return a.value < b.value
        end
    )
    table.sort(
        self.commonItem,
        function(a, b)
            return a.value < b.value
        end
    )
end

-- 检查单独类型道具是否满足条件
function ConfirmPopup:CheckItems(items, time, M)
    local uses = {}
    for _, v in ipairs(items) do
        local amount = self:CheckItem(v, time, M)
        if amount > 0 then
            time = time - v.value * amount
            local use = {ConfId = v.ConfId, Amount = amount, value = v.value}
            table.insert(uses, use)
            if time <= 0 then
                return {SyTime = 0, Uses = uses}
            end
        end
    end
    return {SyTime = time, Uses = uses}
end

-- 检查单个道具使用情况
function ConfirmPopup:CheckItem(item, time, M)
    for i = 1, item.Amount do
        if item.value <= 5 * 60 then
            if (item.value * i >= time) then
                return i
            end
        else
            if (item.value * i >= time) then
                local index = M and i or (i - 1)
                return index
            end
        end
    end
    return item.Amount
end

function ConfirmPopup:Show()
    self._list.numItems = #self.uses
    self._rowController.selectedPage = RowController[math.floor((#self.uses-1)/3+1)]
    local tTime = 0
    for k, v in pairs(self.uses) do
        tTime = tTime + v.value * v.Amount
        local node = self._list:GetChildAt(k - 1)
        local confItem = ConfigMgr.GetItem("configItems", v.ConfId)
        local title = GD.ItemAgent.GetItemNameByConfId(v.ConfId)
        node:SetChoose(false)
        node:SetAmount(confItem.icon, confItem.color, v.Amount, title)
    end
    self.totalTime = tTime
    self.isMore = PropModel.CheckFarTime(self.totalTime, self.accTime)
    self._list.scrollPane.touchEffect = self._list.scrollPane.contentHeight > self._list.height
end

function ConfirmPopup:ClickUse()
    local use_func = function()
        local data = {}
        for _, v in pairs(self.uses) do
            local item = {ConfId = v.ConfId, Amount = v.Amount}
            table.insert(data, item)
        end
        Net.Events.SpeedupByItem(
            self.event.Category,
            self.event.Uuid,
            data,
            function(rsp)
                self:CloseFunc(rsp)
            end
        )
    end
    -- 道具时间不足完成加速时间
    -- if self.isNotEnough then
    --     local values = {
    --         rest_time = Tool.FormatTimeCN(self.resetTime)
    --     }
    --     local data = {
    --         content = StringUtil.GetI18n(I18nType.Commmon, "Time_Not_Enough", values),
    --         sureCallback = use_func
    --     }
    --     UIMgr:Open("ConfirmPopupText", data)
    --     return
    -- end
    -- 道具时间远大于加速时间
    if self.isMore then
        local values = {
            minute = math.floor((self.totalTime - self.accTime) / 60)
        }
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Ui_OverTime", values),
            sureCallback = use_func
        }
        UIMgr:Open("ConfirmPopupText", data)
        return
    end
    -- 道具使用提示
    use_func()
end

function ConfirmPopup:FarTip()
    TipUtil.TipById(50107)
end

return ConfirmPopup
