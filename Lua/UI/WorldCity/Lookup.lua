local Lookup = UIMgr:NewUI("Lookup")

local BuildModel = import("Model/BuildModel")
local PlayerDataEnum = import("Enum/PlayerDataEnum")
local WorldMap = import("UI/WorldMap/WorldMap")
local configList
local canSearchTime = 0
local GuidePanel=import("Model/GuideControllerModel")
function Lookup:OnInit()
    -- body
    local view = self.Controller.contentPane
    self._bgMask = view:GetChild("bgMask")
    self._contentList = view:GetChild("liebiao")
    self._contentList = self._contentList.asList
    self._textSurplus = view:GetChild("textSurplus")
    self._btnLookup = view:GetChild("btnLookup")
    self._btnAdd = view:GetChild("btnAdd")
    self._textNow = view:GetChild("textInput")
    self._textMax = view:GetChild("textInputNum")
    self._slideGroup = view:GetChild("group")
    local box = view:GetChild("bgBox")
    self._tweenIn = view:GetTransition("in")
    self._tweenOut = view:GetTransition("out")
    self._bgInputBox = view:GetChild("bgInputBox")
    self._textName = view:GetChild("textName")
    self:OnRegister()

    self:AddEvent(
        EventDefines.UIWorldMapSerch,
        function()
            self:Search()
        end
    )
    self:AddEvent(
        EventDefines.UISearchTimeChange,
        function()
            self:CheckSearchTime()
        end
    )
end

function Lookup:OnRegister()
    self:AddListener(self._bgMask.onClick,
        function()
            if not self.isOpenFace then
                return
            end

            self:Close()
        end
    )

    --开始查找目标地块
    self:AddListener(self._btnLookup.onClick,
        function()
            if not Model.Player.VipActivated and self.canSearchTime <= 0 then
                TipUtil.TipById(50195)
                return
            end

            self:Search()
        end
    )
    self.silderCallback = function()
        self:ChangeSilder()
    end

    self:AddEvent(
        EventDefines.UISelectMapSearch,
        function(id)
            self.selectType = configList[id]["category"]
            self.maxLevel = configList[id]["max_level"] or 1
            self.condition = configList[id]["condition"]
            self.searchId = id
            local val = self:GetSearchVal(self.selectType)
            if (val and val > 0) then
                self.selectLevel = val
            else
                self.selectLevel = 1
            end
            if (self.selectType == 0) then
                self.maxLevel = Model.ServerMaxMonsterLevel
            end
            self._slide:Init("Lookup", 1, self.maxLevel, self.silderCallback)
            self._slide:SetNumber(self.selectLevel)

            self:RefreshTitle()
        end
    )
end

function Lookup:OnOpen()
    local isGuide=GuidePanel:IsGuideState()
    -- print("UItype:----------",GuidePanelModel.uiType)
    if isGuide and GuidePanel.uiType == _G.GD.GameEnum.UIType.SearchIconUI then
        Event.Broadcast(EventDefines.JumpTipEvent,nil,-1,_G.GD.GameEnum.UIType.LookUpUI)
    end
    self:InitItemInfo()
    self.dataCache = PlayerDataModel:GetData(PlayerDataEnum.MapSearchData)
    if not self.dataCache then
        self.dataCache = {}
    end
    self:CheckSearchTime()
    self.selectType = 0

    self._tweenIn:Play()
    self._contentList.selectedIndex = 0
    Event.Broadcast(EventDefines.UISelectMapSearch, 1)
end

function Lookup:DoOpenAnim(...)
    self.isOpenFace = false
    self:OnOpen(...)
    AnimationLayer.PanelAnim(AnimationType.PanelMoveUp, self, false, function()
        self.isOpenFace = true
    end)
end
function Lookup:DoCloseAnim()
    AnimationLayer.PanelAnim(AnimationType.PanelMoveDown, self, true)
end

function Lookup:Close()
    self.isOpenFace = false
    UIMgr:Close("Lookup")
end

--检测搜索次数
function Lookup:CheckSearchTime()
    if Model.Player.VipActivated then
        self._textSurplus.text = StringUtil.GetI18n(I18nType.Commmon, "MAP_SEARCH_VIP")
        return
    end
    self.canSearchTime = Global.MapSearchTimes - Model.Player.SearchUsed
    self._textSurplus.text = StringUtil.GetI18n(I18nType.Commmon, "MAP_SEARCH_TIMES_LFET", {amount = self.canSearchTime})
end
--进度条变化
function Lookup:ChangeSilder()
    local val = 1
    -- val = math.floor()bux
    self.selectLevel = self._slide:GetNumber()
    self:SetSearchVal()
end

function Lookup:Search()
    if (self.selectType == 0) then
        Net.MapInfos.SearchMonster(
            false,
            self.selectLevel,
            function(val)
                self:CheckSearchTime()
                WorldMap.Instance():MoveToPoint(val.X, val.Y, false, true)
                self:Close()
            end
        )
    else
        local centerLevel = (BuildModel.GetCenterLevel()) or 0
        if self.condition > centerLevel then
            TipUtil.TipById(13010 + self.selectType, {level = self.condition})
            return
        end

        Net.MapInfos.SearchMine(
            self.selectType,
            self.selectLevel,
            function(val)
                self:CheckSearchTime()
                WorldMap.AddEventAfterMap(
                    function()
                        WorldMap.Instance():ChooseLogicPos(MathUtil.GetPosNum(val.X, val.Y))
                    end
                )
                Event.Broadcast(EventDefines.OpenWorldMap, val.X, val.Y)
                self:Close()
            end
        )
    end
end

function Lookup:GetSearchVal()
    if not self.dataCache then
        self.dataCache = {}
    end

    local val = self.dataCache[self.selectType + 1]
    if not val or type(val) ~= "number" then
        val = 0
    end
    return math.floor(val)
end

function Lookup:SetSearchVal()
    self.dataCache[self.selectType + 1] = self.selectLevel
    PlayerDataModel:SetData(PlayerDataEnum.MapSearchData, self.dataCache)
    self:RefreshTitle()
end

function Lookup:OnClose()
    PlayerDataModel:SetData(PlayerDataEnum.MapSearchData, self.dataCache)
end

function Lookup:InitItemInfo()
    self._contentList:RemoveChildrenToPool()
    local centerLevel = (BuildModel.GetCenterLevel()) or 0

    configList = ConfigMgr.GetList("configMapSearchs")
    for i = 1, #configList do
        local item = self._contentList:AddItemFromPool()
        item:init(configList[i], configList[i].condition <= centerLevel)
    end
end
--刷新标题
function Lookup:RefreshTitle()
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, configList[self.searchId].text_level, {level = self.selectLevel})
end

return Lookup
