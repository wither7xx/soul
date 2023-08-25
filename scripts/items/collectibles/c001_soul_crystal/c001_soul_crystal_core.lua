local SoulCrystal_META = {
	__index = {},
}
local SoulCrystal = SoulCrystal_META.__index
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths
local Translation = Soul.Global.Translation

local modCollectibleType = Soul.modCollectibleType

local function GetSoulCrystalGlobalData()
	return Tools:Global_GetCollectibleData(modCollectibleType.COLLECTIBLE_SOUL_CRYSTAL)
end

function SoulCrystal:GetSoulStones()
	local data = GetSoulCrystalGlobalData()
	data.SoulStones = data.SoulStones or {}
	return data.SoulStones
end

function SoulCrystal:AddSoulStone(card_list)
	local soul_stones = SoulCrystal:GetSoulStones()
	if type(card_list) == "number" then
		local card = card_list
		if not Common:IsInTable(card, soul_stones) then
			table.insert(soul_stones, card)
		end
	elseif type(card_list) == "table" then
		for _, card in pairs(card_list) do
			if not Common:IsInTable(card, soul_stones) then
				table.insert(soul_stones, card)
			end
		end
	end
end

function SoulCrystal:RandomSoulStone(player, rng, try_spawn)
	local soul_stones = SoulCrystal:GetSoulStones()
	local rand = Maths:RandomInt(#soul_stones, rng, false, true)
	local card = soul_stones[rand] or Card.RUNE_SHARD
	if try_spawn then
		return Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
	else
		return card
	end
end

return SoulCrystal_META