--[[
    Author: songzeming
    Function: 资源收集动画item
]]
local TechCollectAnim = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/TechCollectAnim", TechCollectAnim)

function TechCollectAnim:ctor()

end

function TechCollectAnim:setIcon(techId)
    self._icon.url = UITool.GetIcon(ConfigMgr.GetItem("configTechDisplays", techId).icon)
end

function TechCollectAnim:GetContext()
    return self
end

return TechCollectAnim
