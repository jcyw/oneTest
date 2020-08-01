--author: 	Amu
--time:		2019-11-05 16:59:39

local BtnMessageShield = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/btnMessageShield", BtnMessageShield)

BtnMessageShield.tempList = {}

function BtnMessageShield:ctor()
    self._title = self:GetChild("title")
    self:InitEvent()
end

function BtnMessageShield:InitEvent()

end

function BtnMessageShield:SetData(name, index)
    self.index = index
    self._title.text = name
end

function BtnMessageShield:getData(  )
    return self.index
end

return BtnMessageShield