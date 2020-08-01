--author: 	Amu
--time:		2020-06-19 14:48:42

local ArenaModel = import("Model/ArenaModel")

local ArenaRank = fgui.extension_class(GComponent)
fgui.register_extension("ui://Arena/ArenaRank", ArenaRank)


function ArenaRank:ctor()

    self._textRank = self:GetChild("textRank")

    self._textLuckyValue = self:GetChild("textLuckyValue")
    self._btnLuckDraw = self:GetChild("btnLuckDraw")

    self._listView = self:GetChild("_list")

    self:InitEvent()
end

function ArenaRank:InitEvent(  )
    self:AddListener(self._btnHelp.onClick,function()
        local data = {
            title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
            info = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS19")
        }
        UIMgr:Open("ConfirmPopupTextCentered", data)
    end)
    
    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end

        item:SetData(ArenaModel._ranlList[index+1])
    end

    self:AddListener(self._listView.scrollPane.onPullUpRelease,function()
        self:refreshListItems()
    end)
end

function ArenaRank:InitData()
    self:RefreshData()
end

function ArenaRank:RefreshData()
    ArenaModel.ArenaRankPageInfo(function()
        self._textRank.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS1") .. ArenaModel._rank
        self:RefreshListView()
    end)
end

function ArenaRank:refreshListItems()
    ArenaModel.ArenaRankPlayerInfo(function()
        
        self:RefreshListView()
    end)
end

function ArenaRank:RefreshListView(  )
    self._listView.numItems = #ArenaModel._ranlList
end
return ArenaRank