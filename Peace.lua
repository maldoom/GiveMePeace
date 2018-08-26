﻿
--[[

	$project:	Give Me Peace
	$copyright:	© Copyright Michael Boyle.
			All Rights Reserved.
	$email:		michael.boyle@softrix.co.uk
	$website:	www.softrix.co.uk
														
]]--

PEACE_VERSION = "r09129";	-- 30300 Version.

PEACE_SUMMARY = "Give Me Peace has been protecting you since %s and has blocked a total of %s unauthorised whispers across all characters.";PEACE_ADVERT = "I'm protected by the 'Give Me Peace' addon which blocks and hides incoming whispers from unauthorised players. Get your copy from either wowinterface.com or curse.com.";Peace_Options = { true, true, true, false, false, true, 0, 0, 0, true, true, nil, true, true, true };Peace_CustomMsg = { "Auto Reply: I'm currently busy in %s, please try again later or send me an in-game mail.", "Auto Reply: I'm currently busy, please try again later or send me an in-game mail.", false }; Peace_BlockedSND = "Interface\\Addons\\Peace\\blocked.mp3";Peace_FriendList = {};Peace_ManualList = {};Peace_IgnoreList = {};Peace_Temporary = {};Peace_BlockedMsg = {};function Peace_OnLoad() this:RegisterEvent("ADDON_LOADED");this:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");this:RegisterEvent("PLAYER_LOGIN");this:RegisterEvent("FRIENDLIST_UPDATE");this:RegisterEvent("GUILD_ROSTER_UPDATE");this:RegisterEvent("CHAT_MSG_WHISPER");this:RegisterEvent("CHAT_MSG_WHISPER_INFORM");SlashCmdList["PEACE"] = Peace_Commandline;SLASH_PEACE1="/peace"; end;function Peace_Commandline(args) local lowerargs = strlower(args);if(lowerargs == "blocked") then Peace_ListWhispers();elseif(lowerargs == "advert") then if(Peace_Options[14]) then Peace_Options[14] = false;DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE : |cffffffff Advert [OFF].");else Peace_Options[14] = true;DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE : |cffffffff Advert [ON].");end; elseif(lowerargs == "scan") then if(Peace_Options[2]) then Peace_ScanGuild(); end;if(Peace_Options[3]) then Peace_ScanFriends(); end; elseif(lowerargs == "toggle") then if(Peace_Options[1]) then  Peace_Options[1] = false;DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE : |cffffffff Turned [OFF].");else  Peace_Options[1] = true;  DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE : |cffffffff Turned [ON].");end;else DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffOther options available in the 'Give Me Peace' addon are as follows:");DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ff/peace blocked : |cffffffff Shows a list of whispers for the current character and session.");DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ff/peace toggle : |cffffffff Toggle On/Off the blocking of whispers by the addon.");DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ff/peace scan : |cffffffff Manually scan your guild and friends list and authorise them.");DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ff/peace advert : |cffffffff The addon also sends a 'Protected by' message to blocked players, this option turns this feature on/off.");local msgOptions = string.format(PEACE_SUMMARY, Peace_Options[12], Peace_Options[7]);OptionsBlockedSummary:SetText(msgOptions);Peace_CustomMsgEditBox:SetText(Peace_CustomMsg[2]);Peace_ProcessOptions();Peace_OptionsFrame:Show();end;end;function Peace_OnUpdate() end;function Peace_Initialise() Peace_Localisation();if(Peace_Options[10]) then  if(Peace_Options[12]) then DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffGive Me Peace ("..PEACE_VERSION..") loaded! |cffffffffType /peace for options. "..Peace_Options[7].." whispers have been blocked since installing this addon on "..Peace_Options[12]..".");  else DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffGive Me Peace ("..PEACE_VERSION..") loaded! |cffffffffType /peace for options.");  end;end;end;function Peace_EventHandler(event,...) if(event == "ADDON_LOADED") then if(arg1 == "Peace") then Peace_Initialise();end;end; if(event == "PLAYER_LOGIN") then if(IsInGuild()) then GuildRoster();end;ShowFriends();Peace_CleanBlockedHistory();if(not(Peace_Options[12])) then  local hour, minute = GetGameTime();local weekday, month, day, year = CalendarGetDate();Peace_Options[12] = day.."/"..month.."/"..year.." "..hour..":"..minute;  end;end; if(event == "FRIENDLIST_UPDATE") then if(not(loginFriendsLoad)) then loginFriendsLoad = true;if(Peace_Options[3]) then Peace_ScanFriends(); end;end; elseif(event == "GUILD_ROSTER_UPDATE") then if(not(loginGuildList)) then loginGuildList= true;if(IsInGuild()) then Peace_ScanGuild();end;end;end; end;function Peace_ScanGuild() if(IsInGuild() and Peace_Options[2]) then GuildRoster();local numGuild = 0;local numMembers = GetNumGuildMembers(true) for i=1, numMembers do local memberName = strlower(GetGuildRosterInfo(i));if(memberName and not(Peace_IsAuthorised(memberName))) then  numGuild = numGuild + 1;tinsert(Peace_FriendList, memberName);end;end;if(Peace_Options[11] and numGuild > 0) then DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE|cffffffff : Added "..numGuild.." guild members to the safe list."); end;end;end;function Peace_ScanFriends() ShowFriends();local numPeeps = 0;local numFriends = GetNumFriends();for i = 1, numFriends do local friendName = GetFriendInfo(i);if(not(friendName)) then ShowFriends();return;end;friendName = strlower(friendName);if(friendName and not(Peace_IsAuthorised(friendName))) then numPeeps = numPeeps + 1;tinsert(Peace_FriendList, friendName);end;end;for count,value in ipairs(Peace_ManualList) do  if(not(Peace_IsAuthorised(value))) then  tinsert(Peace_FriendList, value);numPeeps = numPeeps + 1;end;  end; if(Peace_Options[11] and numPeeps > 0) then DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE|cffffffff : Added "..numPeeps.." friends to the safe list."); end;end;function Peace_IsAuthorised(name) for count,value in ipairs(Peace_FriendList) do  if(value == name) then  return(true);end;  end;for count,value in ipairs(Peace_Temporary) do  if(value == name) then  return(true);end;  end;return(false);end;function Peace_IsIgnored(name) for count,value in ipairs(Peace_IgnoreList) do  if(value == name) then  return(true);end;  end;return(false);end;function Peace_CheckInGroup(name) if(UnitPlayerOrPetInRaid(name) or UnitInParty("name")) then return(true); end;return(false); end;ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(...) if(not(Peace_Options[1])) then return; end;local hour, minute = GetGameTime();local weekday, month, day, year = CalendarGetDate();local msgTime = hour..":"..minute;local msgDate = day.."/"..month.."/"..year;local incomingPlayer = strlower(select(4, ...));local whisperFlag = select(8, ...);if(whisperFlag == "GM") then return; end;if(Peace_CheckInGroup(incomingPlayer) and not(Peace_IsIgnored(incomingPlayer))) then return; end;if(Peace_IsAuthorised(incomingPlayer) and not(Peace_IsIgnored(incomingPlayer))) then return; end; local msgBlocked = string.format(MSG_BLOCKED1, UnitName("player"), UnitName("player"), UnitName("player"));if(Peace_Options[6]) then  if(Peace_CustomMsg[3]) then  SendChatMessage(Peace_CustomMsg[2], "WHISPER", nil, incomingPlayer);else SendChatMessage(msgBlocked, "WHISPER", nil, incomingPlayer); end;if(Peace_Options[14]) then SendChatMessage(PEACE_ADVERT, "WHISPER", nil, incomingPlayer);end;end;if(Peace_Options[4]) then DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE : |cffffffff"..incomingPlayer.." sent a whisper which was blocked. Type /peace blocked to view any blocked whispers."); end;tinsert(Peace_BlockedMsg, {incomingPlayer, arg1, msgDate, msgTime, UnitName("player")});if(not(lastPlayerMsg == arg1)) then lastPlayerMsg = arg1;Peace_Options[7] = tonumber(Peace_Options[7]) + 1 if(Peace_Options[5]) then PlaySoundFile(Peace_BlockedSND); end;end;return(true);end);ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(_,_,msg,player) if(not(Peace_Options[1])) then return; end;local lowerPlayer = strlower(player);local msgBlocked = string.format(MSG_BLOCKED1, UnitName("player"), UnitName("player"),UnitName("player"));if(msg == msgBlocked or msg == Peace_CustomMsg[2] or msg == PEACE_ADVERT) then return(true); end;if(Peace_Options[13]) then if(not(Peace_IsAuthorised(lowerPlayer)) and not(Peace_CheckInGroup(lowerPlayer))) then tinsert(Peace_Temporary, lowerPlayer);DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE|cffffffff : Initiated first whisper to "..player..", adding to your temporary authorised list for any replies.");end;end;return;end);function Peace_ListWhispers() for count,value in ipairs(Peace_BlockedMsg) do  if(value[1] and value[2]) then  if(value[5]) then DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ff["..value[3].." "..value[4].." -> "..value[5].."] "..value[1].." said|cffffffff : "..value[2]);else DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ff["..value[3].." "..value[4].."] "..value[1].." said|cffffffff : "..value[2]); end;end;  end;end;function Peace_CleanBlockedHistory() if(Peace_Options[15]) then for i in pairs(Peace_BlockedMsg) do  Peace_BlockedMsg[i] = nil;end;end;end;function PeaceCloseCreditsFrame_OnClick() Peace_ShowCreditsFrame:Hide();Peace_OptionsFrame:Show();end;function Peace_CloseOptionsFrame_OnClick() local customText = Peace_CustomMsgEditBox:GetText();Peace_CustomMsg[2] = customText;Peace_OptionsFrame:Hide();end;function Peace_CreditsButton_OnClick() Peace_OptionsFrame:Hide(); Peace_ShowCreditsFrame:Show();end;function Peace_ScanGuildFriendsButton_OnClick() if(Peace_Options[2]) then Peace_ScanGuild(); end;if(Peace_Options[3]) then Peace_ScanFriends(); end; end;function Peace_ManualClearHistoryButton_OnClick() for i in pairs(Peace_BlockedMsg) do  Peace_BlockedMsg[i] = nil;end;DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE|cffffffff : Deleted any saved blocked whispers. ");end;function Peace_ProcessOptions() if(Peace_Options[1]) then Peace_EnableAddonCheck:SetChecked(true); end;if(Peace_Options[2]) then Peace_AutoAddGuildCheck:SetChecked(true); end;if(Peace_Options[3]) then Peace_AutoAddFriendsCheck:SetChecked(true); end;if(Peace_Options[6]) then Peace_NotifyBlockedPlayersCheck:SetChecked(true); end;if(Peace_Options[4]) then Peace_InformWhenPlayerBlockedCheck:SetChecked(true); end;if(Peace_Options[5]) then Peace_DoSoundOnBlockCheck:SetChecked(true); end;if(Peace_Options[13]) then Peace_AutoAddWhisperedPlayersCheck:SetChecked(true); end;if(Peace_Options[15]) then Peace_ResetBlockedWhisperHistoryCheck:SetChecked(true); end;if(Peace_CustomMsg[3]) then Peace_UseCustomMessageTextCheck:SetChecked(true); end;end;function Peace_EnableAddonCheck_OnClick() local CheckboxEnabled = Peace_EnableAddonCheck:GetChecked();if(CheckboxEnabled == 1) then Peace_Options[1] = true;  else Peace_Options[1] = false; end; end;function Peace_AutoAddGuildCheck_OnClick() local CheckboxEnabled = Peace_AutoAddGuildCheck:GetChecked();if(CheckboxEnabled == 1) then  Peace_Options[2] = true;  Peace_ScanGuild();else Peace_Options[2] = false; end; end;function Peace_AutoAddFriendsCheck_OnClick() local CheckboxEnabled = Peace_AutoAddFriendsCheck:GetChecked();if(CheckboxEnabled == 1) then  Peace_Options[3] = true;  Peace_ScanFriends();else Peace_Options[3] = false; end; end;function Peace_AutoAddWhisperedPlayersCheck_OnClick() local CheckboxEnabled = Peace_AutoAddWhisperedPlayersCheck:GetChecked();if(CheckboxEnabled == 1) then Peace_Options[13] = true;  else Peace_Options[13] = false; end; end;function Peace_NotifyBlockedPlayersCheck_OnClick() local CheckboxEnabled = Peace_NotifyBlockedPlayersCheck:GetChecked();if(CheckboxEnabled == 1) then Peace_Options[6] = true;  else Peace_Options[6] = false; end; end;function Peace_InformWhenPlayerBlockedCheck_OnClick() local CheckboxEnabled = Peace_InformWhenPlayerBlockedCheck:GetChecked();if(CheckboxEnabled == 1) then Peace_Options[4] = true;  else Peace_Options[4] = false; end; end;function Peace_UseCustomMessageTextCheck_OnClick() local CheckboxEnabled = Peace_UseCustomMessageTextCheck:GetChecked();if(CheckboxEnabled == 1) then Peace_CustomMsg[3] = true;  else Peace_CustomMsg[3] = false; end; end;function Peace_ResetBlockedWhisperHistoryCheck_OnClick() local CheckboxEnabled = Peace_ResetBlockedWhisperHistoryCheck:GetChecked();if(CheckboxEnabled == 1) then Peace_Options[15] = true;  else Peace_Options[15] = false; end; end;function Peace_DoSoundOnBlockCheck_OnClick() local CheckboxEnabled = Peace_DoSoundOnBlockCheck:GetChecked();if(CheckboxEnabled == 1) then Peace_Options[5] = true;  else Peace_Options[5] = false; end; end;function AddNewAuthorisedButton_OnClick() local playerName = strlower(EnteredPlayerNameBox:GetText());if(playerName and not(Peace_IsAuthorised(playerName))) then tinsert(Peace_ManualList, playerName);for count,value in ipairs(Peace_ManualList) do  if(not(Peace_IsAuthorised(value))) then  tinsert(Peace_FriendList, value);end;  end;DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE|cffffffff : Added "..playerName.." to the authorised list.");else DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE|cffffffff : "..playerName.." already exists in your authorised list.");end;end;function DoesPlayerExistManual(player) if(player) then for count,value in ipairs(Peace_ManualList) do  if(value == player) then return(true); end;  end; end;end;function DeleteAuthoriseButton_OnClick() local playerName = strlower(EnteredPlayerNameBox:GetText());if(playerName and Peace_IsAuthorised(playerName)) then for count,value in ipairs(Peace_FriendList) do  if(value == playerName) then  tremove(Peace_FriendList, count);DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE|cffffffff : Removed "..playerName.." from the authorised list.");end;  end; else DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE|cffffffff : "..playerName.." doesnt exist in the automatic authorised list.");end;if(playerName and DoesPlayerExistManual(playerName)) then for count,value in ipairs(Peace_ManualList) do  if(value == playerName) then  tremove(Peace_ManualList, count);end;  end; end;if(playerName and Peace_IsIgnored(playerName)) then for count,value in ipairs(Peace_IgnoreList) do  if(value == playerName) then  tremove(Peace_IgnoreList, count);DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE|cffffffff : Removed "..playerName.." from the ignore list.");end;  end; end;if(Peace_Options[2]) then Peace_ScanGuild(); end;if(Peace_Options[3]) then Peace_ScanFriends(); end; end;function IgnorePlayerWhisperButton_OnClick() local playerName = strlower(EnteredPlayerNameBox:GetText());if(playerName and not(Peace_IsIgnored(playerName))) then tinsert(Peace_IgnoreList, playerName);DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE|cffffffff : Added "..playerName.." to the ignore list.");else DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE|cffffffff : "..playerName.." is already ignored.");end;end;function Peace_CleanWholePlayerList_OnClick() local refreshCount = 0;for i in pairs(Peace_FriendList) do  Peace_FriendList[i] = nil;refreshCount = refreshCount + 1;end;DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffPEACE|cffffffff : Removed "..refreshCount.." players from the authorised list. No ignored entries have been deleted and those will need to be removed manually.");if(Peace_Options[2]) then Peace_ScanGuild(); end;if(Peace_Options[3]) then Peace_ScanFriends();end;end;