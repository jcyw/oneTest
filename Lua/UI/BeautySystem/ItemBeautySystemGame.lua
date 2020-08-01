--author: 	Amu
--time:		2020-04-13 11:29:47
local GD = _G.GD
local BuildModel = import("Model/BuildModel")
local BeautyGirlModel = import("Model/BeautyGirlModel")
local GameCtrView = {}  --游戏状态控制
GameCtrView.Ready    = 0
GameCtrView.Gameing   = 1

local GameViewState = {}
GameViewState.Show = 0
GameViewState.Hide = 1

local ItemBeautySystemGame = fgui.extension_class(GComponent)
fgui.register_extension("ui://BeautySystem/itemBeautySystemGame", ItemBeautySystemGame)

function ItemBeautySystemGame:ctor()
    self._proBar = self:GetChild("progressBar")
    self._proText = self:GetChild("progressText")

    self._itemSpeak = self:GetChild("itemSpeak")
    self._itemSpeakText = self._itemSpeak:GetChild("title")

    self._btnStart = self:GetChild("btnStart")
    self._btnAdd = self:GetChild("btnAdd")
    self._btnQuestion = self:GetChild("btnQuestion")
    self._btnArrowDown = self:GetChild("_btnArrowDown")
    
    self._itemIntroduce = self:GetChild("itemIntroduce")
    self._btnIntroduce = self:GetChild("btnHear")

    self._textFavorable = self:GetChild("textFavorable")

    self._flowerText = self:GetChild("textSurplus")

    self._minHeart = self:GetChild("itemHeart1")
    self._maxHeart = self:GetChild("itemHeart2")
    
    self.heartItemList = {self._minHeart, self._maxHeart}
    self._minX = self._minHeart.x
    self._maxX = self._maxHeart.x

    self._continuEffectItem = self:GetChild("itemComb2")
    self._raiseEffectItem = self:GetChild("itemComb1")

    self._continuEffectItem:GetChild("text").visible = false
    self._continuEffectItem:GetChild("textNum2").visible = false
    self._c_Num = self._continuEffectItem:GetChild("textNum")
    self._r_Num = self._raiseEffectItem:GetChild("textNum")

    self._c_Anim = self._continuEffectItem:GetTransition("Anim")
    self._r_Anim = self._raiseEffectItem:GetTransition("Anim")

    self._continuEffectItem.visible = false
    self._raiseEffectItem.visible = false

    self._downAnim = self:GetTransition("out")
    self._upAnim = self:GetTransition("In")
    self._shakeAnim = self:GetTransition("Anim")

    self._shakeState = false

    self._itemIntroduce.visible = false

    self._diceList = {
        {
            index = 1,
            touch = self:GetChild("itemTouch1"),
            graph = self:GetChild("itemCup1").asGraph,
            texture = "fa",
        },
        {
            index = 2,
            touch = self:GetChild("itemTouch2"),
            graph = self:GetChild("itemCup2").asGraph,
            texture = "ha",
        },
        {
            index = 3,
            touch = self:GetChild("itemTouch3"),
            graph = self:GetChild("itemCup3").asGraph,
            texture = "j",
        }
    }
    self.J_Card_Url = "j"
    self.Normal_Card_Url = {
        "fa",
        "ha"
    }
    self.Card_List = {}
    self.cardUrl = "beautygirl/prefab/cardpreb"
    self.texUrl = "beautygirl/texture/card/"
    self.materialUrl = "beautygirl/material/"

    self._gameCtrView = self:GetController("c1")

    self.girlsInfo = ConfigMgr.GetList("configGirls")

    self:InitCard()
    self:InitEvent()
end

function ItemBeautySystemGame:InitCard()
    local cb = function()
        for k,dice in ipairs(self._diceList)do
            local _card = BeautyGirlModel.Create(self.cardUrl)
            -- _card.transform.localEulerAngles = Vector3(200, 200, 1)
            _card.transform.localScale = Vector3(200, 200, 200)
            _card.transform.localPosition = Vector3(148/2, -100, 100)
            local texture = ResMgr.Instance:LoadTextureSync(self.texUrl..dice.texture)
            local material = _card:GetComponent("MeshRenderer").material
            material:SetTexture("_MainTex", texture)
            if _card then
                dice.card = _card
                dice.animation = _card:GetComponent("Animation")
                dice.graph:SetNativeObject(GoWrapper(_card))
            end
        end
    end
    BeautyGirlModel.Load(self.cardUrl, cb)
end

function ItemBeautySystemGame:InitEvent()
    self:AddListener(self._btnStart.onClick,function()
        local grilInfo = self.girlsInfo[self._selectGirlIndex]
        if grilInfo.msg.Exp >= grilInfo.totalfavor then
            TipUtil.TipById(50298)
            return
        end
        if self._Rose <= 0 then
            local bulding = BuildModel.GetCenter()
            local maxFlower = ConfigMgr.GetItem("configBases", bulding.ConfId + bulding.Level).rose_upperlimt
            TipUtil.TipById(50297, {num = maxFlower})
            return
        end
        self:StartGame()
    end)

    self:AddListener(self._btnQuestion.onClick,function()
        UIMgr:Open("BeautyUpperLimit")
    end)

    self:AddListener(self._btnArrowDown.onClick,function()
        self:ChangeBoardState()
    end)

    self:AddListener(self._btnIntroduce.onClick,function()
        if not self._itemIntroduce.visible then
            self:ShowGirlIntroduce()
        else
            self:HideGirlIntroduce()
        end
    end)

    self:AddListener(self._btnAdd.onClick,function()
        local item = GD.ItemAgent.GetItemModelById(Global.GetmoreBeautyItemId)
        if(item and item.Amount>0)then
            local data = {
                config = ConfigMgr.GetItem("configItems", Global.GetmoreBeautyItemId),
                amount = item.Amount,
                initAmount = item.Amount,
                useCallBack = function(amount)
                    Event.Broadcast(BEAUTY_GIRL_EVENT.FlowerAdd,amount)
                end
            }
            UIMgr:Open("ResourceDisplayUse", data)
            return
        end
        UIMgr:Open("AccessWay", Global.GetmoreItemBeauty)
    end)

    self:AddListener(self.onTouchEnd,function()
        if self._itemIntroduce.visible then
            self:HideGirlIntroduce()
        end
    end)

    for k,dice in ipairs(self._diceList)do
        self:AddListener(dice.touch.onClick,function()
            if BeautyGirlModel._canClick  then
                BeautyGirlModel._canClick  = false
                Net.Beauties.PlayGame(self.girlsInfo[self._selectGirlIndex].id, k, function(msg)
                    BeautyGirlModel.gameState = GameCtrView.Ready
                    -- for _,v in ipairs(self.girlsInfo)do
                    --     if v.id == msg.BeautyId then
                    --         v.msg.Exp = v.msg.Exp + msg.AddExp
                    --         break
                    --     end
                    -- end
                    self._overCb = function()
                        -- self:RefreshFavorable()
                        self:GameOver()
                    end

                    if msg.Win then
                        self._itemSpeakText.text = StringUtil.GetI18n("configI18nCommons", "TIPS_BEAUTY_GUESS_RIGHT")
                        local texture = ResMgr.Instance:LoadTextureSync(self.texUrl..self.J_Card_Url)
                        local material = dice.card:GetComponent("MeshRenderer").material
                        material:SetTexture("_MainTex", texture)
                        self.Card_List = {
                            "fa",
                            "ha"
                        }
                    else
                        self._itemSpeakText.text = StringUtil.GetI18n("configI18nCommons", "TIPS_BEAUTY_GUESS_WRONG")
                        local index = math.random(2)
                        local card_url = self.Normal_Card_Url[index]
                        local texture = ResMgr.Instance:LoadTextureSync(self.texUrl..card_url)
                        local material = dice.card:GetComponent("MeshRenderer").material
                        material:SetTexture("_MainTex", texture)
                        
                        if index > 1 then
                            index = index - 1
                        else
                            index = index + 1
                        end
                        
                        self.Card_List = {}
                        table.insert(self.Card_List, self.J_Card_Url)
                        table.insert(self.Card_List, self.Normal_Card_Url[index])
                    end
                    dice.animation:Play("turnLeft")
                    self._raiseEffectItem.visible = true
                    self._r_Num.text = "+"..msg.AddExp
                    self._r_Anim:Play(function()
                        self._raiseEffectItem.visible = false
                    end)

                    if msg.WinStream > 1 then
                        self._continuEffectItem.visible = true
                        self._c_Num.text = msg.WinStream
                        self._c_Anim:Play(function()
                            self._continuEffectItem.visible = false
                        end)
                        self:PlayeContinuEffect(self._continuEffectItem)
                    end


                    local _cb_turn = function()

                        local index = math.random(2)
                        for _k,_dice in ipairs(self._diceList)do
                            if k ~= _k then
                                local texture = ResMgr.Instance:LoadTextureSync(self.texUrl..self.Card_List[index])
                                local material = _dice.card:GetComponent("MeshRenderer").material
                                material:SetTexture("_MainTex", texture)
                                if not self.stopGame then
                                    _dice.animation:Play("turnLeft")
                                end
                                if index > 1 then
                                    index = index - 1
                                else
                                    index = index + 1
                                end
                            end
                        end
                        if self.stopGame then
                            return
                        end
                        if msg.Win then
                            self:PlayCardEffect(dice.touch)
                        end
                    end
                    self:ScheduleOnceFast(_cb_turn, 0.8)
                    self:ScheduleOnceFast(self._overCb, 3)
                end)
            end
        end)
    end

    local _state = false
    local grilInfo
    local exp = 0
    local sp_exp = 0
    local _updateFun = function()
        grilInfo = self.girlsInfo[self._selectGirlIndex]
        if grilInfo.msg.Exp >= grilInfo.totalfavor then
            self._textFavorable.text = ""
        else
            for k,v in ipairs(grilInfo.skill)do
                exp = v.favor
                if grilInfo.msg.Exp < v.favor then
                    break
                end
            end
            for k,v in ipairs(grilInfo.specialskill)do
                sp_exp = v
                if grilInfo.msg.Exp < v then
                    break
                end
            end
            if _state then
                _state = false
                self._textFavorable.text = StringUtil.GetI18n("configI18nCommons", "GirlOnlineReward_Favordesc", {number = exp})
            else
                _state = true
                self._textFavorable.text = StringUtil.GetI18n("configI18nCommons", "TIPS_BEAUTY_SURPRISE", {number = sp_exp})
            end
        end
    end

    self:AddEvent(BEAUTY_GIRL_EVENT.Open, function( )
        grilInfo = self.girlsInfo[self._selectGirlIndex]
        -- self:InitCard()
        -- if grilInfo.msg.Exp >= grilInfo.totalfavor then
        --     self._textFavorable.text = ""
        -- else
        --     -- _state = false
        --     -- _updateFun()
        --     -- self:Schedule(_updateFun, 2)
        -- end
        _state = false
        _updateFun()
        self:Schedule(_updateFun, 2)
    end)

    self:AddEvent(BEAUTY_GIRL_EVENT.Close, function( )
        self:UnSchedule(_updateFun)
    end)

    self:AddEvent(BEAUTY_GIRL_EVENT.Close, function( )
        self:UnSchedule(_updateFun)
    end)

    self:AddEvent(BEAUTY_GIRL_EVENT.FlowerAdd, function(num)
        self._Rose = self._Rose + num
        self:RefreshFlower()
    end)
end

function ItemBeautySystemGame:RefreshView(girlIndex, girlsInfo, state, Rose)
    self._selectGirlIndex = girlIndex
    self.girlsInfo = girlsInfo
    self._state = state
    self._Rose = Rose
    self:RefreshFlower()
    self:RefreshFavorable()
    self._gameCtrView.selectedIndex = BeautyGirlModel.gameState
    -- self:RefreshGameViewShow()
end

function ItemBeautySystemGame:StartGame()
    self._itemSpeakText.text = StringUtil.GetI18n("configI18nCommons", "TIPS_BEAUTY_GUESS_BEGIN")
    BeautyGirlModel.gameState = GameCtrView.Gameing
    self._gameCtrView.selectedIndex = GameCtrView.Gameing
    self._continuEffectItem.visible = false
    self._raiseEffectItem.visible = false
    self.stopGame = false

    for k,dice in ipairs(self._diceList)do
        dice.animation:Play("turnRight")
    end

    self._playShakeAnime_cb = function()
        self._shakeAnim:Play(function()
            Net.Beauties.GameStart(self.girlsInfo[self._selectGirlIndex].id, false, function(msg)
                self.Except = msg.Except
                self._Rose = self._Rose - 1
                -- if self.Except > 0 then
                --     self._diceList[self.Except].cup:PlayFall()
                -- end
                self._shakeState = false
                BeautyGirlModel._canClick  = true

                Event.Broadcast(BEAUTY_GIRL_EVENT.FlowerReduce, self._Rose)
    
                self:RefreshFlower()
            end)
        end)
    end
    self._shakeState = true
    self:ScheduleOnce(self._playShakeAnime_cb, 2)
end

function ItemBeautySystemGame:StopGame()
    self.stopGame = true
    if self._shakeState then
        self:UnSchedule(self._playShakeAnime_cb)
        self._shakeAnim:Stop()
        self._c_Anim:Stop()
        self._r_Anim:Stop()
        self._continuEffectItem.visible = false
        self._raiseEffectItem.visible = false
        BeautyGirlModel._canClick  = false
        BeautyGirlModel.gameState = GameCtrView.Ready
        self._gameCtrView.selectedIndex = GameCtrView.Ready
    else
        self._gameCtrView.selectedIndex = BeautyGirlModel.gameState
    end
    if self.cardeffect then
        NodePool.Set(NodePool.KeyType.BeautyGirl_CardEffect, self.cardeffect)
    end
    self:UnSchedule(self._overCb)
    for k,dice in ipairs(self._diceList)do
        if dice.animation and dice.animation.isPlaying then
            dice.animation:Stop()
        end
    end
    self._shakeState = false
end

function ItemBeautySystemGame:GameOver()
    BeautyGirlModel._canClick  = false
    BeautyGirlModel.gameState = GameCtrView.Ready
    self._gameCtrView.selectedIndex = BeautyGirlModel.gameState
    Event.Broadcast(BEAUTY_GIRL_EVENT.GameOver)
end

function ItemBeautySystemGame:ShowGirlIntroduce()
    self._itemIntroduce.visible = true
    self._itemIntroduce:SetData(self.girlsInfo[self._selectGirlIndex])
end

function ItemBeautySystemGame:HideGirlIntroduce()
    self._itemIntroduce.visible = false
end

function ItemBeautySystemGame:RefreshFlower()
    local bulding = BuildModel.GetCenter()
    local maxFlower = ConfigMgr.GetItem("configBases", bulding.ConfId + bulding.Level).rose_upperlimt
    
    self._flowerText.text = StringUtil.GetI18n("configI18nCommons", "rosenum", {down = self._Rose, upper = maxFlower})
end

function ItemBeautySystemGame:RefreshFavorable()
    local grilInfo = self.girlsInfo[self._selectGirlIndex]

    local index = 1
    for _,v in ipairs(grilInfo.specialskill)do
        if not self.heartItemList[index] then
            local item = UIMgr:CreateObject("BeautySystem", "ItemHeart")
            self:AddChild(item)
            self.heartItemList[index] = item
            self.heartItemList[index].y = self._minHeart.y
        end
        self.heartItemList[index].x = self._minX + (v/grilInfo.totalfavor)*(self._maxX - self._minX) + self.heartItemList[index].width/2
        self.heartItemList[index].visible = true
        self.heartItemList[index]:SetData(v)

        index = index + 1
    end
    for i = index, #self.heartItemList do
        self.heartItemList[i].visible = false
    end


    self._proBar.max = grilInfo.totalfavor
    self._proBar.value = grilInfo.msg.Exp
    
    self._proText.text = string.format("%d/%d", grilInfo.msg.Exp, grilInfo.totalfavor)
end

function ItemBeautySystemGame:RefreshGameViewShow(state)
    if state then
        self._state = state
    end
    if self._state == GameViewState.Show then
        self._upAnim:Play(function()
            Event.Broadcast(BEAUTY_GIRL_EVENT.GameTableIn)
        end)
    else
        self._downAnim:Play()
    end
end

function ItemBeautySystemGame:PlayCardEffect(parent)
    NodePool.Init(NodePool.KeyType.BeautyGirl_CardEffect, "Effect", "EffectNode")
    local item = NodePool.Get(NodePool.KeyType.BeautyGirl_CardEffect)
    self.cardeffect = item
    item.x = parent.x + parent.width/2
    item.y = parent.y - parent.height/3
    self:AddChild(item)
    item:InitNormal()
    item:PlayEffectLoop("effects/beauty/prefab/effect_pai_shine", Vector3(100, 100, 100))

    self:PlayerFlowerEffect(parent)
    self:ScheduleOnce(function()
       NodePool.Set(NodePool.KeyType.BeautyGirl_CardEffect, self.cardeffect)
    end, 1.5)
end

function ItemBeautySystemGame:PlayerFlowerEffect(parent)
    NodePool.Init(NodePool.KeyType.BeautyGirl_FlowerEffect, "Effect", "EffectNode")
    local item = NodePool.Get(NodePool.KeyType.BeautyGirl_FlowerEffect)
    self.flowerffect = item
    item.x = parent.x + parent.width/2
    item.y = parent.y
    self:AddChild(item)
    item:InitNormal()
    item:PlayEffectLoop("effects/beauty/prefab/effect_pai_huaban", Vector3(50, 50, 50))

    self:ScheduleOnce(function()
        NodePool.Set(NodePool.KeyType.BeautyGirl_FlowerEffect, self.flowerffect)
    end, 3)
end

function ItemBeautySystemGame:PlayeContinuEffect(parent)
    NodePool.Init(NodePool.KeyType.BeautyGirl_FavorEffect, "Effect", "EffectNode")
    local item = NodePool.Get(NodePool.KeyType.BeautyGirl_FavorEffect)
    self.continueffect = item
    -- item.x = parent.width/2
    -- item.y = parent.height/3
    item.x = self._c_Num.x + self._c_Num.width / 2
    item.y = self._c_Num.y + self._c_Num.height / 2
    parent:AddChild(item)
    item:InitNormal()
    item:PlayEffectSingle("effects/beauty/prefab/effect_haogandu", function()
        NodePool.Set(NodePool.KeyType.BeautyGirl_FavorEffect, self.continueffect)
    end,Vector3(133, 133, 133))
end

function ItemBeautySystemGame:ChangeBoardState()
    if self._state == GameViewState.Show then
        self._state = GameViewState.Hide
    else
        self._state = GameViewState.Show
    end
    self:RefreshGameViewShow()
end

return ItemBeautySystemGame
