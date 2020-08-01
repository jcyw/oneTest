--[[
    author:{zhanzhang}
    time:2019-09-05 10:28:10
    function:{联盟标记功能}
]]
local UnionSignPopup = UIMgr:NewUI("UnionSignPopup")
local MapModel = import("Model/MapModel")

function UnionSignPopup:OnInit()
    local view = self.Controller.contentPane
    self._controller = view:GetController("c1")
    self._mask = view:GetChild("bgMask")
    self._btnList = {}
    for i = 1, 4 do
        self._btnList[i] = view:GetChild("btn" .. i)
    end

    self:OnRegister()
end

function UnionSignPopup:OnRegister()
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("UnionSignPopup")
        end
    )
    self:AddListener(self._btnSign.onClick,
        function()
            self:AddSign()
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            UIMgr:Close("UnionSignPopup")
        end
    )
    self:AddListener(self._textInput.onFocusOut,
        function()
            --local str = StringUtil.RemoveSpaceAndNextLine(StringUtil.Utf8LimitOfByte(self._textInput.text, 10))
            local str = Util.GetStringByLimit(self._textInput.text,10)
            self._textInput.text = str
        end
    )
    self:AddListener(self._textInput.onChanged,
        function()
            self._textInput.text = string.gsub(self._textInput.text, "[\t\n\r[%]]+", "")
        end
    )
end

function UnionSignPopup:OnOpen(posNum)
    self._textInput.text = ""
    self.posNum = posNum
    self._controller.selectedIndex = 0
    self:RefreshSign()
end
--添加联盟标记
function UnionSignPopup:AddSign()
    local posX, posY = MathUtil.GetCoordinate(self.posNum)
    Net.Bookmarks.AddAlliance(
        self._controller.selectedIndex,
        self._textInput.text,
        posX,
        posY,
        function(val)
            UIMgr:Close("UnionSignPopup")
        end
    )
end

function UnionSignPopup:DelSign()
    Net.Bookmarks.DelAlliance(
        self._controller.selectedIndex,
        function(val)
            self:RefreshSign()
        end
    )
end

function UnionSignPopup:RefreshSign()
    for i = 1, 4 do
        self._btnList[i]:Init(i)
    end
end

return UnionSignPopup
