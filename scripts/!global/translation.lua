local Translation = {}
local ModRef = Soul

local Common = Soul.Global.Common
local Tools = Soul.Global.Tools

local SoulCallbacks = Soul.SoulCallbacks
local modPlayerType = Soul.modPlayerType
local modCollectibleType = Soul.modCollectibleType
local modTrinketType = Soul.modTrinketType
local modCard = Soul.modCard

local BirthrightName = {
	["zh"] = "长子名分",
	["en"] = "Birthright",
}

local BirthrightDesc = {
	["zh"] = {
		[modPlayerType.PLAYER_TAOYUFEI] = "？？？",
	},
	["en"] = {
		[modPlayerType.PLAYER_TAOYUFEI] = "???",
	},
}

local CollectibleConfigText = {
	["zh"] = {
		--[modCollectibleType.XXX] = {Name = "", Desc = "",},
		[modCollectibleType.COLLECTIBLE_SOUL_CRYSTAL] = {Name = "桃灵之魄", Desc = "？？？",},
		[modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL] = {Name = "盗取灵魂的方法", Desc = "？？？",},
		[modCollectibleType.COLLECTIBLE_SOUL_BET] = {Name = "灵魂赌约", Desc = "筹码",},
		[modCollectibleType.COLLECTIBLE_SOUL_CONTRACT] = {Name = "灵魂契约", Desc = "信物",},
	},
}

local TrinketConfigText = {
	["zh"] = {
		--[modTrinketType.XXX] = {Name = "", Desc = "",},
	},
}

local CardConfigText = {
	["zh"] = {
		--[modCard.XXX] = {Name = "", Desc = "",},
	},
}

local function GetPlayerTranslationData(player)
	local data = Tools:GetPlayerData(player)
	data.TranslationData = data.TranslationData or {}
	return data.TranslationData
end

function Translation:FixLanguage(lang)
	local lang_fixed = lang or Options.Language
	if lang_fixed ~= "en" and lang_fixed ~= "zh" then
		lang_fixed = "en"
	end
	return lang_fixed
end

function Translation:GetDefaultCollectibleConfigText(collectible_type, lang)
	local lang_fixed = Translation:FixLanguage(lang)
	if CollectibleConfigText[lang_fixed] and CollectibleConfigText[lang_fixed][collectible_type] then
		return CollectibleConfigText[lang_fixed][collectible_type]
	end
	local item_config_item = Isaac.GetItemConfig():GetCollectible(collectible_type)
	if item_config_item then
		return {Name = item_config_item.Name, Desc = item_config_item.Description,}
	end
	return {Name = "", Desc = "",}
end

function Translation:GetDefaultTrinketConfigText(trinket_type, lang)
	local lang_fixed = Translation:FixLanguage(lang)
	if TrinketConfigText[lang_fixed] and TrinketConfigText[lang_fixed][trinket_type] then
		return TrinketConfigText[lang_fixed][trinket_type]
	end
	local item_config_item = Isaac.GetItemConfig():GetTrinket(trinket_type)
	if item_config_item then
		return {Name = item_config_item.Name, Desc = item_config_item.Description,}
	end
	return {Name = "", Desc = "",}
end

function Translation:GetDefaultCardConfigText(card, lang)
	local lang_fixed = Translation:FixLanguage(lang)
	if CardConfigText[lang_fixed] and CardConfigText[lang_fixed][card] then
		return CardConfigText[lang_fixed][card]
	end
	local item_config_card = Isaac.GetItemConfig():GetCard(card)
	if item_config_card then
		return {Name = item_config_card.Name, Desc = item_config_card.Description,}
	end
	return {Name = "", Desc = "",}
end

function Translation:ShowDefaultCollectibleText(collectible_type)
	local HUD = Game():GetHUD()
	local CollectibleConfigText = Translation:GetDefaultCollectibleConfigText(collectible_type)
	if CollectibleConfigText then
		HUD:ShowItemText(CollectibleConfigText.Name, CollectibleConfigText.Desc)
	end
end

function Translation:ShowDefaultTrinketText(trinket_type)
	local HUD = Game():GetHUD()
	local TrinketConfigText = Translation:GetDefaultTrinketConfigText(trinket_type)
	if TrinketConfigText then
		HUD:ShowItemText(TrinketConfigText.Name, TrinketConfigText.Desc)
	end
end

function Translation:ShowDefaultCardText(card)
	local HUD = Game():GetHUD()
	local CardConfigText = Translation:GetDefaultCardConfigText(card)
	if CardConfigText then
		HUD:ShowItemText(CardConfigText.Name, CardConfigText.Desc)
	end
end

local ItemTranslation_DONE = false

function Translation:CheckQueuedItem()
	local flag = false
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		local data = GetPlayerTranslationData(player)
		if not (player:IsItemQueueEmpty() and data.QueuedCard == nil) then	
			flag = true
			break
		end
	end
	if not flag then
		ItemTranslation_DONE = false
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, Translation.CheckQueuedItem)

function Translation:PreAddItem_RunCallback(player)
	local lang_fixed = Translation:FixLanguage(Options.Language)
	local data = GetPlayerTranslationData(player)
	if not player:IsItemQueueEmpty() then
		local item_config_item = player.QueuedItem.Item
		if item_config_item then
			local item_ID = item_config_item.ID
			if item_config_item:IsCollectible() then
				if not ItemTranslation_DONE then
					local collectible_type = item_ID
					--if CollectibleConfigText[lang_fixed][collectible_type] ~= nil then
					--	HUD:ShowItemText(CollectibleConfigText[lang_fixed][collectible_type].Name, CollectibleConfigText[lang_fixed][collectible_type].Desc)
					if collectible_type == CollectibleType.COLLECTIBLE_BIRTHRIGHT then
						local player_type = player:GetPlayerType()
						if BirthrightName[lang_fixed] and BirthrightDesc[lang_fixed] and BirthrightDesc[lang_fixed][player_type] then
							local HUD = Game():GetHUD()
							HUD:ShowItemText(BirthrightName[lang_fixed], BirthrightDesc[lang_fixed][player_type])
						end
					end
					Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_PRE_ADD_COLLECTIBLE, collectible_type, collectible_type, player:GetCollectibleRNG(collectible_type), player)
					ItemTranslation_DONE = true
				end
			elseif item_config_item:IsTrinket() then
				if not ItemTranslation_DONE then
					local trinket_type = item_ID
					Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_PRE_ADD_TRINKET, trinket_type, trinket_type, player:GetTrinketRNG(trinket_type), player)
					ItemTranslation_DONE = true
				end
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Translation.PreAddItem_RunCallback)

function Translation:PrePickupCollision(pickup, other, collides_other_first)
	local player = other:ToPlayer()
	if player and pickup.Variant == PickupVariant.PICKUP_TAROTCARD then
		local data = GetPlayerTranslationData(player)
		if player:IsItemQueueEmpty() then
			data.QueuedCard = pickup
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, Translation.PrePickupCollision)

function Translation:PreAddCard_RunCallback(player)
	local data = GetPlayerTranslationData(player)
	if data.QueuedCard then
		if (not data.QueuedCard:Exists()) or data.QueuedCard:IsDead() then
			local card = data.QueuedCard.SubType
			for slot_ID = 0, 3 do
				local current_card = player:GetCard(slot_ID)
				if current_card == card then
					if not ItemTranslation_DONE then
						Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_PRE_ADD_CARD, card, card, player)
						ItemTranslation_DONE = true
						return
					end
				end
			end
		end
		data.QueuedCard = nil
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Translation.PreAddCard_RunCallback)

return Translation