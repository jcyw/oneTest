-- author:{zhanzhang}
-- time:2019-06-13 19:16:41
--function{雷达成员详情}
local CommonModel = import("Model/CommonModel")
local BuildModel = import("Model/BuildModel")
local ItemRadar2 = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemRadar2", ItemRadar2)

ItemRadar2.tempList = {}

function ItemRadar2:ctor()
    self._nameText = self:GetChild("textName")
    self._numText = self:GetChild("textNumber")
    self._controller = self:GetController("c1")
    self._icon = self:GetChild("n59")
    self.tempList = {}

    self._icon_x = self._icon.x

    self:InitEvent()
end

function ItemRadar2:InitEvent()
    self:AddListener(self.onClick,
        function()
            if self._controller.selectedIndex == 1 then
                self._controller.selectedIndex = 0
                self.height = 128
            else
                self._controller.selectedIndex = 1
                self:ShowDetail()
                self.height = self._height * 133 + 178
            end
        end
    )
end

function ItemRadar2:Init(data)
    local buildInfo = BuildModel.FindByConfId(417000)
    local buildLevel = buildInfo.Level
    self.isDetail = false
    self._controller.selectedIndex = 0
    self.height = 128
    self._height = 0
    self._nameText.text = data.Name
    -- CommonModel.SetUserAvatar(self._icon, data.Avatar)
    self._icon:SetAvatar(data)
    self.ArmiesList = {}
    self.data = data

    if buildLevel > 6 then
        self._height = self._height + #data.Beasts
    end
    if buildLevel > 10 then
        self._height = self._height + #data.Armies
    end
    self._height = #data.Beasts + #data.Armies
    self._contentList:RemoveChildrenToPool()
    self._contentList.height = self._height * 133 + 178
end

function ItemRadar2:ShowDetail()
    if self.isDetail then
        return
    end

    self._contentList:RemoveChildrenToPool()
    local item = self._contentList:AddItemFromPool()
    --13解锁数量
    item:Init(self.data, 0)
end

return ItemRadar2
