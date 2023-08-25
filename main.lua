Soul = RegisterMod("Soul",1)

local Fonts = {
	["en"] = Font(),
	["zh"] = Font(),
	["number"] = Font(),
}
Fonts["en"]:Load("font/pftempestasevencondensed.fnt")
Fonts["zh"]:Load("font/cjk/lanapixel.fnt")
Fonts["number"]:Load("font/pftempestasevencondensed.fnt")

Soul.modCollectibleType = {
	COLLECTIBLE_SOUL_CRYSTAL = Isaac.GetItemIdByName("Soul Crystal"),
	COLLECTIBLE_WAY_TO_STEAL_SOUL = Isaac.GetItemIdByName("The Way To Steal The Soul"),
	COLLECTIBLE_SOUL_BET = Isaac.GetItemIdByName("Soul Bet"),
	COLLECTIBLE_SOUL_CONTRACT = Isaac.GetItemIdByName("Soul Contract"),
}

Soul.modCostume = {
	TAOYUFEI_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_taoyufei_hair.anm2"),
}

Soul.modEffectVariant = {
	BLANK_ANIM = Isaac.GetEntityVariantByName("Blank Animation"),
}

Soul.Fonts = Fonts

Soul.modPlayerType = {
	PLAYER_TAOYUFEI = Isaac.GetPlayerTypeByName("Taoyufei", false),
}

Soul.modTrinketType = {
	TRINKET_RED_CRYSTAL_NECKLACE = Isaac.GetTrinketIdByName("Red Crystal Necklace"),
}


Soul.TempData = {}
Soul.TempData.PlayerData = {}
Soul.TempData.GameData = {}
Soul.TempData.NPCData = {}
Soul.TempData.EffectData = {}

Soul.SoulCallbacks = {
	SOULC_DOUBLE_TAP = "SOULC_DOUBLE_TAP",								--回调参数：button_action（整数）；函数参数：button_action（整数），player（角色实体对象）；返回值类型：无
	SOULC_TAP_AND_HOLD_MOVING = "SOULC_TAP_AND_HOLD_MOVING",			--回调参数：action_type（整数；0：按住；1：释放）；函数参数：move_dir（向量），player（角色实体对象）；返回值类型：无
	SOULC_TAP_AND_HOLD_SHOOTING = "SOULC_TAP_AND_HOLD_SHOOTING",		--回调参数：action_type（整数；0：按住；1：释放）；函数参数：shoot_dir（向量），player（角色实体对象）；返回值类型：无
	SOULC_PRE_ADD_COLLECTIBLE = "SOULC_PRE_ADD_COLLECTIBLE",			--回调参数：collectible_type（整数）；函数参数：collectible_type（整数），rng（RNG对象），player（角色实体对象）；返回值类型：无
	SOULC_POST_ADD_COLLECTIBLE = "SOULC_POST_ADD_COLLECTIBLE",			--回调参数：collectible_type（整数）；函数参数：collectible_type（整数），rng（RNG对象），player（角色实体对象），is_newly_added（逻辑）；返回值类型：无
	SOULC_PRE_ADD_TRINKET = "SOULC_PRE_ADD_TRINKET",					--回调参数：trinket_type（整数）；函数参数：trinket_type（整数），rng（RNG对象），player（角色实体对象）；返回值类型：无
	SOULC_PRE_ADD_CARD = "SOULC_PRE_ADD_CARD",							--回调参数：card（整数）；函数参数：card（整数），player（角色实体对象）；返回值类型：无
	SOULC_POST_NEW_GREED_MODE_WAVE = "SOULC_POST_NEW_GREED_MODE_WAVE",	--回调参数：无；函数参数：current_wave（整数）；返回值类型：无
}

Soul.Global = {}
Soul.Global.Common = include("scripts/!global/common")
Soul.Global.Maths = include("scripts/!global/maths")
Soul.Global.Tools = include("scripts/!global/tools")
Soul.Global.Translation = include("scripts/!global/translation")
Soul.Global.ModData = include("scripts/!global/mod_data")


local modCollectibleType = Soul.modCollectibleType
Soul.Collectibles = {
	[modCollectibleType.COLLECTIBLE_SOUL_CRYSTAL] = include("scripts/items/collectibles/c001_soul_crystal/c001_soul_crystal_main"),
	[modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL] = include("scripts/items/collectibles/c002_way_to_steal_soul/c002_way_to_steal_soul_main"),
	[modCollectibleType.COLLECTIBLE_SOUL_BET] = include("scripts/items/collectibles/c003_soul_bet/c003_soul_bet_main"),
	[modCollectibleType.COLLECTIBLE_SOUL_CONTRACT] = include("scripts/items/collectibles/c004_soul_contract/c004_soul_contract_main"),
}

local modTrinketType = Soul.modTrinketType
Soul.Trinkets = {
	[modTrinketType.TRINKET_RED_CRYSTAL_NECKLACE] = include("scripts/items/trinkets/t001_red_crystal_necklace/t001_red_crystal_necklace_main"),
}

local modPlayerType = Soul.modPlayerType
Soul.Characters = {
	[modPlayerType.PLAYER_TAOYUFEI] = include("scripts/characters/p001_taoyufei/p001_taoyufei_main"),
}

Soul.CompatibleMods = include("compatible mods/main")

function Soul:TryReloadShaders()
	local players = Isaac.FindByType(EntityType.ENTITY_PLAYER)
    if #players <= 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end
Soul:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Soul.TryReloadShaders)

--调试专用
--[[
do
	local Tools = Soul.Global.Tools
	local modCollectibleType = Soul.modCollectibleType
	function Soul:DebugWatcher(player, offset)
		local font = Fonts[Options.Language] or Fonts["en"]
		local bet_data = Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_SOUL_BET)
		local contract_data = Tools:GetPlayerCollectibleData(player, modCollectibleType.COLLECTIBLE_SOUL_CONTRACT)
		local texts = {
			[1] = "Bet Count: ".. tostring(bet_data.EnemyCount),
			[2] = "Contract Count: ".. tostring(contract_data.EnemyCount),
			[3] = "Charge: " .. tostring(player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) + player:GetBatteryCharge(ActiveSlot.SLOT_PRIMARY)),
			[4] = "MaxCharge: " .. tostring(Isaac.GetItemConfig():GetCollectible(modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL).MaxCharges)
		}
		local pos = Tools:GetEntityRenderScreenPos(player)
		for i = 1, #texts do
			font:DrawStringUTF8(texts[i], pos.X - 200, pos.Y - 5 * #texts + i * 15, KColor(1, 1, 1, 0.8), 400, true)
		end
	end
	Soul:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Soul.DebugWatcher)
end
]]
