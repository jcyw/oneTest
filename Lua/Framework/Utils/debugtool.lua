local split = string.split
function dump(value, desciption, nesting , color)
    --if true then return end
    -- if (tostring(Internal_Platform) ~= "WindowsEditor") then return end
    --
    if value == nil then
        print(desciption, "is nil")
        return
    end
    if not color then
        print("<color=orange>" .. tostring(desciption) .. "</color>")
    else
        print(string.format("<color=%s>" , color) .. tostring(desciption) .. "</color>")
    end

    if type(nesting) ~= "number" then nesting = 3 end
    print( debug.traceback() )
    local lookupTable = {}
    local result = ""

    local traceback = split(debug.traceback("", 2), "\n")
    -- print("dump from: " .. string.trim(traceback[3]))

    local function dump_value_(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local function dump_(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep("", keylen - string.len(dump_value_(desciption)))
        end

        if type(value) ~= "table" then
            result = result .. string.format("%s%s%s = %s,\n", indent, dump_value_(desciption), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result = result .. string.format("%s%s%s = *REF*,\n", indent, dump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true

            if nest > nesting then
                -- print("--" .. indent .. "--")
                result = result .. string.format("%s%s = *MAX NESTING*,\n", indent, dump_value_(desciption))
            else
                result = result .. string.format("%s%s = {\n", indent, dump_value_(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result = result .. string.format("%s\n},\n", indent)
            end
        end
    end
    dump_(value, desciption, "", 1)

    -- for i, line in ipairs(result) do
    if color then
        print(string.format("<color=%s>" , color) .. result .. "</color>")
    else
        print(result)
    end
end
