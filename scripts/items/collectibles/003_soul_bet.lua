local SoulBet = {}
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths
local Translation = Soul.Global.Translation

local SoulCallbacks = Soul.SoulCallbacks
local modCollectibleType = Soul.modCollectibleType

local function RandomCollectibleByQuality_Ranged(player, rng, min_quality, max_quality)
	local quality = Maths:RandomInt_Ranged(min_quality, max_quality, rng)
	Tools:RandomCollectible_ByQuality(player, quality, rng)
end

function SoulBet:PlayerCollectibleDataInit(player)
	local data = Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_SOUL_BET)
	if data.EnemyCount == nil then
		data.EnemyCount = 0
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, SoulBet.PlayerCollectibleDataInit, 0)

function SoulBet:GetEnemyCount(player)
	local data = Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_SOUL_BET)
	return data.EnemyCount or 0
end

function SoulBet:ResetEnemyCount(player)
	local data = Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_SOUL_BET)
	data.EnemyCount = 0
end

function SoulBet:ModifyEnemyCount(player, amount)
	local data = Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_SOUL_BET)
	if data.EnemyCount then
		data.EnemyCount = math.max(0, data.EnemyCount + amount)
	end
end

function SoulBet:PostNPCDeath(npc)
	local NumPlayers = Game():GetNumPlayers()
	if (not npc:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) and (not EntityRef(npc).IsFriendly) then
		for p = 0, NumPlayers - 1 do
			local player = Isaac.GetPlayer(p)
			SoulBet:ModifyEnemyCount(player, 1)
		end
		return
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, SoulBet.PostNPCDeath, nil)

function SoulBet:PostEntityKill(entity)
	local NumPlayers = Game():GetNumPlayers()
	if entity:IsActiveEnemy(true) and entity:HasEntityFlags(EntityFlag.FLAG_ICE) and (not entity:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) then
		local npc = entity:ToNPC()
		if not EntityRef(npc).IsFriendly then
			for p = 0, NumPlayers - 1 do
				local player = Isaac.GetPlayer(p)
				SoulBet:ModifyEnemyCount(player, 1)
			end
			return
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, SoulBet.PostEntityKill, nil)

function SoulBet:OnNewLevel()
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		local playerType = player:GetPlayerType()
		local rng = player:GetCollectibleRNG(modCollectibleType.COLLECTIBLE_SOUL_BET)	
		if player:HasCollectible(modCollectibleType.COLLECTIBLE_SOUL_BET) then
			if playerType ~= PlayerType.PLAYER_KEEPER and playerType ~= PlayerType.PLAYER_KEEPER_B then
				if player:GetEffectiveMaxHearts() > 2 then
					if player:GetBoneHearts() > 0 then
						player:AddBoneHearts(-1)
					else
						player:AddMaxHearts(-2, true)
					end
				end
			else
				player:AddCoins(-15)
			end
			if SoulBet:GetEnemyCount(player) >= 35 then
				for i = 1, 2 do
					RandomCollectibleByQuality_Ranged(player, rng, 3, 4)
				end
				player:AnimateHappy()
			else
				if playerType ~= PlayerType.PLAYER_KEEPER and playerType ~= PlayerType.PLAYER_KEEPER_B then
					if player:GetHearts() + player:GetSoulHearts() + player:GetBoneHearts() > 1 then
						if player:GetEffectiveMaxHearts() > 2 then
							if player:GetBoneHearts() > 0 then
								player:AddBoneHearts(-1)
							else
								player:AddMaxHearts(-2, true)
							end
						else
							for i = 1, 3 do
								if player:GetSoulHearts() > 2 then
									player:AddSoulHearts(-2)
								end	
							end
						end
					end
				else
					player:AddCoins(-15)
				end
				player:AnimateSad()
			end
		end
		SoulBet:ResetEnemyCount(player)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, SoulBet.OnNewLevel)

function SoulBet:PreAddCollectible(collectible_type, rng, player)
	Translation:ShowDefaultCollectibleText(collectible_type)
end
ModRef:AddCallback(SoulCallbacks.SOULC_PRE_ADD_COLLECTIBLE, SoulBet.PreAddCollectible, modCollectibleType.COLLECTIBLE_SOUL_BET)

return SoulBet