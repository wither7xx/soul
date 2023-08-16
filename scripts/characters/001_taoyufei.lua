local Taoyufei = {}
local ModRef = Soul

local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths

local SoulCallbacks = Soul.SoulCallbacks
local modCollectibleType = Soul.modCollectibleType
local modPlayerType = Soul.modPlayerType
local modCostume = Soul.modCostume

function Taoyufei:PostPlayerInit(player)
	if player:GetPlayerType() == modPlayerType.PLAYER_TAOYUFEI then
		local game = Game()
		if not (game:GetRoom():GetFrameCount() < 0 and game:GetFrameCount() > 0) then
			player:SetPocketActiveItem(modCollectibleType.COLLECTIBLE_SOUL_CRYSTAL, ActiveSlot.SLOT_POCKET, false)
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Taoyufei.PostPlayerInit, 0)

function Taoyufei:CheckPlayerData(player)
	if player:GetPlayerType() == modPlayerType.PLAYER_TAOYUFEI then
		local default_sprite_path = "gfx/characters/001_taoyufei.anm2"
		Tools:TrySetStartingCostume(player, modCostume.TAOYUFEI_HAIR, default_sprite_path)

		Tools:PlayerData_SetAttribute(player, "Taoyufei_PlayerDataInited", true)
	else
		if Tools:PlayerData_GetAttribute(player, "Taoyufei_PlayerDataInited") == true then
			--TBA
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.EARLY, Taoyufei.CheckPlayerData, 0)

function Taoyufei:EvaluateCache(player, caflag)
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
ModRef:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Taoyufei.EvaluateCache)

return Taoyufei