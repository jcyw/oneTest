--author: 	Amu
--time:		2019-12-09 15:38:06

local ItemUnionVoteParticipantw = fgui.extension_class(GButton)
fgui.register_extension('ui://Union/itemUnionVoteParticipantw', ItemUnionVoteParticipantw)

local CommonModel = import('Model/CommonModel')

function ItemUnionVoteParticipantw:ctor()
    self._iconFlag.visible = false
end

--投票相关
function ItemUnionVoteParticipantw:SetData(info, type)
    self.info = info
    self._name.text = info.Name
    self._force.text = ConfigMgr.GetI18n('configI18nCommons', 'Ui_Power') .. ': \n' .. Tool.FormatNumberThousands(info.Power)
    -- CommonModel.SetUserAvatar(self._icon, info.Icon)
    self._icon:SetAvatar({Avatar = info.Icon, DressUpUsing = info.DressUpUsing})
    local config = ConfigMgr.GetItem('configLanguages', info.Language)
    if config then
        self._language.text = config.language
    end
end

function ItemUnionVoteParticipantw:GetData()
    return self.info
end

return ItemUnionVoteParticipantw
