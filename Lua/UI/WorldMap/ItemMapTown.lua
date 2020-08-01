--[[
    author:{zhanzhang}
    time:2020-03-17 10:17:55
    function:{大地图主城item}
]]
local ItemMapTown = {}

local protectConfig

function ItemMapTown:ctor()
    self:OnRegister()
end

function ItemMapTown:OnRegister()
    _G.Event.AddListener(
        _G.EventDefines.ShieldAt,
        function(val)
            if self.UserId == _G.Model.Account.accountId then
                self.Info.ProtectedAt = val.ProtectedAt
                self:RefreshShield(self.Info)
            end
        end
    )
end

function ItemMapTown:Init(obj)
    --主城Mesh
    self.Renderer = obj:GetComponent("Renderer")
    --防护罩Mesh

    self.Flag = obj.transform:Find("Flag")
    self.FlagRender = self.Flag:GetComponent("MeshRenderer")
    --wait optimize  底板
    self.BlackTileRender = obj.transform:Find("BlackTile"):GetComponent("SpriteRenderer")
    self.CommonTileRender = obj.transform:Find("CommonTile"):GetComponent("SpriteRenderer")
    protectConfig = _G.ConfigMgr.GetItem("configResourcePaths", 800001)
end
function ItemMapTown:RefreshCity(posNum)
    self.posNum = posNum
    local areaInfo = _G.MapModel.GetArea(posNum)
    if not areaInfo then
        return
    end
    local ownerInfo = _G.MapModel.GetMapOwner(areaInfo.OwnerId)
    if not ownerInfo then
        return
    end
    _G.CSCoroutine.Start(
        function()
            local path = "materials/buildings/building_town_lv" .. ownerInfo.BaseLevel
            coroutine.yield(_G.ResMgr.Instance:LoadMaterial(path))
            local mat = _G.ResMgr.Instance:GetMaterial(path)
            if not mat or not mat.mainTexture then
                _G.Log.Error("ItemMapTown: 获取材质球失败")
                return
            end
            local prop = _G.MaterialPropertyBlock()
            self.Renderer:GetPropertyBlock(prop)
            prop:SetTexture("_MainTex", mat.mainTexture)
            self.Renderer:SetPropertyBlock(prop)
        end
    )
end

function ItemMapTown:RefreshComponent(posNum)
    local areaInfo = _G.MapModel.GetArea(posNum)
    if not areaInfo then
        return
    end
    local ownerInfo = _G.MapModel.GetMapOwner(areaInfo.OwnerId)
    self.UserId = areaInfo.OwnerId
    self:RefreshPosNum(posNum)
    self:SetFlag(ownerInfo)
    self:RefreshShield(ownerInfo)
    self:CheckIsFire(areaInfo)
end

function ItemMapTown:RefreshPosNum(posNum)
    local posX, posY = _G.MathUtil.GetCoordinate(posNum)
    if _G.MapModel.IsInBlackZone(posX, posY) then
        self.BlackTileRender.enabled = true
        self.CommonTileRender.enabled = false
    else
        self.BlackTileRender.enabled = false
        self.CommonTileRender.enabled = true
    end
end

function ItemMapTown:RefreshShield(info)
    self.Info = info
    local shieldIndex = -1
    if info.ProtectedAt > _G.Tool.Time() then
        if info.ShieldSource <= 1 then
            --普通防护罩 --蓝色
            shieldIndex = 800101
        elseif info.ShieldSource == 2 then
            --活动特殊保护罩  --紫色
            shieldIndex = 800102
        end
    elseif info.ResProtectedAt > _G.Tool.Time() then
        --资源保护罩
        shieldIndex = 800103
    end
    local posX, posY = _G.MathUtil.GetCoordinate(self.posNum)
    if shieldIndex >= 0 then
        -- self.ProtectAnim:SetInteger("ProtectType", shieldIndex)
        if shieldIndex == self.shieldIndex and self.ProtectObj then
            local offsetValue = 1 + (self.Info.BaseLevel - 1) / 30 * 0.5
            self.ProtectObj.transform.localPosition = _G.CVector3(posX - offsetValue, 0, posY - offsetValue)
            return
        end
        self.isChangeColor = (self.shieldIndex ~= shieldIndex)
        self.shieldIndex = shieldIndex
        local resConfig = _G.ConfigMgr.GetItem("configResourcePaths", shieldIndex)
        _G.GameUtil.GetObjFromPool(
            800001,
            function()
                _G.CSCoroutine.Start(
                    function()
                        if self.ProtectObj then
                            print("已经创建直接return")
                            return
                        end
                        coroutine.yield(_G.ResMgr.Instance:LoadMaterial(resConfig.resPath))
                        if self.ProtectObj then
                            if self.isChangeColor then
                                self.mat = _G.ResMgr.Instance:GetMaterial(resConfig.resPath)
                                self.ProtectRenderer.material = self.mat
                            end
                            return
                        end
                        self.mat = _G.ResMgr.Instance:GetMaterial(resConfig.resPath)
                        self.ProtectObj = _G.ObjectPoolManager.Instance:Get(protectConfig.name)
                        self.ProtectObj.transform.parent = _G.WorldMap.Instance().RouteLayer.transform
                        self.ProtectRenderer = self.ProtectObj:GetComponent("Renderer")
                        local offsetValue = 1 + (self.Info.BaseLevel - 1) / 30 * 0.5
                        self.ProtectObj.transform.localPosition = _G.CVector3(posX - offsetValue, 0, posY - offsetValue)
                        self.ProtectObj.transform.localScale = _G.CVector3.one * (0.7 + self.Info.BaseLevel * 0.01)
                        self.ProtectObj.transform:GetChild("huzhao_Glow").transform.localScale = _G.CVector3.one * (0.7 + self.Info.BaseLevel * 0.01)
                        self.ProtectRenderer.material = self.mat
                        -- print("创建保护罩 posX" .. posX .. "   posY  " .. posY)
                    end
                )
            end
        )
    else
        self:RecycleProtect()
    end
end
function ItemMapTown:SetFlag(Owner)
    local flag = ConfigMgr.GetItem("configFlags", Owner.Flag).icon[2]
    local name = string.lower(flag)
    _G.DynamicRes.GetTexture2D(
        "worldmapflag",
        name,
        function(texture)
            local prop = _G.MaterialPropertyBlock()
            self.FlagRender:GetPropertyBlock(prop)
            prop:SetTexture("_MainTex", texture)
            self.FlagRender:SetPropertyBlock(prop)
        end
    )
end

function ItemMapTown:CheckIsFire(area)
    if area.State == _G.Global.MapRecStateBurning then
        local posX, posY = _G.MathUtil.GetCoordinate(area.Id)
        if self.fireObj then
            self.fireObj.transform.localPosition = _G.CVector3(posX - 0.5, 0, posY - 0.5)
        else
            if self.isloading then
                _G.Log.Warning("防止城墙火焰重复加载，直接return")
                return
            end

            self.isloading = true
            DynamicRes.GetBundle(
                "effect_worldmap",
                function()
                    DynamicRes.GetPrefab(
                        "effect_worldmap",
                        "effect_cityfire",
                        function(prefab)
                            local fireObj = GameObject.Instantiate(prefab)
                            fireObj.transform.parent = _G.WorldMap.Instance().RouteLayer.transform
                            fireObj.transform.localScale = _G.CVector3.one * 0.8
                            fireObj.transform.localPosition = _G.CVector3(posX - 0.6, 0, posY - 0.6)
                            self.fireObj = fireObj
                            self.isloading = false
                        end
                    )
                end
            )
        end
    else
        if self.fireObj then
            ObjectUtil.Destroy(self.fireObj)
            self.fireObj = nil
        end
    end
end

function ItemMapTown:CloseCityUI()
    self.BlackTileRender.enabled = false
    self.CommonTileRender.enabled = false
    self:RecycleProtect()
    if self.fireObj then
        ObjectUtil.Destroy(self.fireObj)
        self.fireObj = nil
    end
end

function ItemMapTown:ClearBuildInfo()
    self:RecycleProtect()
    if self.fireObj then
        ObjectUtil.Destroy(self.fireObj)
        self.fireObj = nil
    end
end

function ItemMapTown:RecycleProtect()
    if self.ProtectObj then
        self.ProtectObj.transform.localPosition = _G.CVector3.one * 1000
        -- print("回收保护罩" .. self.posNum)
        _G.ObjectPoolManager.Instance:Release(protectConfig.name, self.ProtectObj)
        self.ProtectObj = nil
    end
end

return ItemMapTown
