--[[
    Author: songzeming
    Function: 联盟设置 修改联盟名称和简称
]]
local ItemUnionSetupName = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionReviseName", ItemUnionSetupName)

local UnionInfoModel = import("Model/Union/UnionInfoModel")
local CTR = {
    Name = "Name",
    NameNo = "NameNo",
    NameFree = "NameFree",
    NameFreeNo = "NameFreeNo",
    ShortName = "ShortName",
    ShortNameNo = "ShortNameNo",
    ShortNameFree = "ShortNameFree",
    ShortNameFreeNo = "ShortNameFreeNo"
}

function ItemUnionSetupName:ctor()
    self._ctr = self:GetController("Ctr")

    self:AddListener(self._name.onChanged,
        function()
            self:CheckName()
        end
    )
    self:AddListener(self._shortName.onChanged,
        function()
            self:CheckShortName()
        end
    )
    
    self._goldNo = self._btnGoldNo:GetChild("text")
    self._goldYes = self._btnGold:GetChild("text")
    self:AddListener(self._btnGold.onClick,
        function()
            if self._ctr.selectedPage == CTR.Name then
                self:OnBtnNameGold()
            elseif self._ctr.selectedPage == CTR.ShortName then
                self:OnBtnShortNameGold()
            end
        end
    )
    self:AddListener(self._btnFree.onClick,
        function()
            if self._ctr.selectedPage == CTR.NameFree then
                self:OnBtnNameFree()
            elseif self._ctr.selectedPage == CTR.ShortNameFree then
                self:OnBtnShortNameFree()
            end
        end
    )

    self._btnGoldNo.touchable = false
    self._btnFreeNo.touchable = false
end

function ItemUnionSetupName:Init(title)
    self.title = title
    if title == "Ui_Name" then
        if not PlayerDataModel:GetData(PlayerDataEnum.UNIONFREENAME) then
            self._ctr.selectedPage = CTR.NameFreeNo
        else
            self._ctr.selectedPage = CTR.NameNo
        end
        self._name.text = ""
        self._goldYes.text = Global.AllianceChangeNameFee
        self._goldNo.text = Global.AllianceChangeNameFee
    elseif title == "Ui_Ui_hort" then
        if not PlayerDataModel:GetData(PlayerDataEnum.UNIONFREESHORTNAME) then
            self._ctr.selectedPage = CTR.ShortNameFreeNo
        else
            self._ctr.selectedPage = CTR.ShortNameNo
        end
        self._shortName.text = ""
        self._goldYes.text = Global.AllianceChangeShortNameFee
        self._goldNo.text = Global.AllianceChangeShortNameFee
    end
end

function ItemUnionSetupName:SetValid(flag)
    if flag then
        if self._ctr.selectedPage == CTR.NameNo then
            self._ctr.selectedPage = CTR.Name
        elseif self._ctr.selectedPage == CTR.ShortNameNo then
            self._ctr.selectedPage = CTR.ShortName
        elseif self._ctr.selectedPage == CTR.NameFreeNo then
            self._ctr.selectedPage = CTR.NameFree
        elseif self._ctr.selectedPage == CTR.ShortNameFreeNo then
            self._ctr.selectedPage = CTR.ShortNameFree
        end
    else
        if self._ctr.selectedPage == CTR.Name then
            self._ctr.selectedPage = CTR.NameNo
        elseif self._ctr.selectedPage == CTR.ShortName then
            self._ctr.selectedPage = CTR.ShortNameNo
        elseif self._ctr.selectedPage == CTR.NameFree then
            self._ctr.selectedPage = CTR.NameFreeNo
        elseif self._ctr.selectedPage == CTR.ShortNameFree then
            self._ctr.selectedPage = CTR.ShortNameFreeNo
        end
    end
end
function ItemUnionSetupName:GetValid()
    return self._yes.visible
end

--检测联盟名称是否合法
function ItemUnionSetupName:CheckName()
    -- 去掉回车
    local name = string.gsub(self._name.text, "[\t\n\r[%]]+", "")
    self._name.text = name
    if #name < 3 then
        self:SetValid(false)
    else
        Net.Alliances.NameValid(
            name,
            function(rsp)
                local isValid = rsp.Result == 0
                self:SetValid(isValid)
                if not isValid then
                    TipUtil.TipById(50168)
                end
            end
        )
    end
end
--检测联盟简称是否合法
function ItemUnionSetupName:CheckShortName()
    -- 去掉回车
    local shortName = string.gsub(self._shortName.text, "[\t\n\r[%]]+", "")
    self._shortName.text = shortName
    if #shortName ~= 3 then
        self:SetValid(false)
    else
        Net.Alliances.ShortNameValid(
            shortName,
            function(rsp)
                local isValid = rsp.Result == 0
                self:SetValid(isValid)
                if not isValid then
                    TipUtil.TipById(50169)
                end
            end
        )
    end
end

--免费修改联盟名称
function ItemUnionSetupName:OnBtnNameFree()
    if not self:GetValid() then
        TipUtil.TipById(50172)
        return
    end
    local name = self._name.text
    Net.Alliances.ChangeName(
        name,
        function()
            TipUtil.TipById(50171)
            self._name.text = ""
            local info = UnionInfoModel.GetInfo()
            info.Name = name
            Event.Broadcast(EventDefines.UIAllianceInfoExchanged)
            self:SetValid(false)

            PlayerDataModel:SetData(PlayerDataEnum.UNIONFREENAME, true)
            self:Init(self.title)
        end
    )
end
--钻石修改联盟名称
function ItemUnionSetupName:OnBtnNameGold()
    if not self:GetValid() then
        TipUtil.TipById(50172)
        return
    end
    local values = {
        diamond_num = Global.AllianceChangeNameFee
    }
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "Alliance_ChangeName_Confirm", values),
        gold = Global.AllianceChangeNameFee,
        sureCallback = function()
            self:OnBtnNameFree()
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

--免费修改联盟简称
function ItemUnionSetupName:OnBtnShortNameFree()
    if not self:GetValid() then
        TipUtil.TipById(50173)
        return
    end
    local shortName = self._shortName.text
    Net.Alliances.ChangeShortName(
        shortName,
        function()
            TipUtil.TipById(50174)
            self._shortName.text = ""
            local info = UnionInfoModel.GetInfo()
            info.ShortName = shortName
            Event.Broadcast(EventDefines.UIAllianceInfoExchanged)
            self:SetValid(false)

            PlayerDataModel:SetData(PlayerDataEnum.UNIONFREESHORTNAME, true)
            self:Init(self.title)
        end
    )
end
--钻石修改联盟简称
function ItemUnionSetupName:OnBtnShortNameGold()
    if not self:GetValid() then
        TipUtil.TipById(50173)
        return
    end
    local values = {
        diamond_num = Global.AllianceChangeShortNameFee
    }
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "Alliance_ChangeAkaName_Confirm", values),
        gold = Global.AllianceChangeShortNameFee,
        sureCallback = function()
            self:OnBtnShortNameFree()
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

return ItemUnionSetupName
