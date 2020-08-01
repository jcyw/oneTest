local ItemBtnBoxName = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/btnBoxName", ItemBtnBoxName)

function ItemBtnBoxName:ctor()
    self._c2 = self:GetController("c2")
    self._ctrView = self:GetController("c1")
    self._textName = self:GetChild("title")
    self._btnTouch = self:GetChild("btnTouch")
    self:AddListener(self._btnTouch.onClick,
        function()
            if not self.data then
                return
            end
            UIMgr:Open("CumulativeAttendancePopup", {self.data.gift, self._ctrView.selectedIndex})
        end
    )

    self.state = false
    self.front, self.behind = nil, nil
end

function ItemBtnBoxName:SetName(name)
    self._textName.text = name
end

function ItemBtnBoxName:SetType(isNormal)
    self.isNormal = isNormal
end

function ItemBtnBoxName:SetState(index)
    self._ctrView.selectedIndex = index
    if self._ctrView.selectedIndex == 1 then
        self.front, self.behind = AnimationModel.GiftEffect(self, Vector3(1.3, 1.3, 1), Vector3(1, 1, 1), "ItemBtnBoxName"..self._textName.text, self.front, self.behind)
    else
        AnimationModel.DisPoseGiftEffect("ItemBtnBoxName"..self._textName.text, self.front, self.behind)
    end
end

function ItemBtnBoxName:SetData(data)
    self.data = data
end

function ItemBtnBoxName:SetC2Controller(index)
    self._c2.selectedIndex = index
end

return ItemBtnBoxName
