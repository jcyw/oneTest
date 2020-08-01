--[[
    Author: songzeming
    Function: 训练界面 兵种列表展示
]] local ItemTrainArmySlide = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemTrainingArms", ItemTrainArmySlide)

local BuildModel = import("Model/BuildModel")
local TrainModel = import("Model/TrainModel")
import("UI/MainCity/TrainRelated/ItemTrainArmy")
import("UI/Effect/SpineNode")
local BLANK_HALF = 2 --占位

function ItemTrainArmySlide:ctor()
    self._list.itemRenderer = function(index, item)
        local armyId = math.floor(self.armBaseId + index - BLANK_HALF)
        local isShow = index >= BLANK_HALF and index < self.length - BLANK_HALF
        item:Init(index, armyId, isShow, function()
            self:TurnArmyItem(item, true)
            self:PlayClickSound(armyId)
        end)
    end
    self._list:SetVirtual()
    self:AddListener(self._list.scrollPane.onScroll,
        function()
            self:UpdateArmy()
            self:HideLight()
        end
    )
    self:AddListener(self._list.scrollPane.onScrollEnd,
        function()
            self:UpdateArmy()
        end
    )
    --[[
    self:AddListener(self._btnLeft.onClick,
        function()
            self:SetDirectSlide(-1)
        end
    )
    self:AddListener(self._btnRight.onClick,
        function()
            self:SetDirectSlide(1)
        end
    )
    ]]
    self._list.sortingOrder = 2
    --self._btnLeft.sortingOrder = 2
    --self._btnRight.sortingOrder = 2

    --self._icon.scale = Vector2(1.3, 1.3)
    --self._icon.y = 730
end

function ItemTrainArmySlide:Init(confId, recordIndex, cb)
    self.cb = cb
    self.setArmyAmountCb = nil

    self.armBaseId = TrainModel.GetBaseArmId(confId)
    local conf = BuildModel.GetConf(confId)
    self.length = conf.army.amount + BLANK_HALF * 2
    self._list.numItems = self.length
    self._list:EnsureBoundsCorrect()
    if recordIndex == 0 then
        recordIndex = BLANK_HALF
    end
    self._list:ScrollToView(recordIndex - BLANK_HALF)

    self.showIndex = nil
    self:UpdateArmy()
end

function ItemTrainArmySlide:TurnArmyItem(item, flag)
    self._list.scrollPane:SetPosX(item.x - (item.width+12)*2, flag)
end

function ItemTrainArmySlide:GetSlideIndex()
    return self.showIndex
end

function ItemTrainArmySlide:SetDirectSlide(dir)
    local index = self.showIndex + dir
    if index >= BLANK_HALF and index < self.length - BLANK_HALF then
        local itemIndex = self.itemIndex + dir - 1
        local item = self._list:GetChildAt(itemIndex)
        local mvx = item.x + item.width / 2 - self._list.viewWidth / 2
        self._list.scrollPane:SetPosX(mvx, true)
    end
end

function ItemTrainArmySlide:SetArrowActive()
    self._btnLeft.visible = self.showIndex > BLANK_HALF
    self._btnRight.visible = self.showIndex + 1 < self.length - BLANK_HALF
end

function ItemTrainArmySlide:UpdateArmy()
    local center = self._list.scrollPane.posX + self._list.viewWidth / 2
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local distance = math.abs(center - item.x - item.width / 2)
        --if distance > item.width / 2 + self._list.columnGap / 2 then
        if distance > item.width then
            -- item:SetScale(1, 1)
            --item.y = 0
            item:SetLight(false)
        else
            self.itemIndex = i
            -- local scale = 1 + (item.width / (item.width + distance) - 0.5) * 0.2
            -- item:SetScale(scale, scale)
            --item.y = -(item.width / (item.width + distance) - 0.5) * 40
            local index = item:GetIndex()
            if index ~= self.showIndex then
                self.showIndex = index
                local armyId = item:GetArmyId()
                --self:SetArrowActive()
                self:ShowAnim(armyId)
                local isLock = item:GetLock()
                self.cb(armyId, isLock)
                if self.setArmyAmountCb then
                    --设置兵种数量回调
                    self.setArmyAmountCb()
                    self.setArmyAmountCb = nil
                end
                self:HideLight(item)

                local config = ConfigMgr.GetItem("configArmys", armyId)
                if config.line then
                    AudioModel.Play(config.line)
                end
            end
        end
    end
end

function ItemTrainArmySlide:HideLight(item)
    if item or self.item then
        if item then
            self.item = item
        else
            item = self.item
        end
        local index = item:GetIndex()
        local childIndex = self._list:ItemIndexToChildIndex(index)

        if childIndex == 2 or childIndex == 3 then
            for i = 1, self._list.numChildren do
                local child = self._list:GetChildAt(i - 1)
                child:SetLight(false)
                child:SetMaskAlpha(0.5)
            end
            item:SetLight(true)
            item:SetMaskAlpha(0)
            self._list:GetChildAt(childIndex - 1):SetMaskAlpha(0.3)
            self._list:GetChildAt(childIndex + 1):SetMaskAlpha(0.3)
        end
    end
end

--指定训练工厂训练兵种和数量
function ItemTrainArmySlide:SetArmyAmount(armyId, cb)
    local index = armyId - self.armBaseId
    self._list.scrollPane.posX = self._list.scrollPane.contentWidth / self.length * index
end

--安保工厂跳转到解锁的最后一个兵种项
function ItemTrainArmySlide:SetSecurityFactoryUnlock()
    for i = 1 + BLANK_HALF, self.length - BLANK_HALF do
        local id = i - BLANK_HALF - 1
        local armyId = math.floor(self.armBaseId + id)
        local isUnlock = TrainModel.GetArmUnlock(armyId)
        if not isUnlock then
            local maxUnlock = id - 1
            self._list.scrollPane.posX = self._list.scrollPane.contentWidth / self.length * maxUnlock
            return
        end
    end
    --全部解锁
    self._list.scrollPane.percX = 1
end

--打开界面出场动画
function ItemTrainArmySlide:ShowAnim(armyId)
    -- self:ClearArmyAnim(armyId)
    -- if Tool.Equal(armyId, 107000, 107004) then
    --     self.armyId = armyId
    --     self._icon.visible = false
    --     NodePool.Init(NodePool.KeyType.TrainShowAnim .. armyId, "Effect", "SpineNode")
    --     local anim = NodePool.Get(NodePool.KeyType.TrainShowAnim .. armyId)
    --     anim.sortingOrder = 1
    --     anim:SetXY(self.width / 2 + 60, self.height - 420)
    --     self:AddChild(anim)
    --     anim:PlayTrainShowAnim("prefabs/spine/trainarmy/army" .. armyId)
    --     self.armyAnim = anim
    -- else
        self._icon.visible = true
        self._icon.icon = TrainModel.GetImageNormal(armyId)
    -- end
end

--将兵种出场动画回收到对象池
function ItemTrainArmySlide:ClearArmyAnim()
    if self.armyAnim then
        NodePool.Set(NodePool.KeyType.TrainShowAnim .. self.armyId, self.armyAnim)
        self.armyAnim = nil
    end
end

--播放兵种点击声音
function ItemTrainArmySlide:PlayClickSound(armyId)
    local armyType = TrainModel.GetConf(armyId).arm
    if armyType == 1 then
        --步兵（MBT主战坦克）
        AudioModel.Play(31001)
    elseif armyType == 2 then
        --步兵（AT反坦克载具）
        AudioModel.Play(31002)
    elseif armyType == 3 then
        --骑兵（IMV轮式战车）
        AudioModel.Play(32001)
    elseif armyType == 4 then
        --骑兵（IFV装甲战车）
        AudioModel.Play(32002)
    elseif armyType == 5 then
        --弓兵（UH通用直升机）
        AudioModel.Play(33001)
    elseif armyType == 6 then
        --弓兵（AH武装直升机）
        AudioModel.Play(33002)
    elseif armyType == 7 then
        --冲车（ART远程火力)
        AudioModel.Play(34001)
    elseif armyType == 8 then
        --冲车（UT工程车))
        AudioModel.Play(34002)
    end
end

return ItemTrainArmySlide
