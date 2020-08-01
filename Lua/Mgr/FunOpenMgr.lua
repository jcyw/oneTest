--author: 	Amu
--time:		2020-07-08 14:48:24
--静默下载   功能开启

if FunOpenMgr then
    return FunOpenMgr
end

FunType = {}
FunType.DressUp = "DressUp"

local funList = {       --功能列表
    [FunType.DressUp] = true
}

local FunOpenMgr = {}

function FunOpenMgr.GetFunIsOpen(funType)
    return funList[funType]
end


return FunOpenMgr