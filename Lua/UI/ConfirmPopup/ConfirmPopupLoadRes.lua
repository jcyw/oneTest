--[[
    author:{zhanzhang}
    time:2020-05-30 14:25:09
    function:{加载资源确认框}
]]
local ConfirmPopupLoadRes = UIMgr:NewUI("ConfirmPopupLoadRes")

local isCancel = false

function ConfirmPopupLoadRes:OnInit()
    local view = self.Controller.contentPane

    self:AddListener(self._btnSure.onClick,
        function()
            isCancel = true
            self:Close()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            isCancel = true
            self:Close()
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            isCancel = true
            self:Close()
        end
    )
    self._title.text = StringUtil.GetI18n(I18nType.Commmon,"Tips_TITLE")
end
--bundleName
--callback = callFunc,
--closeBack = callFunc
function ConfirmPopupLoadRes:OnOpen(data)
    self._btnSure.title = data.textBtnSure
    self._progressBar.value = 0
    self._textDesc.text = data.textPopupDesc
    isCancel = false
    local progressCb = function(proNum)
        local val = math.floor(proNum * 100)
        self._progressBar.value = val
        self._textProgress.text = val .. "%"
        -- Log.Error("当前进度条值为  " .. proNum)
    end
    DynamicRes.GetBundle(
        data.bundleName,
        function()
            if isCancel then
                return
            end
            data.loadBack()
            self:Close()
        end,
        progressCb
    )
end

function ConfirmPopupLoadRes:DoOpenAnim(data)
    self.data = data
    AnimationLayer.PanelScaleOpenAnim(self)
    self:OnOpen(data)
end

function ConfirmPopupLoadRes:Close()
    UIMgr:Close("ConfirmPopupLoadRes")
end

function ConfirmPopupLoadRes:OnClose()
end

return ConfirmPopupLoadRes
