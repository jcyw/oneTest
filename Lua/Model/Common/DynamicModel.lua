--[[
    Author: songzeming
    Function: 内城地图 滑动
]]
if DynamicModel then
    return DynamicModel
end
DynamicModel = {}

--解析获得配置的图片路径
local DynamicBundles = {
    army_helicopter = true, --训练兵种
    army_tank = true, --训练兵种
    army_vehicle = true, --训练兵种
    army_warchariot = true, --训练兵种
    army_monster = true,
    banner = true,
    banner_activity = true,
    banner_gift = true,
    banner_mail = true,
    banner_union = true,
    banner_welfare = true,
    banner_taskplot = true,
    falcon = true,
    icon = true, --道具
    icon_activity = true,--活动图标
    icon_effect = true,--特效图标
    icon_skill = true,--技能图标
    world = true,
    wordart = true,
    tech_icon = true,
    achievement = true,
    IconEquip = true, --装备
    equip_plane = true, --战机
    dressup = true,
    giricon = true,
}

-- 静默下载资源
local SilentlyBundles = {
    Individuation = true    -- 装扮
}

--获取本地资源、动态资源
function DynamicModel.GetIcon(icon, dynamicNode)
    if not icon then
        Log.Error("error: icon is nil")
        return
    end
    local pkgName = icon[1]
    local resName = icon[2]
    if not pkgName then
        Log.Error("error: not package name: {0}", icon and table.inspect(icon) or icon)
        return
    end
    if not resName then
        Log.Error("error: not resource name: {0}", icon and table.inspect(icon) or icon)
        return
    end

    if DynamicBundles[pkgName] then
        if pkgName == "icon" or pkgName == "tech_icon" then
            --道具
            if dynamicNode then
                -- Log.Info("道具动态资源 >> pkgName: {0}, resName: {1}", pkgName, resName)
                --动态加载资源
                --检测是否已经下载
                if DynamicRes.CheckDownloaded(pkgName) then
                    -- Log.Info("已经下载")
                    DynamicRes.GetTexture2D(pkgName, resName, function(tex)
                        dynamicNode.texture = NTexture(tex)
                    end)
                else
                    -- Log.Info("尚未下载成功")
                    -- dynamicNode:Dispose()
                    DynamicRes.GetTexture2D(pkgName, resName, function(tex)
                        -- Log.Info("------------------- cb tex:", tex)
                        dynamicNode.texture = NTexture(tex)
                    end)
                    if not DynamicRes.CheckDownloaded(pkgName) then
                        return DynamicModel.GetItemIcon()
                    end
                end
            else
                -- Log.Info("动态资源未设置")
                return pkgName .. ":" .. string.lower(resName)
            end
        elseif pkgName == "falcon" and dynamicNode then
            if not dynamicNode.texture then
                DynamicModel.GetBgIcon(dynamicNode)
            end
            DynamicRes.GetTexture2D(pkgName, resName, function(tex)
                if dynamicNode.texture then
                    dynamicNode.texture = NTexture(tex)
                end
            end)
        else
            return pkgName .. ":" .. string.lower(resName)
        end
    elseif SilentlyBundles[pkgName] then
        if UIPackage.GetByName(pkgName) then
            return UIPackage.GetItemURL(pkgName, resName)
        else
            UIMgr:AddPackage(pkgName)
            return DynamicModel.GetItemIcon()
        end
    else
        --本地资源
        return UIPackage.GetItemURL(pkgName, resName)
    end
end

--获取道具默认图标(问号)
function DynamicModel.GetItemIcon()
    return UIPackage.GetItemURL("Common", "default_item")
end
--默认背景图
function DynamicModel.GetBgIcon(node)
    if node then
        node.icon = UIPackage.GetItemURL("Common", "bg")
    else
        return UIPackage.GetItemURL("Common", "bg")
    end
end

--设置道具动态资源 [道具Bundle下载返回错误时,但Gloader中url已设置,但实际还是显示问号,再设置url时与之前设置值相等会直接return,任然会显示问号,导致设置失败]
function DynamicModel.FixItemIcon(node)
    node.icon = UIPackage.GetItemURL("Common", "default_item")
end

return DynamicModel
