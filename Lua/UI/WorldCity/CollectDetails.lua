--采矿详情
local CollectDetails = UIMgr:NewUI("CollectDetails")

local MapModel = import("Model/MapModel")
local ArmiesModel = import("Model/ArmiesModel")
local BuffItemModel = import("Model/BuffItemModel")
local DetailModel = import("Model/DetailModel")
import("Enum/ResType")
local armiesList = {}

local mineInfo
function CollectDetails:OnInit()
    local view = self.Controller.contentPane
    self:AddListener(view:GetChild("bgMask").onClick,
        function()
            UIMgr:Close("CollectDetails")
        end
    )

    self.armyList = {}
    self._content = view:GetChild("liebiao")
    self._content:SetVirtual()
    self._content.itemRenderer = function(index, item)
        if index < math.ceil(self.beastNum / 2) then
            local itemIndex = index * 2 + 1
            item:Init(self.beastList[1], self.beastNum >= (itemIndex + 1) and self.beastList[itemIndex + 1], true)
        else
            local itemIndex = (index - math.ceil(self.beastNum / 2)) * 2 + 1
            if #self.armyList >= itemIndex then
                item:Init(self.armyList[itemIndex], #self.armyList >= (itemIndex + 1) and self.armyList[itemIndex + 1], false)
            end
        end
    end
    self._content.numItems = 0

    self:AddListener(self._btnAddition.onClick,
        function()
            UIMgr:Close("CollectDetails")
            UIMgr:Open("CollectBuff", mineInfo)
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("CollectDetails")
        end
    )
    self.calCollectFunc = function()
        self:CalCollection()
    end
    self:AddEvent(
        EventDefines.UIBuffUpdate,
        function(val)
            if not self.visible then
                Log.Info("界面未开启不需要刷新")
                return
            end
        end
    )
end

function CollectDetails:OnOpen(info)
    mineInfo = info
    local posX, posY = MathUtil.GetCoordinate(mineInfo.Id)
    self.model = BuffItemModel.GetModelByConfigId(Global.GatherSpeedBuffCategory)
    self.configInfo = ConfigMgr.GetItem("configMines", mineInfo.ConfId)
    -- self._iconBuild.icon = UITool.GetIcon(self.configInfo.mine_icon)
    self.detailInfo = MapModel.GetMineOwner(mineInfo.Id)
    --总量
    local mineType = math.floor(mineInfo.ConfId / 1000)
    self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "MAP_RESOURCETYPE_" .. mineType, {level = math.floor(mineInfo.ConfId % 100)})
    --坐标
    self._textCoordinateNum.text = StringUtil.GetCoordinataStr(posX, posY)
    local baseSpeed = 0
    local baseConfig = DetailModel.GetCenterConf(Global.BuildingCenter + Model.Player.Level)
    mineType = math.floor(mineType % 10)
    if mineType == ResType.iron then
        baseSpeed = baseConfig.collect_speed_iron
    elseif mineType == ResType.food then
        baseSpeed = baseConfig.collect_speed_food
    end
    baseSpeed = baseSpeed + self.configInfo.collect_speed
    self._btnAddition.visible = mineType ~= ResType.diamond
    self._textSpeedNum.text = math.floor(self.detailInfo.MineSpeed) .. StringUtil.GetI18n(I18nType.Commmon, "UI_COLLECT_PERHOUR")
    self._textBuffTimeNum.text = "00:00:00"
    self.armyList = self.detailInfo.Armies
    self.beastList = self.detailInfo.Beasts
    self.beastNum = 0
    for _, v in pairs(self.beastList) do
        self.beastNum = self.beastNum + 1
    end
    self._content.numItems = math.ceil(#self.armyList / 2) + math.ceil(self.beastNum / 2)
    self.buffTime = 0
    local addSpeed = math.ceil(self.detailInfo.MineSpeed - baseSpeed)
    if addSpeed > 0 then
        self._textAddition.text = "+" .. addSpeed
    else
        self._textAddition.text = ""
    end

    if self.model then
        self.buffTime = self.model.ExpireAt - Tool.Time()
    end

    self._textTotalNum.text = self.detailInfo.MineStartLeft
    self:UnSchedule(self.calCollectFunc)

    self:Schedule(self.calCollectFunc, 1, true)
end

function CollectDetails:OnClose()
    self:UnSchedule(self.calCollectFunc)
end

function CollectDetails:CalCollection()
    local getNum = MapModel.CalCollection(mineInfo.Id)
    if self.detailInfo.MineStartLeft <= getNum then
        self:UnSchedule(self.calCollectFunc)
        UIMgr:Close("CollectDetails")
        return
    end

    --已经采集数量
    self._textCollectionNum.text = getNum
    if self.buffTime > 0 then
        self.buffTime = self.buffTime - 1
        self._textBuffTimeNum.text = Tool.FormatTime(self.buffTime)
    else
        self._textBuffTimeNum.text = "00:00:00"
    end
end

return CollectDetails
