local itemEquipBackpack = _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://EquipmentSystem/itemEquipBackpack", itemEquipBackpack)

function itemEquipBackpack:ctor()
    --获取部件
    self.icon = self:GetChild("icon")
    self._amount = self:GetChild("_amount")
    self._ctr = self:GetController("c1")
    self._qualityCtr = self:GetController("quality")
    -- 回调以及回调参数
    self._callback = nil
    self._cbData = nil
    self.tipData = {}

    --提示说明
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabelTwo")

    --事件
    self:AddListener(self.onClick, function()
        if self._callback then
            self._callback(self._cbData)
        end
    end)

    self:AddListener(self.onTouchBegin, function()
        if next(self.tipData) then
            self.detailPop:InitLabel(self.tipData.title, self.tipData.datas)
            UIMgr:ShowPopup("Common", "LongPressPopupLabelTwo", self.icon, false)
        end
    end)

    self:AddListener(self.onTouchEnd, function()
        UIMgr:HidePopup("Common", "LongPressPopupLabelTwo")
    end)

    self:AddListener(self.onRollOut, function()
        UIMgr:HidePopup("Common", "LongPressPopupLabelTwo")
    end)
end
--[[
    data.cbData 回调参数
    data.cb 回调
    data.quality 装备品质
    data.icon 装备icon
    data.ctr 状态控制器
    data.num 如果时装备就表示等级 如果时材料就表示是数量

]]
function itemEquipBackpack:SetData(data)
    if not data then
        return
    end
    self._cbData = data.cbData
    self._callback = data.cb
    if data.icon then
        self.icon.icon = _G.UITool.GetIcon(data.icon, self._icon)
        self.icon.visible = true
        self._addIcon.visible = false
    else
        self.icon.visible = false
        self._addIcon.visible = true
    end
    self._ctr.selectedIndex = data.ctr
    self._qualityCtr.selectedIndex = data.quality
    -- if data.ctr == 2 or data.ctr == 6 then
    --     self._amount.text =  ("x%d"):format(data.num)
    -- elseif data.ctr == 1 or data.ctr == 3 or data.ctr == 4 or data.ctr == 5 then
    --     self._amount.text = ("Lv.%d"):format(data.num)
    -- end
    self._amount.text = data.num
end

function itemEquipBackpack:SetStyle(ctr)
    self._ctr.selectedIndex = ctr
end

function itemEquipBackpack:RefeshIcon(icon)
    if icon then
        self.icon.icon = _G.UITool.GetIcon(icon, self._icon)
        self.icon.visible = true
        self._addIcon.visible = false
    else
        self.icon.visible = false
        self._addIcon.visible = true
    end
end

function itemEquipBackpack:RefreshQuality(quality)
    self._qualityCtr.selectedIndex = quality
end

--[[
    title,
    content
]]
function itemEquipBackpack:SetTipData(data)
    self.tipData = data
end

return itemEquipBackpack