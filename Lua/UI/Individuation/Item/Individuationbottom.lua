--author: 	Amu
--time:		2020-07-17 17:22:13

local DressUpModel = import("Model/DressUpModel")
local ActivityModel = _G.ActivityModel
local Individuationbottom = fgui.extension_class(GComponent)
fgui.register_extension("ui://Individuation/Individuationbottom", Individuationbottom)

function Individuationbottom:ctor()
    self._ctrView = self:GetController("type")

    self._listView = self._itemShow:GetChild("_listView")

    self:InitEvent()
    -- self._banner.icon = UITool.GetIcon(GlobalBanner.ArenaBanner)
end

function Individuationbottom:InitEvent( )
    self:AddListener(self._btnChose.onClick,function()
        if self._isForever or self._default or self.isUsed then
            DressUpModel.UseDressUp(self._dressUpConfId, function(msg)
            end)
        elseif #self.dressUpList>0 then
            self._ctrView.selectedIndex = 0
            self:RefreshListView()
        else
            self:GetDressWay()
        end
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end

        item:SetData(self.dressUpList[index+1], index+1)
    end
end
-- 当没有此装扮时获取途径是否开启
function Individuationbottom.IsGetWayOpen()
    local infoWay = DressUpModel.GetDressUpInfoById(DressUpModel.curSubSelect).config
    if infoWay.obtain_way and infoWay.obtain_way[1].num == 1 then
        local activityID = infoWay.obtain_way[1].activityID
        
        if ActivityModel.GetIsOpenActivity(activityID) then
            return true
        end
    end
    return false
end
-- 获取装扮
function Individuationbottom:GetDressWay()
    local ActivityGet = function (activityID)
        local configinfo = ActivityModel.GetActivityConfig(activityID)
        local Netinfo =ActivityModel.GetActivityInfo(activityID)

        --如果活动开启 没有详情UI 跳转UI是Jump activityId是configJump的id
        if Netinfo.Open
        and not configinfo.openPanel
        and configinfo.jumpPage
        and configinfo.jumpPage.page == "Jump"
        then
            JumpMap:JumpSimple(configinfo.jumpPage.activityId)
            return
        end

        --打开对应的页面
        if Netinfo.Open and configinfo.openPanel then
            UIMgr:Open(configinfo.openPanel, Netinfo)
        elseif configinfo.readyPanel and not Netinfo.Open then
            UIMgr:Open(configinfo.readyPanel, Netinfo)
        end
    end

    local config = DressUpModel.GetDressUpInfoById(DressUpModel.curSubSelect).config
    -- if config.obtain_way[1].num == 1 then
    --     local activityID = config.obtain_way[1].activityID
    --     if ActivityModel.GetIsOpenActivity(activityID) then
    --         ActivityGet(activityID)
    --     else
    --         local activityInfo = ActivityModel.GetActivityConfig(activityID)
    --         TipUtil.TipById(config.way, {activity_name = StringUtil.GetI18n(I18nType.Commmon, activityInfo.activity_name)})
    --     end
    -- end

    local openWay = self:GetOpenWay(config)
    if openWay then
        ActivityGet(openWay.activityID)
    else
        if config.obtain_way[1].num == 1 then
            local activityID = config.obtain_way[1].activityID
            local activityInfo = ActivityModel.GetActivityConfig(activityID)
            TipUtil.TipById(config.way, {activity_name = StringUtil.GetI18n(I18nType.Commmon, activityInfo.activity_name)})
        end
    end
end

function Individuationbottom:GetOpenWay(config)
    if not config then
        config = DressUpModel.GetDressUpInfoById(DressUpModel.curSubSelect).config
    end
    for _,v in ipairs(config.obtain_way)do
        if v.num == 1 then
            local activityID = v.activityID
        
            if ActivityModel.GetIsOpenActivity(activityID) then
                return v
            end
        end
    end
    return false
end

function Individuationbottom:Refresh(dressUpList)
    self.dressUpList = dressUpList
    self._isForever = false
    self._default = false
    self._dressUpConfId = nil
    if #dressUpList > 0 then
        for _,v in ipairs(dressUpList) do
            if v.DressUpSubType == 0 then
                self._default = true
                self._dressUpConfId = v.ConfId
                break
            end
            local time = v.ExpireAt - Tool.Time()
            if time > 0 and time < 622080000 then
                self.isUsed = true
                self._dressUpConfId = v.ConfId
            elseif time > 622080000 then  -- 大于20年  永久
                self._isForever = true
                self._dressUpConfId = v.ConfId
                -- break
            end
        end
        if self._default or self._isForever or self.isUsed then
            self._ctrView.selectedIndex = 1
        else
            self._ctrView.selectedIndex = 0
            self:RefreshListView()
        end
        -- self._ctrView.selectedIndex = 1
        -- self._btnChose.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_USE_ITEM")
    else
        self._ctrView.selectedIndex = 1
        -- self._btnChose.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get_Res")
    end

    if self._isForever or self._default or self.isUsed then
        self._btnChose.grayed = false
        self._btnChose.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_USE_ITEM")
    else
        self._btnChose.grayed = not self:GetOpenWay()
        self._btnChose.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get_Res")
    end
end

function Individuationbottom:RefreshListView(  )
    self._listView.numItems = #self.dressUpList
end


return Individuationbottom