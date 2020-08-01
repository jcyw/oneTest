--[[
    Author: songzeming
    Function: 修改玩家旗帜/修改联盟旗帜
]]
local PlayerFlag = UIMgr:NewUI("PlayerFlag")

local UnionInfoModel = import("Model/Union/UnionInfoModel")
import("UI/PlayerDetail/ItemPlayerFlag")

function PlayerFlag:OnInit()
    self:AddListener(self._btnSure.onClick,function()
        self:ExgFlag()
    end)
    self:AddListener(self._btnClose.onClick,function()
        self:DoClose()
    end)

    self.flags = ConfigMgr.GetList("configFlags")
    self._listView.itemRenderer = function(index, item)
        if not index then
            return
        end
        local flag = self.flags[index+1]
        item:SetData(flag)
        if self.chooseFlag == flag.id or (not self.chooseFlag and flag.id == self.info.Flag) then
            item:SetLight(true)
            self.selectItem = item
            self._btnSure.enabled = self.info.Flag ~= self.selectItem:GetIndex()
            self._textFlag.text = flag.language
        else
            item:SetLight(false)
        end
    end
    self._listView:SetVirtual()

    self:AddListener(self._listView.onClickItem,function(context)
        local item = context.data
        if self.selectItem then
            self.selectItem:SetLight(false)
        end
        self.selectItem = item
        item:SetLight(true)
        local id = item:GetIndex()
        self.chooseFlag = id
        self._textFlag.text = ConfigMgr.GetItem("configFlags", id).language
        self._btnSure.enabled = self.info.Flag ~= id
    end)
end

function PlayerFlag:OnOpen(type)
    self.type = type
    self._btnSure.enabled = false

    if self.type == FLAG_TYPE.Alliance then
        self.info = UnionInfoModel.GetInfo()
    elseif self.type == FLAG_TYPE.Player then
        self.info = Model.Player
    end
    
    local flag = ConfigMgr.GetListBySearchKeyValue("configFlags", "id", self.info.Flag)
    if flag then
        self._textFlag.text = flag[1].language
    end

    self.chooseFlag = nil
    self._listView.numItems = #self.flags
end

function PlayerFlag:Choose(index)
    self.chooseIndex = index
    for i = 1, self._listView.numChildren do
        local item = self._listView:GetChildAt(i - 1)
        item:SetLight(i == index)
        local id = item:GetIndex()
        self._textFlag.text = ConfigMgr.GetItem("configFlags", id).language
    end
    self._btnSure.enabled = self.info.Flag + 1 ~= index
end

function PlayerFlag:ExgFlag()
    local flag = self.selectItem:GetIndex()
    if self.type == FLAG_TYPE.Alliance then
        --修改联盟旗帜
        Net.Alliances.ChangeFlag(flag, function()
            self.changeSuccess = true
            local info = UnionInfoModel.GetInfo()
            info.Flag = flag
            Event.Broadcast(EventDefines.UIAllianceInfoExchanged)
            TipUtil.TipById(50127)
            self:DoClose()
        end)
    elseif self.type == FLAG_TYPE.Player then
        --修改玩家旗帜
        Net.UserInfo.ModifyUserFlag(flag, function()
            Model.Player.Flag = flag
            Event.Broadcast(EventDefines.UIPlayerInfoExchange)
            TipUtil.TipById(50128)
            self:DoClose()
        end)
    end
end

function PlayerFlag:DoClose()
    UIMgr:Close("PlayerFlag")
end

return PlayerFlag