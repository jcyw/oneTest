--[[
    author:Temmie
    time:2019-11-22 20:51:50
    function:语言切换界面
]]
local SetupLanguage = UIMgr:NewUI("SetupLanguage")
local LanguageModel = import("Model/LanguageModel")

function SetupLanguage:OnInit()
    self:InitList()

    self:AddListener(self._btnReturn.onClick,function()
        UIMgr:Close("SetupLanguage")
    end)
end

function SetupLanguage:OnOpen()
    
end

function SetupLanguage:InitList()
    local configs = ConfigMgr.GetList("configLanguages")
    table.sort(configs, function(a,b)
        return b.show_order >= a.show_order
    end)
    self._list:RemoveChildrenToPool()
    for _,v in pairs(configs) do
        local item = self._list:AddItemFromPool()
        item:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, v.text)

        local check = item:GetChild("check"):GetChild("check")
        if ConfigMgr:GetLocale() == v.language then
            check.visible = true
            self:ClearListener(item.onClick)
        else
            check.visible = false
            self:ClearListener(item.onClick)
            self:AddListener(item.onClick,function()
                local data = {
                    content = StringUtil.GetI18n(I18nType.Commmon, "ALERT_CHANGE_LANGUAGE", {language = StringUtil.GetI18n(I18nType.Commmon, v.local_text)}),
                    sureCallback = function()
                        Net.UserInfo.SetUserLanguage(v.id, function(rsp)
                            LanguageModel.SetLanguageCache(v.id)              
                            Network.Relogin()
                        end)
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
            end)
        end

    end
end

return SetupLanguage