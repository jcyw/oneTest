--[[
    Author: songzeming
    Function: 资源数量显示和刷新Item
]]
local GD = _G.GD
local ItemResources = fgui.extension_class(GButton)
fgui.register_extension('ui://Common/itemResources', ItemResources)

function ItemResources:ctor()
    self:AddListener(self.onClick,
        function()
            UIMgr:Open("ResourceDisplay", self.category, nil, nil, function()
                Event.Broadcast(EventDefines.UIResourcesDisplayClose)
            end)
        end
    )
end

function ItemResources:Init(category)
    self.category = category
    self._icon.icon = UITool.GetIcon(ConfigMgr.GetItem('configResourcess', category).img)
    self._title.text = GD.ResAgent.Amount(category, true)
end

return ItemResources
