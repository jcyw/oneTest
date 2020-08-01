local WorldSearch = UIMgr:NewUI("WorldSearch")

local WorldMap = import("UI/WorldMap/WorldMap")
local nowPosX = 0
local nowPosY = 0

function WorldSearch:OnInit()
    local view = self.Controller.contentPane
    self._Mask = view:GetChild("bgMask")
    self._country = view:GetChild("textServerId")
    self._posX = view:GetChild("textPosX")
    self._posY = view:GetChild("textPosY")
    self._btnGo = view:GetChild("btnGo")
    -- self._btnFavorites = view:GetChild("btnFavorites")
    self:OnRegister()
end

function WorldSearch:OnRegister()
    self._country.enabled = false
    self:AddListener(self._Mask.onClick,
        function()
            UIMgr:Close("WorldSearch")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("WorldSearch")
        end
    )

    self:AddListener(self._posX.onChanged,
        function()
            if self._posX.text ~= "" then
                nowPosX = math.floor(self._posX.text)
                self._posX.text = nowPosX
            end
        end
    )
    -- self:AddListener(self._posX.onFocusIn,
    --     function()
    --         self._posX.text = ""
    --     end
    -- )
    -- self:AddListener(self._posY.onFocusIn,
    --     function()
    --         self._posY.text = ""
    --     end
    -- )
    self:AddListener(self._posX.onFocusOut,
        function()
            if self._posX.text == "" then
                nowPosX = self.OpenData.x
                self._posX.text = nowPosX
            end
        end
    )
    self:AddListener(self._posY.onChanged,
        function()
            if self._posY.text ~= "" then
                nowPosY = math.floor(self._posY.text)
                self._posY.text = nowPosY
            end
        end
    )
    self:AddListener(self._posY.onFocusOut,
        function()
            if self._posY.text == "" then
                nowPosY = self.OpenData.y
                self._posY.text = nowPosY
            end
        end
    )

    self:AddListener(self._btnGo.onClick,
        function()
            if nowPosX < mapOffset or nowPosX > (1200 - mapOffset) or nowPosY < mapOffset or nowPosY > (1200 - mapOffset) then
                self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "UI_COORDINATE_ERROR_TIPS")
                return
            end
            self._textTip.text = ""
            WorldMap.Instance():GotoPoint(nowPosX, nowPosY)
            UIMgr:Close("WorldSearch")
        end
    )
end

function WorldSearch:OnOpen(data)
    self.OpenData = data
    self._country.text = Model.Player.Server
    nowPosX = data.x
    nowPosY = data.y
    self._posX.text = ""
    self._posY.text = ""
    self._posX.promptText = data.x
    self._posY.promptText = data.y
end

return WorldSearch
