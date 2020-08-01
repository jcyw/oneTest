--author: 	Amu
--time:		2019-10-31 20:40:15

local itemResoureProductionDetail = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemResoureProductionDetail", itemResoureProductionDetail)

itemResoureProductionDetail.iconItemList = {}

function itemResoureProductionDetail:ctor()
    self._iconBuild = self:GetChild("iconBuild")
    self._title = self:GetChild("title")
    self._btnSearch = self:GetChild("btnSearch")

    self._listView = self:GetChild("liebiao")

    self._resIcon = self:GetChild("icon")

    self._btnIncrease = self:GetChild("btnIncrease")


    self._ctrView = self:GetController("c1")

    self:InitEvent()
end

function itemResoureProductionDetail:InitEvent(  )

end

function itemResoureProductionDetail:SetData()

end

return itemResoureProductionDetail