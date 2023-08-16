local Maths = {}

--四舍五入保留小数点后m位（默认保留整数），返回浮点数
function Maths:Fix_Round(x, m)
	if m == nil or m == 0 then
		return math.floor(x + 0.5)
	end
	local mod = 10 ^ m
	return math.floor(x * mod + 0.5) / mod
end

--计算一个二阶方阵matrix的行列式，返回浮点数
function Maths:Determinant_2x2(matrix)
	local det = matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1]
	return det
end

--计算一个三阶方阵matrix的行列式，返回浮点数
function Maths:Determinant_3x3(matrix)
	local det = matrix[1][1] * matrix[2][2] * matrix[3][3] 
		+ matrix[1][2] * matrix[2][3] * matrix[3][1] 
		+ matrix[1][3] * matrix[2][1] * matrix[3][2] 
		- matrix[1][3] * matrix[2][2] * matrix[3][1] 
		- matrix[1][2] * matrix[2][1] * matrix[3][3] 
		- matrix[1][1] * matrix[2][3] * matrix[3][2]
	return det
end
		
--计算一个N*M矩阵matrix的秩，返回整数
function Maths:Rank_NxM(matrix, N, M)
	local rank = 0
	local row = 1
	local k = 1
	local temp
	for i = 1, M do
		k = row
		for j = row + 1, N do
			if math.abs(matrix[k][i]) < math.abs(matrix[j][i]) then
				k = j
			end
		end
		if k ~= row then
			for j = i, M do
				temp = matrix[row][j]
				matrix[row][j] = matrix[k][j]
				matrix[k][j] = temp
			end
		end
		if matrix[row][i] == 0 then
			goto Rank_continue
		else
			rank = rank + 1
			for j = 1, N do
				if j ~= row then
					temp = (-1) * matrix[j][i] / matrix[row][i]
					for k = i, M do
						matrix[j][k] = matrix[j][k] + temp * matrix[row][k]
					end
				end
			end
			temp = matrix[row][i]
			for j = i, M do
				matrix[row][j] = matrix[row][j] / temp
			end
		end
		row = row + 1
		if row > N then
			break
		end
		::Rank_continue::
	end
	return rank
end

--计算自然数n的阶乘，返回整数
function Maths:Fact(n)
	if math.floor(n) ~= n or n < 0 then
		return nil
	end
	if n == 0 then
		return 1
	elseif n > 0 then
		return n * Maths:Fact(n - 1)
	end
end

--计算从n个不同元素中任取m个元素的排列数，返回整数
function Maths:Perm(m, n)
	if n >= m then
		return (Maths:Fact(n) / Maths:Fact(n - m))
	else
		return 0
	end
end

--计算从n个不同元素中任取m个元素的组合数，返回整数
function Maths:Comb(m, n)
	return (Maths:Perm(m, n) / Maths:Fact(m))
end

--求实数x的符号，返回整数（1、-1或0）
function Maths:Sign(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	else
		return 0
	end
end

--判断整数x是否为偶数，返回逻辑或nil
function Maths:IsEven(x)
	if x < 0 then
		local x_abs = math.abs(x)
	end
	if math.floor(x_abs) < x_abs then
		return nil
	else
		return (x_abs % 2) == 0
	end
end

function Maths:RandomInt(max, rng, include_zero, include_max)
	if include_zero == nil then
		include_zero = true
	end
	if include_max == nil then
		include_max = false
	end
	local max_fixed = max
	if include_zero and include_max then
		max_fixed = max + 1
	elseif (not include_zero) and (not include_max) then
		max_fixed = max - 1
	end
	if max_fixed <= 0 then
		return 0
	end
	local rand = math.random(max_fixed)
	if rng == nil then
		if include_zero then
			if not include_max then
				if rand == max then
					rand = 0
				end
			else
				rand = rand - 1
			end
		end
	else
		rand = rng:RandomInt(max_fixed)
		if not include_zero then
			if include_max then
				if rand == 0 then
					rand = max
				end
			else
				rand = rand + 1
			end
		end
	end
	return rand
end

function Maths:RandomInt_Ranged(min, max, rng, include_min, include_max)
	if include_min == nil then
		include_min = true
	end
	if include_max == nil then
		include_max = true
	end
	return min + Maths:RandomInt(max - min, rng, include_min, include_max)
end

function Maths:RandomFloat(rng)
	if rng == nil then
		return math.random()
	end
	return rng:RandomFloat()
end

return Maths