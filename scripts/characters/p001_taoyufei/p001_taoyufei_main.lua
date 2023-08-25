local Main = {}
local Taoyufei = include("scripts/characters/p001_taoyufei/p001_taoyufei_api")
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths

local SoulCallbacks = Soul.SoulCallbacks
local modCollectibleType = Soul.modCollectibleType
local modPlayerType = Soul.modPlayerType
local modCostume = Soul.modCostume

local EnemyProjectiles = Taoyufei.EnemyProjectiles

local function HasTaoyufei()
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		if player:GetPlayerType() == modPlayerType.PLAYER_TAOYUFEI then
			return true
		end
	end
	return false
end

local function CheckSoulCrystal(player)
	if player:GetPlayerType() == modPlayerType.PLAYER_TAOYUFEI 
	and player:GetActiveItem(ActiveSlot.SLOT_POCKET) ~= modCollectibleType.COLLECTIBLE_SOUL_CRYSTAL then
		player:SetPocketActiveItem(modCollectibleType.COLLECTIBLE_SOUL_CRYSTAL, ActiveSlot.SLOT_POCKET, false)
	end
end

function Main:PostPlayerInit(player)
	if player:GetPlayerType() == modPlayerType.PLAYER_TAOYUFEI then
		local game = Game()
		if game:GetFrameCount() <= 0 or game:GetRoom():GetFrameCount() > 0 then
			player:SetPocketActiveItem(modCollectibleType.COLLECTIBLE_SOUL_CRYSTAL, ActiveSlot.SLOT_POCKET, true)
			game:GetItemPool():RemoveCollectible(modCollectibleType.COLLECTIBLE_SOUL_CRYSTAL)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Main.PostPlayerInit, 0)

function Main:PostPlayerUpdate(player)
	if player:GetPlayerType() == modPlayerType.PLAYER_TAOYUFEI then
		local default_sprite_path = "gfx/characters/001_taoyufei.anm2"
		Tools:TrySetStartingCostume(player, modCostume.TAOYUFEI_HAIR, default_sprite_path)
		Taoyufei:TaoyufeiDataInit(player)

		local controller_idx = player.ControllerIndex
		if Input.IsActionTriggered(ButtonAction.ACTION_DROP, controller_idx) then
			--player:SetColor(Color(1, 1, 1, 1, 0.5, 0.5, 0.5), 6, -1, true)
			Taoyufei:TriggerHalfSoulState(player)
		end

		Tools:PlayerData_SetAttribute(player, "Taoyufei_PlayerDataInited", true)
	else
		if Tools:PlayerData_GetAttribute(player, "Taoyufei_PlayerDataInited") == true then
			Taoyufei:SetHalfSoulState(player, false)
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.EARLY, Main.PostPlayerUpdate, 0)

function Main:PostUpdate()
	Tools:TryCheckEsauJrData(CheckSoulCrystal)
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_UPDATE, 10, Main.PostUpdate)

function Main:EvaluateCache(player, caflag)
	if player:GetPlayerType() == modPlayerType.PLAYER_TAOYUFEI then
		--≥ı º Ù–‘
		--[[
		if caflag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage - 0.5
		end
		if caflag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = (30 / (30 / (player.MaxFireDelay + 1) - 0.2) - 1)
		end
		if caflag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange - 40
		end
		if caflag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed - 0.1
		end
		]]
	end
end
ModRef:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Main.EvaluateCache)

function Main:PostProjectileUpdate(projectile)
	if projectile.FrameCount == 1 then
		if Random() % 2 == 0 then
			EnemyProjectiles:TriggerHalfSoulState(projectile)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, Main.PostProjectileUpdate)

function Main:PreProjectileCollision(projectile, other, is_low)
	if other.Type == EntityType.ENTITY_PLAYER and other.Variant == 0 then
		local player = other:ToPlayer()
		if projectile and player and (Taoyufei:IsHalfSoulState(player) == EnemyProjectiles:IsHalfSoulState(projectile)) then
			projectile:Die()
			return false
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, Main.PreProjectileCollision, nil)

return Main