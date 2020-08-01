--[[
    Author: songzeming
    Function: 联盟设置 修改联盟社交信息
]]
local ItemUnionSetupSocialInfo = fgui.extension_class(GComponent)
fgui.register_extension('ui://Union/itemUnionReviseSocial', ItemUnionSetupSocialInfo)

local UnionInfoModel = import('Model/Union/UnionInfoModel')
import('UI/Union/UnionSetup/ItemUnionSetupSocialInfoBtn')

function ItemUnionSetupSocialInfo:ctor()
    self._list = self._listBox:GetChild('list')

    self:AddListener(self._btnSave.onClick,
        function()
            self:ExgSocial()
        end
    )
    self:AddListener(self._desc.onFocusOut,
        function()
            self:Check()
        end
    )
    self:AddListener(self._desc.onChanged,
        function()
            self._desc.text = string.gsub(self._desc.text, "[\t\n\r[%]]+", "")
        end
    )
    self._arrow = self._btnArrow:GetChild("icon")
    self:AddListener(self._btnArrow.onClick,
        function()
            self:OnBtnArrowClick()
        end
    )
end

function ItemUnionSetupSocialInfo:Init()
    self.info = UnionInfoModel.GetInfo()
    self._list.numItems = #UnionType.SOCIAL_INFO
    for k, v in pairs(UnionType.SOCIAL_INFO) do
        local title = StringUtil.GetI18n(I18nType.Commmon, v)
        local item = self._list:GetChildAt(k - 1)
        local cb_func = function()
            --点击
            for i = 1, self._list.numChildren do
                self._list:GetChildAt(i - 1):SetLight(false)
            end
            self._title.text = title
            item:SetLight(true)
            self:OnBtnArrowClick()
            self.chooseIndex = k - 1
            self:Check()
        end
        item:Init(cb_func, title)
        --当前选中
        if self.info.SocialType == k - 1 then
            self._title.text = title
            item:SetLight(true)
        end
    end

    self.isOpen = false
    self._arrow.scaleY = -1
    self._listBox.visible = false
    self._btnSave.enabled = false
end

function ItemUnionSetupSocialInfo:OnBtnArrowClick()
    self.isOpen = not self.isOpen
    self._listBox.visible = self.isOpen
    self._arrow.scaleY = self.isOpen and 1 or -1
end

function ItemUnionSetupSocialInfo:Check()
    local isSameType = self.info.SocialType == self.chooseIndex
    local isSameId = self.info.SocialId == self._desc.text
    self._btnSave.enabled = not isSameType or not isSameId
end

function ItemUnionSetupSocialInfo:ExgSocial()
    local socialType = self.chooseIndex
    local socialId = self._desc.text
    Net.Alliances.ChangeSocial(
        socialType,
        socialId,
        function()
            TipUtil.TipById(50178)
            self.info.SocialType = socialType
            self.info.SocialId = socialId
            Event.Broadcast(EventDefines.UIAllianceInfoExchanged)
        end
    )
end

return ItemUnionSetupSocialInfo
