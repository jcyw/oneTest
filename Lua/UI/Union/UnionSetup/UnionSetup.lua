--[[
    Author: songzeming
    Function: 联盟设置界面
]]
local UnionSetup = UIMgr:NewUI("UnionSetup/UnionSetup")

local UnionModel = import("Model/UnionModel")
local UnionMemberModel = import("Model/Union/UnionMemberModel")
import("UI/Union/UnionSetup/ItemUnionSetup")
import("UI/Union/UnionSetup/ItemUnionSetupDeclaration")
import("UI/Union/UnionSetup/ItemUnionSetupRecruit")
import("UI/Union/UnionSetup/ItemUnionSetupName")
import("UI/Union/UnionSetup/ItemUnionSetupLanguage")
import("UI/Union/UnionSetup/ItemUnionSetupAppellation")
import("UI/Union/UnionSetup/ItemUnionSetupFlag")
import("UI/Union/UnionSetup/ItemUnionSetupSocialInfo")
import("UI/Union/UnionSetup/ItemUnionSetupOnlineReminder")
import("UI/Union/UnionSetup/ItemUnionSetupFortressName")

local function GetUrl(type)
    if type == "Ui_Modify_Declaration" then
        --修改联盟宣言
        return "ui://Union/itemUnionReviseDeclaration"
    end
    if type == "Ui_Modify_Recruit" then
        --修改联盟招募
        return "ui://Union/itemUnionRevisePublicOffering"
    end
    if type == "Ui_Name" or type == "Ui_Ui_hort" then
        --修改联盟名称、简称
        return "ui://Union/itemUnionReviseName"
    end
    if type == "Ui_Changing_Language" then
        --修改联盟交流语言
        return "ui://Union/itemUnionReviseLanguage"
    end
    if type == "Ui_Class_Appellation" then
        --修改联盟称谓
        return "ui://Union/itemUnionReviseClassAppellation"
    end
    if type == "Ui_Change_Flag" then
        --修改联盟旗帜
        return "ui://Union/itemUnionReviseFlag"
    end
    if type == "Ui_Modifying_SocialRelations" then
        --修改联盟社交信息
        return "ui://Union/itemUnionReviseSocial"
    end
    if type == "Ui_Jurisdiction_1038" then
        --修改联盟成员上线提醒
        return "ui://Union/itemUnionOnLinePrompt"
    end
    if type == "Ui_FortressName_change" then
        --修改联盟堡垒名字
        return "ui://Union/itemUnionReviseClassFortressAppellation"
    end
end

function UnionSetup:OnInit()
    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("UnionSetup/UnionSetup")
    end)
end

function UnionSetup:OnOpen()
    -- 策划要求屏蔽联盟堡垒改名功能
    -- Net.AllianceBuildings.FortressList(Model.Player.AllianceId, function(rsp)
    --     if rsp.Fail then
    --         return
    --     end

    --     self.fortresseInfos = rsp.Fortresses
    --     self:OnInitUI()
    -- end)

    -- 屏蔽联盟堡垒改名功能
    self.itemList = {}
    self.fortresseInfos = {}
    self:OnInitUI()
end

function UnionSetup:OnClose()
    self._list.numItems = 0
end

function UnionSetup:OnInitUI()
    local members = UnionMemberModel.GetMembers()
    local conf = ConfigMgr.GetList("configeSetJurisdictions")
    local confData = UnionModel.GetPermissionsByConf(conf)
    local arr = confData[Model.Player.AlliancePos]
    self._list.numItems = #arr
    for k, v in pairs(arr) do
        local confItem = conf[v]
        if confItem.name == "Ui_FortressName_change" and #self.fortresseInfos <=0 then
            self._list:RemoveChildAt(k - 1, false)
        else
            local item = self._list:GetChildAt(k - 1)
            local name = confItem.name
            local icon = confItem.icon
            local title = StringUtil.GetI18n(I18nType.Commmon, name)
            self.itemList[name] = item
            item:Init(title, icon, function(isOpen)
                local index = self._list:GetChildIndex(item)
                if not isOpen then
                    local box = self._list:GetChildAt(index + 1)
                    self._list:RemoveChildToPool(box)
                else
                    local url = GetUrl(name)
                    local box = self._list:AddItemFromPool(url)
                    self._list:SetChildIndex(box, index + 1)
                    if name == "Ui_Name" or name == "Ui_Ui_hort" then
                        box:Init(name)
                    elseif name == "Ui_Jurisdiction_1038" then
                        box:Init(members)
                    elseif name == "Ui_FortressName_change" then
                        box:Init(self.fortresseInfos)
                    else
                        box:Init()
                    end
                end
            end)
        end
    end
end

return UnionSetup