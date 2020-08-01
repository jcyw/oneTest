--[[
    author:{zhanzhang}
    time:2020-04-22 11:22:52
    function:{大地图炮塔Item}
]]
local ItemMapThrone = {}

local protectConfig
local ActivityModel = import("Model/ActivityModel")

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

function ItemMapThrone:Refresh(posNum)
    --主城Mesh
    -- self.Renderer = obj:GetComponent("Renderer")
    --防护罩Mesh
    self.posNum = posNum
    if not self.posX or not self.posY then
        self.posX, self.posY = MathUtil.GetCoordinate(posNum)
    end

    protectConfig = ConfigMgr.GetItem("configResourcePaths", 800001)
    self:RefreshShield(posNum)
end

function ItemMapThrone:RefreshShield(posNum)
    if self.isExistShield or ActivityModel.IsRoyalBattleOpen() then
        return
    end
    self.isExistShield = true
    if self.ProtectObj then
        return
    end

    local resConfig = ConfigMgr.GetItem("configResourcePaths", 800101)
    GameUtil.GetObjFromPool(
        800001,
        function()
            CSCoroutine.Start(
                function()
                    coroutine.yield(ResMgr.Instance:LoadMaterial(resConfig.resPath))
                    if self.ProtectObj then
                        return
                    end
                    self.mat = ResMgr.Instance:GetMaterial(resConfig.resPath)
                    self.ProtectObj = ObjectPoolManager.Instance:Get(protectConfig.name)
                    self.ProtectObj.transform.parent = WorldMap.Instance().RouteLayer.transform
                    self.ProtectRenderer = self.ProtectObj:GetComponent("Renderer")
                    self.ProtectObj.transform.localPosition = CVector3(self.posX - 1, 0, self.posY - 1)
                    self.ProtectObj.transform.localScale = CVector3.one
                    self.ProtectObj.transform:GetChild("huzhao_Glow").transform.localScale = CVector3.one
                    self.ProtectRenderer.material = self.mat
                end
            )
        end
    )
end

return ItemMapThrone
