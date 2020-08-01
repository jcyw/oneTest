--author: 	Amu
--time:		2019-11-01 17:26:00
local GD = _G.GD
local BuffItemModel = import("Model/BuffItemModel")


local ResourceProductionDetailPopup = UIMgr:NewUI("ResourceProductionDetailPopup")

function ResourceProductionDetailPopup:OnInit()
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnReturn")

    self._listView = self._view:GetChild("liebiaoAddition")

    --self._resIcon = self._view:GetChild("icon")
    --self._resIconBg = self._view:GetChild("iconBg")
    self._resTitle = self._view:GetChild("textYieldResource")

    self._allproduce = self._view:GetChild("textYieldResourceNum")
    self._produce = self._view:GetChild("textYieldBasicNum")
    self._addproduce = self._view:GetChild("textYieldAdditionNum")


    self:InitEvent()
end

function ResourceProductionDetailPopup:InitEvent(  )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    self._listView.itemProvider = function(index)
        if not index then 
            return
        end
        if index == 0 then
            return "ui://MainCity/itemResourceProductionDetailPopup1"
        end
        return "ui://MainCity/itemResourceProductionDetailPopup2"
    end

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self._infoList[index+1], self.type, self._resBuildList)
    end

    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        if not item.GetData then
            return
        end
        local data = item:GetData()
        local buildInfo = Model.Buildings[data.Id]
        ScrollModel.GiveUpCloseScale()
        UIMgr:ClosePopAndTopPanel()
        TurnModel.BuildFuncDetail(buildInfo.ConfId, buildInfo, true)
    end)
end

function ResourceProductionDetailPopup:OnOpen(type, data)
    self.type = type
    self.data = data

    --self._resIcon.icon = GD.ResAgent.Get128IconUrl(type)
    --self._resIconBg.icon = GD.ItemAgent.GetItmeQualityByColor(GD.ResAgent.GetIconQuality(type))
    self._itemProp:SetShowData(GD.ResAgent.Get128Icon(type),GD.ResAgent.GetIconQuality(type))
    self._resTitle.text = data.title

    self._allproduce.text = Tool.FormatNumberThousands(GD.ResAgent.GetResOutPut(type)).."/h"
    self._produce.text = Tool.FormatNumberThousands(GD.ResAgent.GetResBasicOutPut(type)).."/h"
    self._addproduce.text = BuffItemModel.GetResBonus(type).."/h"


    self._infoList = {}
    self._resBuildList = {}
    table.insert(self._infoList, {})

    local resBuildInfo = Model.GetMap(ModelType.ResBuilds)

    for _,v in pairs(resBuildInfo)do
        if v.Category == self.type then
            table.insert(self._infoList, v)
            table.insert(self._resBuildList, v)
        end
    end

    self:RefreshListView()
end

function ResourceProductionDetailPopup:RefreshListView()
    self._listView.numItems = #self._infoList
end

function ResourceProductionDetailPopup:Close()
    UIMgr:Close("ResourceProductionDetailPopup")
end

return ResourceProductionDetailPopup