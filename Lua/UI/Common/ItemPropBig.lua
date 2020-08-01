--[[
    Author: songzeming
    Function: 道具Item
]]
local GD = _G.GD
local ItemPropBig = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemPropBig", ItemPropBig)

function ItemPropBig:ctor()
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
    self:InitEvent()
end

function ItemPropBig:InitEvent()
    self:AddListener(self.onClick,
        function()
            if self.cb then
                self.cb()
            end
        end
    )

    self:AddListener(self.onTouchBegin,
        function()
            if self.touchCb then
                self.touchCb()
            end
            if not self._info then
                return
            end
            if(self.detailPop and self.detailPop.OnShowUI)then
                self.detailPop:OnShowUI(self._info[1], self._info[2],self._item, false)
            end
        end
    )

    self:AddListener(self.onTouchEnd,
        function()
            self.detailPop:OnHidePopup()
        end
    )
    self:AddListener(self.onRollOut,function()
        self.detailPop:OnHidePopup()
    end)
end

-- 设置图片、数量、标题
function ItemPropBig:SetAmount(image, quality, amount, title, mid, SeekCb)
    self._item:SetShowData(image, quality, amount, title, mid, SeekCb)
end
function ItemPropBig:SetShowData(image, quality, amount, title, mid, SeekCb)
    self._item:SetShowData(image, quality, amount, title, mid, SeekCb)
end

--设置名字颜色
function ItemPropBig:SetTitleColor(color)
    self._item:SetTitleColor(color)
end
-- 设置是否选中状态
function ItemPropBig:SetChoose(flag)
    self._item:SetChoose(flag)
end
-- 获取是否选中状态
function ItemPropBig:GetChoose()
    return self._item:GetChoose()
end
--设置是否是热卖 0新的 1热卖 2普通
function ItemPropBig:SetNewActive(flag)
    self._item:SetNewActive(flag)
end
--设置是否是热卖 0新的 1热卖 2普通
function ItemPropBig:SetHotActive(flag)
    self._item:SetHotActive(flag)
end
-- 设置安全图标是否显示 0安全 1提升 2普通
function ItemPropBig:SetSafetyActive(flag)
    self._item:SetSafetyActive(flag)
end
-- 设置提升图标是否显示 0安全 1提升 2普通
function ItemPropBig:SetUpActive(flag)
    self._item:SetUpActive(flag)
end
--设置左下角勾选标记 0左下 1 中心
function ItemPropBig:SetPickTypeLeftBottom(flag)
    self._item:SetPickTypeLeftBottom(flag)
end
--设置中心勾选标记 0左下 1 中心
function ItemPropBig:SetPickTypeMidde(flag)
    self._item:SetPickTypeMidde(flag)
end
--设置中心锁标记 0 中心 1左上
function ItemPropBig:SetLockTypeMidde(flag)
    self._item:SetLockTypeMidde(flag)
end
--设置左上锁标记 0 中心 1左上
function ItemPropBig:SetLockTypeTopLeft(flag)
    self._item:SetLockTypeTopLeft(flag)
end
--蒙版
function ItemPropBig:SetMask(flag)
    self._item:SetMask(flag)
end
-- 设置点击回调
function ItemPropBig:ClickCB(cb)
    self.cb = cb
end

function ItemPropBig:SetData(info)
    self._info = info
end

function ItemPropBig:SetTouchCb(cb)
    self.touchCb = cb
end
--特效挂点
function ItemPropBig:GetEffect()
    return self._item:GetEffect()
end
--动画状态隐藏内容
function ItemPropBig:SetAnimState(flag)
    self._item:SetMiddleActive(flag)
    self._item:SetTitleActive(false)
end

return ItemPropBig
