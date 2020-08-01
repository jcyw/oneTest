--[[
    author:Temmie
    time:2019-12-02 20:22:41
    function:更换头像道具使用弹窗
]]
local BackpackImageModification = UIMgr:NewUI("BackpackImageModification")
local DressUpModel = import("Model/DressUpModel")

_G.BackpackImageModificationType = {
    Head = 1,
    AvatarAndHead = 2,
}

function BackpackImageModification:OnInit()
    self:AddListener(self._btnOK.onClick,function()
        local func = function()
            if self.type == _G.BackpackImageModificationType.AvatarAndHead then
                Net.UserInfo.ModifyUserAvatarAndBust(self.selected, function()
                    Model.Player.Avatar = tostring(self.selected)
                    Model.Player.Bust = self.selected
                    Event.Broadcast(EventDefines.UIPlayerInfoExchange)
                    if self.useCb then
                        self.useCb()
                    end

                    TipUtil.TipById(50123)
                    UIMgr:Close("BackpackImageModification")
                end)
            elseif self.type == _G.BackpackImageModificationType.Head then
                Net.UserInfo.ModifyUserAvatarToSystemAvatar(self.selected, function()
                    Model.Player.Avatar = tostring(self.selected)
                    Event.Broadcast(EventDefines.UIPlayerInfoExchange)
                    if self.useCb then
                        self.useCb()
                    end

                    TipUtil.TipById(50313)
                    UIMgr:Close("BackpackImageModification")
                end)
            end
        end

        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Ui_PlayImage_ChangeTips"),
            buttonType = "double",
            sureCallback = function()
                func()
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    end)
    
    self:AddListener(self._bgMask.onClick,function()
        UIMgr:Close("BackpackImageModification")
    end)

    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("BackpackImageModification")
    end)
end

function BackpackImageModification:OnOpen(type, useCallback)
    self.selected = 0
    self.type = type
    self.items = {}
    self._btnOK.enabled = false
    self.useCb = useCallback

    if type == _G.BackpackImageModificationType.AvatarAndHead then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_PlayImage_Change_title")
        self._desc.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_PlayImage_Change")
    elseif type == _G.BackpackImageModificationType.Head then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_PlayHead_Portrait")
        self._desc.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_PlayHead_Choose")
    end

    self:RefreshList()
end

function BackpackImageModification:RefreshList()
    self._list:RemoveChildrenToPool()
    local configs = ConfigMgr.GetList("configAvatars")
    local datas = configs
    if self.type == _G.BackpackImageModificationType.AvatarAndHead then
        datas = {}
        for _,v in pairs(configs) do
            if v.bust then
                table.insert(datas, v)
            end
        end
    end

    for _,v in pairs(datas) do
        if v.avatar_type == 0 then
            local item = {}
            local object = self._list:AddItemFromPool()
            -- object:GetChild("icon").url =  UITool.GetIcon(v.avatar)
            object:SetAvatar(v.avatar, "custom")
            item.object = object
            item.config = v
            -- item.controller = object:GetController("c1")
            -- item.controller.selectedIndex = 0
            self:ClearListener(object.onClick)
            self:AddListener(object.onClick,function()
                self.selected = item.config.id
                -- item.controller.selectedIndex = 1
                item.object:SetChoose(true)
                for _,v1 in pairs(self.items) do
                    if v1.config.id ~= item.config.id then
                        -- v1.controller.selectedIndex = 0
                        v1.object:SetChoose(false)
                    end
                end

                local isSelected = false
                if self.type == _G.BackpackImageModificationType.Head and Model.Player.Avatar == tostring(self.selected) then
                    isSelected = true
                elseif self.type == _G.BackpackImageModificationType.AvatarAndHead and Model.Player.Bust == self.selected then
                    isSelected = true
                else
                    isSelected = false
                end

                if isSelected then
                    self._btnOK.enabled = false
                else
                    self._btnOK.enabled = true
                end
            end)

            table.insert(self.items, item)
        end
    end
end

return BackpackImageModification