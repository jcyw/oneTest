--[[
    Author: songzeming
    Function: 地图空白按钮 点击创建建筑 城内
]]
local ItemInnerMapPiece = fgui.extension_class(GComponent)
fgui.register_extension("ui://City/pieceInner", ItemInnerMapPiece)

local BuildModel = import("Model/BuildModel")

function ItemInnerMapPiece:ctor()
    self:AddListener(self.onClick,
        function()
            self:OnBtnPieceClick()
        end
    )

    self:SetPieceBuild(false)
    self:SetMoveState(false)
    self:SetPieceUnlock(true)
end

--初始化地图块
function ItemInnerMapPiece:InitPiece(pos, cb)
    self.goalpos = pos
    self.cb = cb
end

--设置地图块移动起始位置
function ItemInnerMapPiece:SetStartPiecePos(pos)
    self.oldpos = pos
end

--是否显示移动效果
function ItemInnerMapPiece:SetMoveState(flag)
    self._move.visible = flag
end
--设置地图块颜色显示
function ItemInnerMapPiece:SetMoveStateColor(flag)
    self._move.color = flag and Color.green or Color.red
end

--是否可触摸
function ItemInnerMapPiece:SetPieceTouch(flag)
    self.touchable = flag
end

--是否显示地图按钮
function ItemInnerMapPiece:SetPieceActive(flag)
    self.visible = flag
end
function ItemInnerMapPiece:GetPieceActive()
    return self.visible
end

--地图渐显/渐隐
function ItemInnerMapPiece:SetPieceFade(isShow, time)
    if not time then
        time = 1
    end
    if isShow then
        self:SetPieceActive(true)
        self.alpha = 0
        self:TweenFade(1, time)
    else
        self:SetPieceActive(true)
        self.alpha = 1
        self:TweenFade(0, time)
    end
end

--地图块是否有建筑
function ItemInnerMapPiece:SetPieceBuild(flag)
    self.isBuild = flag
    self:SetPieceActive(not flag)
end
function ItemInnerMapPiece:GetPieceBuild()
    return self.isBuild
end

--设置位置是否解锁
function ItemInnerMapPiece:SetPieceUnlock(flag)
    self.isUnlock = flag
end
function ItemInnerMapPiece:GetPieceUnlock()
    return self.isUnlock
end

--获取地图块的位置
function ItemInnerMapPiece:GetPiecePos()
    return self.goalpos
end

--点击地图块
function ItemInnerMapPiece:OnBtnPieceClick()
    if self.triggerFunc then
        self.triggerFunc()
    end
    if not CityType.BUILD_MOVE_TIP then
        self.cb()
        return
    end
    if not self.oldpos then
        return
    end

    local move_func = function()
        Net.Buildings.Move(
            self.oldpos,
            self.goalpos,
            function()
                CityType.BUILD_MOVE_POS = nil
                local building = BuildModel.FindByPos(self.oldpos)
                building.Pos = self.goalpos
                local node = BuildModel.GetObject(building.Id)
                node:SetXY(self.x, self.y)
                node:ResetPos()
                node:UpdateBuilding(building)
                self:SetPieceBuild(true)
                self.parent:GetMapPiece(self.oldpos):SetPieceBuild(false)
                Event.Broadcast(EventDefines.UICityBuildMove, BuildType.MOVE.Reset)
            end
        )
    end
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "ALERT_MOVE_BUILDING"),
        sureCallback = move_func
    }
    UIMgr:Open("ConfirmPopupText", data)
end

function ItemInnerMapPiece:TriggerOnclick(callback)
        self.triggerFunc = callback
end

return ItemInnerMapPiece
