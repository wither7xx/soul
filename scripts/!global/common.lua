local Common = {}

--�жϱ����Ƿ���prev_table�У������߼�
function Common:IsInTable(v, prev_table)
	for _, value in pairs(prev_table) do
		if v == value then
			return true
		end
	end
	return false
end

--�߼���򣬷����߼�
function Common:Xor(a,b)
	return ((not a) and b) or (a and (not b))
end

--�ж�prev_table�Ƿ�Ϊ�ձ������߼�
function Common:IsTableEmpty(prev_table)
    return _G.next(prev_table) == nil
end

--����һ����prev_table�����ı�ԭ�����ݣ����ر�
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