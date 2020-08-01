--[[
    Author: songzeming
    Function: 建筑创建
]]
local BuildCreate = UIMgr:NewUI("BuildRelated/BuildCreate")

local BuildModel = import("Model/BuildModel")
local UpgradeModel = import("Model/UpgradeModel")
local GuidePanel = import("Model/GuideControllerModel")
local JumpMapModel = import("Model/JumpMapModel")
local UIType = _G.GD.GameEnum.UIType
import("UI/MainCity/BuildRelated/ListBuildSlide")
import("UI/MainCity/BuildRelated/BuildCommon/ItemBuildInfo")

function BuildCreate:OnInit()
    local view = self.Controller.contentPane
    self._view = view
    self._ctr = view:GetController("Ctr")

    self._touchMask = self._btnBuild:GetChild("_touchMask")
    self:AddListener(self._btnBuild.onClick,
        function()
            self:OnBtnBuildClick()
            if self.triggerFunc then
                self.triggerFunc()
            end
        end
    )
    self:AddListener(self._btnReturn.onClick,
        function()
            self:DoClose()
        end
    )

    GuidePanel:SetParentUI(self, UIType.BuildCreateUI)
end

function BuildCreate:OnOpen(pos, confId)
    ScrollModel.Scale(pos, true)
    self.pos = pos
    self._btnBuild.enabled = true
    self.IsVisible = true
    self._btnBuild.grayed = false
    self._touchMask.visible = GlobalVars.IsTriggerStatus

    if not confId then
        local c = PlayerDataModel:GetData(PlayerDataEnum.BUILD_CREATE)
        if c then
            confId = tonumber(c)
        end
    end

    local slide_func = function()
        self:ResetInfo()
    end
    local isGuideShow = GuidePanel:IsGuideState(self.pos)
    if isGuideShow == true then
        local buildId = JumpMapModel:GetBuildId()
        self._slide:Init(slide_func, pos, buildId)
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.BuildCreateUI)
    else
        self._slide:Init(slide_func, pos, confId)
    end
end

--设置推荐位置
function BuildCreate:SetRecommendPos(confId, flag)
    self._slide:SetRecommendPos(confId, flag)
end

function BuildCreate:DoClose()
    UIMgr:Close("BuildRelated/BuildCreate")
end

function BuildCreate:OnClose()
    ScrollModel.SetScaling(false)
    self:ShowImage(false)
    self.IsVisible = false
    Event.Broadcast(EventDefines.CloseGuide)
end

--建筑显示和地图块显示
function BuildCreate:ShowImage(flag)
    local piece = CityMapModel.GetCityMap():GetMapPiece(self.pos)
    if flag then
        local img = UITool.GetIcon(UpgradeModel.GetIcon(self.building.id, 1))
        Event.Broadcast(EventDefines.UICityBuildImage, img)
        piece:SetPieceActive(false)
    else
        Event.Broadcast(EventDefines.UICityBuildImage)
        if BuildModel.FindByPos(self.pos) == nil then
            piece:SetPieceActive(true)
        end
    end
end

--刷新数据
function BuildCreate:ResetInfo()
    self.building = self._slide:GetShowItem():GetBuilding()
    local config = ConfigMgr.GetItem("configBuildings", self.building.id)
    local sound = config.building_click_line
    if sound then
        AudioModel.Play(sound)
    end
    --建筑显示和地图块显示
    self:ShowImage(true)

    self._info:Init("", BuildModel.GetName(self.building.id))
    self._desc.text = BuildModel.GetDesc(self.building.id)
    local lock_func = function()
        local values = {
            building_name = BuildModel.GetName(Global.BuildingCenter),
            building_levle = self.building.unlock_level
        }
        local args = StringUtil.GetI18n(I18nType.Commmon, "Ui_Building_Requirement", values)
        self._condition.text = UITool.GetTextColor(GlobalColor.Red, args)
    end

    local isLock = self.building.unlock_level > Model.Player.Level
    self._info:SetAlpha(isLock and 0.75 or 1)
    if BuildModel.IsInnerOrBeastByPos(self.pos) then
        lock_func()
        self._condition.visible = isLock
    else
        if isLock then
            lock_func()
        else
            local unlockLv
            local amounts = self.building.amounts
            for k, v in ipairs(amounts) do
                if Model.Player.Level < v.base_level then
                    unlockLv = amounts[k - 1 < 1 and 1 or k - 1].amount
                    break
                end
            end
            if not unlockLv then
                unlockLv = self.building.amount or 0
            end
            local num = #BuildModel.GetAll(self.building.id)
            local lock = num >= unlockLv
            self._btnBuild.grayed = lock
            local values = {
                num_now = num,
                num_limit = unlockLv
            }
            local args = StringUtil.GetI18n(I18nType.Commmon, "Ui_Building_Can_Build", values)
            self._condition.text = UITool.GetTextColor(lock and GlobalColor.Red or GlobalColor.Green, args)
        end
        self._condition.visible = true
    end
end

--点击建筑创建按钮
function BuildCreate:OnBtnBuildClick()
    if self._btnBuild.grayed then
        --建筑数量超过指定数量 不可建造
        local sameBuild = BuildModel.GetAll(self.building.id)
        local num = #sameBuild
        if num >= self.building.amount then
            --建筑数量最大值 不可建造
            TipUtil.TipById(50094)
            return
        end
        local unlockLv
        local amounts = self.building.amounts
        for _, v in ipairs(amounts) do
            if Model.Player.Level < v.base_level then
                unlockLv = v.base_level
                break
            end
        end
        if not unlockLv then
            unlockLv = self.building.amounts[#self.building.amounts].base_level
        end
        local values = {
            base_name = BuildModel.GetName(Global.BuildingCenter),
            base_level = unlockLv
        }
        TipUtil.TipById(30602, values)
    else
        --可建造 跳转升级界面
        ScrollModel.LRMove(-1, true)
        UIMgr:Open("BuildRelated/BuildUpgrade", self.pos, self.building)
    end
end

function BuildCreate:GuildShow()
    self._touchMask.visible = true
    return self._btnBuild
end

function BuildCreate:TriggerOnclick(callback)
        self.triggerFunc = callback
end

return BuildCreate
