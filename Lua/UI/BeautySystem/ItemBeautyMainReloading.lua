--author: 	Amu
--time:		2020-04-23 16:03:19

local BeautyGirlModel = import("Model/BeautyGirlModel")

local ItemBeautyMainReloading = fgui.extension_class(GComponent)
fgui.register_extension("ui://BeautySystem/itemBeautyMainReloading", ItemBeautyMainReloading)

function ItemBeautyMainReloading:ctor()
    self._title = self:GetChild("title")
    self._desc = self:GetChild("text")

    self._btnChange = self:GetChild("btnUse")

    self._listView = self:GetChild("_list").asList


    self._downAnim = self:GetTransition("out")
    self._upAnim = self:GetTransition("In")

    self:InitEvent()
end

function ItemBeautyMainReloading:InitEvent()

    self._listView:SetVirtualAndLoop()
    self._listView.scrollPane.inertiaDisabled = true --惯性禁用
    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        -- item:SetPivot(0.5, 0.5)
        -- local grilInfo = self.girlsInfo[self._selectGirlIndex]
        -- item:SetData(grilInfo.skill[index+1], grilInfo.msg.Exp)
        local clothid = self._girlInfo.clothid[index+1]
        local clothInfo = self._girlInfo.clothInfo[clothid]
        item:SetData(clothInfo, self._girlInfo.msg.Costume, self._girlInfo.msg.OwnCostumes, index)
    end

    self:AddListener(self._listView.scrollPane.onScroll,function()
        self:DoSpecialEffect()
    end)

    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        local index = item:GetIndex()
        if index == (self._selectIndex-1) or index == (self._selectIndex+#self._girlInfo.clothid-1) then
            self._listView.scrollPane:ScrollLeft(1, true)
        end
    end)

    self:AddListener(self._btnChange.onClick,function()
        if self.ChangeCostumeCoolAt <= Tool.Time() then
            local data = {
                content = StringUtil.GetI18n("configI18nCommons", "Girl_Change_Cloth_Tips5"),
                sureCallback = function()
                    Net.Beauties.ChangeCostume(self._girlInfo.id, self.selectClothid, function(msg)
                        self.ChangeCostumeCoolAt = msg.CoolAt
                        Event.Broadcast(BEAUTY_GIRL_EVENT.ChangeChothes, self.selectClothid)
                        Event.Broadcast(BEAUTY_GIRL_EVENT.RefreshChoiceTime, msg.CoolAt)
                        self:RefreshListView()
                        self:DoSpecialEffect()
                    end)
                end
            }
            UIMgr:Open("ConfirmPopupText", data)

        else
            local data = {
                content = StringUtil.GetI18n("configI18nCommons", "Girl_Change_Cloth_Tips6"),
                gold = 300,
                sureCallback = function()
                    Net.Beauties.BuyChangeCostumeCool(function(msg)
                        self.ChangeCostumeCoolAt = 0
                        Event.Broadcast(BEAUTY_GIRL_EVENT.RefreshChoiceTime, 0)
                    end)
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    end)

    self:AddListener(self._btnArrowDown.onClick,function()
        if self._state == 0 then
            self._state = 1
        else
            self._state = 0
        end
        self:RefreshViewShow()
    end)

    self:AddListener(self._btnLeft.onClick,function()
        self._listView.scrollPane:ScrollLeft(1, true)
    end)

    self:AddListener(self._btnRight.onClick,function()
        self._listView.scrollPane:ScrollRight(1, true)
    end)
end

function ItemBeautyMainReloading:RefreshClothes(girlInfo, ChangeCostumeCoolAt)
    self.ChangeCostumeCoolAt = ChangeCostumeCoolAt
    self._girlInfo = girlInfo
    self._state = 1
    self:RefreshListView()
    self:DoSpecialEffect()
    self:RefreshViewShow()
    self:MoveSelectToMid()
end

function ItemBeautyMainReloading:MoveSelectToMid()
    self._listView.scrollPane:SetPercX(0, false)
    for i, id in ipairs(self._girlInfo.clothid) do
        if id == self._girlInfo.msg.Costume then
            self._listView.scrollPane:ScrollRight(i - 2, false)
            break
        end
    end
end

function ItemBeautyMainReloading:DoSpecialEffect()
    local midx = self._listView.scrollPane.posX + self._listView.viewWidth/2
    local cnt = self._listView.numItems
    for i=0, cnt-1, 1 do
        local obj = self._listView:GetChildAt(i)
        local dist = math.abs(midx - obj.x - obj.width/2)
        if dist > obj.width then
            obj:SetScale(1, 1)
        else
            local s = 1 + (1 - dist/obj.width) * 0.24
            obj:SetScale(s, s)
        end
    end

    local selectIndex = math.fmod((self._listView:GetFirstChildInView() + 1), self._listView.numItems)
    if self._selectIndex ~= selectIndex then
        self._selectIndex = selectIndex
        self.selectClothid = self._girlInfo.clothid[self._selectIndex+1]
        local clothInfo = self._girlInfo.clothInfo[self.selectClothid]

        Event.Broadcast(BEAUTY_GIRL_EVENT.ChoiceChothes, self.selectClothid)
    
        if BeautyGirlModel.Shield then
            self._title.text = StringUtil.GetI18n(I18nType.Commmon, clothInfo.spine_clothing_name)
            self._desc.text = StringUtil.GetI18n(I18nType.Commmon, clothInfo.spine_clothing_desc) 
        else
            self._title.text = StringUtil.GetI18n(I18nType.Commmon, clothInfo.clothing_name)
            self._desc.text = StringUtil.GetI18n(I18nType.Commmon, clothInfo.clothing_desc) 
        end
    end

    if self.selectClothid == self._girlInfo.msg.Costume then
        self._btnChange.enabled = false
    else
        self._btnChange.enabled = true
    end
end

function ItemBeautyMainReloading:RefreshListView()
    self._listView.numItems = #self._girlInfo.clothid
end

function ItemBeautyMainReloading:RefreshViewShow(state)
    if state then
        self._state = state
    end
    if self._state == 1 then
        self._upAnim:Play()
    else
        self._downAnim:Play()
    end
end

return ItemBeautyMainReloading