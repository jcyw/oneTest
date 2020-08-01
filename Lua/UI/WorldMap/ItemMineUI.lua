--[[
    author:{zhanzhang}
    time:2020-04-08 13:53:59
    function:{function}
]]
local ItemMineUI = {}

--index 100002
function ItemMineUI:Init(index)
    local resInfos = ConfigMgr.GetItem("configWorldMapUIs", index)
    self.resList = {}
    self.tranSprite = GameUtil.CreateObj(resInfos.nodeSprite[1]).transform
    self.tranTextLevel =GameUtil.CreateObj(resInfos.nodeText[1]).transform

    self.tranImgBgWithLevel = self.tranSprite:Find("imgLevelBg").transform

    table.insert(self.resList, self.tranSprite)
    table.insert(self.resList, self.tranTextLevel)

    self.tranSprite:SetParent(WorldMap.Instance():GetNodeSprite(), false)
    self.tranTextLevel:SetParent(WorldMap.Instance().NodeWhite, false)

    self:InitTrans()

    self.tranTextLevel.localEulerAngles = CVector3(-15, -50, 18)

    self._imgIcon = self.tranSprite:Find("imgIcon"):GetComponent("Image")
    self._textLevel = self.tranTextLevel:GetComponent("Text")
end

function ItemMineUI:Refresh(areaId, position)
    local area = MapModel.GetArea(areaId)
    if not area then
        return
    end

    local info = ConfigMgr.GetItem("configMines", area.ConfId)
    self._textLevel.text = info.level
    local owerType = MapModel.CheckOwnerType(area)
    -- 0无归属-- 1自己 米色-- 2盟友 蓝色-- 3敌方 红色
    if owerType == 0 then
        self._imgIcon.enabled = false
    else
        --     end
        -- )
        -- ResMgr.Instance:LoadSpriteAtlas
        self._imgIcon.enabled = true
        local path = "world_sign_occupied_0" .. owerType
        -- CSCoroutine.Start(
        --     function()
        --         coroutine.yield(ResMgr.Instance:LoadSpriteAtlas("uiatlas/worldmapui"))
        local sp = ResMgr.Instance:GetSprite("uiatlas/worldmapui", path)
        self._imgIcon.sprite = sp
    end

    self.tranSprite.position = position
    self.tranTextLevel.position = self.tranImgBgWithLevel.position + CVector3(-0.03, 0, 0.02)
end

function ItemMineUI:OnClose()
    for i = 1, #self.resList do
        self.resList[i].position = CVector3.one * 1000
    end
end

function ItemMineUI:InitTrans()
    for i = 1, #self.resList do
        local temp = self.resList[i]
        temp.localScale = CVector3.one
        temp.localEulerAngles = CVector3.zero
    end
end

return ItemMineUI
