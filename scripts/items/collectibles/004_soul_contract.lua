local SoulContract = {}
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

function SoulContract:PlayerCollectibleDataInit(player)
	local data = Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_SOUL_CONTRACT)
	if data.EnemyCount == nil then
		data.EnemyCount = 0
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, SoulContract.PlayerCollectibleDataInit, 0)

function SoulContract:GetEnemyCount(player)
	local data = Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_SOUL_CONTRACT)
	return data.EnemyCount or 0
end

function SoulContract:ResetEnemyCount(player)
	local data = Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_SOUL_CONTRACT)
	data.EnemyCount = 0
end

function SoulContract:ModifyEnemyCount(player, amount)
	local data = Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_SOUL_CONTRACT)
	if data.EnemyCount then
		data.EnemyCount = math.max(0, data.EnemyCount + amount)
	end
end

function SoulContract:PostNPCDeath(npc)
	local NumPlayers = Game():GetNumPlayers()
	if (not npc:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) and (not EntityRef(npc).IsFriendly) then
		for p = 0, NumPlayers - 1 do
			local player = Isaac.GetPlayer(p)
			SoulContract:ModifyEnemyCount(player, 1)
		end
		return
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, SoulContract.PostNPCDeath, nil)

function SoulContract:PostEntityKill(entity)
	local NumPlayers = Game():GetNumPlayers()
	if entity:IsActiveEnemy(true) and entity:HasEntityFlags(EntityFlag.FLAG_ICE) and (not entity:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) then
		local npc = entity:ToNPC()
		if not EntityRef(npc).IsFriendly then
			for p = 0, NumPlayers - 1 do
				local player = Isaac.GetPlayer(p)
				SoulContract:ModifyEnemyCount(player, 1)
			end
			return
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, SoulContract.PostEntityKill, nil)

function SoulContract:OnNewLevel()
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		local playerType = player:GetPlayerType()
		local rng = player:GetCollectibleRNG(modCollectibleType.COLLECTIBLE_SOUL_CONTRACT)	
		if player:HasCollectible(modCollectibleType.COLLECTIBLE_SOUL_CONTRACT) then
			if SoulContract:GetEnemyCount(player) >= 35 then
				RandomCollectibleByQuality_Ranged(player, rng, 2, 4)
				player:AnimateHappy()
			else
				player:UseActiveItem(CollectibleType.COLLECTIBLE_DECK_OF_CARDS, false, false)
			end
		end
		SoulContract:ResetEnemyCount(player)
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, SoulContract.OnNewLevel)

function SoulContract:PreAddCollectible(collectible_type, rng, player)
	Translation:ShowDefaultCollectibleText(collectible_type)
end
ModRef:AddCallback(SoulCallbacks.SOULC_PRE_ADD_COLLECTIBLE, SoulContract.PreAddCollectible, modCollectibleType.COLLECTIBLE_SOUL_CONTRACT)

return SoulContract