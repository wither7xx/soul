local SoulCrystal = {}
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths
local Translation = Soul.Global.Translation

local SoulCallbacks = Soul.SoulCallbacks
local modCollectibleType = Soul.modCollectibleType

SoulCrystal.SoulStones = {}
for i = Card.CARD_SOUL_ISAAC, Card.CARD_SOUL_JACOB do
	table.insert(SoulCrystal.SoulStones, i)
end

function SoulCrystal:AddSoulStone(cards)
	local list = {}
	if type(cards) == "number" then
		list = {cards}
	elseif type(cards) == "table" then
		list = cards
	else
		return
	end
	for i, card in pairs(list) do
		if not Common:IsInTable(card, SoulCrystal.SoulStones) then
			table.insert(SoulCrystal.SoulStones, card)
		end
	end
end

function SoulCrystal:OnUse(item, rng, player, use_flags, active_slot, custom_var_data)
	local rand = Maths:RandomInt(#(SoulCrystal.SoulStones), rng, false, true)
	local card = SoulCrystal.SoulStones[rand] or Card.RUNE_SHARD
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
	return {ShowAnim = true, Remove = false}
end
ModRef:AddCallback(ModCallbacks.MC_USE_ITEM, SoulCrystal.OnUse, modCollectibleType.COLLECTIBLE_SOUL_CRYSTAL)

function SoulCrystal:PreAddCollectible(collectible_type, rng, player)
	Translation:ShowDefaultCollectibleText(collectible_type)
end
ModRef:AddCallback(SoulCallbacks.SOULC_PRE_ADD_COLLECTIBLE, SoulCrystal.PreAddCollectible, modCollectibleType.COLLECTIBLE_SOUL_CRYSTAL)

return SoulCrystal