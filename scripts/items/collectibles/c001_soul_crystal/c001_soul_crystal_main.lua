local Main = {}
local SoulCrystal = include("scripts/items/collectibles/c001_soul_crystal/c001_soul_crystal_api")
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools
local Maths = Soul.Global.Maths
local Translation = Soul.Global.Translation

local SoulCallbacks = Soul.SoulCallbacks
local modCollectibleType = Soul.modCollectibleType

for card = Card.CARD_SOUL_ISAAC, Card.CARD_SOUL_JACOB do
	SoulCrystal:AddSoulStone(card)
end

function Main:OnUse(item, rng, player, use_flags, active_slot, custom_var_data)
	SoulCrystal:RandomSoulStone(player, rng, true)
	return {ShowAnim = true, Remove = false}
end
ModRef:AddCallback(ModCallbacks.MC_USE_ITEM, Main.OnUse, modCollectibleType.COLLECTIBLE_SOUL_CRYSTAL)

return Main