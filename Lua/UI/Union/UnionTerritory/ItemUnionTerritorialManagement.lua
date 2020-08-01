--[[
    author:{zhanzhang}
    time:2019-07-08 17:52:59
    function:{联盟建筑管理界面分类条}
]]
local ItemUnionTerritorialManagement = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionTerritorialManagement", ItemUnionTerritorialManagement)

local UnionTrritoryModel = import("Model/Union/UnionTrritoryModel")

function ItemUnionTerritorialManagement:ctor()
    self._textTitle = self:GetChild("title")
    self._btnArrow = self:GetChild("btnArrow")
    self._btnTitle = self:GetChild("btnTitle")
    self._DetailBox = self:GetChild("itemDetailBox")
    self._contentList = self._DetailBox:GetChild("liebiao")
    self.FormerHight = self.height

    self.isShowDetail = false
    self:AddListener(self._btnTitle.onClick,
        function()
            if self.isShowDetail then
                self:HideDetail()
            else
                self:ShowDetail()
            end
        end
    )
end

function ItemUnionTerritorialManagement:Init(index)
    self.configList = UnionTrritoryModel.GetTerritorTypeListByIndex(index)
    self._textTitle.text = ConfigMgr.GetI18n(I18nType.Commmon, self.configList[1].buildingtype_name)
    self:HideDetail()
end

function ItemUnionTerritorialManagement:ShowDetail()
    self.isShowDetail = true
    self._DetailBox.visible = true
    self._btnArrow.rotation = 90
    self._contentList:RemoveChildrenToPool()
    for i = 1, #self.configList do
        local item = self._contentList:AddItemFromPool()
        item:Init(self.configList[i])
    end
    self._contentList:ResizeToFit(#self.configList)
    self.height = self._contentList.height + self.FormerHight + 25
end

function ItemUnionTerritorialManagement:HideDetail()
    self.isShowDetail = false
    self._DetailBox.visible = false
    self._btnArrow.rotation = 0
    self.height = self.FormerHight
end

return ItemUnionTerritorialManagement
