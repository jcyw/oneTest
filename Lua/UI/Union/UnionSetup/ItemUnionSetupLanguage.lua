--[[
    Author: songzeming
    Function: 联盟设置 修改联盟交流语言列表
]]
local ItemUnionSetupLanguage = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionReviseLanguage", ItemUnionSetupLanguage)

local UnionInfoModel = import("Model/Union/UnionInfoModel")
import("UI/Union/UnionSetup/ItemUnionSetupLanguageBox")

function ItemUnionSetupLanguage:ctor()
end

function ItemUnionSetupLanguage:Init()
    local info = UnionInfoModel.GetInfo()
    local confLanguage = ConfigMgr.GetList("configAlliancelanguages")
    self._list.numItems = #confLanguage
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local conf = confLanguage[i]
        local title = StringUtil.GetI18n(I18nType.Commmon, conf.local_text)
        local choose = conf.id == info.Language
        item:Init(title, choose, function()
            self:Choose(i)
        end)
    end
end

function ItemUnionSetupLanguage:Choose(index)
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        item:SetCheck(i == index)
    end
    local confLanguage = ConfigMgr.GetList("configAlliancelanguages")
    local conf = confLanguage[index]
    local language = conf.id
    Net.Alliances.ChangeLanguage(language, function()
        TipUtil.TipById(50167)
        local info = UnionInfoModel.GetInfo()
        info.Language = language
        Event.Broadcast(EventDefines.UIAllianceInfoExchanged)
    end)
end

return ItemUnionSetupLanguage