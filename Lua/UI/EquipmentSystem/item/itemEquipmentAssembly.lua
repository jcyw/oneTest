local itemEquipmentAssembly =  _G.fgui.extension_class(_G.GComponent)
_G.fgui.register_extension("ui://EquipmentSystem/itemEquipmentAssembly", itemEquipmentAssembly)

function itemEquipmentAssembly:ctor()
    --获取部件
    self._icon = self:GetChild("icon")
    self._btnView = self:GetChild("btnView")
    self._textName = self:GetChild("_textName")
    self._textLevelNum = self:GetChild("textLevelNum")
    self._btnEquipment = self:GetChild("btnEquipment")
    self.iconLock = self:GetChild("iconLock")
    --buff属性显示
    self.itemAttack = {}
    for i = 1,4 do
        self.itemAttack[i] = self:GetChild("item"..i)
    end
    self._ctr = self:GetController("c1")
    self._qualityCtr = self:GetController("quality")

    --当前装备信息
    self._equipinfo = nil


    --父列表
    self.parentLlist = nil

    --buff数目
    self.BuffNum = 0

    --事件
    self:AddListener(self._btnView.onClick,
        --buff信息的显示隐藏
        function()
            if self._ctr.selectedIndex == 0 then
                return
            elseif self._ctr.selectedIndex == 1 then
                self._ctr.selectedIndex = 2
            else
                self._ctr.selectedIndex = 1
            end
            self._equipinfo.ctr = self._ctr.selectedIndex
            self.parentLlist:RefreshVirtualList()
        end
    )
end
function itemEquipmentAssembly:SetViewHeight(status)
    if status == 2 then
        self:SetSize(750,  180 + self.BuffNum * 35)
    else
        self:SetSize(750,  170)
    end
end
function itemEquipmentAssembly:SetData(equipinfo,list)
    if not equipinfo then
        Log.Error("--------------- itemEquipmentAssembly:SetData nil ")
        return
    end
    self._ctr.selectedIndex = equipinfo.ctr
    self._qualityCtr.selectedIndex = equipinfo.quality
    self._equipinfo = equipinfo
    self.iconLock.visible = equipinfo.IsLock
    if equipinfo.ctr == 1 or equipinfo.ctr == 2 then
        self._ctr.selectedIndex = self._ctr.selectedIndex == 0 and equipinfo.ctr or self._ctr.selectedIndex
        self._icon.icon = _G.UITool.GetIcon(equipinfo.icon, self._icon.icon)
        self._textName.text = _G.StringUtil.GetI18n("configI18nEquips", equipinfo.name)
        self._textLevelNum.text =
            _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_Level", {number = equipinfo.equip_level})

        self.parentLlist = list
        if equipinfo.buff_values then
            self.BuffNum = #equipinfo.buff_values
        end
        for i = 1,#self.itemAttack do
            local item = self.itemAttack[i]
            if equipinfo.att_name and equipinfo.buff_values[i] then
                local buffvalue = ("+ %.2f"):format(equipinfo.buff_values[i]/100).."%"
                local name = equipinfo.att_name[i]
                item.visible = true
                item:SetData(name,buffvalue,1)
            else
                item.visible = false
            end
        end
    else
        self._EquipOrRemoveCbData = equipinfo.partID
    end
    self:SetViewHeight(equipinfo.ctr)
end

return itemEquipmentAssembly
