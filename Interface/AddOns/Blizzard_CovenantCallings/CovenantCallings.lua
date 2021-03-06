-- NOTE: This is intended to use a calling/bounty created from the client, this just extends that table by adding an API and some cached data.
Enum.CallingStates = {
	QuestOffer = 1,
	QuestActive = 2,
	QuestCompleted = 3,
};

Constants.Callings = {
	MaxCallings = 3, -- TODO: This needs to come from data, but it's completely arbitrary based on the scheduler, need to figure this out
}

CallingMixin = {};

function CallingMixin:Init()
	self.quest = QuestCache:Get(self.questID);
	self.isOnQuest = C_QuestLog.IsOnQuest(self.questID); -- The only reason it's safe to cache this is that when quests are updated, we rebuild everything.
	self.isLockedToday = false;
end

function CallingMixin:InitEmpty()
	self.isLockedToday = true;
end

function CallingMixin:SetIndex(index)
	self.index = index;
end

function CallingMixin:IsLocked()
	return self.isLockedToday;
end

function CallingMixin:IsActive()
	return self.isOnQuest;
end

function CallingMixin:GetState()
	if self:IsLocked() then
		return Enum.CallingStates.QuestCompleted;
	elseif self:IsActive() then
		return Enum.CallingStates.QuestActive;
	else
		return Enum.CallingStates.QuestOffer;
	end
end

function CallingMixin:GetIcon(covenantData)
	if self:IsLocked() or self.icon == 0 then
		return ("Interface/Pictures/Callings-%s-Head-Disable"):format(covenantData.textureKit);
	end

	return self.icon;
end

function CallingMixin:GetBang()
	local state = self:GetState();
	if state == Enum.CallingStates.QuestActive and self.quest:IsComplete() then
		return "Callings-Turnin";
	elseif state == Enum.CallingStates.QuestOffer then
		return "Callings-Available";
	end

	return nil;
end

function CallingMixin:GetDaysUntilNext()
	if self:IsLocked() and self.index then
		return Constants.Callings.MaxCallings - self.index + 1;
	end

	return 0;
end

function CallingMixin:GetDaysUntilNextString()
	return _G["BOUNTY_BOARD_NO_CALLINGS_DAYS_" .. self:GetDaysUntilNext()] or BOUNTY_BOARD_NO_CALLINGS_DAYS_1;
end

CovenantCallingQuestMixin = {};

function CovenantCallingQuestMixin:Set(calling, covenantData)
	self.calling = calling;
	self.covenantData = covenantData;
	self:Update();
	self:Show();
end

function CovenantCallingQuestMixin:Update()
	self:UpdateIcon();
	self:UpdateBang();
end

function CovenantCallingQuestMixin:UpdateIcon()
	local icon = self.calling:GetIcon(self.covenantData);
	self.Icon:SetTexture(icon);
	self.Highlight:SetTexture(icon);
end

function CovenantCallingQuestMixin:UpdateBang()
	local bang = self.calling:GetBang();
	self.Bang:SetShown(bang ~= nil);
	if bang then
		self.Bang:SetAtlas(bang, true);
	end

	self.Glow:SetShown(self.calling:GetState() == Enum.CallingStates.QuestOffer);
end

function CovenantCallingQuestMixin:UpdateTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local state = self.calling:GetState();
	if state == Enum.CallingStates.QuestOffer then
		self:UpdateTooltipQuestOffer();
	elseif state == Enum.CallingStates.QuestActive then
		self:UpdateTooltipQuestActive();
	elseif state == Enum.CallingStates.QuestCompleted then
		GameTooltip:SetText(self.calling:GetDaysUntilNextString(), HIGHLIGHT_FONT_COLOR:GetRGB());
	end

	GameTooltip:Show();
	GameTooltip.recalculatePadding = true;
end

function CovenantCallingQuestMixin:UpdateTooltipCheckHasQuestData()
	if HaveQuestData(self.calling.questID) then
		return true;
	end

	GameTooltip_AddColoredLine(GameTooltip, RETRIEVING_DATA, RED_FONT_COLOR);
	return false;
end

function CovenantCallingQuestMixin:UpdateTooltipQuestOffer()
	if not self:UpdateTooltipCheckHasQuestData() then
		return;
	end

	GameTooltip_SetTitle(GameTooltip, QuestUtils_GetQuestName(self.calling.questID), nil, false);
	WorldMap_AddQuestTimeToTooltip(self.calling.questID);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, CALLING_QUEST_TOOLTIP_DESCRIPTION, true);
	GameTooltip_AddQuestRewardsToTooltip(GameTooltip, self.calling.questID, TOOLTIP_QUEST_REWARDS_STYLE_CALLING_REWARD);
end

-- NOTE/TODO: Basically lifted from TaskPOI_OnEnter, but there were enough differences that I decided to keep this separate until we get approvals
function CovenantCallingQuestMixin:UpdateTooltipQuestActive()
	if not self:UpdateTooltipCheckHasQuestData() then
		return;
	end

	local questID = self.calling.questID;

	-- Add the quest title
	local title = QuestUtils_GetQuestName(questID);
	GameTooltip_SetTitle(GameTooltip, title);

	-- Add the "faction", really just the covenant name
	-- TODO: Not planning on being able to use the same system that WQs use to put the faction on the quest tooltip, so just grab covenant name for now
	if self.covenantData then
		GameTooltip_AddNormalLine(GameTooltip, self.covenantData.name);
	end

	-- Add the remaining time
	WorldMap_AddQuestTimeToTooltip(questID);

	-- Add the objectives
	local questCompleted = C_QuestLog.IsComplete(questID);
	local shouldShowObjectivesAsStatusBar = false; -- Not sure where to pull this from yet, MapIndicatorQuestDataProviderMixin:AddMapIndicatorQuest is what was setting it before

	if shouldShowObjectivesAsStatusBar then
		if questCompleted then
			GameTooltip_AddColoredLine(GameTooltip, QUEST_DASH .. QUEST_WATCH_QUEST_READY, HIGHLIGHT_FONT_COLOR);
		else
			local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
			if questLogIndex then
				questDescription = select(2, GetQuestLogQuestText(questLogIndex));
				GameTooltip_AddColoredLine(GameTooltip, QUEST_DASH .. questDescription, HIGHLIGHT_FONT_COLOR);
			end
		end
	end

	local isFirstObjectiveFinished;
	for objectiveIndex = 1, self.calling.numObjectives do
		local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(questID, objectiveIndex, false);
		if objectiveIndex == 1 then
			isFirstObjectiveFinished = finished;
		end

		local showObjective = not (finished and self.isThreat);
		if showObjective then
			if self.shouldShowObjectivesAsStatusBar and numRequired > 0 then
				local percent = math.floor((numFulfilled/numRequired) * 100);
				GameTooltip_ShowProgressBar(GameTooltip, 0, numRequired, numFulfilled, PERCENTAGE_STRING:format(percent));
			elseif objectiveText and objectiveText ~= "" then
				local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
				GameTooltip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true);
			end
		end
	end

	local showObjective = not (isFirstObjectiveFinished and self.isThreat);
	if showObjective then
		local percent = C_TaskQuest.GetQuestProgressBarInfo(questID);
		if percent then
			GameTooltip_ShowProgressBar(GameTooltip, 0, 100, percent, PERCENTAGE_STRING:format(percent));
		end
	end

	-- Add the rewards
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, CALLING_QUEST_TOOLTIP_DESCRIPTION, true);
	GameTooltip_AddQuestRewardsToTooltip(GameTooltip, questID, TOOLTIP_QUEST_REWARDS_STYLE_CALLING_REWARD);
end

function CovenantCallingQuestMixin:OnEnter()
	self:UpdateTooltip();
	self.Highlight:Show();
end

function CovenantCallingQuestMixin:OnLeave()
	if self.usedTaskPOI then
		TaskPOI_OnLeave(self);
		self.usedTaskPOI = nil;
	else
		GameTooltip:Hide();
	end

	self.Highlight:Hide();
end

CovenantCallingsMixin = {};

function CovenantCallingsMixin:OnLoad()
	self.pool = CreateFramePool("Frame", self, "CovenantCallingQuestTemplate");
	self.layout = AnchorUtil.CreateGridLayout(nil, Constants.Callings.MaxCallings, 35, 0);
end

local CovenantCallingsEvents = {
	"COVENANT_CALLINGS_UPDATED",
	"QUEST_LOG_UPDATE",
	"QUEST_LOG_CRITERIA_UPDATE",
}

function CovenantCallingsMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CovenantCallingsEvents);
end

function CovenantCallingsMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CovenantCallingsEvents);
end

function CovenantCallingsMixin:OnEvent(event, ...)
	if event == "COVENANT_CALLINGS_UPDATED" then
		self:OnCovenantCallingsUpdated(...);
	else
		self:Update();
	end
end

function CovenantCallingsMixin:Update()
	C_CovenantCallings.RequestCallings();

	self.covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID());
	self:UpdateBackground();
end

function CovenantCallingsMixin:UpdateBackground()
	local decor = ("shadowlands-landingpage-callingsdecor-%s"):format(self.covenantData.textureKit);
	self.Decor:SetAtlas(decor, true);
end

function CovenantCallingsMixin:OnCovenantCallingsUpdated(callings)
	self:ProcessCallings(callings);

	self.pool:ReleaseAll();

	local frames = {};
	for index, calling in ipairs(self.callings) do
		local callingFrame = self.pool:Acquire();
		callingFrame:Set(calling, self.covenantData);
		table.insert(frames, callingFrame);
	end

	AnchorUtil.GridLayout(frames, AnchorUtil.CreateAnchor("LEFT", self.Decor, "LEFT", -30, 0), self.layout);
	self:Layout();
end

-- TODO: Not sure how we want the sort to behave yet...maybe using time remaining similar to emissary quests?
local function CompareCallings(c1, c2)
	if c1:IsLocked() ~= c2:IsLocked() then
		return c2:IsLocked();
	end

	if c2:IsLocked() then
		return true;
	end

	if c1:IsActive() ~= c2:IsActive() then
		return not c1:IsActive();
	end

	return c1.tempTimeRemaining < c2.tempTimeRemaining;
end

function CovenantCallingsMixin:ProcessCallings(callings)
	self.callings = {};
	for index = 1, Constants.Callings.MaxCallings do
		local calling = callings[index];
		if calling then
			calling = Mixin(calling, CallingMixin);
			calling:Init();

			-- Cache the remaining time on the quest to help sort
			calling.tempTimeRemaining = C_TaskQuest.GetQuestTimeLeftSeconds(calling.questID) or 0;
		else
			calling = CreateFromMixins(CallingMixin);
			calling:InitEmpty();
			calling.tempTimeRemaining = 0;
		end

		self.callings[index] = calling;
	end

	table.sort(self.callings, CompareCallings);

	for index, calling in ipairs(self.callings) do
		calling:SetIndex(index);

		-- Then nuke the remaining time after the sort, must be updated anyway.
		calling.tempTimeRemaining = nil;
	end
end

CovenantCallings = {};

function CovenantCallings.Create(parent)
	return CreateFrame("Frame", nil, parent, "CovenantCallingsTemplate");
end