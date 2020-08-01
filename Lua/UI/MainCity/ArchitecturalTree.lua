-- 指挥中心详情页面
local ArchitecturalTree = UIMgr:NewUI("ArchitecturalTree")

local BuildModel = import("Model/BuildModel")
local EventModel = import("Model/EventModel")

function ArchitecturalTree:OnInit()
    local view = self.Controller.contentPane
    self._list = view:GetChild("liebiao")
    self._showController = view:GetController("upgradeControl")

    local btnCanel = view:GetChild("btnUse")
    self:AddListener(btnCanel.onClick,function()
        local data = {
            content = "是否确定取消升级？\n若您取消队列则会返回全部已消耗的建筑升级道具和一半的资源，除此之外将不会得到任何东西！",
            sureCallback = function()
                Net.Events.Cancel(self.event.Category, self.event.Uuid, function(rsp)
                    local node = BuildModel.GetObject(self.event.TargetId)
                    Model.Delete(ModelType.UpgradeEvents, self.event.Uuid)
                    node:ResetCD()
                    UIMgr:Close("ArchitecturalTree")
                end)
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end)

    local btnReturn = view:GetChild("btnReturn")
    self:AddListener(btnReturn.onClick,function()
        UIMgr:Close("ArchitecturalTree")
    end)
end

function ArchitecturalTree:OnOpen(building)
    self.model = BuildModel.GetCenter()
    self.event = EventModel.GetUpgradeEvent(building.Id)

    local event = EventModel.GetEvent(self.model)
    if event ~= nil and (event.Category == EventType.B_BUILD or event.Category == EventType.B_DESTROY) then
        self._showController.selectedPage = "show"
    else
        self._showController.selectedPage = "hide"
    end

    self:InitList()
end

function ArchitecturalTree:InitList()
    self._list:RemoveChildrenToPool()
    local showItemIndex = 0
    local configs = ConfigMgr.GetList("configBases")
    for k,v in pairs(configs) do
        local item = self._list:AddItemFromPool()
        item:Init(v)
        if (v.id % 400000) == BuildModel.GetCenterLevel() then
            showItemIndex = self._list.numItems
        end
    end
    
    self._list.scrollPane:ScrollTop()
    self._list:ScrollToView(showItemIndex - 1, true)
end

return ArchitecturalTree