local Main = {}
local SoulContract = include("scripts/items/collectibles/c004_soul_contract/c004_soul_contract_api")
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
	SoulContract:SoulContractDataInit()
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, Main.PostUpdate)

function Main:PostNPCDeath(npc)
	if (not npc:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) and (not EntityRef(npc).IsFriendly) then
		SoulContract:ModifyEnemyCount(1)
		return
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Main.PostNPCDeath, nil)

function Main:PostEntityKill(entity)
	if entity:IsActiveEnemy(true) and entity:HasEntityFlags(EntityFlag.FLAG_ICE) and (not entity:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) then
		local npc = entity:ToNPC()
		if not EntityRef(npc).IsFriendly then
			SoulContract:ModifyEnemyCount(1)
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
		local rng = player:GetCollectibleRNG(modCollectibleType.COLLECTIBLE_SOUL_CONTRACT)	
		if player:HasCollectible(modCollectibleType.COLLECTIBLE_SOUL_CONTRACT) then
			if SoulContract:GetEnemyCount() >= SoulContract.EnemyCountDefaultCritValue then
				RandomCollectibleByQuality_Ranged(player, rng, 2, 4)
				player:AnimateHappy()
			else
				player:UseActiveItem(CollectibleType.COLLECTIBLE_DECK_OF_CARDS, false, false)
			end
		end
		SoulContract:ResetEnemyCount()
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Main.OnNewLevel)

return Main