--author: 	Amu
--time:		2020-07-07 16:07:00

local DressUpModel = import("Model/DressUpModel")

local BottomControl = fgui.extension_class(GComponent)
fgui.register_extension("ui://Individuation/BottomControl", BottomControl)

function BottomControl:ctor()
    self.configDressUpType = ConfigMgr.GetList("configDressupTypes")
    self:InitEvent()
end

function BottomControl:InitEvent()

    self._dressUpListView.itemRenderer = function(index, item)
        if not index then 
            return
        end

        item:SetData(self.configDressUpType[index+1])
    end
    self._itemListView.scrollPane.decelerationRate = 0
    self._itemListView.itemRenderer = function(index, item)
        if not index then 
            return
        end

        item:SetData(self._curSelectInfo[index+1])
    end

    self:AddEvent(DRESSUP_EVENT.ChoseChange, function(dressUpType)
        -- DressUpModel.RevertDefaultDressUp(dressUpType)
        self._curSelectInfo = DressUpModel.GetCurSelectDressUpInfo()
        if self._curSelectInfo then
            self._itemListView.numItems = #self._curSelectInfo
        end
    end)
end

function BottomControl:OnOpen()
    self:Refresh()
end

function BottomControl:Refresh()
    -- self._itemShow:Refresh()
    
    self._curSelectInfo = DressUpModel.GetCurSelectDressUpInfo()
    if self._curSelectInfo then
        self._itemListView.numItems = #self._curSelectInfo
    end
    self._dressUpListView.numItems = #self.configDressUpType
end

return BottomControl