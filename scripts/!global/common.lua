local Common = {}

--判断变量是否在prev_table中，返回逻辑
function Common:IsInTable(v, prev_table)
	for _, value in pairs(prev_table) do
		if v == value then
			return true
		end
	end
	return false
end

--逻辑异或，返回逻辑
function Common:Xor(a,b)
	return ((not a) and b) or (a and (not b))
end

--判断prev_table是否为空表，返回逻辑
function Common:IsTableEmpty(prev_table)
    return _G.next(prev_table) == nil
end

--复制一个表prev_table，不改变原表数据，返回表
function Common:CopyTable(prev_table)
	local new_table = {}
	for key, value in pairs(prev_table) do
		if type(value) == "table" then
			new_table[key] = Common:CopyTable(value)
		else
			new_table[key] = value
		end
	end
end

return Common