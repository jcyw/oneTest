--author: 	Amu
--time:		2019-07-02 14:07:02
local GD = _G.GD
local BtnUnionTaskActive = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/btnUnionTaskActive", BtnUnionTaskActive)

local UnionModel = import("Model/UnionModel")

BtnUnionTaskActive.tempList = {}

function BtnUnionTaskActive:ctor()
    self._title = self:GetChild("title")
    self._icon = self:GetChild("icon")
    self._point = self:GetChild("point1")

    self._ctrView = self:GetController("c1")

    self._pointCtrView = self._point:GetController("c1")

    self.front, self.behind=nil,nil

    self:InitEvent()
end

function BtnUnionTaskActive:InitEvent()
    self:AddListener(self.onClick,function()
        if self.state == RECEIVE_STATE.CanReceive then
            local itemInfos = {
                {
                    id = self.info.gift_id,
                    amount = 1
                }
            }
            UIMgr:Open("UnionTaskActiveRewardPopup", ITEM_TYPE.Gift, itemInfos, true, function()
                -- UnionModel.notReadUnionTask = UnionModel.notReadUnionTask - 1
                -- Event.Broadcast(EventDefines.UIAllianceTaskPonit)
                Event.Broadcast(TASKACTIVETYPE.Claim, self.taskConfId)
            end)
        elseif self.state == RECEIVE_STATE.HavaReceive then
            TipUtil.TipById(50226)
        else
            local itemInfos = {
                {
                    id = self.info.gift_id,
                    amount = 1
                }
            }
            UIMgr:Open("UnionTaskActiveRewardPopup", ITEM_TYPE.Gift, itemInfos, false)
        end
    end)
end

function BtnUnionTaskActive:SetData(info, state)
    self.taskConfId = info.id
    self._title.text = info.target
    self.info = info
    self.state = state
    if self.state == RECEIVE_STATE.CanReceive then
        self._ctrView.selectedIndex = 1
        self._pointCtrView.selectedIndex = 1
    elseif self.state == RECEIVE_STATE.HavaReceive then
        self._ctrView.selectedIndex = 2
        self._pointCtrView.selectedIndex = 1
    else
        self._ctrView.selectedIndex = 0
        self._pointCtrView.selectedIndex = 0
    end

    if self._ctrView.selectedIndex == 1 then
        self.front, self.behind = AnimationModel.GiftEffect(self, nil, nil, "BtnUnionTaskActive"..info.target, self.front, self.behind)
    else
        AnimationModel.DisPoseGiftEffect("BtnUnionTaskActive"..info.target, self.front, self.behind)
    end
end

return BtnUnionTaskActive