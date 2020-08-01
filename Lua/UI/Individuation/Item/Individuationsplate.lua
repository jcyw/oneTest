--author: 	Amu
--time:		2020-07-11 15:30:43

local WorldMapModel = import("Model/WorldMapModel")
local BuildModel = import("Model/BuildModel")
local DressUpModel = import("Model/DressUpModel")

local Individuationsplate = fgui.extension_class(GComponent)
fgui.register_extension("ui://Individuation/Individuationsplate", Individuationsplate)

function Individuationsplate:ctor()

    self._getCtrView = self:GetController("type")
    self._useCtrView = self:GetController("ItemUse")

    self._bgName = self._nameplate:GetChild("_bgName")
    self._iconVilla = self._nameplate:GetChild("_iconVilla")
    self._textName = self._nameplate:GetChild("_textName")

    self.NameplateIcon = {
        [DRESSUP_NAMEPLATE_TYPE.Head] = self._nameplate:GetChild("_iconVilla"),
        [DRESSUP_NAMEPLATE_TYPE.Bg] = self._nameplate:GetChild("_bgName")
    }

    self._dressUpIcon.icon = UITool.GetIcon({"dressup", "zb_bg"})

    self.configDressUpType = ConfigMgr.GetList("configDressupTypes")
    self:InitEvent()
end

function Individuationsplate:InitEvent()
end

function Individuationsplate:SetData(dressUpId)
    local config = DressUpModel.GetDressUpInfoByTypeAndId(DRESSUP_TYPE.Nameplate, dressUpId).config
    for _,v in pairs(config.urls)do
        if self.NameplateIcon[v.id] then
            self.NameplateIcon[v.id].icon = UITool.GetIcon({v.pkg, v.url})
        end
    end
    self._textName.text = TextUtil.GetFormatPlayName(Model.Player.AllianceName, Model.Player.Name)
    self:InitBuild()
end

function Individuationsplate:InitBuild()
    if not self._buildObj then
        self._buildObj = GameObject.Instantiate(WorldMapModel.GetWorldMapPrefab(1000))
        self._buildObj.transform.localScale = Vector3(200, 200, 200)
        self._buildObj.transform.localEulerAngles = Vector3(22.5, 135, -22.5)
        self._buildObj.transform.localPosition = Vector3(0, 0, 200)

        self._buildGoWrapper:SetNativeObject(GoWrapper(self._buildObj))

        self._buildGoWrapper.visible = false

        self.Renderer = self._buildObj:GetComponent("Renderer")

        destroy(self._buildObj.transform:Find("CommonTile").gameObject)
        destroy(self._buildObj.transform:Find("Flag").gameObject)
        destroy(self._buildObj.transform:Find("4").gameObject)

        self:RefreshBuild()
        -- self:RefreshBuildFlag()


        -- local uiPath = "prefabs/worldmapui/nodesprite/maptownui"
        -- self._uiObj = GameObject.Instantiate(ResMgr.Instance:LoadPrefabSync(uiPath))

        -- self._tranSprite = self._uiObj.transform
        -- -- uiobj.transform:SetParent(self._buildObj.transform, false)

        -- self._imgMainCityIcon = self._tranSprite:Find("imgMainCityIcon"):GetComponent("Image")
        -- self._imgBgIcon = self._tranSprite:Find("imgBg"):GetComponent("Image")

        -- self._uiObj.transform.localScale = Vector3(300, 300, 300)
        -- self._buildObj.transform.localPosition = Vector3(0, 0, 100)

        -- -- self._imgMainCityIcon.position = Vector3(0, 0, 0)
        -- -- self._imgBgIcon.position = Vector3(0, 0, 0)

        -- self._builduiGoWrapper:SetNativeObject(GoWrapper(self._uiObj))


        -- DynamicRes.GetTexture2D("dressup", "icon_wcz_mp_01", function(tex)
        --     local sprite = CS.UnityEngine.Sprite.Create(tex, Rect(0, 0, tex.width, tex.height), Vector2(0.5, 0.5))
        --     self._imgMainCityIcon.sprite = sprite
        -- end)
    end
end

function Individuationsplate:RefreshBuild()
    if self._buildObj then
        _G.CSCoroutine.Start(function()
            local path = "materials/buildings/building_town_lv" .. BuildModel.GetCenterLevel()
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
            self._buildGoWrapper.visible = true
        end)
    end
end

function Individuationsplate:RefreshBuildFlag()
    if self._buildObj then
        self.Flag = self._buildObj.transform:Find("Flag")
        self.FlagRender = self.Flag:GetComponent("MeshRenderer")
    
        local flag = ConfigMgr.GetItem("configFlags", Model.Player.Flag).icon[2]
        local name = string.lower(flag)
        _G.DynamicRes.GetTexture2D("worldmapflag", name,
        function(texture)
            local prop = _G.MaterialPropertyBlock()
            self.FlagRender:GetPropertyBlock(prop)
            prop:SetTexture("_MainTex", texture)
            self.FlagRender:SetPropertyBlock(prop)
        end)
    end
end

return Individuationsplate