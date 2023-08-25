local CM_EID = {}
local ModRef = Soul

local Tools = Soul.Global.Tools
local modCollectibleType = Soul.modCollectibleType
local modPlayerType = Soul.modPlayerType

local CharacterIcon = Sprite()
CharacterIcon:Load("gfx/compatible mods/eid/character icon.anm2", true)

EID:addIcon("Player"..modPlayerType.PLAYER_TAOYUFEI, "Taoyufei", 0, 12, 12, -1, 1, CharacterIcon)

local desc_root = "compatible mods/external item descriptions/descriptions/rep/"
CM_EID.Descriptions = {
	["zh_cn"] = include(desc_root .. "zh_cn"),
	["en_us"] = include(desc_root .. "en_us"),
}

do
	local Descriptions = CM_EID.Descriptions
	for lang, desc in pairs(Descriptions) do
		local OrigDescList = EID.descriptions[lang]
		if OrigDescList then
			if desc.Collectibles then
				for id, collectible in pairs(desc.Collectibles) do
					EID:addCollectible(id, collectible.Description, collectible.Name, lang)
					if collectible.bookOfVirtuesWisps and OrigDescList.bookOfVirtuesWisps then
						OrigDescList.bookOfVirtuesWisps[id] = collectible.bookOfVirtuesWisps
					end
					if collectible.bookOfBelialBuffs and OrigDescList.bookOfBelialBuffs then
						OrigDescList.bookOfBelialBuffs[id] = collectible.bookOfBelialBuffs
					end
				end
			end
			if desc.Trinkets then
				for id, trinket in pairs(desc.Trinkets) do
					EID:addTrinket(id, trinket.Description, trinket.Name, lang)
				end
			end
			if desc.Birthrights then
				for id, birthright in pairs(desc.Birthrights) do
					EID:addBirthright(id, birthright.Description, birthright.PlayerName, lang)
				end
			end
		end
	end
end

return CM_EID