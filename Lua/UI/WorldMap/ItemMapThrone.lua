--[[
    author:{zhanzhang}
    time:2020-04-22 11:22:52
    function:{大地图王城Item}
]]
local ItemMapThrone = {}

function ItemMapThrone:ctor()
    self:OnRegister()
end

function ItemMapThrone:OnRegister()
    Event.AddListener(
        EventDefines.RoyalBattleActivity,
        function()
            local isOpen = ActivityModel.IsRoyalBattleOpen()
            if isOpen then
                if self.isExistShield then
                    GameObject.Destroy(self.ProtectObj)
                    self.isExistShield = false
                    self.ProtectObj = nil
                end
            else
                self:RefreshShield( self.posNum)
            end
        end
    )
end

function ItemMapThrone:Refresh()
    --主城Mesh
    -- self.Renderer = obj:GetComponent("Renderer")
    --防护罩Mesh

    local isOpen = ActivityModel.IsRoyalBattleOpen()
    if isOpen then
        if self.ProtectObj then
            self.ProtectObj.transform.localPosition = CVector3.one * 1000
        end
    else
        self:RefreshShield()
    end
end

function ItemMapThrone:RefreshShield()
    if self.isExistShield then
        return
    end

    self.isExistShield = true
    local posX = 599.5
    local posY = 599.5
    self.protectConfig = ConfigMgr.GetItem("configResourcePaths", 800002)
    GameUtil.GetObjFromPool(
        800002,
        function()
            CSCoroutine.Start(
                function()
                    if self.ProtectObj then
                        return
                    end
                    self.ProtectObj = ObjectPoolManager.Instance:Get(self.protectConfig.name)
                    self.ProtectObj.transform.parent = WorldMap.Instance().RouteLayer.transform
                    self.ProtectObj.transform.localPosition = CVector3(posX, 0, posY)
                end
            )
        end
    )
end

return ItemMapThrone
