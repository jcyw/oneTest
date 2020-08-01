--[[
    author:{zhanzhang}
    time:2019-06-06 16:13:49
    function:{地图搜索选项}
]]
local ItemLookupBtn = fgui.extension_class(GButton)
fgui.register_extension("ui://WorldCity/ItemLookupBtn", ItemLookupBtn)

---ItemLookupBtn   环状操作列表item
function ItemLookupBtn:ctor()
    self._icon = self:GetChild("icon")
    self._iconLock = self:GetChild("iconLock")
    self._title = self:GetChild("title")
    self._lockController = self:GetController("c1")
    --选择控制器 0未选中 1为选中
    self._selectController = self:GetController("c2")
    self:AddListener(self.onClick,
        function()
            if self.isLock then
                local centerLevel = (BuildModel.GetCenterLevel()) or 0
                if self.data.condition > centerLevel then
                    TipUtil.TipById(13010+self.selectId, {level = self.data.condition})
                    return
                end
                return
            end

            Event.Broadcast(EventDefines.UISelectMapSearch, self.selectId)
        end
    )
    self:AddEvent(
        EventDefines.UISelectMapSearch,
        function(id)
            if id == self.selectId then
                --1为选中状态
                self._selectController.selectedIndex = 1
            else
                self._selectController.selectedIndex = 0
            end
        end
    )
end

function ItemLookupBtn:init(data, isUnLock)
    self.isLock = not isUnLock
    self.data = data
    self.selectId = data.id
    self._icon.url = UITool.GetIcon(data.img)
    -- self.grayed = not isUnLock
    self._lockController.selectedIndex = isUnLock and 0 or 1
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "MAP_SEARCH_TEXT_" .. data.id)
end

function ItemLookupBtn:Use()
    -- body
end

function ItemLookupBtn:FreeUse()
    -- body
end
