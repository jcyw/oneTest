local LoadHelper = {}

local GameObject = _G.GameObject

function LoadHelper.LoadObject(url)
    print(url)
    local prefab = _G.ResMgr.Instance:GetPrefab(url)
    if not prefab then
        prefab = _G.ResMgr.Instance:LoadPrefabSync(url)
    end

    return prefab and GameObject.Instantiate(prefab) or nil
end

function LoadHelper:LoadObjectAsync()
end

_G.LoadHelper = LoadHelper
