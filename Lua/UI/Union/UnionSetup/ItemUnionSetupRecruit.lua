--[[
    Author: songzeming
    Function: 联盟设置 修改联盟招募
]]
local ItemUnionSetupRecruit = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionRevisePublicOffering", ItemUnionSetupRecruit)

local BuildModel = import("Model/BuildModel")
local UnionInfoModel = import("Model/Union/UnionInfoModel")
import("UI/Common/ItemKeyboard")
local CTR = {
    Choose = "Choose",
    NotChoose = "NotChoose"
}

function ItemUnionSetupRecruit:ctor()
    self._ctr = self:GetController("Controller")

    self:AddListener(self._btnLevel.onClick,
        function()
            local cb = function(num)
                self._level.text = num
                self:CheckBtnSave()
            end
            local _keyboard = UIMgr:CreatePopup("Common", "itemKeyboard")
            _keyboard:Init(self._maxLevel, cb)
            UIMgr:ShowPopup("Common", "itemKeyboard", self._btnLevel)
        end
    )
    self:AddListener(self._btnPower.onClick,
        function()
            local cb = function(num)
                self._power.text = num
                self:CheckBtnSave()
            end
            local _keyboard = UIMgr:CreatePopup("Common", "itemKeyboard")
            _keyboard:Init(self._maxPower, cb)
            UIMgr:ShowPopup("Common", "itemKeyboard", self._btnPower)
        end
    )
    self:AddListener(self._btnSave.onClick,
        function()
            self:ExgRecruit()
        end
    )
    self:AddListener(self._btnChoose.onClick,
        function()
            self:CheckShow()
            self:CheckBtnSave()
        end
    )
    self:AddListener(self._btnHelp.onClick,
        function()
            self:OnBtnHelpClick()
        end
    )
end

function ItemUnionSetupRecruit:Init()
    self._btnSave.enabled = false

    local info = UnionInfoModel.GetInfo()
    self.checkChoose = not info.FreeJoin
    self.levelText = info.FreeJoinLevel
    self.powerText = info.FreeJoinPower
    self._btnChoose.selected = self.checkChoose
    self._level.text = self.levelText
    self._power.text = self.powerText

    local conf = BuildModel.GetConf(Global.BuildingCenter)
    self._maxLevel = conf.max_level
    self._maxPower = Global.AllianceRecruitMaxPower

    self:CheckShow()
end

function ItemUnionSetupRecruit:CheckShow()
    self._ctr.selectedPage = self._btnChoose.selected and CTR.Choose or CTR.NotChoose
end

function ItemUnionSetupRecruit:CheckBtnSave()
    --是否修改
    if self.levelText ~= tonumber(self._level.text) or self.powerText ~= tonumber(self._power.text) or not self.checkChoose ~= not self._btnChoose.selected then
        self._btnSave.enabled = true
    else
        self._btnSave.enabled = false
    end
end

function ItemUnionSetupRecruit:ExgRecruit()
    local freeJoin = not self._btnChoose.selected
    local freeJoinLevel = tonumber(self._level.text)
    local freeJoinPower = tonumber(self._power.text)
    Net.Alliances.ChangeFreeJoin(
        freeJoin,
        freeJoinLevel,
        freeJoinPower,
        function()
            TipUtil.TipById(50177)
            local info = UnionInfoModel.GetInfo()
            info.FreeJoin = freeJoin
            info.FreeJoinLevel = freeJoinLevel
            info.FreeJoinPower = freeJoinPower

            self._btnSave.enabled = false
            self.checkChoose = not freeJoin
            self.levelText = freeJoinLevel
            self.powerText = freeJoinPower
        end
    )
end

function ItemUnionSetupRecruit:OnBtnHelpClick()
    local data = {
        title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
        info = StringUtil.GetI18n(I18nType.Commmon, "Ui_Modify_Tips")
    }
    UIMgr:Open("ConfirmPopupTextList", data)
end

return ItemUnionSetupRecruit
