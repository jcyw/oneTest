--[[
    Author: songzeming
    Function: 联盟医院详情列表Item
]]
local ItemUnionHospitalDetail = fgui.extension_class(GButton)
fgui.register_extension('ui://Union/iconUnionHospitalDetail', ItemUnionHospitalDetail)

import('UI/Common/ItemUnionArmyDetail')

function ItemUnionHospitalDetail:ctor()
    self._bgItemOpen = self._itemOpen:GetChild('bg')
    self._list = self._itemOpen:GetChild('liebiao')
    self._list.touchable = false

    self:AddListener(self.onClick,
        function()
            self:OnBtnClick()
        end
    )

    self.defaultHeight = self.height
end

function ItemUnionHospitalDetail:Init(armys)
    self._name.text = armys.Name

    self.armys = armys.Armies
    self._itemOpen.visible = false
    self.isOpened = false
    self._btnArrow.rotation = -180
end

function ItemUnionHospitalDetail:OnBtnClick()
    if not self.armys or next(self.armys) == nil then
        return
    end
    self.isOpen = not self.isOpen
    if self.isOpen then
        if not self.isOpened then
            self.isOpened = true
            self._list.numItems = #self.armys
            self._list:ResizeToFit(self._list.numChildren)
            for k, v in pairs(self.armys) do
                local item = self._list:GetChildAt(k - 1)
                item:Init(v)
            end
        end
        self.height = self.height + self._bgItemOpen.height
        self._btnArrow.rotation = -90
        self._itemOpen.visible = true
    else
        self.height = self.defaultHeight
        self._btnArrow.rotation = -180
        self._itemOpen.visible = false
    end
end

return ItemUnionHospitalDetail
