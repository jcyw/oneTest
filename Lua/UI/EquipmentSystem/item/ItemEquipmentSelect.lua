local Tool = _G.Tool
local BuildModel = _G.BuildModel
local EquipModel = _G.EquipModel

local ItemEquipmentSelect = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://EquipmentSystem/itemEquipmentSelect", ItemEquipmentSelect)
function ItemEquipmentSelect:ctor()
    --获取部件
    self.itemEquip = self:GetChild("itemEquip")
    self._textName = self:GetChild("textName")
    self._textLack = self:GetChild("textLack")
    self._progressBar = self:GetChild("_progressBar")
    self._textProgress = self:GetChild("_textProgress")
    self._btnView = self:GetChild("btnView")
    self._btnView1 = self:GetChild("btnView1")

    --控制器
    self._obtainCtr = self:GetController("c1") --控制是否交易

    -- 回调以及回调参数
    self._callback = nil
    self._callbackData = nil

    --获取属性列表组件
    self.itemAttack = {}
    for i = 1,4 do
        self.itemAttack[i] = self:GetChild("itemAttack"..i)
    end
    --是否能收取装备
    self.isTakeEquip = false

    --事件
    self:AddListener(self._btnView.onClick,
        function()
            if self.isTakeEquip then
                self:Taketequip()
            else
                self._callback(self._callbackData)
            end
        end
    )
    self:AddListener(self._btnView1.onClick,
        function()
            local isLowMaterial=self.triggerFunc and true or false
            if self.isTakeEquip then
                self:Taketequip()
            else
                self._callback(self._callbackData,isLowMaterial)
            end
            if self.triggerFunc then
                self.triggerFunc()
            end
        end
    )
    self._btnView.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "FUND_VIEW_BUTTON")
    self._btnView1.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "equip_btn_1")

end
--[[
    data.callbackData 回调参数
    data.callback 回调
    data.quality 装备品质
    data.icon 装备icon
    data.name 装备名字
    data.level 装备等级
    data.buff.att_name[i] buff名字
    data.buff.buff_values[i] buff值
    data.obtainAble 是否能交易
    data.isObtaining 是否正在交易
    data.Duration 装备交易总时长
    data.FinishAt 装备交易结束时间

]]
function ItemEquipmentSelect:SetData(data)
    if not data then
        return
    end
    self.isTakeEquip = false
    self._callbackData = data.callbackData
    self._callback = data.callback
    self._textName.text = ("%s Lv.%d"):format(_G.StringUtil.GetI18n("configI18nEquips", data.name),data.level)
    self.itemEquip:SetData(data.icon,data.quality-1,("Lv.%d"):format(data.level))
    if data.obtainAble then
        self._textLack.visible = false
        if data.isObtaining then
            self._btnView.visible = true
            self._btnView1.visible = false
        else
            self._btnView.visible = false
            self._btnView1.visible = true
        end
    else
        self._textLack.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "equip_ui_6_2")
        self._textLack.visible = true
        self._btnView.visible = true
        self._btnView1.visible = false
    end
    self._btnView.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "FUND_VIEW_BUTTON")
    self.Uuid = data.Uuid

    for i = 1,#self.itemAttack do
        if data.buff and data.buff.att_name
            and data.buff.buff_values and data.buff.att_name[i]
            and data.buff.buff_values[i] then
            local buffvalue = ("+ %.2f"):format(data.buff.buff_values[i]/100).."%"
            self.itemAttack[i].visible = true
            self.itemAttack[i]:SetData(data.buff.att_name[i],buffvalue,1)
        else
            self.itemAttack[i].visible = false
        end
    end

    self._obtainCtr.selectedIndex = data.isObtaining and 1 or 0
    --时间刷新
    if self.schedule_time then
        self:UnSchedule(self.schedule_time)
    end
    if data.isObtaining then
        self._progressBar.max = data.Duration
        local function time_func()
            return data.FinishAt - Tool.Time()
        end
        self.schedule_time = function()
            local t = time_func()
            if t >= 0 then
                self._textProgress.text = Tool.FormatTime(t)
                self._progressBar.value = data.Duration - t
            else
                self._btnView.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_Get")
                self._textProgress.text = Tool.FormatTime(0)
                self._progressBar.value = data.Duration
                self.isTakeEquip = true
                self:UnSchedule(self.schedule_time)
            end
        end
        self:Schedule(self.schedule_time, 1)
    end
end
function ItemEquipmentSelect:Taketequip()

    if self.Uuid then
        EquipModel.Taketequip(self.Uuid,nil)
    end
end

function ItemEquipmentSelect:TriggerOnclick(callback)
    self.triggerFunc = callback
end

return ItemEquipmentSelect