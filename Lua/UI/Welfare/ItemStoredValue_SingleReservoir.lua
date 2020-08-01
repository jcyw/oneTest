--[[
    author:{maxiaolong}
    time:2019-10-15 16:50:49
    function:{存储奖励列表组件}
]]
local ItemStoredValue_SingleReservoir = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemStoredValue_SingleReservoir", ItemStoredValue_SingleReservoir)
local WelfareModel = import("Model/WelfareModel")
local maxRank = 6
function ItemStoredValue_SingleReservoir:ctor()
    self._listView = self:GetChild("liebiao")
    self._btnGet = self:GetChild("btnGet")
    self._btnRecevie = self:GetChild("btnReceive")
    self._btnDraw = self:GetChild("btnDraw")
    self._controller = self:GetController("c1")
    self._title = self:GetChild("title")
    self._btnRecevie:GetChild("title").text = "前往"
    self._btnDraw:GetChild("title").text =StringUtil.GetI18n(I18nType.Commmon,"ShootingReward_39")
    self._btnGet:GetChild("title").text = "领取"
    self._textTime = self:GetChild("textTime")
    self._textNum = self:GetChild("textNum")
    self._listView.itemRenderer = function(index, item)
        local icon = WelfareModel.DicKeyByIndex(index + 1, self.itemDatas, true).icon
        local amount = WelfareModel.DicKeyByIndex(index + 1, self.itemDatas, false)
        item:SetData(icon, amount)
    end

    self:AddListener(self._btnRecevie.onClick,
        function()
            TipUtil.TipById(50259)
        end
    )
    self:AddListener(self._btnGet.onClick,
        function()
            self:SetStateReceive()
        end
    )
end

--设置列表元素 config 为table表
function ItemStoredValue_SingleReservoir:SetData(giftId, state, isResidue, indexId)
    self.indexId = indexId
    self.giftNum, self.itemDatas = WelfareModel:GetGiftInfoById(giftId,2)
    self._listView.numItems = self.giftNum
    state = tonumber(state)
    if state == 0 then --未领取
        self._controller.selectedIndex = 2
        self._textTime.visible = false
        self._textNum.visible = false
        if isResidue == true then
            self._textTime.visible = true
            self._textNum.visible = true
        end
    elseif state == 1 then --领取
        self._controller.selectedIndex = 1
    elseif state == 2 then --已经领取
        self._controller.selectedIndex = 0
    end
    self.stateId = state
end

--领取奖品
function ItemStoredValue_SingleReservoir.GetReceiveNetParam(activityId, indexId)
    Net.Activity.GetActivityAward(
        activityId,
        indexId,
        function(params)
            Event.Broadcast(EventDefines.RefreshStore, params)
        end
    )
end

function ItemStoredValue_SingleReservoir:SetStateReceive()
    local type = WelfareModel.GetCurentActivity()
    local activityId = 0
    if type == WelfareModel.WelfarePageType.EVERYTIMESTORE then
        activityId = WelfareModel.ActivityID.EVERYDAT
        self.GetReceiveNetParam(activityId, self.indexId)
    elseif type == WelfareModel.WelfarePageType.CONTINUESTORE then
        activityId = WelfareModel.ActivityID.CONTIUNE
        self.GetReceiveNetParam(activityId, self.indexId)
    elseif type == WelfareModel.WelfarePageType.INFINITYSTORE then
        activityId = WelfareModel.ActivityID.INFINITY
        self.GetReceiveNetParam(activityId, self.indexId)
    end
end

--TODO设置高度
function ItemStoredValue_SingleReservoir:SetHeight(config)
    local height = 0
    local row = config.listNum / maxRank
    row = row + 1
    self._listView.numItems = config.listNum
    local item = self._listView:GetChildAt(config.listNum)
    height = item.size.y * row
    self._listView.SetSize(self._listView.size.x, height)
end

return ItemStoredValue_SingleReservoir
