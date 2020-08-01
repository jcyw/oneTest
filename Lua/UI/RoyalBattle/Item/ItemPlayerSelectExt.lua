--[[
    author:{xiaosao}
    time:2020/6/9
    function:{王城战市长发放礼包选择玩家item}
]]
local ItemPlayerSelectExt = fgui.extension_class(GComponent)
fgui.register_extension("ui://RoyalBattle/itemPlayerSelectExt", ItemPlayerSelectExt)
local WelfareModel = import("Model/WelfareModel")

local CtrPage = {
    noSelect = "noSelect",
    selected = "selected",
    selecting = "selecting"
}

function ItemPlayerSelectExt:ctor()
    self._controller = self:GetController("c1")
    self._controller.selectedPage = CtrPage.noSelect
    self._playerNameText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_WarZone_GiftIssued")
    self:InitEvent()
end

function ItemPlayerSelectExt:InitEvent()
    --空位点击
    self:AddListener(self._addPlayer.onClick,
        function()
            UIMgr:Open("UIRoyalGiftSearch","Gift")
        end
    )
    --已发点击
    self:AddListener(self._selected.onClick,
        function()
            TipUtil.TipById(50333)
        end
    )
    --替换点击
    self:AddListener(self._selecting.onClick,
        function()
            local data = {
                textTitle = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                textContent = StringUtil.GetI18n(I18nType.Commmon, "Ui_WarZone_GiftList"),
                textBtnLeft = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES"),
                controlType = "single",
                cbBtnLeft = function()
                    RoyalModel.RoyalGiftUnSelectPlayer(self.playerData)
                    --UIMgr:Open("UIRoyalGiftSearch")
                end
            }
            UIMgr:Open("ConfirmPopupDouble", data)
        end
    )
end

function ItemPlayerSelectExt:SetData(playerData,selected)
    self.playerData = playerData
    self:RefreshShowContent(playerData,selected)
end

function ItemPlayerSelectExt:RefreshShowContent(playerData,selected)
    if not playerData then
        self._controller.selectedPage = CtrPage.noSelect
    elseif selected then
        self._controller.selectedPage = CtrPage.selected
        -- CommonModel.SetUserAvatar(self._selected, playerData.Avatar)
        self._selected:SetAvatar(playerData)
        self._playerNameText.text = playerData.Name
        self._textSelected.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_WarZone_GiftIssued")
    else
        self._controller.selectedPage = CtrPage.selecting
        -- CommonModel.SetUserAvatar(self._selecting, playerData.Avatar)
        self._selecting:SetAvatar(playerData)
        self._playerNameText.text = playerData.Name
    end
end

return ItemPlayerSelectExt
