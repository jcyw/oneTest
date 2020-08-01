--author: 	Amu
--time:		2020-07-07 16:06:35

local DressUpModel = import("Model/DressUpModel")

local Individuation = UIMgr:NewUI("Individuation")

function Individuation:OnInit()
    self._view = self.Controller.contentPane

    self._choseItem = UIMgr:CreateObject("Individuation", "Individuationbottom")
    self._view:AddChild(self._choseItem)
    self._choseItem:MakeFullScreen()
    
    self:InitEvent()
    -- self._banner.icon = UITool.GetIcon(GlobalBanner.ArenaBanner)
end

function Individuation:InitEvent( )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    self:AddEvent(DRESSUP_EVENT.ChoseChange, function(dressUpTyp)
        self._dressUpShow:Refresh(dressUpTyp)
        self._choseItem.visible = false
    end)

    self:AddEvent(DRESSUP_EVENT.Chose, function(dressUpList)
        local isForever = false
        local using = false
        local _default = false
        for _,v in ipairs(dressUpList)do
            if (v.ExpireAt - Tool.Time()) > 622080000 then  -- 大于20年  永久
                isForever = true
            end
            if v.DressUpConId == DressUpModel.usingDressUp[DressUpModel.curSelect].DressUpConId then
                using = true
            end
            if v.DressUpSubType == 0 then
                _default = true
            end
        end
        --[[
            if _default then
                if using then
                    self._choseItem.visible = false
                else
                    self._choseItem.visible = true
                    self._choseItem:Refresh(dressUpList)
                end
            elseif #dressUpList == 1 and using and isForever then
                self._choseItem.visible = false
            else
                self._choseItem.visible = true
                self._choseItem:Refresh(dressUpList)
            end
        --]]
        if using then
            self._choseItem.visible = false
        else
            self._choseItem.visible = true
            self._choseItem:Refresh(dressUpList)
        end
    end)

    self:AddEvent(DRESSUP_EVENT.ChangeDressUp, function(dressUpType)
        if DressUpModel.curSelect == dressUpType then
            DressUpModel.GetDressUpType(DressUpModel.curSelect, function()
                DressUpModel.RevertDefaultDressUp(DRESSUP_TYPE.Nameplate)
                self._itemDressUp:OnOpen()
                self._dressUpShow:Refresh(DressUpModel.curSelect)
            end)
            self._choseItem.visible = false
        end
    end)
end

function Individuation:OnOpen(info)
    DressUpModel.curSelect = DRESSUP_TYPE.Nameplate
    DressUpModel.GetDressUpType(DressUpModel.curSelect, function()
        DressUpModel.RevertDefaultDressUp(DRESSUP_TYPE.Nameplate)
        self._itemDressUp:OnOpen()
        self._dressUpShow:Refresh(DressUpModel.curSelect)
        self._dressUpShow:RefreshById()
    end)

    self._choseItem.visible = false
end



function Individuation:Close()
    UIMgr:Close("Individuation")
end

function Individuation:OnClose()
    Event.Broadcast(DRESSUP_EVENT.Close)
    DressUpModel.ClearAllDressUpItemInfo()
end


return Individuation