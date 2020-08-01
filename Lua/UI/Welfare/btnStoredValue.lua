--[[
    author:{maxiaolong}
    time:2019-09-20 15:15:22
    function:{活动中心列表Item}
]]
local btnStoredValue = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/btnStoredValue", btnStoredValue)

function btnStoredValue:ctor()
    self._bg = self:GetChild("bg")
    self._icon = self:GetChild("icon")
    self._name = self:GetChild("n9")
    self._title = self:GetChild("title")
    self.controller = self:GetController("button")
end

--刷新数据
function btnStoredValue:SetData(param, index)
    if not param then
        return
    end
    local itemData = StringUtil.GetI18n(I18nType.Commmon, param.activity_name)
    self._icon.icon = UITool.GetIcon(param.icon)
    self._title.text = itemData
    self._id = param.id
    self.index = index
    self:CheckPoint()
    self:SetChoice(false)
end

--检测红点
function btnStoredValue:CheckPoint()
    for _, v in pairs(CuePointModel.SubType.Welfare) do
        if v.Id == self._id then
            self.sub = v
            CuePointModel:SetSingle(v.Type, v.Number, self, CuePointModel.Pos.RightUp15)
            break
        end
    end
end

--获取Sub
function btnStoredValue:GetSub()
    return self.sub
end

--获取Id
function btnStoredValue:GetId()
    return self._id
end

function btnStoredValue:GetIndex()
    return self.index
end

--设置是否选中
function btnStoredValue:SetChoice(isChoice)
    if isChoice == true then
        print("23333333333333333333333")
        print("selfId-------------------:",self._id)
        self.controller.selectedIndex = 1
    else
        self.controller.selectedIndex = 0
    end
end

return btnStoredValue
