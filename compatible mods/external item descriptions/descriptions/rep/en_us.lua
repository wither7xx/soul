local CM_Desc_Texts_en_us = {}

local modCollectibleType = Soul.modCollectibleType
local modTrinketType = Soul.modTrinketType
local modPlayerType = Soul.modPlayerType

local lang = "en_us"

CM_Desc_Texts_en_us.Collectibles = {
	--[[	
	[modCollectibleType.XXX] = {
		Name = "",
		Description = "",
		bookOfVirtuesWisps = "",
		bookOfBelialBuffs = "",
	},
	]]
	[modCollectibleType.COLLECTIBLE_SOUL_CRYSTAL] = {
		Name = "Soul Crystal",
		Description = "{{Rune}} Drops a Soul Stone",
	},
	[modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL] = {
		Name = "The Way To Steal The Soul",
		Description = "{{SoulHeart}} Grants a Soul Heart#!!! Won't be charged after clearing rooms#Grants one charge for every 7 enemies killed",
	},
	[modCollectibleType.COLLECTIBLE_SOUL_BET] = {
		Name = "Soul Bet",
		Description = "When entering a new floor:#Removes 1 Red Heart (won't kill the player)#Grants 2 items with a quality greater than 2 if the player kills 35 enemies or more on previous floor#Removes 1 Red Heart or 3 Soul Hearts otherwise (-15 coins as {{Player14}}Keeper)",
	},
	[modCollectibleType.COLLECTIBLE_SOUL_CONTRACT] = {
		Name = "Soul Contract",
		Description = "When entering a new floor:#Grants 1 item with a quality greater than 1 if the player kills 35 enemies or more on the previous floor#Grants a random card otherwise",
	},
}

CM_Desc_Texts_en_us.Trinkets = {
	[modTrinketType.TRINKET_RED_CRYSTAL_NECKLACE] = {
		Name = "Red Crystal Necklace",
		Description = "¡ü {{Luck}} +1 Luck up#Has a 7% chance to make player invincible for 7 second when entering a new room",
	},
}

return CM_Desc_Texts_en_us