--[[
    author:Temmie
    time:2020-06-12
    function:装备材料显示小item
]]
local GD = _G.GD
local ItemEquipTransaction = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://EquipmentSystem/itemEquipTransaction", ItemEquipTransaction)

function ItemEquipTransaction:ctor()
    self._typeController = self:GetController("c1")
    self._iconAnim = self:GetTransition("iconAnim")
    self._iconLock = self:GetChild("iconLockequip")
    self._iconYes = self:GetChild("iconYes")
    self._btnGet.text = StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_ForcesUp_HowGet")
    self.timeFunc = function()
        local time = self.finish - _G.Tool.Time()
        if time > 0 then
            self._textTime.text = _G.TimeUtil.SecondToHMS(time)
        else
            self:UnSchedule(self.timeFunc)
        end
    end

    self.onClickFunc = function()
        if self.triggerFunc then
            self.triggerFunc()
        end
        if self.onClickCB then
            self.onClickCB(self.onClickData)
        end
    end

    self.onDelClickFunc = function()
        if self.onDelClickCB then
            self.onDelClickCB()
        end
    end

    self.onBottomClickFunc = function()
        if self.onBottomClickCB then
            self.onBottomClickCB(self.cbData)
        end
    end

    self.onDropFunc = function()
        if self.onDropCB then
            self.onDropCB()
        end
    end

    self.onRollOverFunc = function()
        if self.onRollOverCB then
            self.onRollOverCB()
        end
    end

    self.onRollOutFunc = function()
        if self.onRollOutCB then
            self.onRollOutCB()
        end
    end

end

function ItemEquipTransaction:Init()
    self._iconBg.url = GD.ItemAgent.GetItmeQualityByColor(0)
    self._icon.url = nil
    self._typeController.selectedIndex = 4
    self._iconAnim:Stop()
    self.finish = 0

    self:RemoveListener(self.onClick, self.onClickFunc)
    self:RemoveListener(self._btnDel.onClick, self.onDelClickFunc)
    self:RemoveListener(self._btnGet.onClick, self.onBottomClickFunc)
    self:RemoveListener(self.onDrop, self.onDropCB)

    if self.timeFunc then
        self:UnSchedule(self.timeFunc)
    end
end

function ItemEquipTransaction:SetType(type)
    self._typeController.selectedIndex = type
end

function ItemEquipTransaction:GetType()
    return self._typeController.selectedIndex
end

function ItemEquipTransaction:SetIcon(icon)
    self._icon.url = UITool.GetIcon(icon, self._icon)
end

function ItemEquipTransaction:SetQuality(quality)
    self._iconBg.url = GD.ItemAgent.GetItmeQualityByColor(quality)
end

function ItemEquipTransaction:SetTitle(text)
    self._textTitle.text = text
end

function ItemEquipTransaction:SetNum(text)
    self._textNum.text = text
    if text and text ~= "" then
        self._textBg.visible = true
    else
        self._textBg.visible = false
    end
end

function ItemEquipTransaction:SetTime(finish)
    self.finish = finish
    self:Schedule(self.timeFunc, 1)
end

function ItemEquipTransaction:SetOnClick(cb,cbdata)
    self.onClickCB = cb
    self.onClickData = cbdata
    self:AddListener(self.onClick, self.onClickFunc)
end

function ItemEquipTransaction:SetBtnDelOnClick(cb)
    self.onDelClickCB = cb
    self:AddListener(self._btnDel.onClick, self.onDelClickFunc)
end

function ItemEquipTransaction:SetBtnGetOnClick(cb,cbData)
    self.onBottomClickCB = cb
    self.cbData = cbData
    self:AddListener(self._btnGet.onClick, self.onBottomClickFunc)
end

function ItemEquipTransaction:SetLockAndPut(isput, islock)
    self._iconLock.visible = islock
    self._iconYes.visible = isput
end

function ItemEquipTransaction:SetOnDrop(cb)
    self.onDropCB = cb
    self:AddListener(self.onDrop, self.onDropFunc)
end

function ItemEquipTransaction:SetOnRollOver(cb)
    self.onRollOverCB = cb
    self:AddListener(self.onRollOver, self.onRollOverFunc)
end

function ItemEquipTransaction:SetOnRollOut(cb)
    self.onRollOutCB = cb
    self:AddListener(self.onRollOut, self.onRollOutFunc)
end

function ItemEquipTransaction:TriggerOnclick(callback)
    self.triggerFunc = callback
end

function ItemEquipTransaction:PlayIconAnim()
    self._iconAnim:Play()
end

return ItemEquipTransaction
