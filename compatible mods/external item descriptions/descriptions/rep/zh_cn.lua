local CM_EID_Desc_zh_cn = {}

local modCollectibleType = Soul.modCollectibleType
local modTrinketType = Soul.modTrinketType
local modPlayerType = Soul.modPlayerType

local lang = "zh_cn"

CM_EID_Desc_zh_cn.Collectibles = {
	--[[	
	[modCollectibleType.XXX] = {
		Name = "",
		Description = "",
		bookOfVirtuesWisps = "",
		bookOfBelialBuffs = "",
	},
	]]
	[modCollectibleType.COLLECTIBLE_SOUL_CRYSTAL] = {
		Name = "桃灵之魄",
		Description = "{{Rune}} 生成1随机魂石",
	},
	[modCollectibleType.COLLECTIBLE_WAY_TO_STEAL_SOUL] = {
		Name = "盗取灵魂的方法",
		Description = "{{SoulHeart}} 获得1魂心#!!! 清理房间时不充能#每击杀7个敌人获得1充能",
	},
	[modCollectibleType.COLLECTIBLE_SOUL_BET] = {
		Name = "灵魂赌约",
		Description = "进入新一层时：#移除一颗红心（不致死）#如果上一层击败敌人数量不小于35，则获得两个等级大于2的道具#否则，移除1颗红心或3颗魂心（{{Player14}} 店主：硬币数-15）",
	},
	[modCollectibleType.COLLECTIBLE_SOUL_CONTRACT] = {
		Name = "灵魂契约",
		Description = "进入新一层时：#如果上一层击败敌人数量不小于35，则获得一个等级大于1的道具#否则，获得一张随机卡牌",
	},
}

CM_EID_Desc_zh_cn.Trinkets = {
	[modTrinketType.TRINKET_RED_CRYSTAL_NECKLACE] = {
		Name = "红水晶吊坠",
		Description = "↑ {{Luck}} +1运气#进入新房间时有7%几率产生7秒护盾",
	},
}

return CM_EID_Desc_zh_cn