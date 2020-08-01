local CollectionInstructions = UIMgr:NewUI("CollectionInstructions")

function CollectionInstructions:OnInit()
    local view = self.Controller.contentPane
    self._bgMask = view:GetChild("bgMask")
    self._titleName = view:GetChild("titleName")
    self._content = view:GetChild("liebiao").asList
    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("CollectionInstructions")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("CollectionInstructions")
        end
    )
end

function CollectionInstructions:OnOpen(data, configId)
    local info = nil
    if data == nil and configId == nil then
        return
    end
    if configId == nil then
        if not data.ConfId then
            Log.Error("CollectionInstructions:OnOpen   data.ConfId 为空")
            return
        end
        local tempInfo = ConfigMgr.GetItem("configMines", data.ConfId)
        if not tempInfo then
            Log.Error("CollectionInstructions:OnOpen  configMines为空  confidID==  " .. data.ConfId)
            return
        end
        info = ConfigMgr.GetItem("configMineDescs", tempInfo.category + 1000)
    else
        info = ConfigMgr.GetItem("configMineDescs", configId)
    end
    self._titleName.text = ConfigMgr.GetI18n("configI18nCommons", info.title)
    local mineInfo = {}
    self._content:RemoveChildrenToPool()
    local count = #info.subtitle
    for i = 1, count do
        mineInfo.subtitle = info.subtitle[i]
        mineInfo.detail = info.detail[i]
        mineInfo.backgroundPath = info.background[1]
        mineInfo.background = info.background[i + 1]
        local item = self._content:AddItemFromPool()
        item:init(mineInfo)
    end
end

return CollectionInstructions
