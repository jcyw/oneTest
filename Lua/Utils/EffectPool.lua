--author: 	Amu
--time:		2019-09-03 17:21:07
--特效池

if EffectPool then
    return
end

local poolList = {}

EffectPool = {}

--放入池中
function EffectPool.Push(type, effect)
    if not poolList[type] then
        poolList[type] = {}
    end
    table.insert(poolList[type], effect)
end

--从池中取出
function EffectPool.Pop(type)
    if not poolList[type] or #poolList[type] <= 0 then
        return nil
    end
    return table.remove(poolList[type])
end

function EffectPool.Dispose(type)
    if not poolList[type] then
        return
    end
    for _,v in ipairs(poolList[type])do
        if v then
            v:Dispose()
        end
        v = nil
    end
    poolList[type] = nil
end

return EffectPool
