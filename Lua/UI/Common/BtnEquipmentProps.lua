local GD = _G.GD

local BtnEquipmentProps = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://Common/btnEquipmentProps", BtnEquipmentProps)
-- 品质
local QualityStatus = {
    [0] = "white",
    [1] = "green",
    [2] = "blue",
    [3] = "purple",
    [4] = "orange",
    [5] = "golden",
    [6] = "empty",
    [7] = "block"
}
-- 框是否被锁住
local ItemlockStatus = {
    lock = "lock",
    unlock = "unlock"
}
-- 框是否显示+
local ItemaddStatus = {
    hide = "hide",
    add = "add"
}
-- 框是否显示+
local ItemSmaalladdStatus = {
    hide = "hide",
    add = "add"
}
-- 左下角显示状态
local leftbottomStatus = {
    upgrade = "upgrade",
    pick = "pick",
    normalck = "normal"
}
-- 左上角小锁显示状态
local smallLockStatus = {
    lock = "lock",
    unlock = "unlock"
}
-- 金边框显示状态
local goldenBoxStatus = {
    normal = "normal",
    goldBox = "goldBox"
}
function BtnEquipmentProps:ctor()
    --获取部件
    self._icon = self:GetChild("icon")
    self._level = self:GetChild("level")
    self._textBg = self:GetChild("textBg")
    self._EquipQuality = self:GetController("EquipQuality")
    self._itemlock = self:GetController("itemlock")
    self._itemadd = self:GetController("itemadd")
    self._itemSmalladd = self:GetController("smallAdd")
    self._leftbottom = self:GetController("leftbottom")
    self._smallLock = self:GetController("smallLock")
    self._goldenBox = self:GetController("goldenBox")
    -- 回调以及回调参数
    self._callBack = nil --回调
    self._cbData = nil --回调参数

    -- 存储的身份信息
    self.IdData = nil

    --事件
    self:AddListener(self.onClick,
        function()
            if self._callBack then
                self._callBack(self._cbData)
            end
        end
    )
    self:SetNormal()
end
function BtnEquipmentProps:SetData(icon,quality,level)
    self:SetIcon(icon)
    self:SetQuality(quality)
    self:SetLevel(level)
end
--设置装备图片
function BtnEquipmentProps:SetIcon(icon)
    if icon then
        self._icon.visible = true
        self._icon.url = _G.UITool.GetIcon(icon)
    else
        self._icon.visible = false
    end
end
--设置底框
function BtnEquipmentProps:SetQuality(quality)
    self._EquipQuality.selectedPage = QualityStatus[quality]
end
--设置等级
function BtnEquipmentProps:SetLevel(level)
    if level then
        self._level.visible = true
        self._textBg.visible = true
        self._level.text = level
    else
        self._level.visible = false
        self._textBg.visible = false
    end
end
function BtnEquipmentProps:SetNormal()
    self:SetLock1(false)
    self:SetLock2(false)
    self:SetAdd(false)
    self:SetUpgrade(false)
    self:SetSmallAdd(false)
    self:SetGoldenBox(false)
end
--是否解锁装备
function BtnEquipmentProps:SetLock1(isLock)
    self._smallLock.selectedPage = isLock and smallLockStatus.lock or smallLockStatus.unlock
end
--是否解锁功能
function BtnEquipmentProps:SetLock2(isLock)
    self._itemlock.selectedPage = isLock and ItemlockStatus.lock or ItemlockStatus.unlock
end
--是否有可添加装备
function BtnEquipmentProps:SetAdd(isAdd)
    self._itemadd.selectedPage = isAdd and ItemaddStatus.add or ItemaddStatus.hide
end
--是否有可添加装备
function BtnEquipmentProps:SetSmallAdd(isAdd)
    self._itemSmalladd.selectedPage = isAdd and ItemSmaalladdStatus.add or ItemSmaalladdStatus.hide
end
--设置左下角状态为可升级
function BtnEquipmentProps:SetUpgrade(isUp)
    self._leftbottom.selectedPage = isUp and leftbottomStatus.upgrade or leftbottomStatus.normalck
end
--设置左下角状态为选中
function BtnEquipmentProps:SetPick(isPick)
    self._leftbottom.selectedPage = isPick and leftbottomStatus.pick or leftbottomStatus.normalck
end
-- 设置是否显示金属边框
function BtnEquipmentProps:SetGoldenBox(isShow)
    self._goldenBox.selectedPage =isShow and goldenBoxStatus.goldBox or goldenBoxStatus.normal
end
-- 设置点击回调
function BtnEquipmentProps:SetClickItem(callBack,cbData)
    self._callBack = callBack
    self._cbData = cbData
end
-- 设置身份数据
function BtnEquipmentProps:SetIdData(data)
    self.IdData = data
end
-- 设置获取数据
function BtnEquipmentProps:GetIdData()
    return self.IdData
end
-- 设置右下角数字缩放
function BtnEquipmentProps:SetTextScale(scaleValue)
    self._level.scale = Vector2.one*scaleValue
    self._textBg.scale = Vector2.one*scaleValue
end
return BtnEquipmentProps