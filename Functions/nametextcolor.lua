local ADDON_NAME, NAMESPACE = ...
local ThreatPlates = NAMESPACE.ThreatPlates

---------------------------------------------------------------------------------------------------
-- Imported functions and constants
---------------------------------------------------------------------------------------------------
local UnitIsConnected = UnitIsConnected
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local IsFriend = IsFriend
local IsGuildmate = IsGuildmate

local TidyPlatesThreat = TidyPlatesThreat
local SetStyle = TidyPlatesThreat.SetStyle
local GetUniqueNameplateSetting = ThreatPlates.GetUniqueNameplateSetting
local GetColorByHealthDeficit = ThreatPlates.GetColorByHealthDeficit

local reference = {
	FRIENDLY = { NPC = "FriendlyNPC", PLAYER = "FriendlyPlayer", },
	HOSTILE = {	NPC = "HostileNPC", PLAYER = "HostilePlayer", },
	NEUTRAL = { NPC = "NeutralUnit", PLAYER = "NeutralUnit",	},
}

local function SetNameColor(unit)
  local style = unit.TP_Style or SetStyle(unit)

  local db = TidyPlatesThreat.db.profile
  local db_mode = db.settings.name
  if style == "NameOnly" or style == "NameOnly-Unique" then
    db_mode = db.HeadlineView
  end

  local color
  local unique_setting = GetUniqueNameplateSetting(unit)
  if unit.isMarked then
    if style == "NameOnly-Unique" and unique_setting.useColor then
      if unique_setting.allowMarked then
        color = db.settings.raidicon.hpMarked[unit.raidIcon]
        return color.r, color.g, color.b
      end
    elseif db_mode.UseRaidMarkColoring then
      color =  db.settings.raidicon.hpMarked[unit.raidIcon]
      return color.r, color.g, color.b
    end
  end

  local unit_reaction = unit.reaction
  local mode = (unit_reaction == "FRIENDLY" and db_mode.FriendlyTextColorMode) or db_mode.EnemyTextColorMode

  if style == "NameOnly-Unique" and unique_setting.useColor then
    color = unique_setting.color
    return color.r, color.g, color.b
  elseif mode == "CUSTOM" then
    if unit_reaction == "FRIENDLY" then
      color = db_mode.FriendlyTextColor
      return color.r, color.g, color.b
    else
      color = db_mode.EnemyTextColor
      return color.r, color.g, color.b
    end
  elseif mode == "HEALTH" then
    local color =  GetColorByHealthDeficit(unit)
    return color.r, color.g, color.b
  elseif mode == "CLASS" then
    if unit.unitid and not UnitIsConnected(unit.unitid) then
      color =  db.DisconnectedUnit
      return color.r, color.g, color.b
    elseif unit.isTapped then
      color =  db.TappedUnit
      return color.r, color.g, color.b
    elseif unit.type == "PLAYER" then
      if unit_reaction == "FRIENDLY" then
        local db_social = db.socialWidget
        if db_social.ShowFriendColor and IsFriend(unit) then
          color =  db_social.FriendColor
          return color.r, color.g, color.b
        elseif db_social.ShowGuildmateColor and IsGuildmate(unit) then
          color =  db_social.GuildmateColor
          return color.r, color.g, color.b
        end
      end

      color =  RAID_CLASS_COLORS[unit.class]
      return color.r, color.g, color.b
    end

    color =  db.ColorByReaction[reference[unit_reaction][unit.type]]
    return color.r, color.g, color.b
  end

  -- Default: By Reaction
  if unit.unitid and not UnitIsConnected(unit.unitid) then
    color =  db.DisconnectedUnit
    return color.r, color.g, color.b
  elseif unit.isTapped then
    color =  db.TappedUnit
    return color.r, color.g, color.b
  elseif unit_reaction == "FRIENDLY" and unit.type == "PLAYER" then
    local db_social = db.socialWidget
    if db_social.ShowFriendColor and IsFriend(unit) then
      color =  db_social.FriendColor
      return color.r, color.g, color.b
    elseif db_social.ShowGuildmateColor and IsGuildmate(unit) then
      color =  db_social.GuildmateColor
      return color.r, color.g, color.b
    end
  end

  color =  db.ColorByReaction[reference[unit_reaction][unit.type]]
  return color.r, color.g, color.b
end

TidyPlatesThreat.SetNameColor = SetNameColor