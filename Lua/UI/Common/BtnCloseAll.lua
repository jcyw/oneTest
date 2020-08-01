--author: 	Amu
--time:		2020-01-11 20:36:31

local BtnCloseAll = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/btnCloseAll", BtnCloseAll)

BtnCloseAll.tempList = {}

function BtnCloseAll:ctor()
    self:InitEvent()
end

function BtnCloseAll:InitEvent()
    self:AddListener(self.onClick,function() 
        UIMgr:ClosePopAndTopPanel()
    end)
end

return BtnCloseAll