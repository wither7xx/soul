local EnemyProjectiles = {}

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths
local Translation = Soul.Global.Translation

local Taoyufei = include("scripts/characters/p001_taoyufei/p001_taoyufei_core").__index

local SoulCallbacks = Soul.SoulCallbacks
local modCollectibleType = Soul.modCollectibleType
local modPlayerType = Soul.modPlayerType
local modCostume = Soul.modCostume

local function GetTaoyufeiEnemyProjectileData(projectile)
	local data = projectile:GetData()
	data.TaoyufeiEnemyProjectileData = data.TaoyufeiEnemyProjectileData or {
		IsHalfSoulState = false
	}
	return data.TaoyufeiEnemyProjectileData
end

function EnemyProjectiles:IsHalfSoulState(projectile)
	local data = GetTaoyufeiEnemyProjectileData(projectile)
	return data.IsHalfSoulState
end

function EnemyProjectiles:SetHalfSoulState(projectile, value)
	local data = GetTaoyufeiEnemyProjectileData(projectile)
	data.IsHalfSoulState = value
end

function EnemyProjectiles:TriggerHalfSoulState(projectile)
	local data = GetTaoyufeiEnemyProjectileData(projectile)
	local sprite = projectile:GetSprite()
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

return EnemyProjectiles