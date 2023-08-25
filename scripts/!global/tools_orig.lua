local Tools = {}

local ModRef = Soul
local Common = Soul.Global.Common
local Maths = Soul.Global.Maths

local SoulCallbacks = Soul.SoulCallbacks
local modEffectVariant = Soul.modEffectVariant

--��ʼ����Ϸ����
function Tools:GameDataInit(is_continued)
	if not is_continued then
		Soul.TempData.GameData = {}
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Tools.GameDataInit, 0)

--��ʼ��NPC����
function Tools:NPCDataInit(is_continued)
	if not is_continued then
		Soul.TempData.NPCData = {}
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Tools.GameDataInit, 0)

function Tools:GetNPCData(entity)
	local idx = tostring(GetPtrHash(entity))
	Soul.TempData.NPCData[idx] = Soul.TempData.NPCData[idx] or {}
	return Soul.TempData.NPCData[idx]
end

--��ʼ����ɫ���ݡ��û��Ĵ������ɫ��̬����
function Tools:PlayerDataInit(is_continued)
	if not is_continued then
		Soul.TempData.PlayerData = {}
		Soul.TempData.PlayerData_UserRegister = {}
		Soul.TempData.PlayerData_Static["UserNum"] = 0
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Tools.PlayerDataInit, 0)

--ȡ��ɫ������ignore_pairing��Ϊfalse��/�û�������ignore_pairing��Ϊtrue������������
function Tools:GetPlayerIndex(player, ignore_pairing)
	local CollectibleRNG = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SAD_ONION)
	local collectible_type = CollectibleType.COLLECTIBLE_SAD_ONION
	local player_type = player:GetPlayerType()
	--����һ�����ߵ�RNG�����ֱ�˫��/�����ı���̬������̬
	if not ignore_pairing then
		if player_type == PlayerType.PLAYER_LAZARUS2_B then
			collectible_type = CollectibleType.COLLECTIBLE_INNER_EYE
		end
	else
		player = player:GetMainTwin()
	end
	local CollectibleRNG = player:GetCollectibleRNG(collectible_type)
	return tostring(CollectibleRNG:GetSeed())
end

--ȡ��ɫ���ݣ���������½�ɫ�����˫��/����/��Ʒ�ޣ������¼���Ĳ��ֳ�ʼ��
function Tools:GetPlayerData(player)
	local idx = Tools:GetPlayerIndex(player, false)
	Soul.TempData.PlayerData[idx] = Soul.TempData.PlayerData[idx] or {}
	return Soul.TempData.PlayerData[idx]
end

--ȡ��ɫ��������
function Tools:GetPlayerCollectibleData(player, collectible_type)
	local data = Tools:GetPlayerData(player)
	if collectible_type == nil or collectible_type <= 0 then
		return data
	end
	local idx = tostring(collectible_type)
	data[idx] = data[idx] or {}
	return data[idx]
end


--����û��Ĵ���������������û������ɵ���ģʽ��Ϊ����ģʽʱ�������¼���Ĳ��ֳ�ʼ��
function Tools:CheckUserNum(player)
	local idx_user = Tools:GetPlayerIndex(player, true)
	if Soul.TempData.PlayerData_UserRegister[idx_user] == nil then
		Soul.TempData.PlayerData_UserRegister[idx_user] = Soul.TempData.PlayerData_Static["UserNum"]
		Soul.TempData.PlayerData_Static["UserNum"] = Soul.TempData.PlayerData_Static["UserNum"] + 1
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.IMPORTANT, Tools.CheckUserNum, 0)

--ȡ��ǰ�û���Ŀ����������
function Tools:GetUserNum()
	return Soul.TempData.PlayerData_Static["UserNum"] or 1
end

--�ɽ�ɫ����ȡ�û���������������
function Tools:GetUserIdx(player)
	local idx_user = Tools:GetPlayerIndex(player, true)
	return Soul.TempData.PlayerData_UserRegister[idx_user] or 0
end

--��ɫ���������������
function Tools:PlayerData_AddAttribute(player, key, starting_value)
	local idx = Tools:GetPlayerIndex(player, false)
	if Soul.TempData.PlayerData[idx] and Soul.TempData.PlayerData[idx][key] == nil then
		Soul.TempData.PlayerData[idx][key] = starting_value
	end
end

function Tools:PlayerData_GetAttribute(player, key)
	local idx = Tools:GetPlayerIndex(player, false)
	if Soul.TempData.PlayerData[idx] then
		return Soul.TempData.PlayerData[idx][key]
	end
	return nil
end

function Tools:PlayerData_SetAttribute(player, key, value)
	local idx = Tools:GetPlayerIndex(player, false)
	if Soul.TempData.PlayerData[idx] then
		Soul.TempData.PlayerData[idx][key] = value
	end
end

function Tools:PlayerData_ClearAttribute(player, key)
	local idx = Tools:GetPlayerIndex(player, false)
	if Soul.TempData.PlayerData[idx] then
		Soul.TempData.PlayerData[idx][key] = nil
	end
end

--�ж�player�Ƿ�Ϊԭ���ɫ
function Tools:IsOriginalCharacter(player)
	local player_type = player:GetPlayerType()
	return player_type < PlayerType.NUM_PLAYER_TYPES
end

--�ж�item�Ƿ�Ϊ��ռ������λ�ĵ��ߣ��������ߡ�������ߡ�����Ȩ���������߼�
function Tools:IsNoPassiveSlotItem(item)
	if item == CollectibleType.COLLECTIBLE_BIRTHRIGHT then
		return true
	end
	local item_config = Isaac.GetItemConfig():GetCollectible(item)
	if item_config then
		if item_config.Type == ItemType.ITEM_ACTIVE or item_config:HasTags(ItemConfig.TAG_QUEST) then
			return true
		end
	end
	return false
end

--ͳ�����е��ߣ���������
function Tools:GetAllSlotItem()
	local ItemList = {}
	for i = 1, Isaac.GetItemConfig():GetCollectibles().Size do
		if Isaac.GetItemConfig():GetCollectible(i) then	--�˴��������ɺ��ԣ�����i��ItemConfigֵΪnilʱ�ᱨ��
			table.insert(ItemList, i)
		end
	end
	return ItemList
end

--ͳ�����в�ռ������λ�ĵ��ߣ���������
function Tools:GetNoPassiveSlotItem()
	local ItemList = {}
	for i = 1, Isaac.GetItemConfig():GetCollectibles().Size do
		if Tools:IsNoPassiveSlotItem(i) then
			table.insert(ItemList, i)
		end
	end
	return ItemList
end

--ͳ������Ʒ��Ϊquality�ĵ��ߣ��������飨�������ص��ߺ�������ߣ�
function Tools:GetAllItem_ByQuality(quality)
	local ItemList = {}
	for i = 1, Isaac.GetItemConfig():GetCollectibles().Size do
		if (Isaac.GetItemConfig():GetCollectible(i)) then
			if Isaac.GetItemConfig():GetCollectible(i).Quality == quality and (not Isaac.GetItemConfig():GetCollectible(i).Hidden) and (not Isaac.GetItemConfig():GetCollectible(i):HasTags(ItemConfig.TAG_QUEST)) then
				table.insert(ItemList, i)
			end
		end
	end
	return ItemList
end

--ǿ����ӵ��ߣ������ɫ�������������߲�λ���������ڽ�ɫ������ɵ��ߣ�
local NoPassiveSlotItem

function Tools:AddCollectibleForcibly(player, item)
	local canAddCollectible = true
	if player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B then
		local slot_capacity
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			slot_capacity = 12
		else
			slot_capacity = 8
		end
		local slot_remain = slot_capacity - player:GetCollectibleCount()
		NoPassiveSlotItem = NoPassiveSlotItem or Tools:GetNoPassiveSlotItem()
		for i, j in pairs(NoPassiveSlotItem) do
			slot_remain = slot_remain + player:GetCollectibleNum(j)
		end
		if slot_remain <= 0 then
			canAddCollectible = false
		end
	end
	if canAddCollectible then
		player:AddCollectible(item)
	else
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector.Zero, nil)
	end
	return
end

--ͳ�ƽ�ɫӵ�еġ�Ʒ��Ϊquality�ĵ�����Ŀ����������
function Tools:GetCollectibleNum_ByQuality(player, quality)
	local sum = 0
	ItemList_All = ItemList_All or Tools:GetAllSlotItem()
	for i, item in pairs(ItemList_All) do
		if Isaac.GetItemConfig():GetCollectible(item).Quality == quality then
			sum = sum + player:GetCollectibleNum(item)
		end
	end
	return sum
end

--ͳ�ƽ�ɫӵ�еġ����б�ǩtag�ĵ�����Ŀ����������
function Tools:GetCollectibleNum_ByTags(player, tag)
	local sum = 0
	ItemList_All = ItemList_All or Tools:GetAllSlotItem()
	for i, item in pairs(ItemList_All) do
	--for i = 1, Isaac.GetItemConfig():GetCollectibles().Size do
		if Isaac.GetItemConfig():GetCollectible(item):HasTags(tag) then
			sum = sum + player:GetCollectibleNum(item)
		end
	end
	return sum
end

--�������һ��Ʒ��Ϊquality�ĵ��ߣ����ص��ߣ�ʰȡ��ʵ�����
function Tools:RandomCollectible_ByQuality(player, quality, rng)
	local DefaultCollectibleType = {
		[0] = CollectibleType.COLLECTIBLE_POOP,
		[1] = CollectibleType.COLLECTIBLE_LUNCH,
		[2] = CollectibleType.COLLECTIBLE_CUBE_OF_MEAT,
		[3] = CollectibleType.COLLECTIBLE_STEVEN,
		[4] = CollectibleType.COLLECTIBLE_BRIMSTONE,
	}
	local ItemList_ByQuality = ItemList_ByQuality or Tools:GetAllItem_ByQuality(quality)
	local size = #ItemList_ByQuality
	local rand = Maths:RandomInt(size, rng, false, true)
	local attempts = 0
	local collectible_type = ItemList_ByQuality[rand + 1]
	while player:HasCollectible(collectible_type) and attempts < size do
		rand = (rand + 1) % size
		attempts = attempts + 1
		collectible_type = ItemList_ByQuality[rand + 1]
	end
	if attempts == size then
		collectible_type = DefaultCollectibleType[quality] or CollectibleType.COLLECTIBLE_BREAKFAST
	end
	return Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible_type, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
end

--����ĳʵ������⶯�������ء��հ׶�������Ч��ʵ�����
function Tools:PlayUniqueAnimation(entity, anim_name)
	local sprite = entity:GetSprite()
	local FILE = sprite:GetFilename()
	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, modEffectVariant.BLANK_ANIM, 0, entity.Position, Vector.Zero, entity)
	local effect_sprite = effect:GetSprite()
	effect_sprite:Load(FILE, true)
	effect_sprite:Play(anim_name)
	return effect
end

--ģ���ɫ�ġ�˦����Ч��������ʸ��
function Tools:GetSwingShotDir(mov_dir, shoot_dir, shot_speed)
	local X_hasVelocity = Maths:Sign(math.max(0, math.abs(mov_dir.X)))	--ֵΪ1����������ٶȷ�ʸ����Ϊ0����
	local Y_hasVelocity = Maths:Sign(math.max(0, math.abs(mov_dir.Y)))
	local X_isSameDir =	Maths:Sign(shoot_dir.X * mov_dir.X)				--ֵΪ1������Ͻ�ɫ�������ٶȷ�ʸ��ͬ��Ϊ-1����Ϊ0������������ɫ�����ߵ��ٶȷ�ʸ��
	local Y_isSameDir =	Maths:Sign(shoot_dir.Y * mov_dir.Y)
	local isSwing = Vector(X_hasVelocity * Maths:Sign(X_isSameDir + X_hasVelocity), Y_hasVelocity * Maths:Sign(Y_isSameDir + Y_hasVelocity))	--����Ϊ1����÷�ʸ������˦��������Ϊ0��˦��

	return (shoot_dir + mov_dir * 0.125 * isSwing) * 10 * shot_speed
end

function Tools:GetHUDOffsetPos(unm_X, unm_Y)
	local game = Game()
	local HUDOffset = Options.HUDOffset
	local sign_X = 1
	if unm_X then
		sign_X = -1
	end
	local sign_Y = 1
	if unm_Y then
		sign_Y = -1
	end
	return Vector(sign_X * HUDOffset * 20, sign_Y * HUDOffset * 12)
end

function Tools:GetPlayerHUDOffsetPos(player)
	local unm_X = false
	local unm_Y = false
	local idx = Tools:GetUserIdx(player)
	if idx > 1 then
		unm_Y = true
	end
	if idx % 2 == 1 then
		unm_X = true
	end
	return Tools:GetHUDOffsetPos(unm_X, unm_Y)
end

--function Tools:GetPlayerMirrorWorldPos(player)		--�����ã��󷿼����Ի���ִ���
--	return (player.Position * Vector(-1, 1)) + Vector(640, 0)
--end

function Tools:GetEntityRenderScreenPos(entity)
	local game = Game()
	local IsMirrorWorld = (game:GetRoom():IsMirrorWorld())
	local world_pos = entity.Position + entity.PositionOffset
	local screen_pos = Isaac.WorldToScreen(world_pos)
	if IsMirrorWorld then
		return Vector(Isaac.GetScreenWidth() - screen_pos.X, screen_pos.Y)
	else
		return screen_pos
	end
end

--ȡprev_entity�Ķ黯�汾��Variant������������nil
function Tools:GetTaintedMonsterVariant(prev_entity)
	local type = prev_entity.Type
	local variant = prev_entity.Variant
	local TaintedMonsters = {
		[1] = {Type = EntityType.ENTITY_POOTER, Variant = 2, VariantOrig = 0,},
		[2] = {Type = EntityType.ENTITY_HIVE, Variant = 3, VariantOrig = 0,},
		[3] = {Type = EntityType.ENTITY_BOOMFLY, Variant = 6, VariantOrig = 0,},
		[4] = {Type = EntityType.ENTITY_HOPPER, Variant = 3, VariantOrig = 0,},
		[5] = {Type = EntityType.ENTITY_SPITTY, Variant = 1, VariantOrig = 0,},
		[6] = {Type = EntityType.ENTITY_SUCKER, Variant = 7, VariantOrig = 0,},
		[7] = {Type = EntityType.ENTITY_WALL_CREEP, Variant = 3, VariantOrig = 0,},
		--[8] = {Type = EntityType.ENTITY_ROUND_WORM, Variant = 2, VariantOrig = 0,},
		[8] = {Type = EntityType.ENTITY_ROUND_WORM, Variant = 3, VariantOrig = 1},
		[9] = {Type = EntityType.ENTITY_SUB_HORF, Variant = 1, VariantOrig = 0,},
		[10] = {Type = EntityType.ENTITY_FACELESS, Variant = 1, VariantOrig = 0,},
		[11] = {Type = EntityType.ENTITY_MOLE, Variant = 1, VariantOrig = 0,},
		[12] = {Type = EntityType.ENTITY_CHARGER_L2, Variant = 1, VariantOrig = 0,},
	}
	for i = 1, #TaintedMonsters do
		if TaintedMonsters[i].Type == type and variant ~= TaintedMonsters[i].Variant then
			return TaintedMonsters[i].Variant
		end
	end
	return nil
end

--�ж��Ƿ���ʾHUD�������߼�
function Tools:CanShowHUD()
	local game = Game()
	return (not game:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD)) and game:GetHUD():IsVisible() == true
end

--��ʹ���������ߵ�player��use_flag�ж��Ƿ��ܹ���ӻ�𣬷����߼�
function Tools:CanAddWisp(player, use_flag)
	return player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
		and (use_flag & UseFlag.USE_NOANIM == 0 
			or use_flag & UseFlag.USE_ALLOWWISPSPAWN > 0)
end

--�ж�entity�Ƿ�Ϊ�����ĵй֣������߼�
function Tools:IsIndividualEnemy(entity)
	if entity and entity:IsActiveEnemy(true) and (not entity:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN)) then
		local npc = entity:ToNPC()
		return npc and (npc.SpawnerType == 0 or npc.SpawnerType == nil)
	end
	return false
end

--�ж�entity��chance%�ļ������Ƿ��ܴ����¼��������߼�
function Tools:CanTriggerEvent(entity, chance)
	if entity and entity.DropSeed then
		return entity.DropSeed % 10000 < chance * 100
	end
	return false
end

--�ж��Ƿ�Ϊͬһʵ�壬�����߼�
function Tools:IsSameEntity(entity_A, entity_B)
	return (entity_A and entity_B) and (GetPtrHash(entity_A) == GetPtrHash(entity_B))
end

--ȡ��other����Ľ�ɫʵ�壬���ؽ�ɫʵ�����
function Tools:GetNearestPlayer(other)
	local player0 = Isaac.GetPlayer(0)
	local dis0 = other.Position:Distance(player0.Position)
	for p = 1, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(p)
		local dis = other.Position:Distance(player.Position)
		if dis < dis0 then
			dis0 = dis
			player0 = player
		end
	end
	return player0
end

--ȡ��other����Ľ�ɫʵ��֮���룬���ظ�����
function Tools:GetNearestPlayerDistance(other)
	local player0 = Tools:GetNearestPlayer(other)
	return other.Position:Distance(player0.Position)
end

--Ϊplayer��ӳ�ʼ���costume
function Tools:SetStartingCostume(player, costume)
	player:TryRemoveNullCostume(costume)
	player:AddNullCostume(costume)
end

--����Ϊplayer��ӳ�ʼ���costume������default_sprite_path��ֹ���׷��ս���ͷ
function Tools:TrySetStartingCostume(player, costume, default_sprite_path)
	if player.Variant == 0 then
		local data = Tools:GetPlayerData(player)
		--print("data.HasStartingCostume: " .. tostring(data.HasStartingCostume))
		if data.HasStartingCostume then
			if player:IsCoopGhost() then
				--player:TryRemoveNullCostume(costume)
				data.HasStartingCostume = false
			end
			if player:HasCurseMistEffect() then
				if not data.HadCurseMistEffect then
					data.HadCurseMistEffect = true
					local sprite = player:GetSprite()
					local anim = sprite:GetAnimation()
					local frame = sprite:GetFrame()
					local overlay_anim = sprite:GetOverlayAnimation()
					local overlay_frame = sprite:GetOverlayFrame()
					sprite:Load(default_sprite_path, true)
					sprite:SetFrame(anim, frame)
					sprite:SetOverlayFrame(overlay_anim, overlay_frame)
				end
			end
		elseif not player:IsCoopGhost() then
			Tools:SetStartingCostume(player, costume)
			data.HasStartingCostume = true
		end
	end
end

function Tools:StartingCostume_OnInit(player)
	if player.Variant == 0 then
		local data = Tools:GetPlayerData(player)
		data.HasStartingCostume = false
		data.HadCurseMistEffect = false
		--print("Tools:StartingCostume_OnInit")
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Tools.StartingCostume_OnInit, 0)
--[[
function Tools:StartingCostume_PostNewRoom()
	local NumPlayers = Game():GetNumPlayers()
	for p = 0, NumPlayers - 1 do
		local player = Isaac.GetPlayer(p)
		local data = Tools:GetPlayerData(player)
		if data.HasStartingCostume then
			data.HasStartingCostume = false
			--print("new room")
		end
	end
end
ModRef:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, Tools.StartingCostume_PostNewRoom)
]]
--ȡ��ɫ������򣬷���ʸ��
function Tools:GetShootingDir(player)
	local dir = player:GetFireDirection()
	if dir ~= Direction.NO_DIRECTION and player:AreControlsEnabled() then
		if dir == Direction.UP then
			return Vector(0, -1)
		elseif dir == Direction.DOWN then
			return Vector(0, 1)
		elseif dir == Direction.LEFT then
			return Vector(-1, 0)
		elseif dir == Direction.RIGHT then
			return Vector(1, 0)
		end
	end
	return Vector(0, 0)
end

function Tools:GetShootingJoystick(player)
    if not player:AreControlsEnabled() then
        return Vector(0, 0)
    end
	local controller_idx = player.ControllerIndex
    if Options.MouseControl and controller_idx == 0 then
        if Input.IsMouseBtnPressed(controller_idx) then
            return (Input.GetMousePosition(true) - player.Position):Normalized()
        end
    end
    return player:GetShootingJoystick()
end

function Tools:GetActualShootingDir(player, analog)
	if analog == true or player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
		return Tools:GetShootingJoystick(player)
	else
		return Tools:GetShootingDir(player)
	end
end

function Tools:GetCachedShootingDir(player)
	local data = Tools:GetPlayerData(player)
	return data.CachedShootingDir or Vector(0, 1)
end

function Tools:UpdateCachedShootingDir(player)
	local data = Tools:GetPlayerData(player)
	data.CachedShootingDir = data.CachedShootingDir or Vector(0, 1)
	local dir = Tools:GetShootingJoystick(player)
	if dir:Length() > 0 then
		data.CachedShootingDir = dir
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Tools.UpdateCachedShootingDir)

function Tools:GetMovingDir(player)
	local idx = player.ControllerIndex
	local dir_X = Input.GetActionValue(ButtonAction.ACTION_RIGHT, idx) - Input.GetActionValue(ButtonAction.ACTION_LEFT, idx)
	local dir_Y = Input.GetActionValue(ButtonAction.ACTION_DOWN, idx) - Input.GetActionValue(ButtonAction.ACTION_UP, idx)
	return Vector(dir_X, dir_Y)
end

do
	--��˫��+��ס��ʽ�������˼·�����ʱ���߼���·��Mealy�ͣ���ÿ������֡Ϊһ��ʱ������
	local States = {
		INIT = 0,	--�����룺״̬���䣻�����룺��¼����ת��TAP
		TAP = 1,	--�����룺����ʱ�ޡ�ת��WAIT�������룺״̬����
		WAIT = 2,	--ʱ��δ���㣺��������ۼ�ʱ�ޡ�״̬���䣬�������ҷ��򲻱��򴥷�����ס���¼���ת��HOLD�������뵫����ı����¼����ת��TAP��ʱ���ѹ��㣺ת��INIT
		HOLD = 3,	--�����룺����ʱ�ޡ��������ͷš��¼���ת��WAIT�������룺��������ס���¼�����¼����״̬����
	}

	local CallbackParams = {
		STANDBY = 0,
		HOLD = 1,
		RELEASE = 2,
	}

	function Tools:TapAndHold_PlayerDataInit(player)
		local data = Tools:GetPlayerData(player)
		if data.MovingData == nil then
			data.MovingData = {
				State = States.INIT,
				PrevDir = Vector(0, 0),
				Timeout = 0,
			}
		end
		if data.ShootingData == nil then
			data.ShootingData = {
				State = States.INIT,
				PrevDir = Vector(0, 0),
				Timeout = 0,
			}
		end
	end
	ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Tools.TapAndHold_PlayerDataInit)

	function Tools:TapAndHold_SetInitStateForcibly_Moving(player, trigger_release)
		if trigger_release == nil then
			trigger_release = false
		end
		local data = Tools:GetPlayerData(player)
		if data.MovingData then
			data.MovingData.State = States.INIT
			if trigger_release then
				Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_TAP_AND_HOLD_MOVING, CallbackParams.RELEASE, data.MovingData.PrevDir, player)
			end
		end
	end

	function Tools:TapAndHold_SetInitStateForcibly_Shooting(player, trigger_release)
		if trigger_release == nil then
			trigger_release = false
		end
		local data = Tools:GetPlayerData(player)
		if data.ShootingData then
			data.ShootingData.State = States.INIT
			if trigger_release then
				Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_TAP_AND_HOLD_SHOOTING, CallbackParams.RELEASE, data.ShootingData.PrevDir, player)
			end
		end
	end

	function Tools:TapAndHold_TriggerReleaseForcibly_Moving(player)
		local data = Tools:GetPlayerData(player)
		if data.MovingData then
			Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_TAP_AND_HOLD_MOVING, CallbackParams.RELEASE, data.MovingData.PrevDir, player)
		end
	end

	function Tools:TapAndHold_TriggerReleaseForcibly_Shooting(player)
		local data = Tools:GetPlayerData(player)
		if data.ShootingData then
			Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_TAP_AND_HOLD_SHOOTING, CallbackParams.RELEASE, data.ShootingData.PrevDir, player)
		end
	end

	function Tools:TapAndHold_OnUpdate(player)
		local data = Tools:GetPlayerData(player)
		local idx = player.ControllerIndex
		local MaxTimeout = 6
		if data.MovingData then
			local is_standby = true
			local dir = Tools:GetMovingDir(player)
			local min_value = 0.5
			--local has_input = math.abs(dir.X) >= min_value or math.abs(dir.Y) >= min_value
			local has_input = math.abs(Input.GetActionValue(ButtonAction.ACTION_RIGHT, idx)) >= min_value 
							or math.abs(Input.GetActionValue(ButtonAction.ACTION_LEFT, idx)) >= min_value 
							or math.abs(Input.GetActionValue(ButtonAction.ACTION_DOWN, idx)) >= min_value 
							or math.abs(Input.GetActionValue(ButtonAction.ACTION_UP, idx)) >= min_value
			--print(data.MovingData.State)
			if data.MovingData.State == States.INIT then
				if has_input then
					data.MovingData.PrevDir = dir
					data.MovingData.State = States.TAP
				end
			elseif data.MovingData.State == States.TAP then
				if not has_input then
					data.MovingData.Timeout = MaxTimeout
					data.MovingData.State = States.WAIT
				end
			elseif data.MovingData.State == States.WAIT then
				local accuracy = 10
				local angle = math.deg(math.acos((data.MovingData.PrevDir):Dot(dir)))
				--print("prev_X: " .. data.MovingData.PrevDir.X .. " " .. "prev_Y: " .. data.MovingData.PrevDir.Y)
				--print("X: " .. dir.X .. " " .. "Y: " .. dir.Y)
				--print(angle)
				if data.MovingData.Timeout > 0 then
					if has_input then
						if math.abs(angle) <= accuracy then	--���ڶ������뷽���Ƿ����һ����ͬ�����
							Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_TAP_AND_HOLD_MOVING, CallbackParams.HOLD, dir, player)
							is_standby = false
							data.MovingData.State = States.HOLD
						else
							data.MovingData.PrevDir = dir
							data.MovingData.State = States.TAP
						end
					else
						data.MovingData.Timeout = data.MovingData.Timeout - 1
					end
				else
					data.MovingData.State = States.INIT
				end
			else
				if has_input then
					data.MovingData.PrevDir = dir
					Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_TAP_AND_HOLD_MOVING, CallbackParams.HOLD, dir, player)
					is_standby = false
				else
					data.MovingData.Timeout = MaxTimeout
					Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_TAP_AND_HOLD_MOVING, CallbackParams.RELEASE, data.MovingData.PrevDir, player)
					is_standby = false
					data.MovingData.State = States.WAIT
				end
			end
			if is_standby == true then
				Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_TAP_AND_HOLD_MOVING, CallbackParams.STANDBY, data.MovingData.PrevDir, player)
			end
		end

		if data.ShootingData then
			local is_standby = true
			local dir = Tools:GetShootingJoystick(player)
			local has_input = dir:Length() > 0 
							or (math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT, idx)) > 0 
								and math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT, idx)) > 0) 
							or (math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, idx)) > 0 
								and math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, idx)) > 0)
			--local has_input = math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT, idx)) > 0 
			--				or math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT, idx)) > 0 
			--				or math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, idx)) > 0 
			--				or math.abs(Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, idx)) > 0

			--print("state: " .. data.ShootingData.State)
			--print("prev_X: " .. data.ShootingData.PrevDir.X .. " " .. "prev_Y: " .. data.ShootingData.PrevDir.Y)
			--print("X: " .. dir.X .. " " .. "Y: " .. dir.Y)

			if data.ShootingData.State == States.INIT then
				if has_input then
					data.ShootingData.PrevDir = dir
					data.ShootingData.State = States.TAP
				end
			elseif data.ShootingData.State == States.TAP then
				if not has_input then
					data.ShootingData.Timeout = MaxTimeout
					data.ShootingData.State = States.WAIT
				end
			elseif data.ShootingData.State == States.WAIT then
				local accuracy = 10
				local angle = math.deg(math.acos((data.ShootingData.PrevDir):Dot(dir)))
				if data.ShootingData.Timeout > 0 then
					if has_input then
						if math.abs(angle) <= accuracy then		--���ڶ������뷽���Ƿ����һ����ͬ�����
							Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_TAP_AND_HOLD_SHOOTING, CallbackParams.HOLD, dir, player)
							is_standby = false
							data.ShootingData.State = States.HOLD
						else
							data.ShootingData.PrevDir = dir
							data.ShootingData.State = States.TAP
						end
					else
						data.ShootingData.Timeout = data.ShootingData.Timeout - 1
					end
				else
					data.ShootingData.State = States.INIT
				end
			else
				if has_input then
					data.ShootingData.PrevDir = dir
					Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_TAP_AND_HOLD_SHOOTING, CallbackParams.HOLD, dir, player)
					is_standby = false
				else
					data.ShootingData.Timeout = MaxTimeout
					Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_TAP_AND_HOLD_SHOOTING, CallbackParams.RELEASE, data.ShootingData.PrevDir, player)
					is_standby = false
					data.ShootingData.State = States.WAIT
				end
			end
			if is_standby == true then
				Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_TAP_AND_HOLD_SHOOTING, CallbackParams.STANDBY, data.ShootingData.PrevDir, player)
			end
		end
	end
	ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Tools.TapAndHold_OnUpdate)
end

--��ɫ������أ���ʼ������
function Tools:AddCollectible_PlayerDataInit(player)
	local data = Tools:GetPlayerData(player)
	if data.CollectibleNumTable == nil then
		data.CollectibleNumTable = {}
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Tools.AddCollectible_PlayerDataInit)

--��ɫ������أ����лص�����
function Tools:AddCollectible_RunCallback(player)
	local data = Tools:GetPlayerData(player)
	if data.CollectibleNumTable then
		local item_list = Tools:GetAllSlotItem()
		for _, collectible_type in pairs(item_list) do
			if player:HasCollectible(collectible_type, true) then
				local num = player:GetCollectibleNum(collectible_type, true)
				local rng = player:GetCollectibleRNG(collectible_type)
				local is_newly_added = true
				local key = tostring(collectible_type)
				if data.CollectibleNumTable[key] == nil then
					data.CollectibleNumTable[key] = {
						CurrentNum = num,
						CachedMaxNum = num,
					}
					for i = 1, num do
						Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_POST_ADD_COLLECTIBLE, collectible_type, collectible_type, rng, player, is_newly_added)
					end
				else
					if data.CollectibleNumTable[key].CurrentNum > num then
						data.CollectibleNumTable[key].CurrentNum = num
					else
						while data.CollectibleNumTable[key].CurrentNum < num do
							if data.CollectibleNumTable[key].CurrentNum <= data.CollectibleNumTable[key].CachedMaxNum then
								is_newly_added = false
							end
							Isaac.RunCallbackWithParam(SoulCallbacks.SOULC_POST_ADD_COLLECTIBLE, collectible_type, collectible_type, rng, player, is_newly_added)
							data.CollectibleNumTable[key].CurrentNum = data.CollectibleNumTable[key].CurrentNum + 1
						end
						if data.CollectibleNumTable[key].CachedMaxNum < num then
							data.CollectibleNumTable[key].CachedMaxNum = num
						end
					end
				end
			end
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Tools.AddCollectible_RunCallback)

--̰��ģʽ��أ���ʼ������
function Tools:Greed_GameDataInit()
	if Soul.TempData.GameData["GreedModeWaveCount"] == nil then
		Soul.TempData.GameData["GreedModeWaveCount"] = 0
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, Tools.Greed_GameDataInit)

--̰��ģʽ��أ����лص�����
function Tools:Greed_RunCallback()
    if (Game():IsGreedMode()) then
		local level = Game():GetLevel()
		local current_wave = level.GreedModeWave
		local GreedModeWaveCount = (Soul.TempData.GameData["GreedModeWaveCount"] or 0)
		if current_wave > GreedModeWaveCount then
			Isaac.RunCallback(SoulCallbacks.SOULC_POST_NEW_GREED_MODE_WAVE, current_wave)
			Soul.TempData.GameData["GreedModeWaveCount"] = current_wave
		end
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, Tools.Greed_RunCallback)

--ȫ�����
function Tools:Global_GameDataInit()
	if Soul.TempData.GameData["MomKilled"] == nil then
		Soul.TempData.GameData["MomKilled"] = false
	end
	if Soul.TempData.GameData["MomsHeartKilled"] == nil then
		Soul.TempData.GameData["MomsHeartKilled"] = false
	end
end
ModRef:AddCallback(ModCallbacks.MC_POST_UPDATE, Tools.Global_GameDataInit)

function Tools:MomKilled()
	return Soul.TempData.GameData["MomKilled"] == true
end

function Tools:SetMomKilled(value)
	Soul.TempData.GameData["MomKilled"] = value
end

function Tools:MomsHeartKilled()
	return Soul.TempData.GameData["MomsHeartKilled"] == true
end

function Tools:SetMomsHeartKilled(value)
	Soul.TempData.GameData["MomsHeartKilled"] = value
end

function Tools:GameData_AddAttribute(key, starting_value)
	if Soul.TempData.GameData[key] == nil then
		Soul.TempData.GameData[key] = starting_value
	end
end

function Tools:GameData_GetAttribute(key)
	return Soul.TempData.GameData[key]
end

function Tools:GameData_SetAttribute(key, value)
	Soul.TempData.GameData[key] = value
end

function Tools:GameData_ModifyAttribute(key, amount, is_unsigned)
	if is_unsigned == nil then
		is_unsigned = true
	end
	if type(Soul.TempData.GameData[key]) == "number" and type(amount) == "number" then
		if is_unsigned then
			Soul.TempData.GameData[key] = math.max(0, Soul.TempData.GameData[key] + amount)
		else
			Soul.TempData.GameData[key] = Soul.TempData.GameData[key] + amount
		end
	end
end

function Tools:GameData_ClearAttribute(key)
	Soul.TempData.GameData[key] = nil
end

return Tools