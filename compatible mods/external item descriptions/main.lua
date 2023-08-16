local CM_EID = {}
local ModRef = Soul

local languages = {
	["zh"] = "zh_cn",
	["en"] = "en_us",
}

EIDtexts = {
	["zh_cn"] = {},
	["en_us"] = {},
}

for i, lang in pairs(languages) do
	include("compatible mods/external item descriptions/descriptions/rep/"..lang)
	local descriptions = EID.descriptions[lang]
	for id, collectible in pairs(EIDtexts[lang].Collectibles) do
		EID:addCollectible(id, collectible.Description, collectible.Name, lang)
		if collectible.bookOfVirtuesWisps and descriptions.bookOfVirtuesWisps then
			descriptions.bookOfVirtuesWisps[id] = collectible.bookOfVirtuesWisps
		end
		if collectible.bookOfBelialBuffs and descriptions.bookOfBelialBuffs then
			descriptions.bookOfBelialBuffs[id] = collectible.bookOfBelialBuffs
		end
	end
	--for id, birthright in pairs(EIDtexts[lang].Birthrights) do
	--	EID:addBirthright(id, birthright.Description, birthright.PlayerName, lang)
	--end
end

return CM_EID