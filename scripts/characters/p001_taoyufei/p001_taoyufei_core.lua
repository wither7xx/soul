local Taoyufei_META = {
	__index = {},
}
local Taoyufei = Taoyufei_META.__index
local ModRef = Soul

local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths

local SoulCallbacks = Soul.SoulCallbacks
local modCollectibleType = Soul.modCollectibleType
local modPlayerType = Soul.modPlayerType
local modCostume = Soul.modCostume

local function GetTaoyufeiData(player)
	local data = Tools:GetPlayerData(player)
	data.TaoyufeiData = data.TaoyufeiData or {}
	return data.TaoyufeiData
end

function Taoyufei:TaoyufeiDataInit(player)
	local data = GetTaoyufeiData(player)
	if data.IsHalfSoulState == nil then
		data.IsHalfSoulState = false
	end
end

function Taoyufei:IsHalfSoulState(player)
	local data = GetTaoyufeiData(player)
	return data.IsHalfSoulState
end

function Taoyufei:SetHalfSoulState(player, value)
	local data = GetTaoyufeiData(player)
	data.IsHalfSoulState = value
end

function Taoyufei:TriggerHalfSoulState(player)
	local data = GetTaoyufeiData(player)
	local sprite = player:GetSprite()
	if data.IsHalfSoulState then
		local color = Color(1, 1, 1, 1, 0, 0, 0)
		sprite.Color = color
		data.IsHalfSoulState = false
	else
		local color = Color(1, 1, 1, 1, 0, 0, 0)
		color:SetColorize(1, 1, 1, 1)
		sprite.Color = color
		data.IsHalfSoulState = true
	end
end

return Taoyufei_META