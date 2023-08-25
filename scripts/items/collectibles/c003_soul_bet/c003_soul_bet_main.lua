local Main = {}
local SoulBet = include("scripts/items/collectibles/c003_soul_bet/c003_soul_bet_api")
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths
local Translation = Soul.Global.Translation

local SoulCallbacks = Soul.SoulCallbacks
local modCollectibleType = Soul.modCollectibleType

local function RandomCollectibleByQuality_Ranged(player, rng, min_quality, max_quality)
	local quality = Maths:RandomInt_Ranged(min_quality, max_quality, rng)
	Tools:RandomCollectible_ByQuality(player, quality, rng, true)
end

function Main:PostUpdate()
	SoulBet:SoulBetDataInit()
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, Main.PostUpdate)

function Main:PostNPCDeath(npc)
	if (not npc:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) and (not EntityRef(npc).IsFriendly) then
		SoulBet:ModifyEnemyCount(1)
		return
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Main.PostNPCDeath, nil)

function Main:PostEntityKill(entity)
	if entity:IsActiveEnemy(true) and entity:HasEntityFlags(EntityFlag.FLAG_ICE) and (not entity:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) then
		local npc = entity:ToNPC()
		if not EntityRef(npc).IsFriendly then
			SoulBet:ModifyEnemyCount(1)
			return
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Main.PostEntityKill, nil)

function Main:OnNewLevel()
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
			if SoulBet:GetEnemyCount() >= SoulBet.EnemyCountDefaultCritValue then
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
		SoulBet:ResetEnemyCount()
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Main.OnNewLevel)

return Main