--author: 	Amu
--time:		2019-07-02 14:00:06
local GD = _G.GD
local ItemUnionTaskActive = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionTaskActive", ItemUnionTaskActive)

function ItemUnionTaskActive:ctor()
    self._textName = self:GetChild("textName")
    self._textAlliesLogin = self:GetChild("textAlliesLogin")
    self._textAlliesLoginNum = self:GetChild("textAlliesLoginNum")
    self._ProgressBar = self:GetChild("ProgressBar")

    self._btnMin = self:GetChild("btnMin")
    self._btnMax = self:GetChild("btnMax")

    self._minX = self._btnMin.x
    self.tempList = {}

    self:InitEvent()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.UnionTaskList)
end

function ItemUnionTaskActive:InitEvent()
end

function ItemUnionTaskActive:SetData(info, activeCount, claimedActive)
    self._info = info

    self._minNum = info[1].target
    self._maxNum = info[#info].target

    activeCount = activeCount and activeCount or 0
    claimedActive = claimedActive and claimedActive or {}

    self._textAlliesLoginNum.text = string.format( "%d/%d", activeCount, self._maxNum)

    self._ProgressBar.value = activeCount/self._maxNum*100

    self._textName.text = ConfigMgr.GetI18n("configI18nCommons", info[1].name)
    self._textAlliesLogin.text = ConfigMgr.GetI18n("configI18nCommons", info[1].task_name)

    self:RefreshItem(activeCount, claimedActive)
end

function ItemUnionTaskActive:RefreshItem(activeCount, claimedActive)
    local index = 1
    local state
    for _,v in ipairs(self._info)do
        if v.target > activeCount then
            state = RECEIVE_STATE.CantReceive
        else
            state = RECEIVE_STATE.CanReceive
        end
        for _,id in pairs(claimedActive)do
            if v.id == id then
                state = RECEIVE_STATE.HavaReceive
            end
        end
        if v.target == self._minNum then
            self._btnMin:SetData(v, state)
            self._btnMin.x = self._minX + (v.target/self._maxNum)*( self._btnMax.x-self._minX)
        elseif v.target == self._maxNum then
            self._btnMax:SetData(v, state)
        else
            if not self.tempList[index] then
                local temp = UIMgr:CreateObject("Union", "btnUnionTaskActive")
                self:AddChild(temp)
                self.tempList[index] = temp
            end
            self.tempList[index].x = self._minX + (v.target/self._maxNum)*( self._btnMax.x-self._minX)
            self.tempList[index].y = self._btnMin.y
            self.tempList[index]:SetData(v, state)
            index = index + 1
        end
    end
end

return ItemUnionTaskActive