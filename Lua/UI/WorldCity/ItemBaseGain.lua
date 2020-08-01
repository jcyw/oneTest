local GD = _G.GD
local ItemBaseGain = fgui.extension_class(GComponent)
fgui.register_extension("ui://WorldCity/BaseGain_liebiaoItem", ItemBaseGain)

local BuffItemModel = import("Model/BuffItemModel")

local barHeight = 160
local itemHeight = 148

function ItemBaseGain:ctor()
    self.isClick = false
    self.itemNum = 0
    self._itemDown = self:GetChild("itemDown")
    self._itemBar = self:GetChild("itemBar")
    self._icon = self._itemBar:GetChild("icon")
    self._txtName = self._itemBar:GetChild("title")
    self._txtDesc = self._itemBar:GetChild("text")
    self._timeBar = self._itemBar:GetChild("progressBar")
    self._txtTime = self._itemBar:GetChild("textTime")
    self._list = self._itemDown:GetChild("liebiao")
    -- self._boxBg = self._itemDown:GetChild("box")
    self._arrow = self._itemBar:GetChild("btnArrow")
    self._btnBg = self._itemBar:GetChild("btnBg")

    self:AddListener(self._btnBg.onClick,function()
        if self.isClick then
            self.isClick = false
            self.height = barHeight
            self._itemDown.visible = false
            self._arrow.rotation = 180
        else
            self.isClick = true
            self.height = (self.itemNum * (itemHeight + 4)) + barHeight
            self._itemDown.visible = true
            self._arrow.rotation = -90
        end
    end)
end

function ItemBaseGain:Init(buffId, configDatas)
    self.height = barHeight
    self.buffId = buffId
    self.configDatas = configDatas
    self.buffConfig = ConfigMgr.GetItem("configAttributes", buffId)
    self._arrow.rotation = 180
    self._itemDown.visible = false
    self._txtName.text = ConfigMgr.GetI18n("configI18nCommons", "Main_Buff_Name_"..buffId)
    self._txtDesc.text = ConfigMgr.GetI18n("configI18nCommons", "Main_Buff_Desc_"..buffId)
    self._icon.url = UITool.GetIcon(self.buffConfig.img)
    
    self:RefreshTimeBar()
    self:RefreshList()
end

function ItemBaseGain:RefreshList()
    self.itemNum = 0
    self._list:RemoveChildrenToPool()
    for k,v in pairs(self.configDatas) do
        local model = GD.ItemAgent.GetItemModelById(v.item.id)
        if (model ~= nil and model.Amount > 0) or v.mainBuff.buy == 1 then
            local item = self._list:AddItemFromPool()
            item:Init(v.item, function()
                self:RefreshTimeBar()
                self:RefreshList()
            end)
            self.itemNum = self.itemNum+1
        end
    end

    self._list:ResizeToFit(self.itemNum)
    -- self._boxBg.height = self.itemNum*143
end

function ItemBaseGain:RefreshTimeBar()
    if self.schedule_funtion then
        self:UnSchedule(self.schedule_funtion)
    end

    local model
    local finishAt = 0
    local startAt = 0
    if self.buffId == PropType.SUBTYPE.CityProtect then
        model = BuffItemModel.GetModelByConfigId(self.buffId)
        if model ~= nil and model.ExpireAt > Model.ServerShield then
            finishAt = model.ExpireAt
            startAt = model.StartAt
        else
            finishAt = Model.ServerShield
            startAt = Model.ServerShieldStart
        end
    else
        model = BuffItemModel.GetModelByIdType(self.buffId, Global.TypedBuffItem)
        if model ~= nil and model.Source == Global.TypedBuffItem then
            finishAt = model.ExpireAt
            startAt = model.StartAt
        end
    end
    local t = Tool.Time()
    if finishAt > Tool.Time() then
        self:SetEffect(true)
        self._timeBar.visible = true
        local total = finishAt - startAt
        local ct = finishAt - Tool.Time()
        self.schedule_funtion = function()
            ct = ct - 1
            if ct >= 0 then
                self._timeBar.value = (ct / total)*100
                self._txtTime.text = StringUtil.GetI18n(I18nType.Commmon,"UI_ACTIVITY_OVER_TIME", {time = Tool.FormatTime(ct)})
            else
                self:SetEffect(false)
                self._txtTime.text = ""
                self._timeBar.visible = false
                self:RefreshList()
                if self.schedule_funtion then
                    self:UnSchedule(self.schedule_funtion)
                end
            end
        end
        self.schedule_funtion()
        self:Schedule(self.schedule_funtion, 1)
    else
        self._txtTime.text = ""
        self:SetEffect(false)
        self._timeBar.visible = false
    end
end

function ItemBaseGain:SetEffect(flag)
    if flag then
        if self.effect == nil then
            self.effect = UIMgr:CreateObject("Effect", "EmptyNode")
            self.effect.xy = Vector2(-4, -2)
            self._itemBar:AddChild(self.effect)
            DynamicRes.GetBundle("effect_collect", function()
                DynamicRes.GetPrefab("effect_collect", "effect_base_gain", function(prefab)
                    local object = GameObject.Instantiate(prefab)
                    self.effect:GetGGraph():SetNativeObject(GoWrapper(object))
                end)
            end)
        end
    else
        if self.effect then
            self.effect:Dispose()
            self.effect = nil
        end
    end
end

return ItemBaseGain