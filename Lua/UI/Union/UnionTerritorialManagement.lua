--[[
    author:{zhanzhang}
    time:2019-07-01 17:32:16
    function:{联盟领地管理}
]]
local UnionTerritorialManagement = UIMgr:NewUI("UnionTerritorialManagement")
local UnionTrritoryModel = import("Model/Union/UnionTrritoryModel")


function UnionTerritorialManagement:OnInit()
    -- body
    local view = self.Controller.contentPane
    self._btnHelp = view:GetChild("btnHelp")
    self._btnReturn = view:GetChild("btnReturn")
    self._btnHelp = view:GetChild("btnHelp")
    self._contentTerrain = view:GetChild("liebiao")

    self:OnRegister()
end

function UnionTerritorialManagement:OnRegister()
    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                info = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_AillancePlace_Tips")
            }
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )

    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("UnionTerritorialManagement")
        end
    )
end
--[[ state:
	LOCKED    = 0 // 未解锁
	BUILDABLE = 1 // 可建造
	BUILDING  = 2 // 建造中
	COMPLETE  = 3 // 建造完成
	ATTACKED  = 4 // 被破坏
]]
function UnionTerritorialManagement:OnOpen()
    Net.AllianceBuildings.BuildingsInfo(
        Model.Player.AllianceId,
        function(buildInfo)
            UnionTrritoryModel.Init(buildInfo)
            self:InitData()
        end
    )
end

function UnionTerritorialManagement:InitData()
    local count ,list= UnionTrritoryModel.GetTerritorTypeCount()
    for i = 1, count do
        local item = self._contentTerrain:AddItemFromPool()
        item:Init(list[i])
    end
end

function UnionTerritorialManagement:OnClose()
    self._contentTerrain:RemoveChildrenToPool()
end

return UnionTerritorialManagement
