-- 联盟科技列表项
local ItemUnionScienceDonate = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionScienceDonate", ItemUnionScienceDonate)


function ItemUnionScienceDonate:ctor()
    self._txtLv = self:GetChild("text")
    self._txtTitle = self:GetChild("title")
    self._txtReTitle = self:GetChild("textRecommend")
    self._arrow = self:GetChild("btnArrow")
    self._list = self:GetChild("liebiao")
    self._bg = self:GetChild("bg")
    self._iconBg = self:GetChild("iconBg")
    self._showControl = self:GetController("showControl")

    self:AddListener(self:GetChild("bgButton").onClick,function()
        if self.isOpen then
            if self.openCb then
                self.openCb(false)
            end
            self:CloseList()
        else
            if self.openCb then
                self.openCb(true)
            end
            self:OpenList()
        end
    end)
end

function ItemUnionScienceDonate:Init(groupNum, techDatas, isLock, isOpen, callback, openCb)
    self.openHeight = 52 + 195 * #techDatas
    if groupNum == -2 then
        self._txtReTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceTech_Researching")
    elseif groupNum == -1 then
        self._txtReTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Recommend")
    end

    if groupNum < 0 or isOpen then
        self:OpenList()
    else
        self:CloseList()
    end

    self.isLock = isLock
    self.callback = callback
    self.openCb = openCb
    self._txtLv.text = groupNum > 0 and groupNum or ""
    
    if isLock then        
        self._txtTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceTech_Need", {number = techDatas[1].config.points})
        self._showControl.selectedPage = "lock"
    else        
        if groupNum > 0 then
            self._txtTitle.text = ConfigMgr.GetI18n(I18nType.Commmon, ConfigMgr.GetItem("configFloorNames", groupNum).name_id)
            self._showControl.selectedPage = "normal"
        else
            if groupNum == -1 then
                self._txtTitle.text = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_AllianceTech_Recommend")
                self._showControl.selectedPage = "recommend"
            else 
                self._txtTitle.text = ConfigMgr.GetI18n(I18nType.Commmon, "Queue_Title4")
                self._showControl.selectedPage = "recommend"
            end
        end
    end
    
    self:InitList(techDatas)
end

function ItemUnionScienceDonate:InitList(techDatas)
    self._list:RemoveChildrenToPool()
    for _,v in pairs(techDatas) do
        local item = self._list:AddItemFromPool()
        item:Init(v.config, v.model, self.isLock, self.callback)
    end
end

function ItemUnionScienceDonate:OpenList()
    self.isOpen = true
    self.height = self.openHeight
    self._arrow.rotation = 270
    self._list.visible = true
end

function ItemUnionScienceDonate:CloseList()
    self.isOpen = false
    self.height = 80
    self._arrow.rotation = 90
    self._list.visible = false
end

return ItemUnionScienceDonate
