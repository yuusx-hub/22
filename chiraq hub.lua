if not game:IsLoaded() then game.Loaded:Wait() end
setfpscap(9999)
Services = setmetatable({}, {
	__index = function(self, name)
		local success, cache = pcall(function()
			return cloneref(game:GetService(name))
		end)
		if success then
			rawset(self, name, cache)
			return cache
		else
			error("Invalid Service: " .. tostring(name))
		end
	end
})
Players = Services.Players
Workspace = Services.Workspace
UserInputService = Services.UserInputService
ReplicatedStorage = Services.ReplicatedStorage
TweenService = Services.TweenService
ProximityPromptService = Services.ProximityPromptService
RunService = Services.RunService
PathfindingService = Services.PathfindingService
Stats = Services.Stats
Lighting = Services.Lighting
SoundService = Services.SoundService
StarterGui = Services.StarterGui
CoreGui = Services.CoreGui
HttpService = Services.HttpService
player = Players.LocalPlayer or Players.PlayerAdded:Wait()
Camera = Workspace.CurrentCamera
plots = Workspace:WaitForChild("Plots")
Debris = Workspace:WaitForChild("Debris")

local __sb = { cycle = 2.6, minHold = 1.3, freshList = nil, freshAt = 0 }

__sb.randomName = function(len)
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local out = {}
	for i = 1, len do
		local n = math.random(1, #chars)
		out[i] = chars:sub(n, n)
	end
	return table.concat(out)
end

__sb.build = function()
	if __sb.gui and __sb.gui.Parent then return end
	local guiParent = player:WaitForChild("PlayerGui")
	__sb.gui = Instance.new("ScreenGui")
	__sb.gui.Name = __sb.randomName(math.random(12, 18))
	__sb.gui.ResetOnSpawn = false
	__sb.gui.IgnoreGuiInset = true
	__sb.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	__sb.gui.Parent = guiParent

	__sb.frame = Instance.new("Frame", __sb.gui)
	__sb.frame.AnchorPoint = Vector2.new(0.5, 1)
	__sb.frame.Position = UDim2.new(0.5, 0, 1, -100)
	__sb.frame.Size = UDim2.fromOffset(360, 60)
	__sb.frame.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
	__sb.frame.BackgroundTransparency = 0.18
	__sb.frame.BorderSizePixel = 0
	__sb.frame.Active = true
	__sb.frame.Draggable = true
	Instance.new("UICorner", __sb.frame).CornerRadius = UDim.new(0, 16)

	local grad = Instance.new("UIGradient", __sb.frame)
	grad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(55, 60, 85)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 22, 32)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(12, 14, 22)),
	}
	grad.Rotation = 90

	local edge = Instance.new("UIStroke", __sb.frame)
	edge.Color = Color3.fromRGB(255, 255, 255)
	edge.Transparency = 0.78
	edge.Thickness = 1.2

	local glow = Instance.new("UIStroke", __sb.frame)
	glow.Color = Color3.fromRGB(255, 90, 105)
	glow.Transparency = 0.55
	glow.Thickness = 1.6
	task.spawn(function()
		while __sb.frame.Parent do
			TweenService:Create(glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Transparency = 0.85}):Play()
			task.wait(1.2)
			TweenService:Create(glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Transparency = 0.4}):Play()
			task.wait(1.2)
		end
	end)

	__sb.label = Instance.new("TextLabel", __sb.frame)
	__sb.label.BackgroundTransparency = 1
	__sb.label.Position = UDim2.new(0, 16, 0, 8)
	__sb.label.Size = UDim2.new(1, -32, 0, 16)
	__sb.label.Text = "Chiraq Hub  -  Stealing"
	__sb.label.Font = Enum.Font.GothamBlack
	__sb.label.TextSize = 14
	__sb.label.TextColor3 = Color3.fromRGB(255, 235, 240)
	__sb.label.TextXAlignment = Enum.TextXAlignment.Left
	__sb.label.TextStrokeColor3 = Color3.fromRGB(200, 30, 50)
	__sb.label.TextStrokeTransparency = 0.7

	local dot = Instance.new("Frame", __sb.frame)
	dot.Position = UDim2.new(1, -22, 0, 14)
	dot.Size = UDim2.fromOffset(8, 8)
	dot.BackgroundColor3 = Color3.fromRGB(255, 90, 100)
	dot.BorderSizePixel = 0
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	task.spawn(function()
		while dot.Parent do
			TweenService:Create(dot, TweenInfo.new(0.7), {BackgroundColor3 = Color3.fromRGB(255, 180, 190)}):Play()
			task.wait(0.7)
			TweenService:Create(dot, TweenInfo.new(0.7), {BackgroundColor3 = Color3.fromRGB(255, 90, 100)}):Play()
			task.wait(0.7)
		end
	end)

	local track = Instance.new("Frame", __sb.frame)
	track.AnchorPoint = Vector2.new(0.5, 1)
	track.Position = UDim2.new(0.5, 0, 1, -10)
	track.Size = UDim2.new(1, -32, 0, 12)
	track.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
	track.BackgroundTransparency = 0.1
	track.BorderSizePixel = 0
	track.ClipsDescendants = true
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local trackStroke = Instance.new("UIStroke", track)
	trackStroke.Color = Color3.fromRGB(255, 255, 255)
	trackStroke.Transparency = 0.82
	trackStroke.Thickness = 1

	local minRatio = math.clamp((__sb.minHold or 1.3) / (__sb.cycle or 2.6), 0, 1)

	local zoneRed = Instance.new("Frame", track)
	zoneRed.Size = UDim2.new(minRatio, 0, 1, 0)
	zoneRed.BackgroundColor3 = Color3.fromRGB(220, 55, 75)
	zoneRed.BorderSizePixel = 0
	local zr = Instance.new("UIGradient", zoneRed)
	zr.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 75, 95)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 35, 55)),
	}
	zr.Rotation = 90

	local zoneGreen = Instance.new("Frame", track)
	zoneGreen.Position = UDim2.new(minRatio, 0, 0, 0)
	zoneGreen.Size = UDim2.new(1 - minRatio, 0, 1, 0)
	zoneGreen.BackgroundColor3 = Color3.fromRGB(80, 220, 130)
	zoneGreen.BorderSizePixel = 0
	local zg = Instance.new("UIGradient", zoneGreen)
	zg.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 235, 150)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 180, 110)),
	}
	zg.Rotation = 90

	local divider = Instance.new("Frame", track)
	divider.AnchorPoint = Vector2.new(0.5, 0.5)
	divider.Position = UDim2.new(minRatio, 0, 0.5, 0)
	divider.Size = UDim2.new(0, 2, 1, 4)
	divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider.BackgroundTransparency = 0.3
	divider.BorderSizePixel = 0
	divider.ZIndex = 2

	__sb.stick = Instance.new("Frame", track)
	__sb.stick.AnchorPoint = Vector2.new(0.5, 0.5)
	__sb.stick.Position = UDim2.new(0, 0, 0.5, 0)
	__sb.stick.Size = UDim2.new(0, 4, 1, 6)
	__sb.stick.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	__sb.stick.BorderSizePixel = 0
	Instance.new("UICorner", __sb.stick).CornerRadius = UDim.new(0, 2)
	local ss = Instance.new("UIStroke", __sb.stick)
	ss.Color = Color3.fromRGB(0, 0, 0)
	ss.Transparency = 0.5
	ss.Thickness = 1

	local stickGlow = Instance.new("Frame", __sb.stick)
	stickGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	stickGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
	stickGlow.Size = UDim2.new(0, 16, 0, 22)
	stickGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	stickGlow.BackgroundTransparency = 0.7
	stickGlow.BorderSizePixel = 0
	stickGlow.ZIndex = -1
	Instance.new("UICorner", stickGlow).CornerRadius = UDim.new(1, 0)
end

__sb.setProgress = function(p)
	if not __sb.stick then return end
	p = math.clamp(p or 0, 0, 1)
	__sb.stick.Position = UDim2.new(p, 0, 0.5, 0)
end

__sb.freshList_get = function()
	local now = tick()
	if __sb.freshList and (now - __sb.freshAt) < 0.1 then
		return __sb.freshList
	end
	local ok, list = pcall(scanAllPlots)
	if ok and list then
		__sb.freshList = list
		__sb.freshAt = now
	end
	return __sb.freshList or {}
end

__sb.nearestFromList = function(list)
	local hrp = getHRP and getHRP() or nil
	if not hrp then return list[1] end
	local hp = hrp.Position
	local best, bestD = nil, math.huge
	for _, br in ipairs(list) do
		local part = type(getPodiumWorldPart) == "function" and getPodiumWorldPart(br) or nil
		local pos = part and part:GetPivot().Position or br.position
		if pos then
			local dx, dz = hp.X - pos.X, hp.Z - pos.Z
			local dy = math.abs(hp.Y - pos.Y)
			local d = math.sqrt(dx*dx + dz*dz) + (dy > 6 and dy * 4 or 0)
			if d < bestD then bestD = d; best = br end
		end
	end
	return best
end

__sb.currentTarget = function()
	if not G then return nil end
	if not (G.AutoStealBest or G.AutoStealNearest or G.AutoStealPriority) then
		return nil
	end
	local ok, target = pcall(function()
		local list = __sb.freshList_get()
		if G.AutoStealPriority then
			for _, br in ipairs(list) do
				if type(isPriorityBrainrot) == "function" and isPriorityBrainrot(br) then
					return br
				end
			end
		end
		if G.AutoStealBest then
			return list[1]
		end
		if G.AutoStealNearest then
			return __sb.nearestFromList(list)
		end
		return nil
	end)
	return ok and target or nil
end

__sb.findByPrompt = function(prompt)
	if not prompt then return nil end
	for _, br in ipairs(__sb.freshList_get()) do
		if br.prompt == prompt then return br end
	end
	return nil
end

__sb.updateLabel = function()
	if not __sb.label then return end
	local t = __sb.lockedPrompt and __sb.findByPrompt(__sb.lockedPrompt) or __sb.currentTarget()
	if t and t.displayName then
		local gen = t.gen or t.generation or ""
		if gen ~= "" then
			__sb.label.Text = ("Stealing: %s  -  %s"):format(tostring(t.displayName), tostring(gen))
		else
			__sb.label.Text = "Stealing: " .. tostring(t.displayName)
		end
	else
		__sb.label.Text = "Chiraq Hub  -  No target"
	end
end

__sb.build()

__sb.hasTarget = function()
	if __sb.lockedPrompt then return true end
	return __sb.currentTarget() ~= nil
end

RunService.RenderStepped:Connect(function()
	__sb.updateLabel()
	if __sb.lockedPrompt and __sb.lockedAt then
		local p = (tick() - __sb.lockedAt) / __sb.cycle
		if p >= 1 then
			__sb.setProgress(1)
		else
			__sb.setProgress(p)
		end
	else
		__sb.setProgress(0)
	end
end)

local __stealCbCache = {}
local function __buildStealCallbacks(prompt)
	if __stealCbCache[prompt] then return __stealCbCache[prompt] end
	if not getconnections then return nil end
	local data = { hold = {}, trigger = {} }
	local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
	if ok1 and type(conns1) == "table" then
		for _, c in ipairs(conns1) do
			if type(c.Function) == "function" then table.insert(data.hold, c.Function) end
		end
	end
	local ok2, conns2 = pcall(getconnections, prompt.Triggered)
	if ok2 and type(conns2) == "table" then
		for _, c in ipairs(conns2) do
			if type(c.Function) == "function" then table.insert(data.trigger, c.Function) end
		end
	end
	if #data.hold == 0 and #data.trigger == 0 then return nil end
	__stealCbCache[prompt] = data
	return data
end

local __MIN_HOLD_TIME = 1.3
local __POST_RAGDOLL_GAP = 0.01
local __TRIGGER_AFTER_GREEN = 0.03
local __RAGDOLL_FALLBACK = 3.0

local function __isWalkMethod()    return G and G.StealMethod == "Walk" end
local function __isPrimeMethod()   return G and G.StealMethod == "Prime" end
local function __isRagdollMethod() return not G or (G.StealMethod ~= "Walk" and G.StealMethod ~= "Prime") end

local function __selfRagdoll()
	if __isWalkMethod() or __isPrimeMethod() then return end
	if not adminRemoteReady or not adminRemote then return end
	pcall(function() adminRemote:InvokeServer(RF_PLOT_KEY, Players.LocalPlayer, "ragdoll") end)
end

local function __pollRagdollEndTime(timeoutSec)
	local lp = Players.LocalPlayer
	local waitStart = tick()
	while tick() - waitStart < timeoutSec do
		local v = lp:GetAttribute("RagdollEndTime") or 0
		if v > workspace:GetServerTimeNow() then return v end
		task.wait()
	end
	return nil
end

function __startStealHold(prompt)
	if not prompt or not prompt.Parent then return nil end
	local cb = __buildStealCallbacks(prompt)
	if not cb then return nil end
	-- Ragdoll method removed: always fire hold callbacks immediately
	-- (previously Walk/Prime-only behavior).
	for _, fn in ipairs(cb.hold) do task.spawn(fn) end
	local holdBeganAt = tick()
	if __sb then
		__sb.lockedPrompt = prompt
		__sb.lockedAt = tick()
	end
	return {
		prompt = prompt,
		cb = cb,
		ragdollFireTime = tick(),
		ragdollEnd = nil,
		startedAt = tick(),
		holdBeganAt = holdBeganAt,
		holdDone = true,
	}
end

local function __doHoldAndWait(ctx)
	if ctx.holdDone then return end
	if ctx.ragdollEnd then
		while workspace:GetServerTimeNow() < ctx.ragdollEnd + __POST_RAGDOLL_GAP do task.wait() end
	elseif __isRagdollMethod() then
		local fb = ctx.ragdollFireTime + __RAGDOLL_FALLBACK + __POST_RAGDOLL_GAP
		while tick() < fb do task.wait() end
	end
	for _, fn in ipairs(ctx.cb.hold) do task.spawn(fn) end
	ctx.holdBeganAt = tick()
	task.wait(__MIN_HOLD_TIME)
	ctx.holdDone = true
end

function __waitForStealTime(ctx, sec)
	if not ctx then return end
	if sec >= 1.0 then
		if __isRagdollMethod() then __doHoldAndWait(ctx) end
		-- For Walk/Prime, hold callbacks already fired at __startStealHold; just respect the min hold window
		if ctx.holdBeganAt then
			local elapsed = tick() - ctx.holdBeganAt
			if elapsed < sec then task.wait(sec - elapsed) end
		end
		return
	end
	local elapsed = tick() - ctx.ragdollFireTime
	if elapsed < sec then task.wait(sec - elapsed) end
end

function __finishStealHold(ctx)
	if not ctx then
		if __sb then __sb.lockedPrompt = nil; __sb.lockedAt = nil end
		return false
	end
	if not ctx.holdBeganAt then __doHoldAndWait(ctx) end
	local heldFor = tick() - (ctx.holdBeganAt or tick())
	if heldFor < __MIN_HOLD_TIME then task.wait(__MIN_HOLD_TIME - heldFor) end
	task.wait(__TRIGGER_AFTER_GREEN)
	if ctx.cb and #ctx.cb.trigger > 0 then
		for _, fn in ipairs(ctx.cb.trigger) do task.spawn(fn) end
	end
	if __sb then __sb.lockedPrompt = nil; __sb.lockedAt = nil end
	return true
end

local __grabActive = {}
function firePatchedSteal(prompt)
	if not prompt or not prompt.Parent then return false end
	if __grabActive[prompt] then return false end
	__grabActive[prompt] = true

	-- Fire hold callbacks immediately, then wait the min hold window. After
	-- that, only fire trigger callbacks once the player is within 10 studs
	-- of the prompt. When we just entered range, wait 0.3s before firing
	-- (gives the server-side prompt state time to settle).
	local cb = __buildStealCallbacks(prompt)
	if not cb then
		__grabActive[prompt] = nil
		return pcall(fireproximityprompt, prompt)
	end

	local origDist = prompt.MaxActivationDistance
	pcall(function() prompt.MaxActivationDistance = 9e9 end)
	pcall(function() prompt.RequiresLineOfSight = false end)

	if __sb then
		__sb.lockedPrompt = prompt
		__sb.lockedAt    = tick()
	end

	for _, fn in ipairs(cb.hold) do task.spawn(fn) end
	local startedAt = tick()
	task.wait(__MIN_HOLD_TIME)

	local function dist()
		local hrp = getHRP and getHRP() or nil
		if not hrp or not prompt.Parent then return math.huge end
		local pp = prompt.Parent
		local pos = pp:IsA("Attachment") and pp.WorldPosition or (pp:IsA("BasePart") and pp.Position) or nil
		if not pos then return math.huge end
		return (hrp.Position - pos).Magnitude
	end

	local alreadyInRange = dist() <= 10
	local fired = false
	while true do
		local elapsed = tick() - startedAt
		if elapsed > 2.6 then break end
		if not prompt.Parent then break end
		if dist() <= 10 then
			if not alreadyInRange then task.wait(0.3) end
			if prompt.Parent and #cb.trigger > 0 then
				for _, fn in ipairs(cb.trigger) do task.spawn(fn) end
				fired = true
			end
			break
		end
		task.wait()
	end

	if prompt and prompt.Parent then
		pcall(function() prompt.MaxActivationDistance = origDist end)
	end
	if __sb then __sb.lockedPrompt = nil; __sb.lockedAt = nil end
	__grabActive[prompt] = nil
	return fired
end

local controls = nil
local function getControls()
	if controls then
		return controls
	end
	local playerScripts = player and player:FindFirstChild("PlayerScripts")
	local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
	if not playerModule then
		return nil
	end
	local okModule, module = pcall(require, playerModule)
	if not okModule or not module then
		return nil
	end
	local okControls, resolvedControls = pcall(function()
		return module:GetControls()
	end)
	if okControls and resolvedControls then
		controls = resolvedControls
	end
	return controls
end
local pingvar = nil
local C = {
	bg = Color3.fromRGB(14, 14, 20),
	header = Color3.fromRGB(18, 18, 28),
	border = Color3.fromRGB(42, 42, 53),
	purple = Color3.fromRGB(138, 43, 226),
	purpleHi = Color3.fromRGB(155, 60, 240),
	purpleDim = Color3.fromRGB(75, 0, 130),
	row = Color3.fromRGB(25, 25, 34),
	rowHov = Color3.fromRGB(30, 30, 40),
	rowSel = Color3.fromRGB(45, 12, 80),
	text = Color3.fromRGB(255, 255, 255),
	textDim = Color3.fromRGB(180, 180, 200),
	textMute = Color3.fromRGB(110, 110, 140),
	green = Color3.fromRGB(68, 238, 136),
	red = Color3.fromRGB(238, 68, 68),
	track = Color3.fromRGB(40, 40, 52),
	cyan = Color3.fromRGB(68, 220, 255),
	gold = Color3.fromRGB(255, 190, 50),
}
local fps = 60
local ping = 0
function connectLoop(callback, interval, passDeltaTime)
	local connection = {
		Connected = true
	}
	function connection:Disconnect()
		self.Connected = false
	end
	task.spawn(function()
		local lastTick = os.clock()
		while connection.Connected do
			local now = os.clock()
			local dt = now - lastTick
			lastTick = now
			local ok, err
			if passDeltaTime then
				ok, err = pcall(callback, dt)
			else
				ok, err = pcall(callback)
			end
			if not ok then
				warn("connectLoop callback failed:", err)
			end
			task.wait(interval or 0)
		end
	end)
	return connection
end
CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
JumpscareModule = require(ReplicatedStorage.Datas.AdminCommands.jumpscare)
Packages = ReplicatedStorage:WaitForChild("Packages")
ShakePackage = require(Packages.Shake)
ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
dataModules = {
	AnimalsData = require(ReplicatedStorage:WaitForChild("Datas"):WaitForChild("Animals")),
	NumberUtils = require(ReplicatedStorage:WaitForChild("Utils"):WaitForChild("NumberUtils")),
}
AnimalsShared = require(ReplicatedStorage.Shared.Animals)
EffectController = require(ReplicatedStorage.Controllers.EffectController)
LocalVFX = require(ReplicatedStorage.Shared.VFX)
ServerData = require(ReplicatedStorage.Datas.ServerData)
syncRemotes = (function()
	local folder = Packages:WaitForChild("Synchronizer")
	return {
		channelFolder = folder:WaitForChild("Channel"),
		routeRemote = folder:WaitForChild("CommunicationRoute"),
		requestData = folder:FindFirstChild("RequestData"),
	}
end)()

local NetFolder = Packages:WaitForChild("Net", 10)
children = NetFolder and NetFolder:GetChildren() or {}

RealUseItem = nil
if getconnections and NetFolder then
	local gc = (debug and debug.getconstants) or getconstants
	for _, r in ipairs(children) do
		if r:IsA("RemoteEvent") and not RealUseItem then
			local ok, conns = pcall(getconnections, r.OnClientEvent)
			if ok and gc then
				for _, c in ipairs(conns) do
					if type(c.Function) == "function" then
						local okc, consts = pcall(gc, c.Function)
						if okc then
							for _, k in ipairs(consts) do
								if k == "PaintballHitted" then RealUseItem = r break end
							end
						end
					end
					if RealUseItem then break end
				end
			end
		end
	end
end

local spamRemotes = {}
local spamPayload = string.rep("X", 768)
local blacklistedNames = {
	"PlaceCooldownFromChat",
	"AdminPanelService",
	"AdminPanel",
	"IntegrityCheckProcessor",
	"LocalizationTableAnalyticsSender",
	"LocalizationService",
	"Analytics",
	"Telemetry",
	"Logger",
	"Reporter",
	"CanChatWith",
	"SetPlayerBlockList",
	"UpdatePlayerBlockList",
	"NewPlayerGroupDetails",
	"NewPlayerCanManageDetails",
	"SendPlayerBlockList",
	"UpdateLocalPlayerBlockList",
	"SendPlayerProfileSettings",
	"RequestPlayerProfileSettings",
	"UpdatePlayerProfileSettings",
	"ShowFriendJoinedPlayerToast",
	"ShowPlayerJoinedFriendsToast",
	"CreateOrJoinParty",
	"ServerSideBulkPurchaseEvent",
	"SetDialogInUse",
	"ContactListInvokeIrisInvite",
	"ContactListIrisInviteTeleport",
	"UpdateCurrentCall",
	"RequestDeviceCameraOrientationCapability",
	"ReceiveLikelySpeakingUsers",
	"ReferredPlayerJoin",
	"Update",
	"RE/Tools/Cooldown",
	"RE/FuseMachine/RevealNow",
	"RE/FuseMachine/FuseAnimation",
	"RE/NotificationService/Notify",
	"RE/PlotService/ClaimCoins",
	"RE/PlotService/Sell",
	"RE/PlotService/Open",
	"RE/PlotService/ToggleFriends",
	"RE/PlotService/CashCollected",
	"RE/ChatService/ChatMessage",
	"RE/SoundService/PlayClientSound",
	"RE/Snapshot/RealiableChannel",
	"RE/CommandsService/OpenCommandBar",
	"RE/92e5a494-0ab4-4c4e-ae6b-96e5f4a2a698",
	"92e5a494-0ab4-4c4e-ae6b-96e5f4a2a698",
	"6411a778-07a5-4513-b1c7-60b65ae05ac8",
	"RE/GameService/SpawnEffect",
	"RE/Leaderboard/ReplicateDisplayNames",
	"eb9dee81-7718-4020-b6b2-219888488d13",
	"fce51e06-a587-4ff0-9e19-869eb1859a01",
	"680db8c7-c46a-492c-b451-6e980910902c",
	"RE/StealService/Grab",
	"RE/PlotService/Place",
	"RE/StealService/StealingSuccess",
	"RE/StealService/StealingFailure",
	"RE/CombatService/ApplyImpulse",
	"RE/InventoryService/Sort",
	"RE/StockEventService/SetFocused",
	"RE/StockEventService/Return",
	"RE/StockEventService/Redeem",
	"RE/MerchantService/SetFocused",
	"RE/MerchantService/Animation",
	"RE/SantaMerchantService/SetFocused",
	"RE/SantaMerchantService/Animation",
	"RE/SantaMerchantService/CollectGoldElf",
	"RE/ShopService/Purchase",
	"RE/TutorialService/StartTutorial",
	"RE/TutorialService/FinishTutorial",
	"RE/TeleportService/Reconnect",
	"RobloxChatSystemMessage",
	"BadgeService.AFK",
	"AFK"
}
local blacklistSet = {}
for _, v in ipairs(blacklistedNames) do
	blacklistSet[v] = true
end
function isBlacklisted(fullName, name)
	if # name ~= 67 then
		return true
	end
	for bl, _ in pairs(blacklistSet) do
		if fullName:find(bl, 1, true) or name:find(bl, 1, true) then
			return true
		end
	end
	return false
end
function findRemotes()
	local found = {}
	local desc = game:GetDescendants()
	local chunkSize = 2000
	for i = 1, # desc, chunkSize do
		for j = i, math.min(i + chunkSize - 1, # desc) do
			local v = desc[j]
			if v:IsA("RemoteEvent") then
				local fn = v:GetFullName()
				local n = v.Name
				if not isBlacklisted(fn, n) then
					table.insert(found, v)
				end
			end
		end
		task.wait()
	end
	spamRemotes = {}
	for i = 1, math.min(5, # found) do
		spamRemotes[i] = found[i]
	end
	task.spawn(function()
		local Packages = ReplicatedStorage:FindFirstChild("Packages")
		if Packages then
			local NetFolder = Packages:FindFirstChild("Net")
			if NetFolder then
				for _, obj in pairs(NetFolder:GetChildren()) do
					if obj:IsA("RemoteEvent") then
						if # spamRemotes < 5 then
							table.insert(spamRemotes, obj)
						end
						break
					end
				end
			end
		end
	end)
end
local spamming = false
function fireSpamRemotes()
	if # spamRemotes == 0 then
		return
	end
	spamming = true
	local char = player.Character
	if not char or not char.Parent then
		spamming = false
		return
	end
	local hum = char:FindFirstChild("Humanoid")
	if not hum then
		spamming = false
		return
	end
	hum.Died:Once(function()
		spamming = false
	end)
	while spamming do
		for _, remote in ipairs(spamRemotes) do
			if not spamming then
				break
			end
			guardedFireServer(remote, "d80e2217-36b8-4bdc-9a46-2281c6f70b28", spamPayload)
		end
		task.wait(0.5)
	end
end
function stopSpam()
	spamming = false
end
player.CharacterAdded:Connect(stopSpam)
task.spawn(findRemotes)
workspace = Workspace
local adminabuseeffects = {
	"Meteor",
	"Explosion",
	"Piles",
	"SnowWeather",
	"RainWeather",
	"Pinata",
	"Wall",
	"Web_Main",
	"Sammy",
	"Stage",
	"Stock",
	"Tree",
	"Hole",
	"FireGoblets",
	"Events",
	"StarfallWeather",
	"1x1x1x1Map",
	"CandyWeather",
	"Part",
	"NyanCat",
	"TacoAmbient",
	"GatitoMap",
	"MapVFX",
	"Nyan",
	"Ocean",
	"Strike",
	"ProximityPart",
	"Planesbg",
	"Taco",
	"Glitch",
	"Crabs",
	"Cannon",
	"YinYangMap",
	"YinYangWeather",
	"BabyTungTung",
	"GalaxyMap",
	"GalaxyWeather",
	"VFX",
	"Caves",
	"Caves2",
	"SammyBase",
	"UFO",
	"ExplosionBoom",
	"ufoemit",
	"CursedSpinWheels"
}
workspace.DescendantAdded:Connect(function(child)
	for index, value in adminabuseeffects do
		local cat = workspace:FindFirstChild(value)
		if cat then
			cat:Destroy()
		end
	end
end)
local RF_PLOT_KEY = "f888ee6e-c86d-46e1-93d7-0639d6635d42"
local adminRemoteReady = true
local adminRemote
do
	local netFolder = ReplicatedStorage.Packages:WaitForChild("Net")
	local LP = game:GetService("Players").LocalPlayer
	local gu = (debug and debug.getupvalues) or getupvalues
	local gp = (debug and debug.getprotos) or getprotos
	local ap = LP:WaitForChild("PlayerGui"):WaitForChild("AdminPanel", 20)
	local tb = ap and ap.AdminPanel.CommandBox:FindFirstChild("TextBox")
	if tb and getconnections and gu then
		local stack, seen = {}, {}
		for _, c in ipairs(getconnections(tb.FocusLost)) do
			if type(c.Function) == "function" then stack[# stack + 1] = c.Function end
		end
		while # stack > 0 and not adminRemote do
			local fn = table.remove(stack)
			if not seen[fn] then
				seen[fn] = true
				local ok, ups = pcall(gu, fn)
				if ok and ups then
					for _, v in pairs(ups) do
						if typeof(v) == "Instance" and v:IsA("RemoteFunction") and v.Parent == netFolder then
							adminRemote = v
							break
						elseif type(v) == "function" then
							stack[# stack + 1] = v
						end
					end
				end
				if gp then
					local ok2, ps = pcall(gp, fn)
					if ok2 and ps then for _, p in ipairs(ps) do stack[# stack + 1] = p end end
				end
			end
		end
	end
end
local CONFIG_FILE = "meowhub.json"
function getVP()
	return Camera.ViewportSize
end
local ALL_COMMANDS = {
	"balloon",
	"ragdoll",
	"rocket",
	"inverse",
	"tiny",
	"jail",
	"jumpscare",
	"morph"
}
local Defaults = {
	AntiRagdoll = true,
	AntiKnockback = false,
	AntiAdminPanel = true,
	AntiGummyBear = true,
	AntiBee = true,
	AntiBoogieBomb = true,
	AntiPaintball = true,
	AutoInstaReset = true,
	AutoInstaResetOnRagdoll = false,
	AutoDestroyTurret = false,
	AutoSpam = true,
	AntiLagEnabled = true,
	StrawberryEvent = false,
	StrawberrySky = false,
	StrawberrySound = false,
	MeowlEvent = false,
	MeowlSky = false,
	MeowlPet = false,
	MeowlPetScale = 1,
	LeaveOnSteal = false,
	Speed = true,
	SpeedValue = 30,
	StealingSpeedValue = 28.6,
	GiantSpeedValue = 34,
	CarpetSpeedValue = 130,
	GravityValue = 196.2,
	BrainrotESP = true,
	FriendPanelESP = true,
	PlayerESP = true,
	TimerESP = true,
	Notifactions = false,
	FOVValue = 80,
	StretchValue = 1.0,
	CurrentSky = "none",
	MineESP = true,
	ForceFieldCubes = false,
	AutoStealBest = false,
	AutoStealNearest = false,
	AutoStealPriority = false,
	Instantsteal = false,
	Semiinstant = true,
	SmartTP = true,
	desyncSendHookEnabled = false,
	desyncUnwalkEnabled = false,
	AutoPotion = false,
	AutoPotion2 = false,
	AutoResetDesync = false,
	AutoTPonUnlock = true,
	AutoTPonAllow = false,
	AutoStealOnTimerEnd = false,
	AutoInstantStealOnRespawn = false,
	AutoDefense = true,
	ShowAdminPanelWindow = false,
	AdminPanelLocked = true,
	AntiTPScam = false,
	TPProtector = false,
	SafteyKick = true,
	KickNoCmds = false,
	KickThirdPlayer = false,
	Autoblock = false,
	AutoWalkAfterSteal = false,
	AutoSpamAfterSteal = false,
	StealSpamCmds = {
		"rocket",
		"tiny",
		"inverse"
	},
	APSpamCmds1 = {
		"balloon",
		"tiny",
		"inverse",
		"rocket"
	},
	APSpamCmds2 = {
		"ragdoll",
		"jail",
		"jumpscare",
		"morph"
	},
	DefCmds1 = {
		"balloon"
	},
	DefCmds2 = {
		"ragdoll",
		"tiny",
		"inverse",
		"rocket",
		"jumpscare"
	},
	DefCmdsMulti1 = {
		"balloon",
		"tiny",
		"inverse",
		"rocket"
	},
	DefCmdsMulti2 = {
		"ragdoll",
		"jail",
		"jumpscare",
		"morph"
	},
	AntiTpCmds = {
		"balloon",
		"jail"
	},
	TpProtCmds = {
		"jail"
	},
	SpamCmds1 = {
		"balloon",
		"tiny",
		"inverse",
		"rocket"
	},
	SpamCmds2 = {
		"ragdoll",
		"jail",
		"jumpscare",
		"morph"
	},
	KeybindToggleSpeed = "Y",
	KeybindToggleGui = "V",
	KeybindManualDefense = "F",
	KeybindManualSemi = "B",
	TPKeybind = "T",
	ActionBtnSemiStealX = 16,
	ActionBtnSemiStealY = 156,
	ActionBtnManualDefX = 16,
	ActionBtnManualDefY = 192,
	ActionBtnInstaResetX = 16,
	ActionBtnInstaResetY = 228,
	ActionBtnSetupDesyncX = 16,
	ActionBtnSetupDesyncY = 264,
	ActionBtnAPSpamX = 16,
	ActionBtnAPSpamY = 336,
	ActionBtnLeaveX = 16,
	ActionBtnLeaveY = 372,
	ActionBtnRejoinX = 16,
	ActionBtnRejoinY = 408,
	ActionBtnAllowToggleX = 16,
	ActionBtnAllowToggleY = 444,
	ActionBtnSelfRagdollX = 16,
	ActionBtnSelfRagdollY = 480,
	ShowActionButtons = true,
	ShowBtnSemiSteal = true,
	ShowBtnManualDef = true,
	ShowBtnInstaReset = true,
	ShowBtnSetupDesync = true,
	ShowBtnAPSpam = true,
	ShowBtnLeave = true,
	ShowBtnRejoin = true,
	ShowBtnAllowToggle = true,
	ShowBtnSelfRagdoll = true,
	UsePVPActionButtonStyle = false,
	TPDirectlyToPet = true,
	AutoFloatThirdFloor = false,
	SecondSlotSteal = false,
	InstantStealSlotMode = "First Slot",
	InfJump = true,
	IS_AutoOnSteal = false,
	IS_AutoFixLagback = false,
	IS_Angle = 180,
	IS_SinkDepth = 4.5,
	IS_KeybindIS = "I",
	PriorityESP = true,
	StealingESP = true,
	PriorityNames = {},
	LineToBest = true,
	LineToBase = true,
	ActionButtonsLocked = true,
	ActionBtnLockX = 16,
	ActionBtnLockY = 84,
	ActionBtnSemiStealKey = "",
	ActionBtnManualDefKey = "",
	ActionBtnInstaResetKey = "",
	ActionBtnSetupDesyncKey = "",
	ActionBtnAPSpamKey = "",
	ActionBtnLeaveKey = "",
	ActionBtnRejoinKey = "",
	ActionBtnAllowToggleKey = "",
	ActionBtnSelfRagdollKey = "",
	StealMethod = "Walk",
}
G = {}
function applyConfig(src)
	for k, v in pairs(Defaults) do
		G[k] = v
	end
	for k, v in pairs(src) do
		G[k] = v
	end
	G.SetupDesync = false
end
function saveConfig()
	if not writefile then
		return
	end
	local data = {}
	for k in pairs(Defaults) do
		data[k] = G[k]
	end
	writefile(CONFIG_FILE, HttpService:JSONEncode(data))
end
function loadConfig()
	if readfile and isfile and isfile(CONFIG_FILE) then
		local ok, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(CONFIG_FILE))
		if ok then
			applyConfig(decoded);
			return
		end
	end
	applyConfig(Defaults)
	saveConfig()
end
loadConfig()
local ARRAY_KEYS = {
	"DefCmds1",
	"DefCmds2",
	"DefCmdsMulti1",
	"DefCmdsMulti2",
	"AntiTpCmds",
	"TpProtCmds",
	"SpamCmds1",
	"SpamCmds2",
	"StealSpamCmds",
	"APSpamCmds1",
	"APSpamCmds2",
	"PriorityNames",
}
for _, k in ipairs(ARRAY_KEYS) do
	if type(G[k]) ~= "table" then
		G[k] = Defaults[k]
	end
end
local PRIORITY_LIST = {
	"Headless Horseman",
	"Strawberry Elephant",
	"Meowl",
	"Signore Carapace",
	"Skibidi Toilet",
	"Griffin",
	"Love Love Bear",
	"Dragon Gingerini",
	"Elefanto Frigo",
	"Ginger Gerat",
	"La Supreme Combinasion",
	"Antonio",
	"Dragon Cannelloni",
	"Hydra Dragon Cannelloni",
	"Dug dug dug",
	"Ketupat Bros",
	"Tirilikalika Tirilikalako",
	"La Casa Boo",
	"Los Amigos",
	"Cerberus",
	"Celestial Pegasus",
	"Cooki and Milki",
	"Rosey and Teddy",
	"Reinito Sleighito",
	"Capitano Moby",
	"Spooky and Pumpky",
	"Fragrama and Chocrama",
	"Garama and Madundung",
	"La Food Combinasion",
	"Burguro and Fryuro",
	"Popcuru and Fizzuru",
	"Ketchuru and Musturu",
	"La Secret Combinasion",
	"Tralaledon",
	"Tictac Sahur",
	"Ketupat Kepat",
	"Tang Tang Keletang",
	"Orcaledon",
	"La Ginger Sekolah",
	"Los Spaghettis",
	"Lavadorito Spinito",
	"Swaggy Bros",
	"La Taco Combinasion",
	"Los Primos",
	"Chillin Chili",
	"Tuff Toucan",
	"W or L",
	"Chipso and Queso",
	"Fishino Clownino"
}
local prioritySet = {}
function rebuildPrioritySet()
	prioritySet = {}
	for _, name in ipairs(G.PriorityNames) do
		prioritySet[name] = true
	end
end
rebuildPrioritySet()
function isPriorityBrainrot(br)
	return prioritySet[br.displayName] ~= nil
end
local LOCAL_EVENT_PROFILES = {
	Strawberry = {
		moduleName = "Strawberry",
		attrName = "StrawberryEvent",
		frameName = "Strawberry",
		labelText = "LOCAL",
		effectName = "StrawberryEvent",
		grassEffect = "GrassRecolor",
		cloneNames = {
			{
				source = "StrawberryVFX",
				target = "_LOCAL_STRAWBERRY_EVENT_VFX",
				useEnable = true,
				when = "normal"
			},
			{
				source = "StrawberryVFXTsunami",
				target = "_LOCAL_STRAWBERRY_EVENT_VFX",
				useEnable = true,
				when = "tsunami"
			},
			{
				source = "Bushes",
				target = "_LOCAL_STRAWBERRY_EVENT_BUSHES",
				when = "normal"
			},
			{
				source = "BushesBigger",
				target = "_LOCAL_STRAWBERRY_EVENT_BUSHES",
				when = "bigger"
			},
			{
				source = "BushesTsunami",
				target = "_LOCAL_STRAWBERRY_EVENT_BUSHES",
				when = "tsunami"
			},
		},
		skyName = "Sky",
		atmosphereName = "Atmosphere",
	},
	Meowl = {
		moduleName = "Meowl",
		attrName = "MeowlEvent",
		frameName = "Meowl",
		labelText = "LOCAL",
		effectName = "MeowlEvent",
		effectNames = {
			"GrassRecolor",
			"WallRecolor",
			"WallBottomRecolor"
		},
		cloneNames = {
			{
				source = "Trees",
				target = "_LOCAL_MEOWL_EVENT_TREES",
				useEnable = true
			},
		},
		mapNames = {
			"MapTsunami",
			"MapBigger",
			"Map"
		},
		atmosphereName = "AtmosphereMeowl",
	},
}
local LOCAL_EVENT_ATTRS = {
	"StrawberryEvent",
	"MeowlEvent",
	"SkibidiEvent",
}
local localEventStates = {}
for profileName in pairs(LOCAL_EVENT_PROFILES) do
	localEventStates[profileName] = {
		eventActive = false,
		eventCleanup = nil,
		skyActive = false,
		skyCleanup = nil,
		iconVisible = nil,
		iconText = nil,
	}
end
local currentLocalEventName = nil
local setLocalEventIcon
function destroyAndClear(value)
	if value and value.Parent then
		value:Destroy()
	end
end
function purgeFakeArtifacts()
	for _, service in ipairs({
		Workspace,
		SoundService,
		Lighting
	}) do
		for _, child in ipairs(service:GetChildren()) do
			local name = child.Name
			if string.sub(name, 1, 6) == "_FAKE_" or string.sub(name, 1, 7) == "_LOCAL_" then
				destroyAndClear(child)
			end
		end
	end
end
function clearAllLocalEventAttributes()
	for attrName in pairs(ReplicatedStorage:GetAttributes()) do
		local isEventAttr = string.find(attrName, "Event", 1, true) ~= nil
		local isStockAttr = string.find(attrName, "StockEvent", 1, true) ~= nil
		local isClockAttr = string.find(attrName, "Next", 1, true) == 1 or string.find(attrName, "LastTime", 1, true) ~= nil
		if (isEventAttr and not isStockAttr and not isClockAttr) or attrName == "CrabRave" or attrName == "Snow" then
			ReplicatedStorage:SetAttribute(attrName, nil)
		end
	end
end
function refreshSharedEffects()
	local refreshKey = "_LOCAL_REFRESH_" .. HttpService:GenerateGUID(false)
	for _, effectName in ipairs({
		"GrassRecolor",
		"WallRecolor",
		"WallBottomRecolor"
	}) do
		pcall(function()
			EffectController:Run(refreshKey, effectName)
		end)
		pcall(function()
			EffectController:Stop(refreshKey, effectName)
		end)
	end
end
local antiBeeUntil = 0
local antiBoogieUntil = 0
local antiShakeInstalled = false
function restoreMoveControls()
	local ctrl = getControls()
	if CharacterController and ctrl then
		ctrl.moveFunction = function(p, x, z)
			CharacterController:RequestMove(p, x, z)
		end
	end
end

function clearNamedLightingEffects(names)
	for _, child in ipairs(Lighting:GetChildren()) do
		if names[child.Name] and (child:IsA("ColorCorrectionEffect") or child:IsA("BlurEffect")) then
			child:Destroy()
		end
	end
end
function stopControllerEffectSound(controllerName, soundName)
	local itemController = ReplicatedStorage:FindFirstChild("Controllers") and ReplicatedStorage.Controllers:FindFirstChild("ItemController")
	local controller = itemController and itemController:FindFirstChild(controllerName)
	local sound = controller and controller:FindFirstChild(soundName)
	if sound and sound:IsA("Sound") then
		sound:Stop()
	end
end
function clearBeeAndBoogieEffects()
	if G.AntiBee and tick() <= antiBeeUntil then
		restoreMoveControls()
		clearNamedLightingEffects({
			BeeBlur = true,
			Flashbang = true,
		})
		stopControllerEffectSound("BeeLauncherController", "Buzzing")
	end
	if G.AntiBoogieBomb and tick() <= antiBoogieUntil then
		clearNamedLightingEffects({
			DiscoEffect = true,
		})
		stopControllerEffectSound("BoogieBombController", "BOOM")
	end
end
if RealUseItem then
	RealUseItem.OnClientEvent:Connect(function(effectName)
		if effectName == "PaintballHitted" then
			runAntiPaintballSweep()
		elseif effectName == "Bee Attack" and G.AntiBee then
			antiBeeUntil = tick() + 6
			clearBeeAndBoogieEffects()
		elseif effectName == "Boogie" and G.AntiBoogieBomb then
			antiBoogieUntil = tick() + 11
			clearBeeAndBoogieEffects()
		end
	end)
end

function clearSharedEffectOwners()
	for _, effectName in ipairs({
		"GrassRecolor",
		"WallRecolor",
		"WallBottomRecolor",
		"Space"
	}) do
		if EffectController.ActiveEffects[effectName] then
			EffectController.ActiveEffects[effectName] = nil
		end
	end
end
function pcallCleanup(callback)
	if callback then
		pcall(callback)
	end
end
function stopCurrentEvent()
	for profileName, state in pairs(localEventStates) do
		if state.eventCleanup then
			pcallCleanup(state.eventCleanup)
		else
			setLocalEventIcon(profileName, false)
		end
		state.eventActive = false
		state.skyActive = false
		state.skyCleanup = nil
		state.eventCleanup = nil
	end
	currentLocalEventName = nil
	clearAllLocalEventAttributes()
	clearSharedEffectOwners()
	refreshSharedEffects()
	purgeFakeArtifacts()
	if G.CurrentSky ~= "none" then
		task.defer(function()
			pcall(setSky, G.CurrentSky)
		end)
	end
end
function getLocalEventModule(profile)
	local controllers = ReplicatedStorage:FindFirstChild("Controllers")
	local eventController = controllers and controllers:FindFirstChild("EventController")
	local events = eventController and eventController:FindFirstChild("Events")
	local exact = events and events:FindFirstChild(profile.moduleName)
	if exact and exact:IsA("ModuleScript") then
		return exact
	end
	if not events then
		return nil
	end
	for _, child in ipairs(events:GetChildren()) do
		if string.find(string.lower(child.Name), string.lower(profile.moduleName), 1, true) then
			return child
		end
	end
end
function getLocalEventFrame(frameName)
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	local screenGui = playerGui and playerGui:FindFirstChild("ActiveEvents")
	local activeEvents = screenGui and screenGui:FindFirstChild("ActiveEvents")
	local frame = activeEvents and activeEvents:FindFirstChild(frameName)
	if frame and frame:IsA("GuiObject") then
		return frame
	end
	if activeEvents then
		local lowered = string.lower(frameName)
		for _, child in ipairs(activeEvents:GetChildren()) do
			if child:IsA("GuiObject") and string.find(string.lower(child.Name), lowered, 1, true) then
				return child
			end
		end
	end
end
setLocalEventIcon = function(profileName, enabled)
	local profile = LOCAL_EVENT_PROFILES[profileName]
	local state = localEventStates[profileName]
	local frame = profile and getLocalEventFrame(profile.frameName)
	if not (profile and state and frame) then
		return
	end
	local main = frame:FindFirstChild("Main")
	local label = main and main:FindFirstChild("TextLabel")
	if enabled then
		if state.iconVisible == nil then
			state.iconVisible = frame.Visible
		end
		if label and state.iconText == nil then
			state.iconText = label.Text
		end
		frame.Visible = true
		if label then
			label.Text = profile.labelText or "LOCAL"
		end
	else
		frame.Visible = state.iconVisible == true
		if label and state.iconText ~= nil then
			label.Text = state.iconText
		end
		state.iconVisible = nil
		state.iconText = nil
	end
end
function shouldCloneDefinition(definition)
	if definition.when == "bigger" then
		return ServerData.IsBiggerServer()
	end
	if definition.when == "tsunami" then
		return ServerData.IsTsunamiServer()
	end
	if definition.when == "normal" then
		return not ServerData.IsBiggerServer() and not ServerData.IsTsunamiServer()
	end
	return definition.when == nil or definition.when == "always"
end
function cloneLocalEventDecor(module, definitions, cleanupTasks, parent)
	for _, definition in ipairs(definitions or {}) do
		if shouldCloneDefinition(definition) then
			local source = module and module:FindFirstChild(definition.source)
			if source then
				local clone = source:Clone()
				clone.Name = definition.target
				clone.Parent = parent or Workspace
				if definition.useEnable then
					pcall(function()
						LocalVFX.enable(clone)
					end)
				end
				table.insert(cleanupTasks, function()
					if clone.Parent then
						clone:Destroy()
					end
				end)
			end
		end
	end
end
function cloneLightingAssetFromModule(module, assetName, cloneName)
	if not module then
		return function()
		end
	end
	local cleanupTasks = {}
	local source = module:FindFirstChild(assetName)
	local existing
	if source and source:IsA("Sky") then
		existing = Lighting:FindFirstChildOfClass("Sky")
	elseif source and source:IsA("Atmosphere") then
		existing = Lighting:FindFirstChildOfClass("Atmosphere")
	else
		existing = Lighting:FindFirstChild(assetName)
	end
	if existing then
		existing.Parent = module
		table.insert(cleanupTasks, function()
			if existing.Parent == module then
				existing.Parent = Lighting
			end
		end)
	end
	if source then
		local clone = source:Clone()
		clone.Name = cloneName or source.Name
		clone.Parent = Lighting
		table.insert(cleanupTasks, function()
			if clone.Parent then
				clone:Destroy()
			end
		end)
	end
	return function()
		for i = # cleanupTasks, 1, - 1 do
			pcall(cleanupTasks[i])
		end
	end
end
function getPreferredLocalEventMap(profile, module)
	if not (profile and module and profile.mapNames) then
		return nil
	end
	if ServerData.IsTsunamiServer() then
		return module:FindFirstChild("MapTsunami") or module:FindFirstChild("Map")
	end
	if ServerData.IsBiggerServer() then
		return module:FindFirstChild("MapBigger") or module:FindFirstChild("Map")
	end
	return module:FindFirstChild("Map") or module:FindFirstChild("MapBigger") or module:FindFirstChild("MapTsunami")
end
function startLocalEventFx(profileName)
	local profile = LOCAL_EVENT_PROFILES[profileName]
	local state = localEventStates[profileName]
	if not (profile and state) then
		return
	end
	if currentLocalEventName and currentLocalEventName ~= profileName then
		stopCurrentEvent()
	end
	if state.eventActive then
		setLocalEventIcon(profileName, true)
		return
	end
	local moduleScript = getLocalEventModule(profile)
	if not moduleScript then
		return
	end
	local cleanupTasks = {}
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	local activeScreen = playerGui and playerGui:FindFirstChild("ActiveEvents")
	local activeEvents = activeScreen and activeScreen:FindFirstChild("ActiveEvents")
	local frame = getLocalEventFrame(profile.frameName)
	local label = frame and frame:FindFirstChild("Main") and frame.Main:FindFirstChild("TextLabel")
	if profile.attrName then
		local originalAttr = ReplicatedStorage:GetAttribute(profile.attrName)
		ReplicatedStorage:SetAttribute(profile.attrName, true)
		table.insert(cleanupTasks, function()
			ReplicatedStorage:SetAttribute(profile.attrName, originalAttr)
		end)
	end
	if activeScreen then
		local oldEnabled = activeScreen.Enabled
		activeScreen.Enabled = true
		table.insert(cleanupTasks, function()
			if activeScreen.Parent then
				activeScreen.Enabled = oldEnabled
			end
		end)
	end
	if activeEvents then
		local oldVisible = activeEvents.Visible
		activeEvents.Visible = true
		table.insert(cleanupTasks, function()
			if activeEvents.Parent then
				activeEvents.Visible = oldVisible
			end
		end)
	end
	if frame then
		local oldVisible = frame.Visible
		local oldText = label and label.Text or nil
		frame.Visible = true
		frame.LayoutOrder = 0
		if label then
			label.Text = profile.labelText or "LOCAL"
		end
		table.insert(cleanupTasks, function()
			frame.Visible = oldVisible
			if label and oldText ~= nil then
				label.Text = oldText
			end
		end)
	end
	if profile.effectName and profile.effectNames then
		for _, effectName in ipairs(profile.effectNames) do
			pcall(function()
				if effectName == "GrassRecolor" then
					EffectController:Activate("Blink")
				end
				EffectController:Run(profile.effectName, effectName)
			end)
			table.insert(cleanupTasks, function()
				pcall(function()
					EffectController:Stop(profile.effectName, effectName)
					if effectName == "GrassRecolor" then
						EffectController:Activate("Blink")
					end
				end)
			end)
		end
	elseif profile.effectName and profile.grassEffect then
		pcall(function()
			EffectController:Activate("Blink")
			EffectController:Run(profile.effectName, profile.grassEffect)
		end)
		table.insert(cleanupTasks, function()
			pcall(function()
				EffectController:Stop(profile.effectName, profile.grassEffect)
				EffectController:Activate("Blink")
			end)
		end)
	end
	local cleanupAtmosphere = cloneLightingAssetFromModule(moduleScript, profile.atmosphereName, "_LOCAL_" .. string.upper(profileName) .. "_ATMOSPHERE")
	table.insert(cleanupTasks, cleanupAtmosphere)
	if profile.skyName then
		local cleanupSky = cloneLightingAssetFromModule(moduleScript, profile.skyName, "_LOCAL_" .. string.upper(profileName) .. "_SKY")
		table.insert(cleanupTasks, cleanupSky)
	end
	local eventFolder = Instance.new("Folder")
	eventFolder.Name = "_LOCAL_" .. string.upper(profileName) .. "_EVENT"
	eventFolder.Parent = Workspace
	table.insert(cleanupTasks, function()
		if eventFolder.Parent then
			eventFolder:Destroy()
		end
	end)
	local preferredMap = getPreferredLocalEventMap(profile, moduleScript)
	if preferredMap then
		local clone = preferredMap:Clone()
		clone.Name = "_LOCAL_" .. string.upper(profileName) .. "_PREFERRED_MAP"
		clone.Parent = eventFolder
		pcall(function()
			LocalVFX.enable(clone)
		end)
		table.insert(cleanupTasks, function()
			if clone.Parent then
				clone:Destroy()
			end
		end)
	end
	cloneLocalEventDecor(moduleScript, profile.cloneNames or {}, cleanupTasks, eventFolder)
	state.eventActive = true
	state.skyActive = true
	currentLocalEventName = profileName
	state.eventCleanup = function()
		for i = # cleanupTasks, 1, - 1 do
			pcall(cleanupTasks[i])
		end
		setLocalEventIcon(profileName, false)
		state.skyActive = false
		if currentLocalEventName == profileName then
			currentLocalEventName = nil
		end
		if G.CurrentSky ~= "none" then
			task.defer(function()
				pcall(setSky, G.CurrentSky)
			end)
		end
	end
	setLocalEventIcon(profileName, true)
end
function stopLocalEventFx(profileName)
	local state = localEventStates[profileName]
	if not state then
		return
	end
	if state.eventCleanup then
		pcall(state.eventCleanup)
	else
		setLocalEventIcon(profileName, false)
	end
	state.eventActive = false
	state.skyActive = false
	state.eventCleanup = nil
	if currentLocalEventName == profileName then
		currentLocalEventName = nil
	end
end
function startLocalEventSky(profileName)
	startLocalEventFx(profileName)
end
function stopLocalEventSky(profileName)
	if not G[(profileName == "Strawberry" and "StrawberryEvent" or "MeowlEvent")] then
		stopLocalEventFx(profileName)
	end
end
function syncLocalEventToggles()
	if G.StrawberrySound then
		G.StrawberrySound = false
	end
	local strawberryEnabled = G.StrawberryEvent or G.StrawberrySky
	local meowlEnabled = G.MeowlEvent or G.MeowlSky
	if not strawberryEnabled and not meowlEnabled then
		stopCurrentEvent()
		return
	end
	local desiredEventName = nil
	if strawberryEnabled then
		desiredEventName = "Strawberry"
	end
	if meowlEnabled then
		desiredEventName = "Meowl"
	end
	if desiredEventName then
		if currentLocalEventName and currentLocalEventName ~= desiredEventName then
			stopCurrentEvent()
		end
		startLocalEventFx(desiredEventName)
	elseif currentLocalEventName then
		stopCurrentEvent()
	end
end
task.spawn(function()
	while task.wait(2.5) do
		saveConfig()
	end
end)
task.spawn(function()
	while task.wait(0.25) do
		syncLocalEventToggles()
	end
end)
local FFlagsDesync = {
	GameNetPVHeaderRotationalVelocityZeroCutoffExponent = - 5000,
	LargeReplicatorWrite5 = true,
	LargeReplicatorEnabled9 = true,
	AngularVelocityLimit = 360,
	TimestepArbiterVelocityCriteriaThresholdTwoDt = 2147483646,
	S2PhysicsSenderRate = 15000,
	DisableDPIScale = true,
	MaxDataPacketPerSend = 2147483647,
	PhysicsSenderMaxBandwidthBps = 20000,
	TimestepArbiterHumanoidLinearVelThreshold = 21,
	MaxMissedWorldStepsRemembered = - 2147483648,
	PlayerHumanoidPropertyUpdateRestrict = true,
	SimDefaultHumanoidTimestepMultiplier = 0,
	StreamJobNOUVolumeLengthCap = 2147483647,
	DebugSendDistInSteps = - 2147483648,
	GameNetDontSendRedundantNumTimes = 1,
	CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent = 1,
	CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth = 1,
	LargeReplicatorSerializeRead3 = true,
	ReplicationFocusNouExtentsSizeCutoffForPauseStuds = 2147483647,
	CheckPVCachedVelThresholdPercent = 10,
	CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth = 1,
	GameNetDontSendRedundantDeltaPositionMillionth = 1,
	InterpolationFrameVelocityThresholdMillionth = 5,
	StreamJobNOUVolumeCap = 2147483647,
	InterpolationFrameRotVelocityThresholdMillionth = 5,
	CheckPVCachedRotVelThresholdPercent = 10,
	WorldStepMax = 30,
	InterpolationFramePositionThresholdMillionth = 5,
	TimestepArbiterHumanoidTurningVelThreshold = 1,
	SimOwnedNOUCountThresholdMillionth = 2147483647,
	GameNetPVHeaderLinearVelocityZeroCutoffExponent = - 5000,
	NextGenReplicatorEnabledWrite4 = true,
	TimestepArbiterOmegaThou = 1073741823,
	MaxAcceptableUpdateDelay = 1,
	LargeReplicatorSerializeWrite4 = true,
}
function applyFFlags(list)
	for name, value in pairs(list) do
		pcall(setfflag, tostring(name), tostring(value))
	end
end
local raknetHookInstalled = false
local raknetDesyncActive = false
local autoResetQueued = false
local autoResetBusy = false
local autoResetLatched = false
function setRaknetDesyncState(enabled)
	raknetDesyncActive = enabled
	if raknet and raknet.desync then
		pcall(function()
			raknet.desync(enabled)
		end)
	end
end
function ensureRaknetSendHook()
	if raknetHookInstalled then
		return
	end
	if not (raknet and raknet.add_send_hook) then
		return
	end
	pcall(function()
		raknet.add_send_hook(function(packet)
			if not raknetDesyncActive then
				return
			end
			if not packet or packet.PacketId ~= 0x1B then
				return
			end
			local data = packet.AsBuffer
			if not data then
				return
			end
			buffer.writeu32(data, 1, 0xFFFFFFFF)
			buffer.writeu32(data, 5, 0xFFFFFFFF)
			buffer.writeu32(data, 9, 0xFFFFFFFF)
			packet:SetData(data)
		end)
		raknetHookInstalled = true
	end)
end
function queueAutoReset()
	if not G.AutoResetDesync then
		return
	end
	if G.SetupDesync or autoResetBusy then
		return
	end
	autoResetQueued = true
end
task.spawn(function()
	autoResetLatched = G.AutoResetDesync == true
	autoResetQueued = G.AutoResetDesync == true and not G.SetupDesync
	while task.wait(0.5) do
		if G.AutoResetDesync then
			if not autoResetLatched then
				autoResetLatched = true
				queueAutoReset()
			end
		else
			autoResetLatched = false
			autoResetQueued = false
		end
		if autoResetQueued and G.AutoResetDesync and not G.SetupDesync and not autoResetBusy then
			autoResetQueued = false
			autoResetBusy = true
			applyFFlags(FFlagsDesync)
			G.SetupDesync = true
			respawn(player)
			task.wait((Players.RespawnTime or 3) + 1)
			autoResetBusy = false
		end
	end
end)
local Skies = {
	greengalaxy = {
		Bk = "rbxassetid://159248188",
		Dn = "rbxassetid://159248183",
		Ft = "rbxassetid://159248187",
		Lf = "rbxassetid://159248173",
		Rt = "rbxassetid://159248192",
		Up = "rbxassetid://159248176",
	},
	space = {
		Bk = "rbxassetid://8395777611",
		Dn = "rbxassetid://8395781584",
		Ft = "rbxassetid://8395846919",
		Lf = "rbxassetid://8395802318",
		Rt = "rbxassetid://8395867135",
		Up = "rbxassetid://8395859118",
	},
	nebula = {
		Bk = "rbxassetid://159454299",
		Dn = "rbxassetid://159454296",
		Ft = "rbxassetid://159454293",
		Lf = "rbxassetid://159454286",
		Rt = "rbxassetid://159454300",
		Up = "rbxassetid://159454288",
	},
}
function clearSky()
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("Sky") then
			v:Destroy()
		end
	end
	G.CurrentSky = "none"
end
function setSky(name)
	local data = Skies[name]
	if not data then
		clearSky();
		return
	end
	clearSky()
	local sky = Instance.new("Sky")
	sky.SkyboxBk = data.Bk;
	sky.SkyboxDn = data.Dn;
	sky.SkyboxFt = data.Ft
	sky.SkyboxLf = data.Lf;
	sky.SkyboxRt = data.Rt;
	sky.SkyboxUp = data.Up
	sky.SunAngularSize = 0;
	sky.MoonAngularSize = 0;
	sky.CelestialBodiesShown = false
	sky.Parent = Lighting
	G.CurrentSky = name
end
task.delay(3, function()
	if G.CurrentSky ~= "none" then
		setSky(G.CurrentSky)
	end
end)
function getHRP()
	local c = player.Character
	return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso"))
end
function getModelBounds(model)
	if not model then
		return nil, nil
	end
	local cf, sz
	local ok = pcall(function()
		cf, sz = model:GetBoundingBox()
	end)
	return (ok and cf) or nil, (ok and sz) or nil
end
function respawn(plr)
	local char = player.Character
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Dead)
	end
	char:ClearAllChildren()
	local newChar = Instance.new("Model")
	newChar.Parent = workspace
	plr.Character = newChar
	task.wait()
	plr.Character = char
	newChar:Destroy()
end
function equipcat()
	local char = player.Character
	local hum = char and char:FindFirstChild("Humanoid")
	if not hum then
		return
	end
	local item = player.Backpack:FindFirstChild("Flying Carpet") or char:FindFirstChild("Flying Carpet") or player.Backpack:FindFirstChild("Cupid's Wings") or char:FindFirstChild("Cupid's Wings") or player.Backpack:FindFirstChild("Witch's Broom") or char:FindFirstChild("Witch's Broom")
	if not item then
		return
	end
	hum:EquipTool(item)
end

function equipTool(name)
	local char = player.Character
	if not char then
		return nil
	end
	local tool = char:FindFirstChild(name) or player.Backpack:FindFirstChild(name)
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if tool and hum then
		hum:EquipTool(tool)
		return char:FindFirstChild(name) or tool
	end
	return nil
end
function equipPotion()
	equipTool("Giant Potion")
end
function activateToolByName(name, attempts)
	attempts = attempts or 6
	for _ = 1, attempts do
		local char = player.Character
		local tool = char and char:FindFirstChild(name)
		if tool then
			pcall(function()
				tool:Activate()
			end)
			return true
		end
		equipTool(name)
	end
	return false
end
function drinkPotion()
	if not G.AutoPotion then
		return
	end
	local char = player.Character
	if not ((char and char:FindFirstChild("Giant Potion")) or player.Backpack:FindFirstChild("Giant Potion")) then
		return
	end
	activateToolByName("Giant Potion")
end
function drinkPotion2()
	if not G.AutoPotion2 then
		return
	end
	local char = player.Character
	if not ((char and char:FindFirstChild("Giant Potion")) or player.Backpack:FindFirstChild("Giant Potion")) then
		return
	end
	activateToolByName("Giant Potion")
end
local BASE_POSITIONS = {
	BASE1 = {
		REFERENCE_POS = Vector3.new(- 328, - 7, 157),
		STAND_POS = CFrame.new(- 334.76, - 5.334, 99.40),
		TP_POS = Vector3.new(- 352.98, - 7.30, 74.3),
	},
	BASE2 = {
		REFERENCE_POS = Vector3.new(- 321, - 7, - 31),
		STAND_POS = CFrame.new(- 336.41, - 5.34, 19.20),
		TP_POS = Vector3.new(- 352.98, - 7.30, 45.76),
	},
}
function getPlotOwner(plot)
	local sign = plot:FindFirstChild("PlotSign")
	local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
	local label = frame and frame:FindFirstChild("TextLabel")
	if not label or label.Text == "Empty Base" then
		return nil
	end
	return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
end
function getMyPlots()
	local result, myName = {}, player.DisplayName
	for _, plot in ipairs(plots:GetChildren()) do
		if getPlotOwner(plot) == myName then
			table.insert(result, plot)
		end
	end
	return result
end
function getEnemyPlots()
	local result, myName = {}, player.DisplayName
	for _, plot in ipairs(plots:GetChildren()) do
		local owner = getPlotOwner(plot)
		if owner and owner ~= myName then
			table.insert(result, plot)
		end
	end
	return result
end
function getOwnCashPad()
	local plot = getMyPlots()[1]
	if not plot then
		return nil
	end
	local cashPad = plot:FindFirstChild("CashPad")
	if cashPad and cashPad:IsA("BasePart") then
		return cashPad
	end
	return cashPad and cashPad:FindFirstChildWhichIsA("BasePart") or nil
end
function lookAtOwnCashPad()
	local cashPad = getOwnCashPad()
	if not cashPad then
		return false
	end
	local camPos = Camera.CFrame.Position
	Camera.CFrame = CFrame.lookAt(camPos, cashPad.Position)
	return true
end
function isEnemyTurret(obj)
	if not obj or not obj:IsA("BasePart") then
		return false
	end
	local ownerId = obj.Name:match("^Sentry_(%d+)$")
	return ownerId ~= nil and ownerId ~= tostring(player.UserId)
end
function setTurretNoClip(turret)
	if not isEnemyTurret(turret) then
		return
	end
	pcall(function()
		turret.CanCollide = false
	end)
end
function getTurretTimeLabel(turret)
	if not turret or not turret.Parent then
		return nil
	end
	local setupFrame = turret:FindFirstChild("SetupFrame")
	local mainFrame = setupFrame and setupFrame:FindFirstChild("MainFrame")
	local timeLabel = mainFrame and mainFrame:FindFirstChild("Time")
	if timeLabel and timeLabel:IsA("TextLabel") then
		return timeLabel
	end
	return nil
end
function shouldAttackTurret(turret)
	if player:GetAttribute("Stealing") ~= nil then
		return false
	end
	if not isEnemyTurret(turret) then
		return false
	end
	setTurretNoClip(turret)
	local timeLabel = getTurretTimeLabel(turret)
	if not timeLabel then
		return false
	end
	local ok, text = pcall(function()
		return timeLabel.Text
	end)
	if not ok then
		return false
	end
	text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
	return text ~= "" and string.find(text, "^%d+s!$") ~= nil
end
local turretAttackBusy = setmetatable({}, {
	__mode = "k"
})
local turretAttackQueued = setmetatable({}, {
	__mode = "k"
})
local turretAttackCooldownUntil = setmetatable({}, {
	__mode = "k"
})
local turretAttackActive = false
local TURRET_ATTACK_RETRY_DELAY = 0.3
function bringTurretInFront(turret, hrp)
	if not turret or not hrp then
		return
	end
	local forward = hrp.CFrame.LookVector
	local targetPos = hrp.Position + forward * 4 + Vector3.new(0, 1.2, 0)
	local targetCf = CFrame.lookAt(targetPos, targetPos + forward)
	pcall(function()
		turret.AssemblyLinearVelocity = Vector3.zero
		turret.AssemblyAngularVelocity = Vector3.zero
	end)
	pcall(function()
		turret.CFrame = targetCf
	end)
end
function attackTurret(turret)
	local now = os.clock()
	if turretAttackBusy[turret] or turretAttackQueued[turret] or turretAttackActive or not shouldAttackTurret(turret) then
		return
	end
	if (turretAttackCooldownUntil[turret] or 0) > now then
		return
	end
	turretAttackQueued[turret] = true
	turretAttackCooldownUntil[turret] = now + TURRET_ATTACK_RETRY_DELAY
	task.spawn(function()
		turretAttackQueued[turret] = nil
		if turretAttackActive or turretAttackBusy[turret] or not shouldAttackTurret(turret) then
			return
		end
		turretAttackActive = true
		turretAttackBusy[turret] = true
		local ok, err = xpcall(function()
			local attempts = 0
			while attempts < 12 and G.AutoDestroyTurret do
				if not turret or not turret.Parent or not shouldAttackTurret(turret) then
					break
				end
				local char = player.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not hrp or not hum or hum.Health <= 0 then
					break
				end
				local okDistance, distance = pcall(function()
					return (turret.Position - hrp.Position).Magnitude
				end)
				if okDistance and distance > 220 then
					break
				end
				setTurretNoClip(turret)
				bringTurretInFront(turret, hrp)
				if not turret or not turret.Parent or not shouldAttackTurret(turret) then
					break
				end
				local bat = equipTool("Bat")
				if bat and bat.Parent ~= char then
					pcall(function()
						hum:EquipTool(bat)
					end)
				end
				bat = (player.Character and player.Character:FindFirstChild("Bat")) or bat
				if bat then
					pcall(function()
						bat:Activate()
					end)
				end
				task.wait(0.03)
				if turret and turret.Parent and shouldAttackTurret(turret) then
					setTurretNoClip(turret)
					bringTurretInFront(turret, hrp)
				end
				attempts = attempts + 1
				task.wait(0.09)
			end
		end, debug.traceback)
		turretAttackBusy[turret] = nil
		turretAttackActive = false
		if not ok then
			warn("attackTurret failed:", err)
		end
	end)
end
local antiGummyRespawnGraceUntil = 0
function clearGummyToolBlockState(char)
	local touched = false
	for _, inst in ipairs({
		player,
		char
	}) do
		if inst then
			if inst:GetAttribute("BlockTools") ~= nil and inst:GetAttribute("BlockTools") ~= false then
				inst:SetAttribute("BlockTools", false)
				touched = true
			end
			if inst:GetAttribute("Web") ~= nil and inst:GetAttribute("Web") ~= false then
				inst:SetAttribute("Web", false)
				touched = true
			end
		end
	end
	if char and char:GetAttribute("BackpackReady") == false then
		char:SetAttribute("BackpackReady", true)
		touched = true
	end
	return touched
end
function getMainHudGui()
	local playerGui = player and player:FindFirstChild("PlayerGui")
	return playerGui and playerGui:FindFirstChild("Main")
end
function isPaintballSplatGui(gui)
	if not gui or gui.Parent ~= getMainHudGui() then
		return false
	end
	if not (gui:IsA("ImageLabel") or gui:IsA("ImageButton")) then
		return false
	end
	if gui:GetAttribute("__UGPaintballIgnore") or gui:GetAttribute("__UGPaintballShrunk") then
		return false
	end
	return math.abs(gui.Rotation) > 0.01
end
function shrinkPaintballSplat(gui)
	if not gui or gui:GetAttribute("__UGPaintballShrunk") then
		return
	end
	gui:SetAttribute("__UGPaintballShrunk", true)
	gui.Size = UDim2.fromOffset(6, 6)
end
function runAntiPaintballSweep()
	if not G.AntiPaintball then
		return
	end
	task.spawn(function()
		for _ = 1, 8 do
			local main = getMainHudGui()
			if not main then
				break
			end
			for _, child in ipairs(main:GetChildren()) do
				if isPaintballSplatGui(child) then
					shrinkPaintballSplat(child)
				end
			end
			task.wait(0.05)
		end
	end)
end
local allowToggleCooldown = false
function getFriendPanelImageLabel(plot)
	local panel = plot and plot:FindFirstChild("FriendPanel")
	local main = panel and panel:FindFirstChild("Main")
	local surfaceGui = main and main:FindFirstChild("SurfaceGui")
	return surfaceGui and surfaceGui:FindFirstChild("ImageLabel")
end
function isFriendPanelUnallowed(plot)
	local img = getFriendPanelImageLabel(plot)
	if not img then
		return nil
	end
	return img.Image == "rbxassetid://110783679426495"
end
function isGuiChainVisible(guiObject)
	local current = guiObject
	while current do
		if current:IsA("GuiObject") and not current.Visible then
			return false
		end
		if current:IsA("ScreenGui") or current:IsA("BillboardGui") or current:IsA("SurfaceGui") then
			break
		end
		current = current.Parent
	end
	return true
end
function getFriendPanelPrompt(plot)
	local panel = plot and plot:FindFirstChild("FriendPanel")
	local main = panel and panel:FindFirstChild("Main")
	local prompt = main and main:FindFirstChild("ProximityPrompt")
	if prompt and prompt:IsA("ProximityPrompt") then
		return prompt
	end
	return nil
end
function tryFirePrompt(prompt)
	if not prompt or not prompt:IsA("ProximityPrompt") then
		return false
	end
	if type(fireproximityprompt) ~= "function" then
		return false
	end
	local ok = pcall(fireproximityprompt, prompt)
	return ok
end
function toggleFriendPanelAllow()
	for _, plot in ipairs(getMyPlots()) do
		local prompt = getFriendPanelPrompt(plot)
		if prompt then
			tryFirePrompt(prompt)
		end
	end
end
function getCurrentBase()
	local myPlots = getMyPlots()
	if # myPlots == 0 then
		return "BASE1", BASE_POSITIONS.BASE1
	end
	local plotPos
	local p = myPlots[1]
	if p:FindFirstChild("PlotSign") then
		plotPos = p.PlotSign.Position
	elseif p:FindFirstChild("Origin") then
		plotPos = p.Origin.Position
	else
		local part = p:FindFirstChildWhichIsA("BasePart")
		plotPos = part and part.Position
	end
	if not plotPos then
		return "BASE1", BASE_POSITIONS.BASE1
	end
	local d1 = (plotPos - BASE_POSITIONS.BASE1.REFERENCE_POS).Magnitude
	local d2 = (plotPos - BASE_POSITIONS.BASE2.REFERENCE_POS).Magnitude
	local key = d1 < d2 and "BASE1" or "BASE2"
	return key, BASE_POSITIONS[key]
end
function getPodiumPrompt(podium)
	local spawn = podium:FindFirstChild("Base") and podium.Base:FindFirstChild("Spawn")
	local att = spawn and spawn:FindFirstChild("PromptAttachment")
	local prompt = att and att:FindFirstChildWhichIsA("ProximityPrompt")
	return (prompt and prompt.ActionText == "Steal") and prompt or nil
end
function getPlotBase(plot)
	if not plot then
		return "BASE1", BASE_POSITIONS.BASE1
	end
	local plotPos
	if plot:FindFirstChild("PlotSign") then
		plotPos = plot.PlotSign.Position
	elseif plot:FindFirstChild("Origin") then
		plotPos = plot.Origin.Position
	else
		local part = plot:FindFirstChildWhichIsA("BasePart")
		plotPos = part and part.Position
	end
	if not plotPos then
		return "BASE1", BASE_POSITIONS.BASE1
	end
	local d1 = (plotPos - BASE_POSITIONS.BASE1.REFERENCE_POS).Magnitude
	local d2 = (plotPos - BASE_POSITIONS.BASE2.REFERENCE_POS).Magnitude
	local key = d1 < d2 and "BASE1" or "BASE2"
	return key, BASE_POSITIONS[key]
end
function getStealPromptForSlot(plot, slot)
	local podiums = plot and plot:FindFirstChild("AnimalPodiums")
	local podium = podiums and slot ~= nil and podiums:FindFirstChild(tostring(slot))
	if not podium then
		return nil, nil, nil
	end
	local base = podium:FindFirstChild("Base")
	local prompt = getPodiumPrompt(podium)
	return prompt, base or podium, podium
end
function getClosestPodium()
	local hrp = getHRP()
	if not hrp then
		return nil
	end
	local best, bestDist = nil, math.huge
	for _, plot in ipairs(getEnemyPlots()) do
		local podiums = plot:FindFirstChild("AnimalPodiums")
		if not podiums then
			continue
		end
		for _, num in ipairs({
			"1",
			"10"
		}) do
			local podium = podiums:FindFirstChild(num)
			local claim = podium and podium:FindFirstChild("Claim") and podium.Claim:FindFirstChild("Main")
			local prompt = podium and getPodiumPrompt(podium)
			if claim and prompt then
				local dist = (hrp.Position - claim.Position).Magnitude
				if dist < bestDist then
					bestDist = dist
					best = {
						podiumNumber = tonumber(num),
						plot = plot,
						position = claim.Position,
						prompt = prompt,
						distance = dist
					}
				end
			end
		end
	end
	return best
end
function getClosestTopFloorPodium()
	local hrp = getHRP()
	if not hrp then
		return nil
	end
	local best, bestDist = nil, math.huge
	local _, base = getCurrentBase()
	local topFloorPodiumName = base == BASE_POSITIONS.BASE2 and "11" or "16"
	for _, plot in ipairs(getEnemyPlots()) do
		local podiums = plot:FindFirstChild("AnimalPodiums")
		if not podiums then
			continue
		end
		local podium = podiums:FindFirstChild(topFloorPodiumName)
		local claim = podium and podium:FindFirstChild("Claim") and podium.Claim:FindFirstChild("Main")
		local prompt = podium and getPodiumPrompt(podium)
		if claim and prompt then
			local dist = (hrp.Position - claim.Position).Magnitude
			if dist < bestDist then
				bestDist = dist
				best = {
					podiumNumber = tonumber(topFloorPodiumName),
					plot = plot,
					position = claim.Position,
					prompt = prompt,
					distance = dist
				}
			end
		end
	end
	return best
end
function getClosestSpecificPodium(slotNumber)
	local hrp = getHRP()
	if not hrp then
		return nil
	end
	local slotName = tostring(slotNumber)
	local best, bestDist = nil, math.huge
	for _, plot in ipairs(getEnemyPlots()) do
		local podiums = plot:FindFirstChild("AnimalPodiums")
		if not podiums then
			continue
		end
		local podium = podiums:FindFirstChild(slotName)
		local claim = podium and podium:FindFirstChild("Claim") and podium.Claim:FindFirstChild("Main")
		local prompt = podium and getPodiumPrompt(podium)
		if claim and prompt then
			local dist = (hrp.Position - claim.Position).Magnitude
			if dist < bestDist then
				bestDist = dist
				best = {
					podiumNumber = tonumber(slotName),
					plot = plot,
					position = claim.Position,
					prompt = prompt,
					distance = dist
				}
			end
		end
	end
	return best
end
function getClosestSecondSlotStealPodium()
	local hrp = getHRP()
	if not hrp then
		return nil
	end
	local best, bestDist = nil, math.huge
	for _, plot in ipairs(getEnemyPlots()) do
		local baseKey = select(1, getPlotBase(plot))
		local slotName = (baseKey == "BASE2") and "9" or "2"
		local podiums = plot:FindFirstChild("AnimalPodiums")
		local podium = podiums and podiums:FindFirstChild(slotName)
		local claim = podium and podium:FindFirstChild("Claim") and podium.Claim:FindFirstChild("Main")
		local prompt = podium and getPodiumPrompt(podium)
		if claim and prompt then
			local dist = (hrp.Position - claim.Position).Magnitude
			if dist < bestDist then
				bestDist = dist
				best = {
					podiumNumber = tonumber(slotName),
					plot = plot,
					position = claim.Position,
					prompt = prompt,
					distance = dist,
					baseKey = baseKey
				}
			end
		end
	end
	return best
end
function syncInstantStealSlotFlags()
	local mode = G.InstantStealSlotMode or "First Slot"
	G.InstantStealSlotMode = mode
	G.SecondSlotSteal = (mode == "Second Slot")
	G.AutoFloatThirdFloor = (mode == "Top Floor First Slot")
end
syncInstantStealSlotFlags()
function getClosestPodiumToggled()
	local data = getClosestPodium()
	if not data then
		return nil
	end
	local toggleNum = (data.podiumNumber == 1) and 10 or (data.podiumNumber == 10 and 1 or nil)
	if not toggleNum then
		return data
	end
	local podiums = data.plot:FindFirstChild("AnimalPodiums")
	local alt = podiums and podiums:FindFirstChild(tostring(toggleNum))
	local claim = alt and alt:FindFirstChild("Claim") and alt.Claim:FindFirstChild("Main")
	local prompt = alt and getPodiumPrompt(alt)
	if claim and prompt then
		return {
			podiumNumber = toggleNum,
			plot = data.plot,
			position = claim.Position,
			prompt = prompt,
			distance = (getHRP().Position - claim.Position).Magnitude
		}
	end
	return data
end
function canDirectTp(hrp, targetPos)
	if not hrp or not targetPos then
		return false
	end
	local origin = hrp.Position
	local ignored = {
		player.Character
	}
	for _ = 1, 12 do
		local direction = targetPos - origin
		if direction.Magnitude <= 0.05 then
			return true
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.FilterDescendantsInstances = ignored
		params.IgnoreWater = true
		local result = Workspace:Raycast(origin, direction, params)
		if not result then
			return true
		end
		local hit = result.Instance
		if not hit then
			return true
		end
		if hit:IsA("BasePart") and not hit.CanCollide then
			table.insert(ignored, hit)
			origin = result.Position + direction.Unit * 0.1
		else
			return (result.Position - targetPos).Magnitude <= 3
		end
	end
	return false
end

function tpThroughWaypoints(hrp, waypoints)
	if not hrp or #waypoints == 0 then
		return
	end

	local startIndex, bestD = 1, math.huge
	for i = 1, #waypoints do
		local d = (hrp.Position - waypoints[i]).Magnitude
		if d < bestD then
			bestD = d
			startIndex = i
		end
	end

	for i = startIndex, #waypoints do
		hrp.CFrame = CFrame.new(waypoints[i])
		if i < #waypoints then
			task.wait(0.13)
		end
	end
end
local StealCache = {}
function buildStealCallbacks(prompt)
	if StealCache[prompt] then
		return
	end
	local data = {
		holdCallbacks = {},
		triggerCallbacks = {},
		ready = true
	}
	function harvest(signal, list)
		local ok, conns = pcall(getconnections, signal)
		if ok then
			for _, c in ipairs(conns) do
				if type(c.Function) == "function" then
					table.insert(list, c.Function)
				end
			end
		end
	end
	harvest(prompt.PromptButtonHoldBegan, data.holdCallbacks)
	harvest(prompt.Triggered, data.triggerCallbacks)
	if # data.holdCallbacks > 0 or # data.triggerCallbacks > 0 then
		StealCache[prompt] = data
	end
end
function fireList(list)
	for _, fn in ipairs(list) do
		task.spawn(fn)
	end
end
function getWalkSpeed()
	local char = player.Character
	local isStealing = player:GetAttribute("Stealing") ~= nil
	local isGiantPotion = player:GetAttribute("GiantPotion") ~= nil
	local isHoldingCarpet = char and char:FindFirstChild("Flying Carpet") ~= nil
	if isHoldingCarpet then
		return G.CarpetSpeedValue
	end
	return isGiantPotion and G.GiantSpeedValue or isStealing and G.StealingSpeedValue or G.SpeedValue
end
local walkDirBase1 = (function()
	local cf = CFrame.new( - 336.355286, - 5.10107088, 17.2327671, - 0.999883354, - 2.76150569e-08, 0.0152716246, - 2.88224964e-08, 1, - 7.88441525e-08, - 0.0152716246, - 7.9275118e-08, - 0.999883354)
	return Vector3.new(cf.LookVector.X + cf.RightVector.X * - 0.1, 0, cf.LookVector.Z + cf.RightVector.Z * - 0.1).Unit
end)()
local walkDirBase2 = (function()
	local cf = CFrame.new( - 336.942902, - 5.10106993, 99.3276443, 0.999914348, - 3.63984611e-08, 0.0130875716, 3.67094941e-08, 1, - 2.35254749e-08, - 0.0130875716, 2.40038975e-08, 0.999914348)
	return Vector3.new(cf.LookVector.X + cf.RightVector.X * 0.1, 0, cf.LookVector.Z + cf.RightVector.Z * 0.1).Unit
end)()
local walkConn = nil
function stopAutoWalk()
	if walkConn then
		walkConn:Disconnect();
		walkConn = nil
	end
end
function startAutoWalk(dir)
	stopAutoWalk()
	local d = Vector3.new(dir.X, 0, dir.Z).Unit
	walkConn = connectLoop(function()
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end
		local spd = getWalkSpeed()
		root.Velocity = Vector3.new( d.X * spd, root.Velocity.Y, d.Z * spd)
	end)
end
function doAutoWalk(isBase1)
	task.spawn(function()
		startAutoWalk(isBase1 and walkDirBase1 or walkDirBase2)
		local startedAt = tick()
		while tick() - startedAt < 6 do
			if player:GetAttribute("Stealing") == nil then
				break
			end
			task.wait(0.1)
		end
		stopAutoWalk()
	end)
end
function getNearestEnemy()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then
		return nil
	end
	local nearest, dist = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local d = (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
			if d < dist then
				dist = d;
				nearest = p
			end
		end
	end
	return nearest
end
local autoStealInProgress = false
local function __walkTo(HRP, targetPos, speed, arriveDist, timeout)
	if not HRP or not HRP.Parent or not targetPos then return end
	speed = speed or 180
	arriveDist = arriveDist or 6
	timeout = timeout or 6
	pcall(equipcat)
	local _controls = getControls and getControls() or nil
	if _controls then pcall(function() _controls:Disable() end) end
	local start = tick()
	while HRP and HRP.Parent do
		local d = targetPos - HRP.Position
		local flat = Vector3.new(d.X, 0, d.Z)
		local mag = flat.Magnitude
		if mag < arriveDist then break end
		if tick() - start > timeout then break end
		local effSpeed = speed
		if mag < 25 then effSpeed = math.max(60, speed * (mag / 25)) end
		local dir = flat.Unit
		local vy = HRP.AssemblyLinearVelocity.Y
		HRP.AssemblyLinearVelocity = Vector3.new(dir.X * effSpeed, vy, dir.Z * effSpeed)
		task.wait()
	end
	if HRP and HRP.Parent then
		HRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		HRP.CFrame = CFrame.new(targetPos)
	end
	if _controls then pcall(function() _controls:Enable() end) end
end

function doSemiInstantApproach(hrp, target, isBase1)
	local p1pos = Vector3.new(-337, -5, 103)
	local p2pos = Vector3.new(-337, -5, 20)
	local redDotPos = nil
	if target then
		local d1 = (p1pos - target.position).Magnitude
		local d2 = (p2pos - target.position).Magnitude
		redDotPos = (d1 < d2) and p1pos or p2pos
	end
	local waypoints
	if isBase1 then
		waypoints = {
			Vector3.new(-353, -7, 107),
			Vector3.new(-352, -7, 81),
			Vector3.new(-352, -7, 68),
			Vector3.new(-352, -7, 54),
			Vector3.new(-352, -7, 41),
			Vector3.new(-338, -5, 20),
		}
	else
		waypoints = {
			Vector3.new(-352, -7, 23),
			Vector3.new(-352, -7, 41),
			Vector3.new(-352, -7, 54),
			Vector3.new(-352, -7, 68),
			Vector3.new(-350, -7, 81),
			Vector3.new(-337, -5, 103)
		}
	end
	if __isWalkMethod() then
		local startIndex = 1
		if canDirectTp then
			for i = #waypoints, 1, -1 do
				if canDirectTp(hrp, waypoints[i]) then
					startIndex = i
					break
				end
			end
		end
		for i = startIndex, #waypoints do
			__walkTo(hrp, waypoints[i], 180)
		end
		return
	end
	tpThroughWaypoints(hrp, waypoints)
end
function doTopFloorPodium11Steal(hrp, prompt)
	if not hrp or not prompt then
		return
	end
	local ctx = __startStealHold(prompt)
	if not ctx then return end
	hrp.CFrame = CFrame.new(- 349, - 7, 114)
	task.wait(0.3)
	hrp.CFrame = CFrame.new(- 334, 3, 92)
	__waitForStealTime(ctx, 1.28)
	local att = Instance.new("Attachment")
	att.Parent = hrp
	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = att
	lv.MaxForce = math.huge
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.VectorVelocity = Vector3.new(0, 8, 0)
	lv.Parent = hrp
	task.wait(0.2)
	lv:Destroy()
	att:Destroy()
	lookAtOwnCashPad()
	__finishStealHold(ctx)
	task.wait(0.015)
	hrp.CFrame = CFrame.new(- 345, 4.5, 92)
end
function doTopFloorPodium16Steal(hrp, prompt)
	if not hrp or not prompt then
		return
	end
	local ctx = __startStealHold(prompt)
	if not ctx then return end
	hrp.CFrame = CFrame.new(- 333, 3, 28)
	__waitForStealTime(ctx, 1.28)
	local att = Instance.new("Attachment")
	att.Parent = hrp
	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = att
	lv.MaxForce = math.huge
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.VectorVelocity = Vector3.new(0, 8, 0)
	lv.Parent = hrp
	task.wait(0.2)
	lv:Destroy()
	att:Destroy()
	lookAtOwnCashPad()
	__finishStealHold(ctx)
	task.wait(0.015)
	hrp.CFrame = CFrame.new(-347, 4, 26)
end
function doSecondSlotSteal(char, hum, hrp, target)
	if not char or not hum or not hrp or not target or not target.prompt then
		return
	end
	local prompt = target.prompt
	local baseKey = target.baseKey or select(1, getPlotBase(target.plot))
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = math.huge
	local ctx = __startStealHold(prompt)
	if not ctx then return end
	equipcat()
	local stealPos
	if baseKey == "BASE2" then
		tpThroughWaypoints(hrp, {
			Vector3.new(-353, -7, 107),
			Vector3.new(-352, -7, 81),
			Vector3.new(-352, -7, 68),
			Vector3.new(-352, -7, 54),
			Vector3.new(-352, -7, 41),
			Vector3.new(-338, -5, 20),
		})
		task.wait(0.25)
		stealPos = Vector3.new(-350.48486328125, -7.3017988204956055, 34.883060455322266)
	else
		tpThroughWaypoints(hrp, {
			Vector3.new(-352, -7, 23),
			Vector3.new(-352, -7, 41),
			Vector3.new(-352, -7, 54),
			Vector3.new(-352, -7, 68),
			Vector3.new(-350, -7, 81),
		})
		task.wait(0.25)
		stealPos = Vector3.new(-351.856, -7.302, 88.026)
	end
	__waitForStealTime(ctx, 1.48)
	hrp.CFrame = CFrame.new(stealPos)
	__finishStealHold(ctx)
	lookAtOwnCashPad()
end
function doSemiInstantSteal()
	stopAutoWalk()
	syncInstantStealSlotFlags()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	autoStealInProgress = true
	local wasAutoStealBest = G.AutoStealBest
	local wasAutoStealNearest = G.AutoStealNearest
	local wasAutoStealPriority = G.AutoStealPriority
	G.AutoStealBest = false
	G.AutoStealNearest = false
	G.AutoStealPriority = false
	local _, base = getCurrentBase()
	local isBase1 = base == BASE_POSITIONS.BASE1
	local target = G.SecondSlotSteal and getClosestSecondSlotStealPodium() or G.AutoFloatThirdFloor and getClosestTopFloorPodium() or getClosestPodium()
	local wasSpeed = G.Speed
	G.Speed = false
	local hum = char:FindFirstChild("Humanoid")
	equipcat()
	task.spawn(function()
		local p1pos = Vector3.new(-337, - 5, 103)
		local p2pos = Vector3.new(-337, - 5, 20)
		local g1pos = Vector3.new(-348, -7, 82)
		local g2pos = Vector3.new(-349.43, -6.78, 37.47)
		if G.SecondSlotSteal then
			doSecondSlotSteal(char, hum, hrp, target)
		elseif target and target.prompt and target.prompt.Parent and G.AutoFloatThirdFloor and target.podiumNumber == 11 then
			doTopFloorPodium11Steal(hrp, target.prompt)
		elseif target and target.prompt and target.prompt.Parent and G.AutoFloatThirdFloor and target.podiumNumber == 16 then
			doTopFloorPodium16Steal(hrp, target.prompt)
		elseif __isPrimeMethod() and target and target.prompt and target.prompt.Parent then
			-- Prime method: hardcoded CFrame sequence ported from faded.lua
			local prompt = target.prompt
			prompt.RequiresLineOfSight   = false
			prompt.MaxActivationDistance = math.huge
			equipcat()
			hrp.CFrame = isBase1 and CFrame.new(-343.08, -6.84, 93.20) or CFrame.new(-342.91, -6.81, 28.00)
			task.wait(0.25)
			hrp.CFrame = isBase1 and CFrame.new(-340.16, -7.29, 48.82) or CFrame.new(-340.16, -7.29, 72.40)
			task.wait(0.12)
			hrp.CFrame = isBase1 and CFrame.new(-341.26, -7.29, 66.95) or CFrame.new(-341.26, -7.29, 54.27)
			task.wait(0.12)
			hrp.CFrame = isBase1 and CFrame.new(-339.93, -7.29, 82.14) or CFrame.new(-339.63, -7.29, 39.33)
			task.wait(0.18)
			local ctx = __startStealHold(prompt)
			hrp.CFrame = isBase1 and CFrame.new(-354.04, -7.21, 90.42) or CFrame.new(-354.04, -7.21, 28.00)
			task.wait(0.45)
			hrp.CFrame = isBase1 and CFrame.new(-334.60, -5.00, 101.30) or CFrame.new(-334.60, -5.00, 19.30)
			if ctx and ctx.holdBeganAt then
				while tick() - ctx.holdBeganAt < __MIN_HOLD_TIME do task.wait() end
			end
			drinkPotion()
			equipcat()
			hrp.CFrame = isBase1 and CFrame.new(-351.53, -7.29, 83.66) or CFrame.new(-350.62, -7.29, 35.91)
			if ctx then __finishStealHold(ctx) end
			lookAtOwnCashPad()
		else
			local ctx
			if target and target.prompt and target.prompt.Parent then
				target.prompt.RequiresLineOfSight = false
				target.prompt.MaxActivationDistance = math.huge
				ctx = __startStealHold(target.prompt)
			end
			doSemiInstantApproach(hrp, target, isBase1)
			drinkPotion()
			equipcat()
			if ctx and target then
				local d1 = (p1pos - target.position).Magnitude
				local d2 = (p2pos - target.position).Magnitude
				local greenDotPos = (d1 < d2) and g1pos or g2pos
				__waitForStealTime(ctx, 1.48)
				hrp.CFrame = CFrame.new(greenDotPos)
				__finishStealHold(ctx)
				lookAtOwnCashPad()
			end
		end
		G.Speed = wasSpeed
		local startTime = tick()
		while player:GetAttribute("Stealing") == nil do
			if tick() - startTime >= 1 then
				break
			end
			task.wait(0.1)
		end
		if player:GetAttribute("Stealing") ~= nil then
			if G.AutoWalkAfterSteal then
				stopAutoWalk()
				task.wait()
				doAutoWalk(isBase1)
			end
			if G.AutoSpamAfterSteal then
				task.spawn(function()
					local enemy = getNearestEnemy()
					if enemy and adminRemoteReady and adminRemote then
						pcall(function()
							for _, cmd in ipairs(G.StealSpamCmds) do
								task.spawn(function()
									adminRemote:InvokeServer(RF_PLOT_KEY, enemy, cmd)
								end)
							end
						end)
					end
				end)
			end
		end
		G.AutoPotion2 = wasAutoPotion2
		autoStealInProgress = false
	end)
end
task.spawn(function()
	local lastFired, cooldown = 0, 10
	while task.wait(0.01) do
		if not G.AutoStealOnTimerEnd or not G.SetupDesync then
			continue
		end
		if tick() - lastFired < cooldown then
			continue
		end
		for _, plot in ipairs(getEnemyPlots()) do
			local purchases = plot:FindFirstChild("Purchases")
			if not purchases then
				continue
			end
			for _, child in ipairs(purchases:GetChildren()) do
				if child:IsA("Model") then
					local board = child:FindFirstChild("Main") and child.Main:FindFirstChild("BillboardGui")
					local label = board and board:FindFirstChild("RemainingTime")
					if label and label.ContentText == "0s" then
						lastFired = tick()
						triggerConfiguredSemiInstant()
						break
					end
				end
			end
		end
	end
end)
local FI = {
	posA = nil,
	posB = nil,
	beamA = nil,
	partA = nil,
	beamB = nil,
	partB = nil,
	currentBase = nil,
	targets = {
		Vector3.new(- 481.88, - 3.79, 138.02),
		Vector3.new(- 481.75, - 3.79, 89.18),
		Vector3.new(- 481.82, - 3.79, 30.95),
		Vector3.new(- 481.75, - 3.79, - 17.79),
		Vector3.new(- 481.80, - 3.79, - 76.06),
		Vector3.new(- 481.72, - 3.79, - 124.70),
		Vector3.new(- 337.45, - 3.85, - 124.72),
		Vector3.new(- 337.37, - 3.85, - 76.07),
		Vector3.new(- 337.46, - 3.79, - 17.72),
		Vector3.new(- 337.41, - 3.79, 30.92),
		Vector3.new(- 337.32, - 3.79, 89.02),
		Vector3.new(- 337.27, - 3.79, 137.90),
		Vector3.new(- 337.45, - 3.79, 196.29),
		Vector3.new(- 337.37, - 3.79, 244.91),
		Vector3.new(- 481.72, - 3.79, 196.21),
		Vector3.new(- 481.76, - 3.79, 244.92),
	},
	bases = {
		Base1 = {
			Vector3.new(- 335.65, - 5.40, - 10.99),
			Vector3.new(- 336.05, - 5.34, 18.08)
		},
		Base2 = {
			Vector3.new(- 335.41, - 5.40, 102.42),
			Vector3.new(- 334.89, - 5.40, 125.81)
		},
	},
}
function fiMakeBeam(targetPos, slot)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local anchor = Instance.new("Part")
	anchor.Anchored = true;
	anchor.CanCollide = false;
	anchor.Transparency = 1
	anchor.CFrame = CFrame.new(targetPos);
	anchor.Parent = Workspace
	local att0 = Instance.new("Attachment", anchor)
	local att1 = Instance.new("Attachment", root)
	local beam = Instance.new("Beam")
	beam.Attachment0 = att0;
	beam.Attachment1 = att1
	beam.Width0 = 0.65;
	beam.Width1 = 0.65;
	beam.FaceCamera = true;
	beam.LightEmission = 0.95
	beam.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226)),
	}
	beam.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(0.5, 0.1),
		NumberSequenceKeypoint.new(1, 0.35),
	}
	beam.Parent = Workspace
	if slot == 1 then
		if FI.beamA then
			FI.beamA:Destroy()
		end
		if FI.partA then
			FI.partA:Destroy()
		end
		FI.beamA, FI.partA = beam, anchor
	else
		if FI.beamB then
			FI.beamB:Destroy()
		end
		if FI.partB then
			FI.partB:Destroy()
		end
		FI.beamB, FI.partB = beam, anchor
	end
end
task.spawn(function()
	while task.wait(0.4) do
		FI.currentBase = nil
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not root then
			continue
		end
		for name, spots in pairs(FI.bases) do
			for _, spot in ipairs(spots) do
				if (root.Position - spot).Magnitude <= 5 then
					FI.currentBase = name;
					break
				end
			end
			if FI.currentBase then
				break
			end
		end
	end
end)
task.spawn(function()
	while task.wait(0.02) do
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not root then
			continue
		end
		local best, bestDist = nil, math.huge
		for _, p in ipairs(FI.targets) do
			if FI.currentBase == "Base1" and p.Z > 60 then
				continue
			end
			if FI.currentBase == "Base2" and p.Z < 60 then
				continue
			end
			local d = (root.Position - p).Magnitude
			if d < bestDist then
				bestDist = d;
				best = p
			end
		end
		if best then
			FI.posB = CFrame.new(best)
			fiMakeBeam(best, 2)
		end
	end
end)
function getCurrentStealCandidate()
	local target
	if selectedBrainrot and selectedBrainrot.prompt and cachedByPrompt[selectedBrainrot.prompt] then
		target = cachedByPrompt[selectedBrainrot.prompt]
	end
	if not target and G.AutoStealPriority then
		target = getNearestPriorityBrainrot()
	end
	return target or (G.AutoStealBest and getBestBrainrot() or getNearestBrainrot())
end
function isFullInstantMode()
	return false
end
function triggerConfiguredSemiInstant()
	FI.posA = getAutoFIWaypoint()
	if FI.posA then
		fiMakeBeam(FI.posA.Position, 1)
	end
	doSemiInstantSteal()
end
do
	local autoSemiRespawnToken = 0
	local function hasRespawnTools(char)
		if char and char:FindFirstChildWhichIsA("Tool") then
			return true
		end
		local backpack = player:FindFirstChild("Backpack")
		return backpack and backpack:FindFirstChildWhichIsA("Tool") ~= nil
	end
	player.CharacterAdded:Connect(function(char)
		autoSemiRespawnToken = autoSemiRespawnToken + 1
		stopAutoWalk()
		local token = autoSemiRespawnToken
		task.spawn(function()
			if not G.AutoInstantStealOnRespawn then
				return
			end
			local hum = char and char:WaitForChild("Humanoid", 8)
			local hrp = char and char:WaitForChild("HumanoidRootPart", 8)
			if token ~= autoSemiRespawnToken or not G.AutoInstantStealOnRespawn then
				return
			end
			if not hum or not hrp or hum.Health <= 0 then
				return
			end
			local startedWaiting = tick()
			while token == autoSemiRespawnToken and G.AutoInstantStealOnRespawn and hum.Health > 0 and not hasRespawnTools(char) do
				if tick() - startedWaiting >= 8 then
					return
				end
				task.wait(0.3)
			end
			if token ~= autoSemiRespawnToken or not G.AutoInstantStealOnRespawn then
				return
			end
			if autoStealInProgress or player:GetAttribute("Stealing") ~= nil then
				return
			end
			triggerConfiguredSemiInstant()
		end)
	end)
end
ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt, sender)
	if sender ~= player then
		return
	end
	if prompt.ActionText ~= "Steal" and prompt.Name ~= "Steal" then
		return
	end
	if G.Instantsteal then
		task.spawn(function()
			if FI.posA then
				player.Character.HumanoidRootPart.CFrame = FI.posA
				task.wait(0.09)
			end
			if FI.posB then
				setfpscap(1)
				player.Character.HumanoidRootPart.CFrame = FI.posB
				setfpscap(9999)
			end
		end)
	end
end)

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, inputPlayer)
    if inputPlayer ~= player then 
        return 
    end

	if G.AutoPotion2 then
        drinkPotion2()
    end
end)

function applyAntiLag()
	local descendants = game:GetDescendants()
	for i, v in ipairs(descendants) do
		if not v.Parent then
			continue
		end
		if v:IsA("AnimationTrack") then
			pcall(function()
				v:Stop()
			end)
		elseif v:IsA("Animator") then
			pcall(function()
				for _, t in ipairs(v:GetPlayingAnimationTracks()) do
					t:Stop();
					t:Destroy()
				end
			end)
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Beam") then
			pcall(function()
				v:Destroy()
			end)
		elseif v:IsA("Texture") or v:IsA("Decal") then
			pcall(function()
				v:Destroy()
			end)
		elseif v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
			pcall(function()
				v:Destroy()
			end)
		elseif v:IsA("SelectionBox") then
			pcall(function()
				v:Destroy()
			end)
		elseif v:IsA("BasePart") then
			pcall(function()
				v.CastShadow = false
				if v.Transparency >= 0.9 then
					v.Transparency = 1
				end
				if v:IsA("MeshPart") then
					v.RenderFidelity = Enum.RenderFidelity.Automatic
				end
			end)
		elseif v:IsA("SpecialMesh") then
			pcall(function()
				v.LODFactor = 0
			end)
		end
		if i % 200 == 0 then
			task.wait()
		end
	end
	Lighting.GlobalShadows = false
	Lighting.FogStart = 9e9;
	Lighting.FogEnd = 9e9
	Lighting.Brightness = 1
	Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
	Lighting.ClockTime = 14
	Lighting.GeographicLatitude = 0
	for _, e in ipairs(Lighting:GetDescendants()) do
		if e:IsA("PostEffect") or e:IsA("Atmosphere") then
			pcall(function()
				e:Destroy()
			end)
		elseif e:IsA("Sky") and G.CurrentSky == "none" then
			pcall(function()
				e:Destroy()
			end)
		end
	end
	pcall(function()
		Workspace.PhysicsSteppingMethod = Enum.PhysicsSteppingMethod.Fixed
	end)
	pcall(function()
		Workspace.InterpolationThrottling = Enum.InterpolationThrottlingMode.Disabled
	end)
	game:GetService("SoundService").AmbientReverb = Enum.ReverbType.NoReverb
	game:GetService("SoundService").DistanceFactor = 9e9
	local destroying = {}
	Workspace.DescendantAdded:Connect(function(v)
		if destroying[v] then
			return
		end
		destroying[v] = true
		if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Beam") or v:IsA("Texture") or v:IsA("Decal") or v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
			pcall(function()
				v:Destroy()
			end)
		elseif v:IsA("BasePart") then
			pcall(function()
				v.CastShadow = false
				if v.Transparency >= 0.9 then
					v.Transparency = 1
				end
				if v:IsA("MeshPart") then
					v.RenderFidelity = Enum.RenderFidelity.Automatic
				end
			end)
		end
		if v.Name:match("%d+_Clone") then
			task.delay(0.1, function()
				if not v.Parent then
					return
				end
				for _, c in ipairs(v:GetChildren()) do
					pcall(function()
						c:Destroy()
					end)
				end
				destroying[v] = nil
			end)
		else
			destroying[v] = nil
		end
	end)
	if G.CurrentSky ~= "none" then
		task.defer(function()
			setSky(G.CurrentSky)
		end)
	end
end
task.spawn(function()
	local wasEnabled = false
	while task.wait(0.5) do
		if G.AntiLagEnabled and not wasEnabled then
			applyAntiLag()
		end
		wasEnabled = G.AntiLagEnabled
	end
end)
local commandCache = {}
local profileCache = {}
local selectedTargets = {}
function getAdminPanel()
	local ap = player.PlayerGui:FindFirstChild("AdminPanel")
	if not ap then
		return nil, nil
	end
	local panel = ap:FindFirstChild("AdminPanel")
	if not panel then
		return nil, nil
	end
	local content = panel:FindFirstChild("Content")
	local profiles = panel:FindFirstChild("Profiles")
	if not content or not profiles then
		return nil, nil
	end
	return content:FindFirstChild("ScrollingFrame"), profiles:FindFirstChild("ScrollingFrame")
end
function harvestActivated(guiObject)
	local fns = {}
	local ok, conns = pcall(getconnections, guiObject.Activated)
	if ok then
		for _, c in ipairs(conns) do
			if type(c.Function) == "function" then
				table.insert(fns, c.Function)
			end
		end
	end
	return fns
end
function buildAdminCache(targetPlayer)
	local cmdFrame, profileFrame = getAdminPanel()
	if not cmdFrame or not profileFrame then
		return false
	end
	local profileBtn = profileFrame:FindFirstChild(targetPlayer.Name)
	if not profileBtn then
		return false
	end
	if not profileCache[targetPlayer.Name] then
		profileCache[targetPlayer.Name] = harvestActivated(profileBtn)
	end
	for _, cmd in ipairs(ALL_COMMANDS) do
		if not commandCache[cmd] then
			local btn = cmdFrame:FindFirstChild(cmd)
			if btn then
				commandCache[cmd] = harvestActivated(btn)
			end
		end
	end
	return true
end
function invalidateCache(name)
	profileCache[name] = nil
end
local lastBalloonTime = 0
local BALLOON_COOLDOWN = 30
local switch = false
function stampBalloon(cmds)
	for _, c in ipairs(cmds) do
		if c == "balloon" then
			lastBalloonTime = tick();
			break
		end
	end
end
function executeAdminCommands(targetPlayer, cmds)
	if adminRemoteReady and adminRemote then
		for _, cmd in ipairs(cmds) do
			task.spawn(function()
				pcall(function()
					adminRemote:InvokeServer(RF_PLOT_KEY, targetPlayer, cmd)
				end)
			end)
		end
		stampBalloon(cmds)
		return true
	end
	if not profileCache[targetPlayer.Name] or # profileCache[targetPlayer.Name] == 0 then
		if not buildAdminCache(targetPlayer) then
			return false
		end
	end
	local profile = profileCache[targetPlayer.Name]
	for _, cmd in ipairs(cmds) do
		local fns = commandCache[cmd]
		if fns and # fns > 0 then
			for _, fn in ipairs(fns) do
				task.spawn(fn)
			end
			for _, fn in ipairs(profile) do
				task.spawn(fn)
			end
		end
	end
	stampBalloon(cmds)
	return true
end
function updateSelectedTargets()
	local myPlot = getMyPlots()[1]
	if not myPlot then
		selectedTargets = {};
		return
	end
	local myHRP = getHRP()
	local ranked = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == player then
			continue
		end
		local char = plr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			continue
		end
		local plotRoot = myPlot.PrimaryPart
		if not plotRoot then
			for _, c in ipairs(myPlot:GetChildren()) do
				if c:IsA("BasePart") then
					plotRoot = c;
					break
				end
			end
		end
		if not plotRoot then
			continue
		end
		local dist = (hrp.Position - plotRoot.Position).Magnitude
		table.insert(ranked, {
			plr = plr,
			dist = dist
		})
	end
	table.sort(ranked, function(a, b)
		return a.dist < b.dist
	end)
	local newTargets = {}
	for i = 1, math.min(2, # ranked) do
		table.insert(newTargets, ranked[i].plr)
	end
	for _, plr in ipairs(newTargets) do
		local found = false
		for _, t in ipairs(selectedTargets) do
			if t == plr then
				found = true;
				break
			end
		end
		if not found then
			task.spawn(buildAdminCache, plr)
		end
	end
	for _, plr in ipairs(selectedTargets) do
		local found = false
		for _, t in ipairs(newTargets) do
			if t == plr then
				found = true;
				break
			end
		end
		if not found then
			invalidateCache(plr.Name)
		end
	end
	selectedTargets = newTargets
end
function getAPSpamTargets()
	updateSelectedTargets()
	local valid = {}
	for _, plr in ipairs(selectedTargets) do
		if plr and plr.Parent == Players and plr ~= player then
			table.insert(valid, plr)
		end
	end
	if # valid > 0 then
		return valid
	end
	local myHRP = getHRP()
	if not myHRP then
		return {}
	end
	local ranked = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChild("Humanoid")
			if hrp and hum and hum.Health > 0 then
				table.insert(ranked, {
					plr = plr,
					dist = (hrp.Position - myHRP.Position).Magnitude,
				})
			end
		end
	end
	table.sort(ranked, function(a, b)
		return a.dist < b.dist
	end)
	for i = 1, math.min(2, # ranked) do
		table.insert(valid, ranked[i].plr)
	end
	return valid
end
function getDefenseTargets()
	local myPlot = getMyPlots()[1]
	if not myPlot then
		return {}
	end
	local ranked = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChild("Humanoid")
			if hrp and hum and hum.Health > 0 then
				local bestDist = math.huge
				for _, obj in ipairs(myPlot:GetChildren()) do
					if obj:IsA("Model") then
						local root = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
						if root then
							local dist = (hrp.Position - root.Position).Magnitude
							if dist < bestDist then
								bestDist = dist
							end
						end
					elseif obj:IsA("BasePart") then
						local dist = (hrp.Position - obj.Position).Magnitude
						if dist < bestDist then
							bestDist = dist
						end
					end
				end
				if bestDist <= 12 then
					table.insert(ranked, {
						plr = plr,
						dist = bestDist
					})
				end
			end
		end
	end
	table.sort(ranked, function(a, b)
		return a.dist < b.dist
	end)
	local out = {}
	for i = 1, math.min(2, # ranked) do
		table.insert(out, ranked[i].plr)
	end
	return out
end
task.spawn(function()
	while task.wait(0.5) do
		updateSelectedTargets()
	end
end)
local stealingDetected = false
local shouldBlockDetected = false
local lastExecuteTime = 0
local executeCooldown = 0.1
local defenseLastExecuteTime = 0
local defenseExecuteCooldown = 0.1
task.spawn(function()
	while task.wait(0.6) do
		local elapsed = tick() - lastBalloonTime
		if elapsed >= BALLOON_COOLDOWN then
			switch = false
		else
			switch = true
		end
	end
end)
local tpLastPos = {}
local tpLastTime = {}
local tpCharTracker = {}
local tpCooldown = {}
function initTpTracking(plr)
	if plr == player then
		return
	end
	if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
		local uid = plr.UserId
		tpLastPos[uid] = plr.Character.HumanoidRootPart.Position
		tpLastTime[uid] = tick()
		tpCharTracker[uid] = plr.Character
	end
end
for _, plr in ipairs(Players:GetPlayers()) do
	initTpTracking(plr)
end
task.spawn(function()
	while task.wait() do
		if not G.TPProtector then
			continue
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == player then
				continue
			end
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChild("Humanoid")
			if not hrp or not hum or hum.Health <= 0 then
				continue
			end
			local uid = plr.UserId
			local cur = hrp.Position
			local now = tick()
			if tpCharTracker[uid] ~= char then
				tpCharTracker[uid] = char
				tpLastPos[uid] = cur
				tpLastTime[uid] = now
				continue
			end
			local lastP = tpLastPos[uid]
			local lastT = tpLastTime[uid]
			if lastP and lastT then
				local dt = now - lastT
				local dist = (cur - lastP).Magnitude
				local speed = dt > 0 and (dist / dt) or 0
				if dt > 0 and (dist > 25 or speed > 400) then
					local hasFlyTool = false
					for _, item in ipairs(char:GetChildren()) do
						if item.Name == "Flying Carpet" or item.Name == "Witch's Broom" or item.Name == "Santa's Sleigh" then
							hasFlyTool = true;
							break
						end
					end
					if hasFlyTool and (not tpCooldown[uid] or now - tpCooldown[uid] > 3) then
						tpCooldown[uid] = now
						task.spawn(function()
							executeAdminCommands(plr, G.TpProtCmds)
						end)
					end
				end
			end
			tpLastPos[uid] = cur
			tpLastTime[uid] = now
		end
	end
end)
task.spawn(function()
	while task.wait() do
		local valid = getDefenseTargets()
		local shouldExec = (G.AutoDefense or G.AntiTPScam) and # valid > 0 and (stealingDetected or shouldBlockDetected)
		if not shouldExec then
			stealingDetected = false
			shouldBlockDetected = false
			continue
		end
		defenseDebug("Execute check", "targets", # valid, "switch", switch, "stealing", stealingDetected, "block", shouldBlockDetected)
		stealingDetected = false
		shouldBlockDetected = false
		if tick() - defenseLastExecuteTime <= defenseExecuteCooldown then
			continue
		end
		if # valid == 1 then
			if not switch then
				defenseDebug("Sending DefCmds1", valid[1] and valid[1].Name or "nil")
				executeAdminCommands(valid[1], G.DefCmds1)
			else
				defenseDebug("Sending DefCmds2", valid[1] and valid[1].Name or "nil")
				executeAdminCommands(valid[1], G.DefCmds2)
				if G.SafteyKick or G.KickNoCmds then
					task.wait(0.25)
					player:Kick("Safety Kick: Out of commands")
				end
			end
		else
			defenseDebug("Sending multi defense", valid[1] and valid[1].Name or "nil", valid[2] and valid[2].Name or "nil")
			executeAdminCommands(valid[1], G.DefCmdsMulti1)
			executeAdminCommands(valid[2], G.DefCmdsMulti2)
		end
		defenseLastExecuteTime = tick()
	end
end)
task.spawn(function()
	while task.wait() do
		if not G.AntiTPScam then
			task.wait(1);
			continue
		end
		local myPlot = getMyPlots()[1]
		if not myPlot then
			continue
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == player then
				continue
			end
			if plr and plr.Parent == Players and plr.Character then
				local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					for _, obj in ipairs(myPlot:GetChildren()) do
						if obj:IsA("Model") then
							local root = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
							if root and (hrp.Position - root.Position).Magnitude < 9 then
								stealingDetected = true
								defenseDebug("Distance trigger", plr.Name, "near", obj.Name)
								break
							end
						end
					end
				end
			end
		end
	end
end)
local vim = Instance.new("VirtualInputManager")
function instantBlockPlayer()
	Character = player.Character or player.CharacterAdded:Wait()
	Root = Character:WaitForChild("HumanoidRootPart")
	local closest, dist = nil, math.huge
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local d = (Root.Position - p.Character.HumanoidRootPart.Position).Magnitude
			if d < dist then
				dist = d;
				closest = p
			end
		end
	end
	if not closest then
		return
	end
	pcall(function()
		StarterGui:SetCore("PromptBlockPlayer", closest)
	end)
	local btn = nil
	local elapsed = 0
	while not btn and elapsed < 2 do
		task.wait(0.05)
		elapsed += 0.05
		for _, v in ipairs(CoreGui:GetDescendants()) do
			if v:IsA("TextButton") and v.Visible and v.AbsolutePosition ~= Vector2.zero and v.Text ~= "" then
				btn = v
				break
			end
		end
	end
	if btn then
		local pos = btn.AbsolutePosition + btn.AbsoluteSize / 2
		vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
		task.wait(0.02)
		vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
	end
end
function tpandblock()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	_G.__tpblock_ballooned = false
	G.AutoStealBest = false
	G.AutoStealNearest = false
	local _, base = getCurrentBase()
	local isBase1 = base == BASE_POSITIONS.BASE1
	local target = getClosestPodium()
	equipcat()
	task.spawn(function()
		local finalPos = isBase1 and Vector3.new(- 335, - 5, 20) or Vector3.new(- 337, - 5, 100)
		if (hrp.Position - finalPos).Magnitude >= 55 then
			if isBase1 then
				hrp.CFrame = CFrame.new(- 351.49, - 3, 113.72);
				task.wait(0.135)
				hrp.CFrame = CFrame.new(- 352.54, - 3, 6.66);
				task.wait(0.135)
			else
				hrp.CFrame = CFrame.new(- 352.54, - 3, 6.66);
				task.wait(0.135)
				hrp.CFrame = CFrame.new(- 351.49, - 3, 113.72);
				task.wait(0.135)
			end
		end
		for i = 1, 3 do
			hrp.CFrame = CFrame.new(finalPos)
			task.wait(0.03)
		end
		task.wait(0.50)
		if _G.__tpblock_ballooned then
			_G.__tpblock_ballooned = false
			return
		end
		instantBlockPlayer()
		task.wait(ping / 250)
		firePatchedSteal(target.prompt)
	end)
end
local autoblockCooldown = false
task.spawn(function()
	local holdingTime = 0
	while task.wait(0.1) do
		if not G.Autoblock or autoblockCooldown then
			holdingTime = 0
			continue
		end
		if player:GetAttribute("Stealing") == nil then
			holdingTime = 0
			continue
		end
		holdingTime = holdingTime + 0.1
		if holdingTime >= 0.3 then
			holdingTime = 0
			autoblockCooldown = true
			instantBlockPlayer()
			task.delay(2, function()
				autoblockCooldown = false
			end)
		end
	end
end)
local IGNORED_PLOT_CHILDREN = {
	AnimalPodiums = true,
	Decorations = true,
	InvisibleWalls = true,
	Laser = true,
	LaserHitbox = true,
	Purchases = true,
	Skin = true,
	Unlock = true,
	CashPad = true,
	FriendPanel = true,
	AnimalTarget = true,
	DeliveryHitbox = true,
	MainRoot = true,
	Multiplier = true,
	PlotSign = true,
	Slope = true,
	Spawn = true,
	StealHitbox = true,
	Model = true,
}
function findPromptForBrainrot(brainrotModel, plot)
	local cache = plot and plotAnimalSync and plotAnimalSync.caches[plot.Name]
	local animalList = cache and cache.AnimalList
	if typeof(animalList) == "table" then
		for slot, data in pairs(animalList) do
			if typeof(data) == "table" then
				local modelRef = rawget(data, "Model")
				local instanceRef = rawget(data, "Instance")
				if modelRef == brainrotModel or instanceRef == brainrotModel then
					local prompt, base = getStealPromptForSlot(plot, slot)
					if prompt then
						return prompt, base
					end
				end
			end
		end
	end
	local podiums = plot:FindFirstChild("AnimalPodiums")
	if not podiums then
		return nil, nil
	end
	local bPos = brainrotModel:GetPivot().Position
	local matches = {}
	for _, podium in ipairs(podiums:GetChildren()) do
		local base = podium:FindFirstChild("Base")
		if base then
			local pPos = base.WorldPivot.Position
			local hDist = math.sqrt((bPos.X - pPos.X) ^ 2 + (bPos.Z - pPos.Z) ^ 2)
			local yDist = bPos.Y - pPos.Y
			if hDist <= 6 and yDist >= - 3 and yDist <= 13 then
				table.insert(matches, {
					base = base,
					yPos = pPos.Y,
					yDist = yDist,
					hDist = hDist,
					podium = podium,
				})
			end
		end
	end
	if # matches == 0 then
		return nil, nil
	end
	table.sort(matches, function(a, b)
		local aAbove, bAbove = a.yDist >= 0, b.yDist >= 0
		if aAbove ~= bAbove then
			return aAbove
		end
		if math.abs(a.hDist - b.hDist) > 0.5 then
			return a.hDist < b.hDist
		end
		return a.yPos > b.yPos
	end)
	local bestMatch = matches[1]
	local spawn = bestMatch.base:FindFirstChild("Spawn")
	local att = spawn and spawn:FindFirstChild("PromptAttachment")
	local prompt = att and att:FindFirstChildWhichIsA("ProximityPrompt")
	if prompt and prompt.ActionText == "Steal" then
		return prompt, bestMatch.base
	end
	return nil, bestMatch.base
end
function parseGenNum(text)
	local num = tonumber(text:match("%d+%.?%d*")) or 0
	if text:find("[Kk]") then
		num = num * 1e3
	elseif text:find("[Mm]") then
		num = num * 1e6
	elseif text:find("[Bb]") then
		num = num * 1e9
	end
	return num
end
function getPodiumWorldPart(animal)
	if not animal then
		return nil
	end
	if animal.base and animal.base.Parent then
		return animal.base
	end
	if animal.prompt and animal.prompt.Parent then
		local current = animal.prompt.Parent
		if current:IsA("Attachment") then
			current = current.Parent
		end
		if current and current.Parent then
			return current
		end
	end
	if animal.model and animal.model.Parent then
		return animal.model
	end
	return nil
end
local plotAnimalSync = {
	caches = {},
	connections = {},
}
function splitSyncPath(path)
	if typeof(path) == "table" then
		return path
	end
	local out = {}
	for part in string.gmatch(tostring(path), "[^%.]+") do
		table.insert(out, tonumber(part) or part)
	end
	return out
end
function resolveSyncPath(path, root)
	local current = root
	local parent = nil
	local key = nil
	for _, part in ipairs(splitSyncPath(path)) do
		parent = current
		key = part
		current = current and current[part] or nil
	end
	return current, parent, key
end
function applyPlotSyncDiff(channelName, packet)
	local cache = plotAnimalSync.caches[channelName]
	if typeof(cache) ~= "table" then
		return
	end
	local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
	local current, parent, key = resolveSyncPath(path, cache)
	if action == "Changed" then
		if parent ~= nil then
			parent[key] = a
		end
	elseif action == "ArrayInsert" then
		if current ~= nil then
			table.insert(current, b, a)
		end
	elseif action == "ArrayRemoved" then
		if current ~= nil then
			table.remove(current, b)
		end
	elseif action == "DictionaryInsert" then
		if current ~= nil then
			current[b] = a
		end
	elseif action == "DictionaryRemoved" then
		if current ~= nil then
			current[b] = nil
		end
	end
end
function attachPlotChannel(remote)
	if plotAnimalSync.connections[remote] then
		return
	end
	local channelName = tostring(remote.Name)
	if not plots:FindFirstChild(channelName) then
		return
	end
	if syncRemotes.requestData and plotAnimalSync.caches[channelName] == nil then
		local ok, data = pcall(function()
			return syncRemotes.requestData:InvokeServer(channelName)
		end)
		if ok and typeof(data) == "table" then
			plotAnimalSync.caches[channelName] = data
		else
			plotAnimalSync.caches[channelName] = {}
		end
	elseif plotAnimalSync.caches[channelName] == nil then
		plotAnimalSync.caches[channelName] = {}
	end
	plotAnimalSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
		for _, packet in ipairs(queue) do
			applyPlotSyncDiff(channelName, packet)
		end
	end)
end
function refreshPlotCache(channelName)
	if not syncRemotes.requestData then
		return
	end
	local ok, data = pcall(function()
		return syncRemotes.requestData:InvokeServer(channelName)
	end)
	if ok and typeof(data) == "table" then
		plotAnimalSync.caches[channelName] = data
	end
end
function detachPlotChannel(channelName)
	for remote, conn in pairs(plotAnimalSync.connections) do
		if tostring(remote.Name) == tostring(channelName) then
			conn:Disconnect()
			plotAnimalSync.connections[remote] = nil
			plotAnimalSync.caches[tostring(channelName)] = nil
			break
		end
	end
end
for _, child in ipairs(syncRemotes.channelFolder:GetChildren()) do
	if child:IsA("RemoteEvent") then
		attachPlotChannel(child)
	end
end
syncRemotes.channelFolder.ChildAdded:Connect(function(child)
	if child:IsA("RemoteEvent") then
		attachPlotChannel(child)
	end
end)
syncRemotes.routeRemote.OnClientEvent:Connect(function(actions)
	for _, action in ipairs(actions) do
		local kind, channelName = action[1], tostring(action[2])
		if not plots:FindFirstChild(channelName) then
			continue
		end
		if kind == "ListenerAdded" then
			local remote = syncRemotes.channelFolder:FindFirstChild(channelName)
			if remote and remote:IsA("RemoteEvent") then
				attachPlotChannel(remote)
			end
		elseif kind == "ListenerRemoved" then
			detachPlotChannel(channelName)
		end
	end
end)
function scanAllPlots()
	local result = {}
	for _, plot in ipairs(getEnemyPlots()) do
		pcall(function()
			local cache = plotAnimalSync.caches[plot.Name]
			local animalList = cache and cache.AnimalList
			if typeof(animalList) ~= "table" then
				return
			end
			for slot, data in pairs(animalList) do
				if typeof(data) ~= "table" or not data.Index then
					continue
				end
				local prompt, base, model = getStealPromptForSlot(plot, slot)
				if not prompt or not prompt.Parent then
					continue
				end
				local animalInfo = dataModules.AnimalsData[data.Index]
				local displayName = (animalInfo and animalInfo.DisplayName) or tostring(data.Index)
				local genValue = AnimalsShared:GetGeneration(data.Index, data.Mutation, data.Traits, nil)
				local genText = "$" .. dataModules.NumberUtils:ToString(genValue) .. "/s"
				table.insert(result, {
					displayName = displayName,
					gen = genText,
					num = genValue,
					plot = plot,
					plotName = plot.Name,
					position = prompt.Parent.WorldPosition,
					prompt = prompt,
					model = model,
					base = base,
					slot = tostring(slot),
					mutation = data.Mutation,
					animalData = data,
					uid = plot.Name .. "_" .. tostring(slot),
				})
			end
		end)
	end
	table.sort(result, function(a, b)
		return a.num > b.num
	end)
	return result
end
local cachedBrainrots = {}
local cachedByPrompt = {}
local selectedBrainrot = nil
task.spawn(function()
	while task.wait(1) do
		pcall(function()
			cachedBrainrots = scanAllPlots()
			cachedByPrompt = {}
			for _, br in ipairs(cachedBrainrots) do
				if br.prompt then
					cachedByPrompt[br.prompt] = br
				end
			end
		end)
	end
end)
task.spawn(function()
	while task.wait(0.2) do
		pcall(function()
			for _, plot in ipairs(getEnemyPlots()) do
				refreshPlotCache(plot.Name)
			end
		end)
	end
end)
function getBestPriorityBrainrot()
	for _, br in ipairs(cachedBrainrots) do
		if isPriorityBrainrot(br) then
			return br
		end
	end
	return nil
end
function getNearestPriorityBrainrot()
	local hrp = getHRP()
	if not hrp then
		return nil
	end
	local best, bestDist = nil, math.huge
	for _, br in ipairs(cachedBrainrots) do
		if isPriorityBrainrot(br) then
			local part = getPodiumWorldPart(br)
			if part then
				local d = (hrp.Position - part:GetPivot().Position).Magnitude
				if d < bestDist then
					bestDist = d;
					best = br
				end
			end
		end
	end
	return best
end
function getHighestPriorityBrainrot()
	for _, name in ipairs(G.PriorityNames) do
		for _, br in ipairs(cachedBrainrots) do
			if br.displayName == name then
				return br
			end
		end
	end
	return nil
end
function getBestBrainrot()
	return cachedBrainrots[1]
end
function getNearestBrainrot()
	local hrp = getHRP()
	if not hrp then
		return nil
	end
	local best, bestDist = nil, math.huge
	for _, br in ipairs(cachedBrainrots) do
		local part = getPodiumWorldPart(br)
		if part then
			local d = (hrp.Position - part:GetPivot().Position).Magnitude
			if d < bestDist then
				bestDist = d;
				best = br
			end
		end
	end
	return best
end
task.spawn(function()
	local currentChar
	while true do
		local ok, dt = pcall(function()
			return task.wait(0.03)
		end)
		if not ok then
			task.wait(0.03);
			continue
		end
		dt = math.min(dt, 1 / 30)
		local char = player.Character
		if char and char ~= currentChar then
			local hum = char:FindFirstChildWhichIsA("Humanoid")
			if hum then
				currentChar = char
			end
			task.wait(0.1)
			continue
		end
		if not currentChar then
			continue
		end
		local hrp = currentChar:FindFirstChild("HumanoidRootPart")
		if not hrp or not G.Speed then
			continue
		end
		local hum = currentChar:FindFirstChildWhichIsA("Humanoid")
		if not hum then
			continue
		end
		pcall(function()
			local isStealing = player:GetAttribute("Stealing") ~= nil
			local isGiantPotion = player:GetAttribute("GiantPotion") ~= nil
			local isHoldingCarpet = currentChar:FindFirstChild("Flying Carpet") ~= nil
			local spd = isHoldingCarpet and G.CarpetSpeedValue or isGiantPotion and G.GiantSpeedValue or isStealing and G.StealingSpeedValue or G.SpeedValue
			local moveDir = hum.MoveDirection
			local vy = math.clamp(hrp.Velocity.Y, - 500, 500)
			local gravDiff = (G.GravityValue or 196.2) - 196.2
			local newVY = vy - (gravDiff * dt)
			if moveDir == Vector3.zero then
				hrp.Velocity = Vector3.new(0, newVY, 0)
			else
				local dir = moveDir.Unit
				hrp.Velocity = Vector3.new(dir.X * spd, newVY, dir.Z * spd)
			end
		end)
	end
end) ;
(function()
	local infJumpData = {
		lastJumpTime = 0
	}
	local infJumpConn
	local function setInfiniteJump(enabled)
		if infJumpConn then
			infJumpConn:Disconnect()
			infJumpConn = nil
		end
		if not enabled then
			return
		end
		infJumpConn = RunService.Heartbeat:Connect(function()
			if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				return
			end
			local now = tick()
			if now - infJumpData.lastJumpTime < 0.1 then
				return
			end
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not hrp or not hum or hum.Health <= 0 then
				return
			end
			infJumpData.lastJumpTime = now
			hrp.Velocity = Vector3.new(hrp.Velocity.X, 55, hrp.Velocity.Z)
		end)
	end
	local lastState = nil
	local function updateInfJump()
		if G.InfJump ~= lastState then
			lastState = G.InfJump
			setInfiniteJump(G.InfJump)
		end
	end
	updateInfJump()
	task.spawn(function()
		while task.wait(0.1) do
			updateInfJump()
		end
	end)
end)()
local originalScales = {}
local originalHipHeight = nil
local scaleNames = {
	"HeadScale",
	"BodyDepthScale",
	"BodyHeightScale",
	"BodyProportionScale",
	"BodyTypeScale",
	"BodyWidthScale"
}
function captureOriginals()
	local char = player.Character
	if not char then
		return
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end
	originalHipHeight = hum.HipHeight
	originalScales = {}
	for _, name in ipairs(scaleNames) do
		local sv = hum:FindFirstChild(name)
		if sv then
			originalScales[name] = sv.Value
		end
	end
end
player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid", 5)
	if not hum then
		return
	end
	task.wait(0.1)
	captureOriginals()
end)
task.spawn(captureOriginals)
task.spawn(function()
	local ragdollAutoResetArmed = true
	while task.wait(0.1) do
		local char = player.Character
		if not char then
			continue
		end
		if G.AntiRagdoll or G.AntiAdminPanel then
			for _, v in ipairs(char:GetDescendants()) do
				if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") or v:IsA("Attachment") then
					v:Destroy()
				elseif v:IsA("Motor6D") then
					v.Enabled = true
				end
			end
		end
		local hum = char:FindFirstChild("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp then
			continue
		end
		restoreMoveControls()
		if G.AntiGummyBear and tick() >= antiGummyRespawnGraceUntil then
			clearGummyToolBlockState(char)
		end
		if G.AntiBee or G.AntiBoogieBomb then
			clearBeeAndBoogieEffects()
		end
		local ragdollEnd = player:GetAttribute("RagdollEndTime") or 0
		local ragdollAttr = player:GetAttribute("Ragdoll")
		local serverTime = Workspace:GetServerTimeNow()
		local isRagdolled = ragdollEnd > serverTime or ragdollAttr == true or hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown
		if G.AutoInstaResetOnRagdoll then
			if isRagdolled then
				if ragdollAutoResetArmed then
					ragdollAutoResetArmed = false
					instareset()
				end
			else
				ragdollAutoResetArmed = true
			end
		else
			ragdollAutoResetArmed = true
		end
		if G.AntiKnockback then
			if Camera.CameraSubject ~= hum then
				Camera.CameraSubject = hum
			end
			if ragdollEnd > serverTime then
				hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
				hrp.Velocity = Vector3.zero
				task.wait(0.2)
				hrp.Velocity = hrp.Velocity * Vector3.new(0.8, 1, 0.8)
			end
		end
		if G.AntiRagdoll or G.AntiAdminPanel then
			local ctrl = getControls()
			if ctrl then
				ctrl:Enable()
			end
			local state = hum:GetState()
			if state ~= Enum.HumanoidStateType.Running and state ~= Enum.HumanoidStateType.Jumping and state ~= Enum.HumanoidStateType.Freefall then
				hum:ChangeState(Enum.HumanoidStateType.Running)
			end
			if Camera.CameraSubject ~= hum then
				Camera.CameraSubject = hum
			end
			if ragdollEnd > serverTime then
				hrp.Velocity = Vector3.zero
				hrp.Velocity = Vector3.zero
				hrp.Velocity = Vector3.zero
				player:SetAttribute("RagdollEndTime", 0)
			end
			if G.AntiAdminPanel then
				if CharacterController then
					local antiAdminCtrl = getControls()
					if antiAdminCtrl then
						antiAdminCtrl.moveFunction = function(p, x, z)
							CharacterController:RequestMove(p, x, z)
						end
					end
				end
				if JumpscareModule and JumpscareModule.effects and JumpscareModule.effects.Victim then
					JumpscareModule.effects.Victim = function()
					end
				end
				if originalHipHeight and hum.HipHeight ~= originalHipHeight then
					hum.HipHeight = originalHipHeight
				end
				for _, name in ipairs(scaleNames) do
					local sv = hum:FindFirstChild(name)
					if sv and originalScales[name] and sv.Value ~= originalScales[name] then
						sv.Value = originalScales[name]
					end
				end
				for _, v in ipairs(char:GetChildren()) do
					if v:IsA("Model") and not v:IsA("BackpackItem") then
						v:Destroy()
					end
				end
			end
		end
	end
end)
Workspace.DescendantAdded:Connect(function(obj)
	if isEnemyTurret(obj) then
		setTurretNoClip(obj)
	end
	if G.AutoDestroyTurret and shouldAttackTurret(obj) then
		task.defer(attackTurret, obj)
	end
end)
task.spawn(function()
	while task.wait(0.4) do
		for _, obj in ipairs(Workspace:GetChildren()) do
			if isEnemyTurret(obj) then
				setTurretNoClip(obj)
			end
			if not G.AutoDestroyTurret then
				continue
			end
			if shouldAttackTurret(obj) then
				attackTurret(obj)
			end
		end
	end
end)
task.spawn(function()
	local function checkTextLabel(obj)
		if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) and obj.Visible then
			local text = obj.Text or ""
			local lower = string.lower(text)
			if G.LeaveOnSteal and string.find(text, "You stole") then
				player:Kick("You stole something")
			end
			if lower:find("trapped for 10 seconds", 1, true) then
				instareset()
			end
		end
	end
	local pg = player:WaitForChild("PlayerGui", 10)
	if pg then
		pg.DescendantAdded:Connect(function(obj)
			checkTextLabel(obj)
			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				pcall(function()
					obj:GetPropertyChangedSignal("Text"):Connect(function()
						checkTextLabel(obj)
					end)
				end)
			end
		end)
	end
end)
local instaResetCooldown = false
local antiDieConnection = nil
local antiDieDisabled = false
local DEFENSE_DEBUG = true
function defenseDebug( ...)
	if not DEFENSE_DEBUG then
		return
	end
	warn("[DefenseDebug]", ...)
end

local resetRemote = nil
local GUID = "f888ee6e-c86d-46e1-93d7-0639d6635d42"
local originalFireServer = nil

local o; o = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
    if not resetRemote and self.Name:sub(1, 3) == "RE/" then
        resetRemote = self
        originalFireServer = o
    end
    return o(self, ...)
end))

function instareset6767()
	if instaResetCooldown then
		return
	end
	instaResetCooldown = true
	stopAutoWalk()
	local player = game.Players.LocalPlayer
	local oldChar = player.Character
	antiDieDisabled = true
	task.spawn(function()
		while player.Character == oldChar do
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildWhichIsA("Humanoid")
			if hrp and hum then
				hum:ChangeState(Enum.HumanoidStateType.Dead)
				hrp.CFrame = CFrame.new(0, 50000, 0)
				pcall(equipcarpet)
			end
			task.wait()
		end
		antiDieDisabled = false
		instaResetCooldown = false
	end)
end

function instareset()
	if instaResetCooldown then
		return
	end
	instaResetCooldown = true
	local player = game.Players.LocalPlayer
	local oldChar = player.Character
	antiDieDisabled = true
	task.spawn(function()
		while player.Character == oldChar do
			resetRemote:FireServer(GUID, LocalPlayer, "balloon")
			task.wait()
		end
		antiDieDisabled = false
		instaResetCooldown = false
	end)
end

for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
	if obj:IsA("RemoteEvent") then
		obj.OnClientEvent:Connect(function(...)
			for _, arg in ipairs({
				...
			}) do
				if type(arg) == "string" then
					local lower = arg:lower()
					if lower:find("stealing") then
						stealingDetected = true
						defenseDebug("Text trigger", arg)
					end
					if lower:find('successfully executed "balloon"') then
						lastBalloonTime = tick()
						switch = true
					end
					if lower:find("trapped for 10 seconds") then
						instareset()
					end
					if lower:find("jump higher") then
						_G.__tpblock_ballooned = true
						if G.AutoInstaReset then
							instareset()
						end
					end
					if lower:find("you successfully broke into") and G.AutoTPonUnlock then
						triggerConfiguredSemiInstant()
					end
				end
			end
		end)
	end
end
local firingPrompt = false
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
	if not G.Instantsteal then
		if firingPrompt then
			return
		end
		firingPrompt = true
		if prompt and prompt:GetAttribute("State") == "Steal" then
			firePatchedSteal(prompt)
		else
			fireproximityprompt(prompt)
		end
		task.delay(0.1, function()
			firingPrompt = false
		end)
	end
end)
function getClosestEnemyPlot()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return nil
	end
	local best, bestDist = nil, math.huge
	for _, plot in ipairs(getEnemyPlots()) do
		local unlock = plot:FindFirstChild("Unlock")
		local main = unlock and unlock:FindFirstChild("Main")
		if main then
			local d = (hrp.Position - main.Position).Magnitude
			if d < bestDist then
				bestDist = d;
				best = plot
			end
		end
	end
	return best
end
function unlockBase(idx)
	local plot = getClosestEnemyPlot()
	local unlock = plot and plot:FindFirstChild("Unlock")
	if not unlock then
		return
	end
	local target = unlock:GetChildren()[idx]
	local prompt = target and target:FindFirstChild("UnlockBase")
	if prompt and prompt:IsA("ProximityPrompt") then
		fireproximityprompt(prompt)
	elseif idx == 1 then
		local main = unlock:FindFirstChild("Main")
		local mPrompt = main and main:FindFirstChild("UnlockBase")
		if mPrompt and mPrompt:IsA("ProximityPrompt") then
			fireproximityprompt(mPrompt)
		end
	end
end
local notify
local stealProgressBar = nil
local showProgress = function()
end
local hideProgress = function()
end
local currentStealTarget = nil
local currentTargetDistance = math.huge
task.spawn(function()
	local lastPrompt, lastNotifTarget = nil, nil
	while task.wait(0.05) do
		if not G.AutoStealBest and not G.AutoStealNearest and not G.AutoStealPriority then
			lastPrompt = nil;
			lastNotifTarget = nil
			currentTargetDistance = math.huge;
			currentStealTarget = nil
			hideProgress();
			continue
		end
		local target
		if selectedBrainrot and selectedBrainrot.prompt and cachedByPrompt[selectedBrainrot.prompt] then
			target = cachedByPrompt[selectedBrainrot.prompt]
		end
		if not target and G.AutoStealPriority then
			target = getNearestPriorityBrainrot()
		end
		target = target or (G.AutoStealBest and getBestBrainrot() or getNearestBrainrot())
		if not target then
			lastPrompt = nil;
			currentTargetDistance = math.huge
			hideProgress();
			continue
		end
		if not target.prompt or not target.prompt.Parent then
			lastPrompt = nil;
			currentTargetDistance = math.huge
			hideProgress();
			continue
		end
		if not target.displayName or not target.gen then
			lastPrompt = nil;
			currentTargetDistance = math.huge
			hideProgress();
			continue
		end
		if type(target.displayName) ~= "string" or type(target.gen) ~= "string" then
			lastPrompt = nil;
			currentTargetDistance = math.huge
			hideProgress();
			continue
		end
		if # target.displayName == 0 or # target.gen == 0 then
			lastPrompt = nil;
			currentTargetDistance = math.huge
			hideProgress();
			continue
		end
		if lastPrompt ~= target.prompt then
			lastPrompt = target.prompt;
			currentStealTarget = target
			if lastNotifTarget ~= target.displayName then
				lastNotifTarget = target.displayName
			end
		end
		local hrp = getHRP()
		if not hrp then
			currentTargetDistance = math.huge;
			continue
		end
		if not target.prompt.Parent then
			lastPrompt = nil;
			currentTargetDistance = math.huge
			hideProgress();
			continue
		end
		local promptPos = target.prompt.Parent.WorldPosition
		local dist = (hrp.Position - promptPos).Magnitude
		currentTargetDistance = dist
		if dist > 30 then
			hideProgress()
			continue
		end
		if G.AutoPotion2 then
			drinkPotion2()
		end
		firePatchedSteal(target.prompt)
	end
end)
function randomString()
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local result = ""
	for i = 1, math.random(10, 20) do
		local idx = math.random(1, # chars)
		result = result .. chars:sub(idx, idx)
	end
	return result
end
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 2147483647
gui.Name = randomString()
gui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
local PARENT = gui
local mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
function tw(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad), props):Play()
end
function mkCorner(p, r)
	local c = Instance.new("UICorner");
	c.CornerRadius = UDim.new(0, r or 6);
	c.Parent = p;
	return c
end
function mkStroke(p, col, th)
	local s = Instance.new("UIStroke");
	s.Color = col or C.border;
	s.Thickness = th or 1.5;
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
	s.Parent = p;
	return s
end
function mkPad(p, t, l, r, b)
	local u = Instance.new("UIPadding");
	u.PaddingTop = UDim.new(0, t or 0);
	u.PaddingLeft = UDim.new(0, l or 0);
	u.PaddingRight = UDim.new(0, r or 0);
	u.PaddingBottom = UDim.new(0, b or 0);
	u.Parent = p;
	return u
end
function mkList(p, dir, pad, ha)
	local l = Instance.new("UIListLayout");
	l.FillDirection = dir or Enum.FillDirection.Vertical;
	l.Padding = UDim.new(0, pad or 6);
	l.HorizontalAlignment = ha or Enum.HorizontalAlignment.Left;
	l.SortOrder = Enum.SortOrder.LayoutOrder;
	l.Parent = p;
	return l
end
local activeNotifs = {}
notify = function(text, color, duration)
	if not G.Notifactions then
		return
	end
	duration = duration or 3;
	color = color or C.purple
	local f = Instance.new("Frame")
	f.Size = UDim2.new(0, 300, 0, 60);
	f.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	f.BorderSizePixel = 0;
	f.ZIndex = 200;
	f.Parent = gui
	mkCorner(f, 10)
	local stroke = mkStroke(f, color, 2)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, - 20, 1, - 20);
	lbl.Position = UDim2.new(0, 10, 0, 10)
	lbl.BackgroundTransparency = 1;
	lbl.Text = text;
	lbl.TextColor3 = C.text
	lbl.Font = Enum.Font.GothamBold;
	lbl.TextSize = 14;
	lbl.TextWrapped = true
	lbl.TextXAlignment = Enum.TextXAlignment.Left;
	lbl.ZIndex = 201;
	lbl.Parent = f
	table.insert(activeNotifs, f)
	local function reposition()
		for i, n in ipairs(activeNotifs) do
			n:TweenPosition(UDim2.new(0.98, - 300, 0.02 + (i - 1) * 0.085, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.3, true)
		end
	end
	f.BackgroundTransparency = 1;
	lbl.TextTransparency = 1;
	stroke.Transparency = 1
	tw(f, {
		BackgroundTransparency = 0
	}, 0.3);
	tw(lbl, {
		TextTransparency = 0
	}, 0.3);
	tw(stroke, {
		Transparency = 0
	}, 0.3)
	reposition()
	task.delay(duration, function()
		tw(f, {
			BackgroundTransparency = 1
		}, 0.3);
		tw(lbl, {
			TextTransparency = 1
		}, 0.3);
		tw(stroke, {
			Transparency = 1
		}, 0.3)
		task.wait(0.3)
		for i, n in ipairs(activeNotifs) do
			if n == f then
				table.remove(activeNotifs, i);
				break
			end
		end
		f:Destroy();
		reposition()
	end)
end
local SIDEBAR_W = 105
local CONTENT_W = mobile and 250 or 320
local WIN_W = SIDEBAR_W + CONTENT_W
local WIN_H = mobile and 260 or 300
local HEADER_H = 32
local vp = Camera.ViewportSize
local startX = math.clamp(math.floor((vp.X - WIN_W) / 2), 0, vp.X - WIN_W)
local startY = math.clamp(60, 0, vp.Y - WIN_H)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, WIN_W, 0, 0)
mainFrame.Position = UDim2.new(0, startX, 0, startY)
mainFrame.BackgroundColor3 = C.bg;
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0;
mainFrame.ZIndex = 10;
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui
mkCorner(mainFrame, 10);
local mainStroke = mkStroke(mainFrame, C.purple, 2)
mainStroke.Transparency = 1
tw(mainFrame, {
	Size = UDim2.new(0, WIN_W, 0, WIN_H),
	BackgroundTransparency = 0.15
}, 0.35)
tw(mainStroke, {
	Transparency = 0
}, 0.35)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, HEADER_H);
header.BackgroundColor3 = C.header
header.BackgroundTransparency = 1;
header.BorderSizePixel = 0;
header.ZIndex = 15
header.Parent = mainFrame
mkCorner(header, 10)
local hFix = Instance.new("Frame")
hFix.Size = UDim2.new(1, 0, 0, 10);
hFix.Position = UDim2.new(0, 0, 1, - 10)
hFix.BackgroundColor3 = C.header;
hFix.BackgroundTransparency = 1
hFix.BorderSizePixel = 0;
hFix.ZIndex = 15;
hFix.Parent = header
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 0, 1, 0);
titleLbl.Position = UDim2.new(0, 6, 0, 0)
titleLbl.BackgroundTransparency = 1;
titleLbl.Text = "CHIRAQ HUB"
titleLbl.TextColor3 = C.purple;
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 24;
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 16;
titleLbl.Parent = header
local fpsLbl = Instance.new("TextLabel")
fpsLbl.Size = UDim2.new(0.5, - 40, 1, 0);
fpsLbl.Position = UDim2.new(0.5, 0, 0, 0)
fpsLbl.BackgroundTransparency = 1;
fpsLbl.Text = "0 FPS | 0 ms"
fpsLbl.TextColor3 = C.textMute;
fpsLbl.Font = Enum.Font.Gotham
fpsLbl.TextSize = 11;
fpsLbl.TextXAlignment = Enum.TextXAlignment.Right
fpsLbl.ZIndex = 16;
fpsLbl.Parent = header
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 20, 0, 20);
minBtn.Position = UDim2.new(1, - 26, 0.5, - 10)
minBtn.BackgroundColor3 = C.purpleDim;
minBtn.TextColor3 = C.text;
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold;
minBtn.TextSize = 14;
minBtn.BorderSizePixel = 0
minBtn.AutoButtonColor = false;
minBtn.ZIndex = 17;
minBtn.Parent = header
mkCorner(minBtn, 4)
local mainMinimized = false
minBtn.MouseButton1Click:Connect(function()
	mainMinimized = not mainMinimized
	if mainMinimized then
		minBtn.Text = "+"
		tw(mainFrame, {
			Size = UDim2.new(0, WIN_W, 0, HEADER_H)
		})
	else
		minBtn.Text = "-"
		tw(mainFrame, {
			Size = UDim2.new(0, WIN_W, 0, WIN_H)
		})
	end
end)
minBtn.MouseEnter:Connect(function()
	tw(minBtn, {
		BackgroundColor3 = C.purple
	})
end)
minBtn.MouseLeave:Connect(function()
	tw(minBtn, {
		BackgroundColor3 = C.purpleDim
	})
end)
local dragging, dragStart, startPos = false, nil, nil
header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true;
		dragStart = i.Position;
		startPos = mainFrame.Position
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - dragStart
		local nx = math.clamp(startPos.X.Offset + d.X, 0, vp.X - mainFrame.AbsoluteSize.X)
		local ny = math.clamp(startPos.Y.Offset + d.Y, 0, vp.Y - mainFrame.AbsoluteSize.Y)
		mainFrame.Position = UDim2.new(0, nx, 0, ny)
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
local function onHeader(p)
	local a = header.AbsolutePosition;
	local s = header.AbsoluteSize;
	return p.X >= a.X and p.X <= a.X + s.X and p.Y >= a.Y and p.Y <= a.Y + s.Y
end
UserInputService.TouchStarted:Connect(function(t, gp)
	if not gp and onHeader(Vector2.new(t.Position.X, t.Position.Y)) then
		dragging = true;
		dragStart = t.Position;
		startPos = mainFrame.Position
	end
end)
UserInputService.TouchMoved:Connect(function(t, gp)
	if not gp and dragging then
		local d = t.Position - dragStart
		local nx = math.clamp(startPos.X.Offset + d.X, 0, vp.X - mainFrame.AbsoluteSize.X)
		local ny = math.clamp(startPos.Y.Offset + d.Y, 0, vp.Y - mainFrame.AbsoluteSize.Y)
		mainFrame.Position = UDim2.new(0, nx, 0, ny)
	end
end)
UserInputService.TouchEnded:Connect(function(_, gp)
	if not gp then
		dragging = false
	end
end)
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, - HEADER_H)
sidebar.Position = UDim2.new(0, 0, 0, HEADER_H)
sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 18);
sidebar.BackgroundTransparency = 1
sidebar.BorderSizePixel = 0;
sidebar.ZIndex = 12;
sidebar.ClipsDescendants = true
sidebar.Parent = mainFrame
mkCorner(sidebar, 10)
local sidebarDivider = Instance.new("Frame")
sidebarDivider.Size = UDim2.new(0, 1, 1, 0);
sidebarDivider.Position = UDim2.new(1, 0, 0, 0)
sidebarDivider.BackgroundColor3 = C.border;
sidebarDivider.BorderSizePixel = 0
sidebarDivider.ZIndex = 13;
sidebarDivider.Parent = sidebar
local sideScroll = Instance.new("ScrollingFrame")
sideScroll.Size = UDim2.new(1, - 1, 1, 0)
sideScroll.BackgroundTransparency = 1;
sideScroll.BorderSizePixel = 0
sideScroll.ScrollBarThickness = 0
sideScroll.CanvasSize = UDim2.new(0, 0, 0, 0);
sideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
sideScroll.ZIndex = 12;
sideScroll.Parent = sidebar
local sideList = mkList(sideScroll, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Center)
mkPad(sideScroll, 8, 6, 6, 8)
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, - SIDEBAR_W, 1, - HEADER_H)
contentArea.Position = UDim2.new(0, SIDEBAR_W, 0, HEADER_H)
contentArea.BackgroundTransparency = 1;
contentArea.BorderSizePixel = 0
contentArea.ZIndex = 11;
contentArea.ClipsDescendants = true
contentArea.Parent = mainFrame
local hasRaknetDesync = pcall(function()
	return raknet and (raknet.add_send_hook or raknet.desync)
end) and raknet and (raknet.add_send_hook or raknet.desync)
local TAB_NAMES = hasRaknetDesync and {
	"General",
	"Stealing",
	"Combat",
	"ESP",
	"Priority",
	"Invis",
	"Desync",
	"Settings"
} or {
	"General",
	"Stealing",
	"Combat",
	"ESP",
	"Priority",
	"Invis",
	"Settings"
}
local tabBtns = {}
local tabFrames = {}
local activeTab = "General"
for _, name in ipairs(TAB_NAMES) do
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1;
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 4;
	scroll.ScrollBarImageColor3 = C.purple
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0);
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ZIndex = 11;
	scroll.Visible = (name == "General")
	scroll.Parent = contentArea
	local layout = mkList(scroll, Enum.FillDirection.Vertical, 5, Enum.HorizontalAlignment.Center)
	mkPad(scroll, 8, 8, 8, 8)
	tabFrames[name] = scroll
end
local function switchTab(name)
	activeTab = name
	for tName, frame in pairs(tabFrames) do
		frame.Visible = (tName == name)
	end
	for tName, btn in pairs(tabBtns) do
		if tName == name then
			tw(btn, {
				BackgroundColor3 = C.purple,
				TextColor3 = C.text
			})
		else
			tw(btn, {
				BackgroundColor3 = Color3.fromRGB(20, 20, 30),
				TextColor3 = C.textMute
			})
		end
	end
end
for i, name in ipairs(TAB_NAMES) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.BackgroundColor3 = (name == "General") and C.rowSel or C.row
	btn.TextColor3 = (name == "General") and C.text or C.textMute
	btn.Text = name;
	btn.Font = Enum.Font.GothamBold;
	btn.TextSize = 11
	btn.BorderSizePixel = 0;
	btn.AutoButtonColor = false
	btn.ZIndex = 13;
	btn.LayoutOrder = i;
	btn.Parent = sideScroll
	mkCorner(btn, 6)
	btn.MouseButton1Click:Connect(function()
		switchTab(name)
	end)
	btn.MouseEnter:Connect(function()
		if activeTab ~= name then
			tw(btn, {
				BackgroundColor3 = Color3.fromRGB(30, 20, 45)
			})
		end
	end)
	btn.MouseLeave:Connect(function()
		if activeTab ~= name then
			tw(btn, {
				BackgroundColor3 = Color3.fromRGB(20, 20, 30)
			})
		end
	end)
	tabBtns[name] = btn
end
function addToggle(tabName, label, gKey)
	local parent = tabFrames[tabName]
	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, 0, 0, 32);
	row.BackgroundColor3 = C.row;
	row.BackgroundTransparency = 0.3
	row.Text = "";
	row.BorderSizePixel = 0;
	row.AutoButtonColor = false;
	row.Parent = parent
	mkCorner(row, 6)
	local stroke = mkStroke(row, C.border, 1.5)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, - 26, 1, 0);
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.BackgroundTransparency = 1;
	lbl.Text = label
	lbl.TextColor3 = C.text;
	lbl.Font = Enum.Font.GothamBold;
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left;
	lbl.Parent = row
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 8, 0, 8);
	dot.Position = UDim2.new(1, - 16, 0.5, - 4)
	dot.BorderSizePixel = 0;
	dot.Parent = row;
	mkCorner(dot, 4)
	local function refresh()
		local on = G[gKey]
		tw(stroke, {
			Color = on and C.purple or C.border
		})
		tw(row, {
			BackgroundColor3 = on and C.rowSel or C.row
		})
		tw(dot, {
			BackgroundColor3 = on and C.green or Color3.fromRGB(60, 60, 75)
		})
	end
	refresh()
	row.MouseButton1Click:Connect(function()
		G[gKey] = not G[gKey];
		refresh()
		notify(label .. " " .. (G[gKey] and "Enabled" or "Disabled"), G[gKey] and C.green or C.red, 2)
	end)
	row.MouseEnter:Connect(function()
		if not G[gKey] then
			tw(row, {
				BackgroundColor3 = C.rowHov
			})
		end
	end)
	row.MouseLeave:Connect(function()
		if not G[gKey] then
			tw(row, {
				BackgroundColor3 = C.row
			})
		end
	end)
	return {
		refresh = refresh,
		row = row
	}
end
function addToggleWithGear(tabName, label, gKey, onGearClick)
	local parent = tabFrames[tabName]
	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, 0, 0, 32);
	row.BackgroundColor3 = C.row;
	row.BackgroundTransparency = 0.3
	row.Text = "";
	row.BorderSizePixel = 0;
	row.AutoButtonColor = false;
	row.Parent = parent
	mkCorner(row, 6)
	local stroke = mkStroke(row, C.border, 1.5)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, - 52, 1, 0);
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.BackgroundTransparency = 1;
	lbl.Text = label
	lbl.TextColor3 = C.text;
	lbl.Font = Enum.Font.GothamBold;
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left;
	lbl.Parent = row
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 8, 0, 8);
	dot.Position = UDim2.new(1, - 38, 0.5, - 4)
	dot.BorderSizePixel = 0;
	dot.Parent = row;
	mkCorner(dot, 4)
	local gear = Instance.new("TextButton")
	gear.Size = UDim2.new(0, 22, 0, 22);
	gear.Position = UDim2.new(1, - 26, 0.5, - 11)
	gear.BackgroundColor3 = C.purpleDim;
	gear.TextColor3 = C.text
	gear.Text = utf8.char(0x2699, 0xFE0F);
	gear.Font = Enum.Font.GothamBold;
	gear.TextSize = 16
	gear.BorderSizePixel = 0;
	gear.AutoButtonColor = false;
	gear.ZIndex = 20
	gear.Parent = row
	mkCorner(gear, 4)
	local function refresh()
		local on = G[gKey]
		tw(stroke, {
			Color = on and C.purple or C.border
		})
		tw(row, {
			BackgroundColor3 = on and C.rowSel or C.row
		})
		tw(dot, {
			BackgroundColor3 = on and C.green or Color3.fromRGB(60, 60, 75)
		})
	end
	refresh()
	row.MouseButton1Click:Connect(function()
		G[gKey] = not G[gKey];
		refresh()
		notify(label .. " " .. (G[gKey] and "Enabled" or "Disabled"), G[gKey] and C.green or C.red, 2)
	end)
	row.MouseEnter:Connect(function()
		if not G[gKey] then
			tw(row, {
				BackgroundColor3 = C.rowHov
			})
		end
	end)
	row.MouseLeave:Connect(function()
		if not G[gKey] then
			tw(row, {
				BackgroundColor3 = C.row
			})
		end
	end)
	gear.MouseEnter:Connect(function()
		tw(gear, {
			BackgroundColor3 = C.purple
		})
	end)
	gear.MouseLeave:Connect(function()
		tw(gear, {
			BackgroundColor3 = C.purpleDim
		})
	end)
	gear.MouseButton1Click:Connect(function()
		if onGearClick then
			onGearClick()
		end
	end)
	return {
		refresh = refresh,
		row = row,
		gear = gear
	}
end
function addButton(tabName, label, cb, bgColor, bgHi, border)
	local parent = tabFrames[tabName]
	bgColor = bgColor or C.purple;
	bgHi = bgHi or C.purpleHi;
	border = border or C.purpleDim
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30);
	btn.BackgroundColor3 = bgColor;
	btn.BackgroundTransparency = 0.3
	btn.TextColor3 = C.text;
	btn.Text = label;
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12;
	btn.BorderSizePixel = 0;
	btn.AutoButtonColor = false;
	btn.Parent = parent
	btn:SetAttribute("HubUiButton", true)
	mkCorner(btn, 6);
	mkStroke(btn, border, 1.5)
	btn.MouseEnter:Connect(function()
		tw(btn, {
			BackgroundColor3 = bgHi
		})
	end)
	btn.MouseLeave:Connect(function()
		tw(btn, {
			BackgroundColor3 = bgColor
		})
	end)
	btn.MouseButton1Click:Connect(cb)
	return btn
end
function addButtonWithGear(tabName, label, cb, onGearClick, bgColor, bgHi, border)
	local parent = tabFrames[tabName]
	bgColor = bgColor or C.purple;
	bgHi = bgHi or C.purpleHi;
	border = border or C.purpleDim
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30);
	btn.BackgroundColor3 = bgColor;
	btn.BackgroundTransparency = 0.3
	btn.TextColor3 = C.text;
	btn.Text = label;
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12;
	btn.BorderSizePixel = 0;
	btn.AutoButtonColor = false;
	btn.Parent = parent
	btn:SetAttribute("HubUiButton", true)
	mkCorner(btn, 6);
	mkStroke(btn, border, 1.5)
	btn.MouseEnter:Connect(function()
		tw(btn, {
			BackgroundColor3 = bgHi
		})
	end)
	btn.MouseLeave:Connect(function()
		tw(btn, {
			BackgroundColor3 = bgColor
		})
	end)
	btn.MouseButton1Click:Connect(cb)
	local gear = Instance.new("TextButton")
	gear.Size = UDim2.new(0, 22, 0, 22);
	gear.Position = UDim2.new(1, - 26, 0.5, - 11)
	gear.BackgroundColor3 = Color3.fromRGB(60, 10, 110);
	gear.TextColor3 = C.text
	gear.Text = utf8.char(0x2699, 0xFE0F);
	gear.Font = Enum.Font.GothamBold;
	gear.TextSize = 16
	gear.BorderSizePixel = 0;
	gear.AutoButtonColor = false;
	gear.ZIndex = 20
	gear.Parent = btn
	mkCorner(gear, 4)
	gear.MouseEnter:Connect(function()
		tw(gear, {
			BackgroundColor3 = C.purple
		})
	end)
	gear.MouseLeave:Connect(function()
		tw(gear, {
			BackgroundColor3 = Color3.fromRGB(60, 10, 110)
		})
	end)
	gear.MouseButton1Click:Connect(function()
		if onGearClick then
			onGearClick()
		end
	end)
	return btn
end
function addSlider(tabName, label, gKey, minV, maxV, step)
	local parent = tabFrames[tabName]
	step = step or 1
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 52);
	frame.BackgroundColor3 = C.row;
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0;
	frame.Parent = parent
	mkCorner(frame, 6);
	mkStroke(frame, C.border, 1.5)
	local topRow = Instance.new("Frame")
	topRow.Size = UDim2.new(1, - 12, 0, 20);
	topRow.Position = UDim2.new(0, 6, 0, 6)
	topRow.BackgroundTransparency = 1;
	topRow.Parent = frame
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(0.7, 0, 1, 0);
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = label;
	nameLbl.TextColor3 = C.textDim;
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextSize = 11;
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left;
	nameLbl.Parent = topRow
	local valLbl = Instance.new("TextLabel")
	valLbl.Size = UDim2.new(0.3, 0, 1, 0);
	valLbl.Position = UDim2.new(0.7, 0, 0, 0)
	valLbl.BackgroundTransparency = 1;
	valLbl.TextColor3 = C.purple;
	valLbl.Font = Enum.Font.GothamBold
	valLbl.TextSize = 11;
	valLbl.TextXAlignment = Enum.TextXAlignment.Right;
	valLbl.Parent = topRow
	local trackBG = Instance.new("Frame")
	trackBG.Size = UDim2.new(1, - 12, 0, 8);
	trackBG.Position = UDim2.new(0, 6, 0, 34)
	trackBG.BackgroundColor3 = C.track;
	trackBG.BorderSizePixel = 0;
	trackBG.Parent = frame
	mkCorner(trackBG, 4)
	local fill = Instance.new("Frame");
	fill.BackgroundColor3 = C.purple
	fill.BorderSizePixel = 0;
	fill.Parent = trackBG;
	mkCorner(fill, 4)
	local function setValue(v)
		local dec = math.max(0, math.ceil(- math.log10(step)))
		local fac = 10 ^ dec
		v = math.round(math.clamp(v / step, minV / step, maxV / step)) * step
		v = math.round(v * fac) / fac
		G[gKey] = v;
		valLbl.Text = tostring(v)
		fill.Size = UDim2.new((v - minV) / (maxV - minV), 0, 1, 0)
	end
	setValue(G[gKey] or minV)
	local sliderDragging = false
	local function fromInput(pos)
		setValue(minV + (maxV - minV) * math.clamp((pos.X - trackBG.AbsolutePosition.X) / trackBG.AbsoluteSize.X, 0, 1))
	end
	trackBG.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliderDragging = true;
			fromInput(i.Position)
		end
	end)
	trackBG.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliderDragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if sliderDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			fromInput(i.Position)
		end
	end)
end
function addLabel(tabName, text)
	local parent = tabFrames[tabName]
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 18);
	lbl.BackgroundTransparency = 1
	lbl.Text = text;
	lbl.TextColor3 = C.textMute;
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 10;
	lbl.TextXAlignment = Enum.TextXAlignment.Left;
	lbl.Parent = parent
end
function addDivider(tabName)
	local parent = tabFrames[tabName]
	local d = Instance.new("Frame");
	d.Size = UDim2.new(1, 0, 0, 1)
	d.BackgroundColor3 = C.border;
	d.BorderSizePixel = 0;
	d.Parent = parent
end
function addKeybind(tabName, label, currentKey, onRebind)
	local parent = tabFrames[tabName]
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30);
	row.BackgroundColor3 = C.row;
	row.BackgroundTransparency = 0.3
	row.BorderSizePixel = 0;
	row.Parent = parent
	mkCorner(row, 6);
	mkStroke(row, C.border, 1.5)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.6, 0, 1, 0);
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.BackgroundTransparency = 1;
	lbl.Text = label;
	lbl.TextColor3 = C.textDim
	lbl.Font = Enum.Font.GothamBold;
	lbl.TextSize = 11;
	lbl.TextXAlignment = Enum.TextXAlignment.Left;
	lbl.Parent = row
	local kbBtn = Instance.new("TextButton")
	kbBtn.Size = UDim2.new(0, 52, 0, 22);
	kbBtn.Position = UDim2.new(1, - 58, 0.5, - 11)
	kbBtn.BackgroundColor3 = C.purpleDim;
	kbBtn.TextColor3 = C.text;
	kbBtn.Text = currentKey
	kbBtn.Font = Enum.Font.GothamBold;
	kbBtn.TextSize = 10;
	kbBtn.BorderSizePixel = 0
	kbBtn.AutoButtonColor = false;
	kbBtn.Parent = row
	mkCorner(kbBtn, 5);
	mkStroke(kbBtn, C.purple, 1)
	local listening = false
	kbBtn.MouseButton1Click:Connect(function()
		if listening then
			return
		end
		listening = true;
		kbBtn.Text = "..."
		tw(kbBtn, {
			BackgroundColor3 = C.purple
		})
		local conn;
		conn = UserInputService.InputBegan:Connect(function(inp, gp)
			if inp.UserInputType == Enum.UserInputType.Keyboard then
				local k = inp.KeyCode.Name
				kbBtn.Text = k;
				tw(kbBtn, {
					BackgroundColor3 = C.purpleDim
				})
				if onRebind then
					onRebind(k)
				end
				listening = false;
				conn:Disconnect()
			end
		end)
	end)
end
local ADMIN_PANEL_STYLE = {
	WIDTH = 420,
	MIN_HEIGHT = 76,
	MAX_HEIGHT = 360,
	ROW_HEIGHT = 32,
}
local ADMIN_PANEL_COMMAND_DEFS = {
	{
		emoji = "Ti",
		cmd = "tiny"
	},
	{
		emoji = "Ja",
		cmd = "jail"
	},
	{
		emoji = "Ro",
		cmd = "rocket"
	},
	{
		emoji = "Ra",
		cmd = "ragdoll"
	},
	{
		emoji = "Ba",
		cmd = "balloon"
	},
}
local function refreshAdminPanelSize(panel, contentLayout)
	local contentHeight = contentLayout.AbsoluteContentSize.Y
	local totalHeight = math.clamp(contentHeight + 42, ADMIN_PANEL_STYLE.MIN_HEIGHT, ADMIN_PANEL_STYLE.MAX_HEIGHT)
	panel.Size = UDim2.new(0, ADMIN_PANEL_STYLE.WIDTH, 0, totalHeight)
end
local function makeAdminPanelActionButton(parent, def, targetPlayer)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 30, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	btn.Text = def.emoji
	btn.TextColor3 = Color3.fromRGB(230, 230, 230)
	btn.TextSize = 14
	btn.TextTransparency = 0.4
	btn.Font = Enum.Font.Gotham
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.ZIndex = 334
	btn.Parent = parent
	mkCorner(btn, 4)
	local stroke = mkStroke(btn, Color3.fromRGB(255, 255, 255), 1.5)
	stroke.Transparency = 0.2
	stroke.Enabled = false
	btn.MouseButton1Click:Connect(function()
		local ok = executeAdminCommands(targetPlayer, {
			def.cmd
		})
		if ok then
			tw(btn, {
				BackgroundColor3 = C.purple
			}, 0.12)
			task.delay(0.18, function()
				if btn.Parent then
					tw(btn, {
						BackgroundColor3 = Color3.fromRGB(150, 0, 0)
					}, 0.12)
				end
			end)
			notify(("Sent %s to %s"):format(def.cmd, targetPlayer.Name), C.green, 1.5)
		else
			notify(("Failed to send %s to %s"):format(def.cmd, targetPlayer.Name), C.red, 1.5)
		end
	end)
end
local function rebuildAdminPanelContent(content)
	for _, child in ipairs(content:GetChildren()) do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, ADMIN_PANEL_STYLE.ROW_HEIGHT)
			row.BackgroundTransparency = 1
			row.ZIndex = 332
			row.Parent = content
			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.new(0.3, 0, 1, 0)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Text = ("%s (@%s)"):format(plr.DisplayName, plr.Name)
			nameLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
			nameLbl.Font = Enum.Font.GothamBold
			nameLbl.TextSize = 13
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
			nameLbl.ZIndex = 333
			nameLbl.Parent = row
			local actions = Instance.new("Frame")
			actions.Size = UDim2.new(0.7, 0, 1, 0)
			actions.Position = UDim2.new(0.3, 0, 0, 0)
			actions.BackgroundTransparency = 1
			actions.ZIndex = 333
			actions.Parent = row
			local actionsLayout = mkList(actions, Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Right)
			actionsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			for _, def in ipairs(ADMIN_PANEL_COMMAND_DEFS) do
				makeAdminPanelActionButton(actions, def, plr)
			end
		end
	end
end
local function createAdminPanelWindow()
	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, ADMIN_PANEL_STYLE.WIDTH, 0, ADMIN_PANEL_STYLE.MIN_HEIGHT)
	panel.Position = UDim2.new(0, 24, 0, 220)
	panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	panel.BackgroundTransparency = 0.1
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.ZIndex = 330
	panel.Parent = gui
	mkCorner(panel, 14)
	local panelStroke = mkStroke(panel, Color3.fromRGB(255, 255, 255), 1.5)
	local panelStrokeGradient = Instance.new("UIGradient")
	panelStrokeGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(87, 126, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(99, 12, 199))
	})
	panelStrokeGradient.Rotation = 348.98
	panelStrokeGradient.Parent = panelStroke
	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 30)
	topBar.BackgroundColor3 = Color3.fromRGB(10, 15, 31)
	topBar.BorderSizePixel = 0
	topBar.ZIndex = 331
	topBar.Parent = panel
	mkCorner(topBar, 14)
	local topFix = Instance.new("Frame")
	topFix.Size = UDim2.new(1, 0, 0, 14)
	topFix.Position = UDim2.new(0, 0, 1, - 14)
	topFix.BackgroundColor3 = topBar.BackgroundColor3
	topFix.BorderSizePixel = 0
	topFix.ZIndex = 331
	topFix.Parent = topBar
	local panelTitle = Instance.new("TextLabel")
	panelTitle.Size = UDim2.new(1, - 68, 1, 0)
	panelTitle.Position = UDim2.new(0, 10, 0, 0)
	panelTitle.BackgroundTransparency = 1
	panelTitle.Text = "Admin Panel (NOT SKIDDED FROM FUNBUNS WALLAHI BRO)"
	panelTitle.TextColor3 = C.text
	panelTitle.Font = Enum.Font.GothamBold
	panelTitle.TextSize = 13
	panelTitle.TextXAlignment = Enum.TextXAlignment.Left
	panelTitle.ZIndex = 332
	panelTitle.Parent = topBar
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 22, 0, 22)
	closeBtn.Position = UDim2.new(1, - 26, 0.5, - 11)
	closeBtn.BackgroundColor3 = Color3.fromRGB(17, 25, 51)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = C.text
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 15
	closeBtn.BorderSizePixel = 0
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 333
	closeBtn.Parent = topBar
	mkCorner(closeBtn, 999)
	local lockBtn = Instance.new("TextButton")
	lockBtn.Size = UDim2.new(0, 22, 0, 22)
	lockBtn.Position = UDim2.new(1, - 52, 0.5, - 11)
	lockBtn.BackgroundColor3 = Color3.fromRGB(17, 25, 51)
	lockBtn.Text = "Click to unlock"
	lockBtn.TextColor3 = C.text
	lockBtn.Font = Enum.Font.GothamBold
	lockBtn.TextSize = 12
	lockBtn.BorderSizePixel = 0
	lockBtn.AutoButtonColor = false
	lockBtn.ZIndex = 333
	lockBtn.Parent = topBar
	mkCorner(lockBtn, 999)
	local content = Instance.new("ScrollingFrame")
	content.Size = UDim2.new(1, 0, 1, - 30)
	content.Position = UDim2.new(0, 0, 0, 30)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ScrollBarThickness = 4
	content.ScrollBarImageColor3 = C.purple
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	content.ZIndex = 331
	content.Parent = panel
	mkPad(content, 6, 6, 6, 6)
	local contentLayout = mkList(content, Enum.FillDirection.Vertical, 4, Enum.HorizontalAlignment.Left)
	contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		refreshAdminPanelSize(panel, contentLayout)
	end)
	local dragActive, dragOrigin, dragPanelPos = false, nil, nil
	local function refreshAdminPanelLock()
		lockBtn.Text = G.AdminPanelLocked and "Click to unlock" or "Click to lock"
		lockBtn.BackgroundColor3 = G.AdminPanelLocked and Color3.fromRGB(17, 25, 51) or C.green
	end
	refreshAdminPanelLock()
	local function panelInHeader(pos)
		local a = topBar.AbsolutePosition
		local s = topBar.AbsoluteSize
		return pos.X >= a.X and pos.X <= a.X + s.X and pos.Y >= a.Y and pos.Y <= a.Y + s.Y
	end
	topBar.InputBegan:Connect(function(i)
		if G.AdminPanelLocked then
			return
		end
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragActive = true
			dragOrigin = i.Position
			dragPanelPos = panel.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragActive and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - dragOrigin
			panel.Position = UDim2.new(0, dragPanelPos.X.Offset + d.X, 0, dragPanelPos.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragActive = false
		end
	end)
	UserInputService.TouchStarted:Connect(function(t, gp)
		if G.AdminPanelLocked then
			return
		end
		if not gp and panelInHeader(Vector2.new(t.Position.X, t.Position.Y)) then
			dragActive = true
			dragOrigin = t.Position
			dragPanelPos = panel.Position
		end
	end)
	UserInputService.TouchMoved:Connect(function(t, gp)
		if not gp and dragActive then
			local d = t.Position - dragOrigin
			panel.Position = UDim2.new(0, dragPanelPos.X.Offset + d.X, 0, dragPanelPos.Y.Offset + d.Y)
		end
	end)
	UserInputService.TouchEnded:Connect(function(_, gp)
		if not gp then
			dragActive = false
		end
	end)
	local function rebuild()
		rebuildAdminPanelContent(content)
		refreshAdminPanelSize(panel, contentLayout)
	end
	Players.PlayerAdded:Connect(rebuild)
	Players.PlayerRemoving:Connect(rebuild)
	rebuild()
	lockBtn.MouseButton1Click:Connect(function()
		G.AdminPanelLocked = not G.AdminPanelLocked
		dragActive = false
		refreshAdminPanelLock()
		saveConfig()
	end)
	lockBtn.MouseEnter:Connect(function()
		tw(lockBtn, {
			BackgroundColor3 = C.purple
		})
	end)
	lockBtn.MouseLeave:Connect(refreshAdminPanelLock)
	closeBtn.MouseButton1Click:Connect(function()
		G.ShowAdminPanelWindow = false
		panel.Visible = false
		saveConfig()
	end)
	closeBtn.MouseEnter:Connect(function()
		tw(closeBtn, {
			BackgroundColor3 = C.purple
		})
	end)
	closeBtn.MouseLeave:Connect(function()
		tw(closeBtn, {
			BackgroundColor3 = Color3.fromRGB(17, 25, 51)
		})
	end)
	return panel, rebuild
end
local openPanelClosers = {}
local adminPanelWindow, rebuildAdminPanelWindow = createAdminPanelWindow()
function makeCmdConfigPanel(titleText, cfgKey, anchorFrame)
	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, 160, 0, 10)
	panel.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
	panel.BorderSizePixel = 0;
	panel.ZIndex = 300;
	panel.Visible = false;
	panel.Parent = gui
	mkCorner(panel, 8);
	mkStroke(panel, C.purple, 1.5)
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 22)
	titleBar.BackgroundColor3 = C.header;
	titleBar.BorderSizePixel = 0;
	titleBar.ZIndex = 301;
	titleBar.Parent = panel
	mkCorner(titleBar, 7)
	local fix = Instance.new("Frame")
	fix.Size = UDim2.new(1, 0, 0, 7);
	fix.Position = UDim2.new(0, 0, 1, - 7)
	fix.BackgroundColor3 = C.header;
	fix.BorderSizePixel = 0;
	fix.ZIndex = 301;
	fix.Parent = titleBar
	local tLbl = Instance.new("TextLabel")
	tLbl.Size = UDim2.new(1, - 24, 1, 0);
	tLbl.Position = UDim2.new(0, 6, 0, 0)
	tLbl.BackgroundTransparency = 1;
	tLbl.Text = titleText
	tLbl.TextColor3 = C.textDim;
	tLbl.Font = Enum.Font.GothamBold
	tLbl.TextSize = 9;
	tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.ZIndex = 302;
	tLbl.Parent = titleBar
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 14, 0, 14);
	closeBtn.Position = UDim2.new(1, - 17, 0.5, - 7)
	closeBtn.BackgroundColor3 = C.purpleDim;
	closeBtn.TextColor3 = C.text;
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.GothamBold;
	closeBtn.TextSize = 10
	closeBtn.BorderSizePixel = 0;
	closeBtn.AutoButtonColor = false;
	closeBtn.ZIndex = 303;
	closeBtn.Parent = titleBar
	mkCorner(closeBtn, 3)
	local ROW_H = 24;
	local PAD = 5
	local function isActive(cmd)
		for _, v in ipairs(G[cfgKey]) do
			if v == cmd then
				return true
			end
		end
		return false
	end
	local checkStates = {}
	local rows = {}
	for i, cmd in ipairs(ALL_COMMANDS) do
		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, - 10, 0, ROW_H)
		row.Position = UDim2.new(0, 5, 0, 22 + PAD + (i - 1) * (ROW_H + PAD))
		row.BackgroundColor3 = C.row;
		row.BorderSizePixel = 0
		row.AutoButtonColor = false;
		row.Text = "";
		row.ZIndex = 301;
		row.Parent = panel
		mkCorner(row, 5)
		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(1, - 28, 1, 0);
		nameLbl.Position = UDim2.new(0, 6, 0, 0)
		nameLbl.BackgroundTransparency = 1;
		nameLbl.Text = cmd
		nameLbl.TextColor3 = C.text;
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.TextSize = 10;
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.ZIndex = 302;
		nameLbl.Parent = row
		local chk = Instance.new("Frame")
		chk.Size = UDim2.new(0, 14, 0, 14);
		chk.Position = UDim2.new(1, - 18, 0.5, - 7)
		chk.BorderSizePixel = 0;
		chk.ZIndex = 302;
		chk.Parent = row;
		mkCorner(chk, 3)
		local active = isActive(cmd)
		checkStates[cmd] = active
		local function refreshRow(state)
			tw(row, {
				BackgroundColor3 = state and C.rowSel or C.row
			})
			tw(chk, {
				BackgroundColor3 = state and C.green or Color3.fromRGB(50, 50, 65)
			})
		end
		refreshRow(active)
		row.MouseButton1Click:Connect(function()
			checkStates[cmd] = not checkStates[cmd]
			refreshRow(checkStates[cmd])
			local lst = {}
			for _, c in ipairs(ALL_COMMANDS) do
				if checkStates[c] then
					table.insert(lst, c)
				end
			end
			G[cfgKey] = lst;
			saveConfig()
		end)
		table.insert(rows, row)
	end
	local totalH = 22 + PAD + # ALL_COMMANDS * (ROW_H + PAD) + PAD
	panel.Size = UDim2.new(0, 160, 0, totalH)
	local function reposition()
		if not anchorFrame or not anchorFrame.Parent then
			return
		end
		local ap = anchorFrame.AbsolutePosition
		local as = anchorFrame.AbsoluteSize
		local vpSize = Camera.ViewportSize
		local px = ap.X + as.X + 6
		local py = ap.Y
		if px + 160 > vpSize.X then
			px = ap.X - 166
		end
		if py + totalH > vpSize.Y then
			py = vpSize.Y - totalH - 4
		end
		panel.Position = UDim2.new(0, px, 0, py)
	end
	local selfClose = function()
		panel.Visible = false
	end
	table.insert(openPanelClosers, selfClose)
	closeBtn.MouseButton1Click:Connect(selfClose)
	local function openPanel()
		for _, cf in ipairs(openPanelClosers) do
			if cf ~= selfClose then
				pcall(cf)
			end
		end
		for _, cmd in ipairs(ALL_COMMANDS) do
			checkStates[cmd] = isActive(cmd)
		end
		for i, cmd in ipairs(ALL_COMMANDS) do
			local state = checkStates[cmd]
			tw(rows[i], {
				BackgroundColor3 = state and C.rowSel or C.row
			})
			local chk = rows[i]:FindFirstChildWhichIsA("Frame")
			if chk then
				tw(chk, {
					BackgroundColor3 = state and C.green or Color3.fromRGB(50, 50, 65)
				})
			end
		end
		reposition();
		panel.Visible = true
	end
	return openPanel
end
function makeTabbedCmdPanel(titleText, tabs, anchorFrame)
	local panel = Instance.new("Frame")
	panel.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
	panel.BorderSizePixel = 0;
	panel.ZIndex = 300;
	panel.Visible = false;
	panel.Parent = gui
	mkCorner(panel, 8);
	mkStroke(panel, C.purple, 1.5)
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 22)
	titleBar.BackgroundColor3 = C.header;
	titleBar.BorderSizePixel = 0;
	titleBar.ZIndex = 301;
	titleBar.Parent = panel
	mkCorner(titleBar, 7)
	local fix2 = Instance.new("Frame")
	fix2.Size = UDim2.new(1, 0, 0, 7);
	fix2.Position = UDim2.new(0, 0, 1, - 7)
	fix2.BackgroundColor3 = C.header;
	fix2.BorderSizePixel = 0;
	fix2.ZIndex = 301;
	fix2.Parent = titleBar
	local tLbl2 = Instance.new("TextLabel")
	tLbl2.Size = UDim2.new(1, - 24, 1, 0);
	tLbl2.Position = UDim2.new(0, 6, 0, 0)
	tLbl2.BackgroundTransparency = 1;
	tLbl2.Text = titleText
	tLbl2.TextColor3 = C.textDim;
	tLbl2.Font = Enum.Font.GothamBold
	tLbl2.TextSize = 9;
	tLbl2.TextXAlignment = Enum.TextXAlignment.Left
	tLbl2.ZIndex = 302;
	tLbl2.Parent = titleBar
	local closeBtn2 = Instance.new("TextButton")
	closeBtn2.Size = UDim2.new(0, 14, 0, 14);
	closeBtn2.Position = UDim2.new(1, - 17, 0.5, - 7)
	closeBtn2.BackgroundColor3 = C.purpleDim;
	closeBtn2.TextColor3 = C.text;
	closeBtn2.Text = "X"
	closeBtn2.Font = Enum.Font.GothamBold;
	closeBtn2.TextSize = 10
	closeBtn2.BorderSizePixel = 0;
	closeBtn2.AutoButtonColor = false;
	closeBtn2.ZIndex = 303;
	closeBtn2.Parent = titleBar
	mkCorner(closeBtn2, 3)
	local TAB_W = 160 / # tabs - 4
	local cmdTabBtns = {}
	for i, tab in ipairs(tabs) do
		local tb = Instance.new("TextButton")
		tb.Size = UDim2.new(0, TAB_W, 0, 18)
		tb.Position = UDim2.new(0, 4 + (i - 1) * (TAB_W + 4), 0, 25)
		tb.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
		tb.TextColor3 = C.textDim;
		tb.Text = tab[1]
		tb.Font = Enum.Font.GothamBold;
		tb.TextSize = 9
		tb.BorderSizePixel = 0;
		tb.AutoButtonColor = false;
		tb.ZIndex = 301;
		tb.Parent = panel
		mkCorner(tb, 4);
		table.insert(cmdTabBtns, tb)
	end
	local ROW_H = 24;
	local PAD = 5
	local CONTENT_Y = 47
	local totalH = CONTENT_Y + # ALL_COMMANDS * (ROW_H + PAD) + PAD
	panel.Size = UDim2.new(0, 160, 0, totalH)
	local tabGroups = {}
	local cmdActiveTab = 1
	for ti, tab in ipairs(tabs) do
		local cfgKey = tab[2]
		local checkStates = {}
		local rows = {}
		local function isActive(cmd)
			for _, v in ipairs(G[cfgKey]) do
				if v == cmd then
					return true
				end
			end
			return false
		end
		for i, cmd in ipairs(ALL_COMMANDS) do
			local row = Instance.new("TextButton")
			row.Size = UDim2.new(1, - 10, 0, ROW_H)
			row.Position = UDim2.new(0, 5, 0, CONTENT_Y + (i - 1) * (ROW_H + PAD))
			row.BackgroundColor3 = C.row;
			row.BorderSizePixel = 0
			row.AutoButtonColor = false;
			row.Text = "";
			row.ZIndex = 301
			row.Visible = (ti == 1);
			row.Parent = panel
			mkCorner(row, 5)
			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.new(1, - 28, 1, 0);
			nameLbl.Position = UDim2.new(0, 6, 0, 0)
			nameLbl.BackgroundTransparency = 1;
			nameLbl.Text = cmd
			nameLbl.TextColor3 = C.text;
			nameLbl.Font = Enum.Font.GothamBold
			nameLbl.TextSize = 10;
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			nameLbl.ZIndex = 302;
			nameLbl.Parent = row
			local chk = Instance.new("Frame")
			chk.Size = UDim2.new(0, 14, 0, 14);
			chk.Position = UDim2.new(1, - 18, 0.5, - 7)
			chk.BorderSizePixel = 0;
			chk.ZIndex = 302;
			chk.Parent = row;
			mkCorner(chk, 3)
			local active = isActive(cmd)
			checkStates[cmd] = active
			local function refreshRow(state)
				tw(row, {
					BackgroundColor3 = state and C.rowSel or C.row
				})
				tw(chk, {
					BackgroundColor3 = state and C.green or Color3.fromRGB(50, 50, 65)
				})
			end
			refreshRow(active)
			local capturedCmd = cmd
			row.MouseButton1Click:Connect(function()
				checkStates[capturedCmd] = not checkStates[capturedCmd]
				refreshRow(checkStates[capturedCmd])
				local lst = {}
				for _, c in ipairs(ALL_COMMANDS) do
					if checkStates[c] then
						table.insert(lst, c)
					end
				end
				G[cfgKey] = lst;
				saveConfig()
			end)
			table.insert(rows, {
				row = row,
				chk = chk,
				cmd = cmd,
				state = checkStates,
				cfgKey = cfgKey
			})
		end
		table.insert(tabGroups, {
			rows = rows,
			checkStates = checkStates,
			cfgKey = cfgKey
		})
	end
	local function goTab(idx)
		cmdActiveTab = idx
		for i, tb in ipairs(cmdTabBtns) do
			tw(tb, {
				BackgroundColor3 = i == idx and C.purple or Color3.fromRGB(35, 35, 50),
				TextColor3 = i == idx and C.text or C.textDim
			})
		end
		for ti, group in ipairs(tabGroups) do
			for _, rowData in ipairs(group.rows) do
				rowData.row.Visible = (ti == idx)
			end
		end
	end
	for i = 1, # tabs do
		local idx = i;
		cmdTabBtns[i].MouseButton1Click:Connect(function()
			goTab(idx)
		end)
	end
	goTab(1)
	local selfClose2 = function()
		panel.Visible = false
	end
	table.insert(openPanelClosers, selfClose2)
	closeBtn2.MouseButton1Click:Connect(selfClose2)
	local function reposition2()
		if not anchorFrame or not anchorFrame.Parent then
			return
		end
		local ap = anchorFrame.AbsolutePosition
		local as = anchorFrame.AbsoluteSize
		local vpSize = Camera.ViewportSize
		local px = ap.X + as.X + 6;
		local py = ap.Y
		if px + 160 > vpSize.X then
			px = ap.X - 166
		end
		if py + totalH > vpSize.Y then
			py = vpSize.Y - totalH - 4
		end
		panel.Position = UDim2.new(0, px, 0, py)
	end
	local function openPanel2()
		for _, cf in ipairs(openPanelClosers) do
			if cf ~= selfClose2 then
				pcall(cf)
			end
		end
		for _, group in ipairs(tabGroups) do
			local function isActiveNow(cmd)
				for _, v in ipairs(G[group.cfgKey]) do
					if v == cmd then
						return true
					end
				end
				return false
			end
			for _, rowData in ipairs(group.rows) do
				local state = isActiveNow(rowData.cmd)
				rowData.state[rowData.cmd] = state
				tw(rowData.row, {
					BackgroundColor3 = state and C.rowSel or C.row
				})
				tw(rowData.chk, {
					BackgroundColor3 = state and C.green or Color3.fromRGB(50, 50, 65)
				})
			end
		end
		reposition2();
		panel.Visible = true
	end
	return openPanel2
end
addLabel("General", "General")
addToggle("General", "Aimbot", "AutoSpam")
addToggle("General", "Anti Ragdoll", "AntiRagdoll")
addToggle("General", "Anti Knockback", "AntiKnockback")
addToggle("General", "Anti Admin Panel", "AntiAdminPanel")
addToggle("General", "Auto Giant Potion", "AutoPotion2")
addToggle("General", "Anti Gummy Bear", "AntiGummyBear")
addToggle("General", "Anti Bee", "AntiBee")
addToggle("General", "Anti Boogie Bomb", "AntiBoogieBomb")
addToggle("General", "Anti Paintball", "AntiPaintball")
addToggle("General", "Auto Destroy Turret", "AutoDestroyTurret")
addToggle("General", "Anti Lag", "AntiLagEnabled")
addToggle("General", "Leave on Steal", "LeaveOnSteal")
addToggle("General", "Infinite Jump", "InfJump")
addToggle("General", "Auto Insta Reset", "AutoInstaReset")
addToggle("General", "Auto Insta Reset On Ragdoll", "AutoInstaResetOnRagdoll")
addDivider("General")
addLabel("General", "SPEED")
addToggle("General", "Speed", "Speed")
addSlider("General", "Speed", "SpeedValue", 1, 80, 0.1)
addSlider("General", "Steal Speed", "StealingSpeedValue", 1, 40, 0.1)
addSlider("General", "Giant Speed", "GiantSpeedValue", 1, 40, 0.1)
addSlider("General", "Carpet Speed", "CarpetSpeedValue", 1, 500, 0.1)
addSlider("General", "Gravity", "GravityValue", 1, 300, 0.1)
addLabel("Stealing", "AUTO STEALING")
addToggle("Stealing", "Auto Steal Best", "AutoStealBest")
addToggle("Stealing", "Auto Steal Nearest", "AutoStealNearest")
addToggle("Stealing", "Auto Steal Priority", "AutoStealPriority")
addLabel("Stealing", "PRIORITIZE BRAINROT")
do
	local brainrotContainer = Instance.new("Frame")
	brainrotContainer.Size = UDim2.new(1, 0, 0, 120);
	brainrotContainer.BackgroundColor3 = C.row
	brainrotContainer.BorderSizePixel = 0;
	brainrotContainer.Parent = tabFrames["Stealing"]
	mkCorner(brainrotContainer, 6);
	mkStroke(brainrotContainer, C.border, 1.5)
	local brainrotScroll = Instance.new("ScrollingFrame")
	brainrotScroll.Size = UDim2.new(1, - 8, 1, - 8);
	brainrotScroll.Position = UDim2.new(0, 4, 0, 4)
	brainrotScroll.BackgroundTransparency = 1;
	brainrotScroll.BorderSizePixel = 0
	brainrotScroll.ScrollBarThickness = 4;
	brainrotScroll.ScrollBarImageColor3 = C.purple
	brainrotScroll.CanvasSize = UDim2.new(0, 0, 0, 0);
	brainrotScroll.Parent = brainrotContainer
	local brainrotLayout = mkList(brainrotScroll, Enum.FillDirection.Vertical, 4, Enum.HorizontalAlignment.Center)
	mkPad(brainrotScroll, 4, 4, 4, 4)
	brainrotLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		brainrotScroll.CanvasSize = UDim2.new(0, 0, 0, brainrotLayout.AbsoluteContentSize.Y + 8)
	end)
	function rebuildBrainrotList()
		for _, c in ipairs(brainrotScroll:GetChildren()) do
			if c:IsA("TextButton") then
				c:Destroy()
			end
		end
		for _, br in ipairs(cachedBrainrots) do
			local sel = selectedBrainrot and selectedBrainrot.uid == br.uid
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 28);
			btn.BackgroundColor3 = sel and C.rowSel or C.row
			btn.TextColor3 = C.text;
			btn.Text = br.displayName .. " | " .. br.gen
			btn.Font = Enum.Font.Gotham;
			btn.TextSize = 10;
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.BorderSizePixel = 0;
			btn.AutoButtonColor = false;
			btn.Parent = brainrotScroll
			mkCorner(btn, 5);
			mkStroke(btn, sel and C.purple or C.border, 1.5);
			mkPad(btn, 0, 6, 6, 0)
			btn.MouseEnter:Connect(function()
				if not sel then
					tw(btn, {
						BackgroundColor3 = C.rowHov
					})
				end
			end)
			btn.MouseLeave:Connect(function()
				if not sel then
					tw(btn, {
						BackgroundColor3 = C.row
					})
				end
			end)
			btn.MouseButton1Click:Connect(function()
				selectedBrainrot = (selectedBrainrot and selectedBrainrot.uid == br.uid) and nil or br
				if selectedBrainrot then
					notify("Prioritizing " .. br.displayName, C.purple, 2)
				end
				rebuildBrainrotList()
			end)
		end
	end
	task.spawn(function()
		while task.wait(2) do
			rebuildBrainrotList()
		end
	end)
end
addDivider("Stealing")
addLabel("Stealing", "SEMI INSTANT STEAL")
addButton("Stealing", "Setup Desync", function()
	if G.SetupDesync then
		notify("Desync already active!", C.gold, 2);
		return
	end
	applyFFlags(FFlagsDesync);
	G.SetupDesync = true
	notify("Desync done! Respawning...", C.green, 3);
	respawn(player)
end)
addToggle("Stealing", "Auto Desync", "AutoResetDesync")
addToggle("Stealing", "Auto Giant Potion", "AutoPotion")
addToggle("Stealing", "Auto TP On Unlock", "AutoTPonUnlock")
addToggle("Stealing", "Auto TP On Allow", "AutoTPonAllow")
addToggle("Stealing", "Auto TP On Timer End", "AutoStealOnTimerEnd")
addToggle("Stealing", "Auto Instant Steal After Respawn", "AutoInstantStealOnRespawn")
addToggle("Stealing", "Auto Walk After Steal", "AutoWalkAfterSteal")
local instantStealSlotBtn = addButton("Stealing", "Instant Steal Slot: " .. tostring(G.InstantStealSlotMode or "First Slot"), function()
end)
instantStealSlotBtn.MouseButton1Click:Connect(function()
	local current = G.InstantStealSlotMode or "First Slot"
	if current == "First Slot" then
		G.InstantStealSlotMode = "Second Slot"
	elseif current == "Second Slot" then
		G.InstantStealSlotMode = "Top Floor First Slot"
	else
		G.InstantStealSlotMode = "First Slot"
	end
	syncInstantStealSlotFlags()
	instantStealSlotBtn.Text = "Instant Steal Slot: " .. tostring(G.InstantStealSlotMode)
	saveConfig()
end)
local stealMethodBtn = addButton("Stealing", "Steal Method: " .. tostring(G.StealMethod or "Walk"), function() end)
stealMethodBtn.MouseButton1Click:Connect(function()
	if G.StealMethod == "Walk" then
		G.StealMethod = "Prime"
	else
		G.StealMethod = "Walk"
	end
	stealMethodBtn.Text = "Steal Method: " .. tostring(G.StealMethod)
	saveConfig()
end)
do
	local sasResult = addToggleWithGear("Stealing", "Auto Spam After Steal", "AutoSpamAfterSteal", nil)
	for _, child in ipairs(sasResult.row:GetChildren()) do
		if child:IsA("TextLabel") then
			child.TextSize = 11;
			break
		end
	end
	local openSASPanel = makeCmdConfigPanel("Spam After Steal Cmds", "StealSpamCmds", sasResult.gear)
	sasResult.gear.MouseButton1Click:Connect(openSASPanel)
end
addButton("Stealing", "Do Instant Steal", function()
	triggerConfiguredSemiInstant()
end)
function getAutoFIWaypoint(target)
	local currentTarget = target or getCurrentStealCandidate() or currentStealTarget
	local _, base = getCurrentBase()
	return (base == BASE_POSITIONS.BASE1) and CFrame.new(-373, -7, 79) or CFrame.new(-371.9351806640625, -6.308239936828613, 50.19520568847656)
end
addLabel("Combat", "AUTO DEFENSE")
do
	local defResult = addToggleWithGear("Combat", "Auto Defense", "AutoDefense", nil)
	local openDefCmdsPanel = makeTabbedCmdPanel("Defense Commands", {
		{
			"1P #1",
			"DefCmds1"
		},
		{
			"1P #2",
			"DefCmds2"
		},
		{
			"2P #1",
			"DefCmdsMulti1"
		},
		{
			"2P #2",
			"DefCmdsMulti2"
		},
	}, defResult.gear)
	defResult.gear.MouseButton1Click:Connect(openDefCmdsPanel)
end
do
	local adminWindowToggle = addToggle("Combat", "Admin Panel Window", "ShowAdminPanelWindow")
	local previousState = nil
	local function syncAdminPanelWindow()
		adminPanelWindow.Visible = G.ShowAdminPanelWindow
		if G.ShowAdminPanelWindow then
			rebuildAdminPanelWindow()
		end
		adminWindowToggle.refresh()
	end
	syncAdminPanelWindow()
	task.spawn(function()
		while task.wait(0.1) do
			if previousState ~= G.ShowAdminPanelWindow then
				previousState = G.ShowAdminPanelWindow
				syncAdminPanelWindow()
			end
		end
	end)
end
do
	local skResult = addToggleWithGear("Combat", "Safety Kick", "SafteyKick", nil)
	local skPanel = Instance.new("Frame")
	skPanel.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
	skPanel.BorderSizePixel = 0;
	skPanel.ZIndex = 300;
	skPanel.Visible = false;
	skPanel.Parent = gui
	mkCorner(skPanel, 8);
	mkStroke(skPanel, C.purple, 1.5)
	local skTitleBar = Instance.new("Frame")
	skTitleBar.Size = UDim2.new(1, 0, 0, 22)
	skTitleBar.BackgroundColor3 = C.header;
	skTitleBar.BorderSizePixel = 0
	skTitleBar.ZIndex = 301;
	skTitleBar.Parent = skPanel
	mkCorner(skTitleBar, 7)
	local skTitleFix = Instance.new("Frame")
	skTitleFix.Size = UDim2.new(1, 0, 0, 7);
	skTitleFix.Position = UDim2.new(0, 0, 1, - 7)
	skTitleFix.BackgroundColor3 = C.header;
	skTitleFix.BorderSizePixel = 0
	skTitleFix.ZIndex = 301;
	skTitleFix.Parent = skTitleBar
	local skTitleLbl = Instance.new("TextLabel")
	skTitleLbl.Size = UDim2.new(1, - 24, 1, 0);
	skTitleLbl.Position = UDim2.new(0, 6, 0, 0)
	skTitleLbl.BackgroundTransparency = 1;
	skTitleLbl.Text = "Kick Settings"
	skTitleLbl.TextColor3 = C.textDim;
	skTitleLbl.Font = Enum.Font.GothamBold
	skTitleLbl.TextSize = 9;
	skTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	skTitleLbl.ZIndex = 302;
	skTitleLbl.Parent = skTitleBar
	local skClose = Instance.new("TextButton")
	skClose.Size = UDim2.new(0, 14, 0, 14);
	skClose.Position = UDim2.new(1, - 17, 0.5, - 7)
	skClose.BackgroundColor3 = C.purpleDim;
	skClose.TextColor3 = C.text;
	skClose.Text = "X"
	skClose.Font = Enum.Font.GothamBold;
	skClose.TextSize = 10
	skClose.BorderSizePixel = 0;
	skClose.AutoButtonColor = false;
	skClose.ZIndex = 303
	skClose.Parent = skTitleBar;
	mkCorner(skClose, 3)
	function mkSubToggle(parent, yPos, labelText, cfgKey)
		local r = Instance.new("TextButton")
		r.Size = UDim2.new(1, - 10, 0, 28);
		r.Position = UDim2.new(0, 5, 0, yPos)
		r.BackgroundColor3 = C.row;
		r.Text = "";
		r.BorderSizePixel = 0
		r.AutoButtonColor = false;
		r.ZIndex = 301;
		r.Parent = parent
		mkCorner(r, 5);
		mkStroke(r, C.border, 1.2)
		local rl = Instance.new("TextLabel")
		rl.Size = UDim2.new(1, - 24, 1, 0);
		rl.Position = UDim2.new(0, 6, 0, 0)
		rl.BackgroundTransparency = 1;
		rl.Text = labelText
		rl.TextColor3 = C.text;
		rl.Font = Enum.Font.GothamBold;
		rl.TextSize = 10
		rl.TextXAlignment = Enum.TextXAlignment.Left;
		rl.ZIndex = 302;
		rl.Parent = r
		local rd = Instance.new("Frame")
		rd.Size = UDim2.new(0, 8, 0, 8);
		rd.Position = UDim2.new(1, - 14, 0.5, - 4)
		rd.BorderSizePixel = 0;
		rd.ZIndex = 302;
		rd.Parent = r;
		mkCorner(rd, 4)
		local rStroke = mkStroke(r, C.border, 1.2)
		function refreshR()
			local on = G[cfgKey]
			tw(rStroke, {
				Color = on and C.purple or C.border
			})
			tw(r, {
				BackgroundColor3 = on and C.rowSel or C.row
			})
			tw(rd, {
				BackgroundColor3 = on and C.green or Color3.fromRGB(50, 50, 65)
			})
		end
		refreshR()
		r.MouseButton1Click:Connect(function()
			G[cfgKey] = not G[cfgKey];
			refreshR()
			notify(labelText .. " " .. (G[cfgKey] and "Enabled" or "Disabled"), G[cfgKey] and C.green or C.red, 2)
		end)
	end
	local PAD = 5;
	local ROW_H = 28
	local skTotalH = 22 + PAD + 2 * (ROW_H + PAD) + PAD
	skPanel.Size = UDim2.new(0, 170, 0, skTotalH)
	mkSubToggle(skPanel, 22 + PAD, "Kick If No Cmds", "KickNoCmds")
	mkSubToggle(skPanel, 22 + PAD + ROW_H + PAD, "Kick 3rd Player", "KickThirdPlayer")
	local skOpen = false
	skClose.MouseButton1Click:Connect(function()
		skPanel.Visible = false;
		skOpen = false
	end)
	table.insert(openPanelClosers, function()
		skPanel.Visible = false;
		skOpen = false
	end)
	skResult.gear.MouseButton1Click:Connect(function()
		skOpen = not skOpen
		if skOpen then
			local ap = skResult.gear.AbsolutePosition
			local as = skResult.gear.AbsoluteSize
			local vpSize = Camera.ViewportSize
			local px = ap.X + as.X + 6;
			local py = ap.Y
			if px + 170 > vpSize.X then
				px = ap.X - 176
			end
			if py + skTotalH > vpSize.Y then
				py = vpSize.Y - skTotalH - 4
			end
			skPanel.Position = UDim2.new(0, px, 0, py)
		end
		skPanel.Visible = skOpen
	end)
end
do
	local atpResult = addToggleWithGear("Combat", "Anti TP Scam", "AntiTPScam", nil)
	local openAntiTpPanel = makeCmdConfigPanel("Anti TP Scam Cmds", "AntiTpCmds", atpResult.gear)
	atpResult.gear.MouseButton1Click:Connect(openAntiTpPanel)
end
do
	local tppResult = addToggleWithGear("Combat", "TP Protector", "TPProtector", nil)
	tppResult.row.MouseButton1Click:Connect(function()
		if G.TPProtector then
			for _, plr in ipairs(Players:GetPlayers()) do
				initTpTracking(plr)
			end
		end
	end)
	local openTpProtPanel = makeCmdConfigPanel("TP Protector Cmds", "TpProtCmds", tppResult.gear)
	tppResult.gear.MouseButton1Click:Connect(openTpProtPanel)
end
do
	function doAPSpam()
		if tick() - lastExecuteTime < executeCooldown then
			return
		end
		local valid = getAPSpamTargets()
		if # valid == 0 then
			defenseDebug("No AP targets found")
			notify("AP Spam found no valid targets", C.red, 2)
			return
		end
		if # valid == 1 then
			if not switch then
				executeAdminCommands(valid[1], G.APSpamCmds1)
			else
				executeAdminCommands(valid[1], G.APSpamCmds2)
				if G.SafteyKick or G.KickNoCmds then
					task.wait(1);
					player:Kick("Safety Kick: Out of commands")
				end
			end
		else
			executeAdminCommands(valid[1], G.APSpamCmds1)
			executeAdminCommands(valid[2], G.APSpamCmds2)
		end
		lastExecuteTime = tick()
	end
	local apBtn = addButtonWithGear("Combat", "AP SPAM", doAPSpam, nil)
	local openAPPanel = makeTabbedCmdPanel("AP Spam Commands", {
		{
			"Player 1",
			"APSpamCmds1"
		},
		{
			"Player 2",
			"APSpamCmds2"
		},
	}, apBtn)
	for _, child in ipairs(apBtn:GetChildren()) do
		if child:IsA("TextButton") and child.Text == "G" then
			child.MouseButton1Click:Connect(openAPPanel)
			break
		end
	end
end
addDivider("Combat")
addLabel("Combat", "AUTO BLOCK")
addToggle("Combat", "Auto Block", "Autoblock")
addButton("Combat", "TP & Block", function()
	tpandblock()
end)
Players.PlayerAdded:Connect(function(plr)
	if plr == player then
		return
	end
	notify(plr.DisplayName .. " joined", Color3.fromRGB(255, 150, 0), 4)
	if G.KickThirdPlayer then
		local others = 0
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player then
				others += 1
			end
		end
		if others >= 2 then
			player:Kick("Safety Kick: 3rd player joined")
		end
	end
	initTpTracking(plr)
end)
Players.PlayerRemoving:Connect(function(plr)
	if plr ~= player then
		notify(plr.DisplayName .. " left", C.red, 4)
	end
	invalidateCache(plr.Name)
	local uid = plr.UserId
	tpLastPos[uid] = nil;
	tpLastTime[uid] = nil;
	tpCooldown[uid] = nil;
	tpCharTracker[uid] = nil
end)
player.CharacterAdded:Connect(function()
	task.wait(1)
	for name in pairs(profileCache) do
		profileCache[name] = nil
	end
end)
for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= player then
		plr.CharacterAdded:Connect(function()
			task.wait(0.5);
			invalidateCache(plr.Name)
			task.wait(0.1);
			initTpTracking(plr)
		end)
	end
end
Players.PlayerAdded:Connect(function(plr)
	if plr ~= player then
		plr.CharacterAdded:Connect(function()
			task.wait(0.5);
			invalidateCache(plr.Name)
			task.wait(0.1);
			initTpTracking(plr)
		end)
	end
end)
addLabel("ESP", "ESP TOGGLES")
addToggle("ESP", "Brainrot ESP", "BrainrotESP")
addToggle("ESP", "FriendPanel ESP", "FriendPanelESP")
addToggle("ESP", "Player ESP", "PlayerESP")
addToggle("ESP", "Stealing ESP", "StealingESP")
addToggle("ESP", "Timer ESP", "TimerESP")
addToggle("ESP", "Notifications", "Notifactions")
addToggle("ESP", "Mine/Trap ESP", "MineESP")
addToggle("ESP", "ForceField Brainrots", "ForceFieldCubes")
addDivider("ESP")
addLabel("ESP", "LINES")
addToggle("ESP", "Line to Best", "LineToBest")
addToggle("ESP", "Line to Base", "LineToBase")
addDivider("ESP")
addLabel("ESP", "CAMERA")
addSlider("ESP", "FOV", "FOVValue", 30, 120, 1)
addSlider("ESP", "Stretch", "StretchValue", 0.1, 1, 0.05)
addDivider("ESP")
addLabel("ESP", "SKY CHANGER")
addToggle("ESP", "Strawberry Event", "StrawberryEvent")
addToggle("ESP", "Strawberry Sky", "StrawberrySky")
addToggle("ESP", "Meowl Event", "MeowlEvent")
addToggle("ESP", "Meowl Sky", "MeowlSky")
addDivider("ESP")
addLabel("ESP", "MEOWL PET")
addToggle("ESP", "Meowl Follow Pet", "MeowlPet")
addSlider("ESP", "Meowl Pet Scale", "MeowlPetScale", 0.25, 2, 0.05)
addButton("ESP", "Green Galaxy", function()
	setSky("greengalaxy");
	saveConfig();
	notify("Sky: Green Galaxy", C.green, 2)
end)
addButton("ESP", "Space", function()
	setSky("space");
	saveConfig();
	notify("Sky: Space", C.green, 2)
end)
addButton("ESP", "Nebula", function()
	setSky("nebula");
	saveConfig();
	notify("Sky: Nebula", C.green, 2)
end)
addButton("ESP", "Clear Sky", function()
	clearSky();
	saveConfig();
	notify("Sky: Cleared", C.green, 2)
end)
addToggle("Priority", "Priority ESP", "PriorityESP")
addDivider("Priority")
addLabel("Priority", "PRIORITY BRAINROTS")
do
	local parent = tabFrames["Priority"]
	addLabel("Priority", "AVAILABLE")
	local availFrame = Instance.new("Frame")
	availFrame.Size = UDim2.new(1, 0, 0, 0);
	availFrame.AutomaticSize = Enum.AutomaticSize.Y
	availFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26);
	availFrame.BackgroundTransparency = 0.2
	availFrame.BorderSizePixel = 0;
	availFrame.Parent = parent
	mkCorner(availFrame, 8);
	mkStroke(availFrame, C.border, 1.5)
	mkList(availFrame, Enum.FillDirection.Vertical, 1, Enum.HorizontalAlignment.Center)
	mkPad(availFrame, 4, 4, 4, 4)
	addDivider("Priority")
	addLabel("Priority", "PRIORITY ORDER (top = highest)")
	local activeFrame = Instance.new("Frame")
	activeFrame.Size = UDim2.new(1, 0, 0, 0);
	activeFrame.AutomaticSize = Enum.AutomaticSize.Y
	activeFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26);
	activeFrame.BackgroundTransparency = 0.2
	activeFrame.BorderSizePixel = 0;
	activeFrame.Parent = parent
	mkCorner(activeFrame, 8);
	mkStroke(activeFrame, C.border, 1.5)
	mkList(activeFrame, Enum.FillDirection.Vertical, 1, Enum.HorizontalAlignment.Center)
	mkPad(activeFrame, 4, 4, 4, 4)
	local function clearChildren(frame)
		for _, c in ipairs(frame:GetChildren()) do
			if c:IsA("GuiObject") and not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
				c:Destroy()
			end
		end
	end
	local function rebuildUI()
		clearChildren(availFrame)
		clearChildren(activeFrame)
		for idx, name in ipairs(G.PriorityNames) do
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, - 4, 0, 28);
			row.BackgroundColor3 = Color3.fromRGB(40, 30, 55)
			row.BackgroundTransparency = 0.1;
			row.BorderSizePixel = 0
			row.LayoutOrder = idx;
			row.Parent = activeFrame
			mkCorner(row, 4)
			local rankLbl = Instance.new("TextLabel")
			rankLbl.Size = UDim2.new(0, 22, 1, 0);
			rankLbl.Position = UDim2.new(0, 4, 0, 0)
			rankLbl.BackgroundTransparency = 1;
			rankLbl.Text = "#" .. idx
			rankLbl.TextColor3 = Color3.fromRGB(255, 200, 50);
			rankLbl.Font = Enum.Font.GothamBold
			rankLbl.TextSize = 11;
			rankLbl.Parent = row
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, - 100, 1, 0);
			lbl.Position = UDim2.new(0, 28, 0, 0)
			lbl.BackgroundTransparency = 1;
			lbl.Text = name
			lbl.TextColor3 = Color3.fromRGB(255, 200, 50);
			lbl.Font = Enum.Font.Gotham
			lbl.TextSize = 11;
			lbl.TextXAlignment = Enum.TextXAlignment.Left;
			lbl.Parent = row
			local upBtn = Instance.new("TextButton")
			upBtn.Size = UDim2.new(0, 22, 0, 22);
			upBtn.Position = UDim2.new(1, - 72, 0.5, - 11)
			upBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70);
			upBtn.BackgroundTransparency = 0.3
			upBtn.Text = "^";
			upBtn.TextColor3 = C.text;
			upBtn.Font = Enum.Font.GothamBold
			upBtn.TextSize = 10;
			upBtn.BorderSizePixel = 0;
			upBtn.AutoButtonColor = false;
			upBtn.Parent = row
			mkCorner(upBtn, 4)
			upBtn.Text = "^";
			upBtn.TextSize = 12;
			upBtn.ZIndex = 5
			local downBtn = Instance.new("TextButton")
			downBtn.Size = UDim2.new(0, 22, 0, 22);
			downBtn.Position = UDim2.new(1, - 48, 0.5, - 11)
			downBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70);
			downBtn.BackgroundTransparency = 0.3
			downBtn.Text = "v";
			downBtn.TextColor3 = C.text;
			downBtn.Font = Enum.Font.GothamBold
			downBtn.TextSize = 10;
			downBtn.BorderSizePixel = 0;
			downBtn.AutoButtonColor = false;
			downBtn.Parent = row
			mkCorner(downBtn, 4)
			downBtn.Text = "v";
			downBtn.TextSize = 12;
			downBtn.ZIndex = 5
			local removeBtn = Instance.new("TextButton")
			removeBtn.Size = UDim2.new(0, 22, 0, 22);
			removeBtn.Position = UDim2.new(1, - 24, 0.5, - 11)
			removeBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30);
			removeBtn.BackgroundTransparency = 0.3
			removeBtn.Text = "X";
			removeBtn.TextColor3 = C.text;
			removeBtn.Font = Enum.Font.GothamBold
			removeBtn.TextSize = 10;
			removeBtn.BorderSizePixel = 0;
			removeBtn.AutoButtonColor = false;
			removeBtn.Parent = row
			mkCorner(removeBtn, 4)
			removeBtn.Text = "X";
			removeBtn.TextSize = 12;
			removeBtn.ZIndex = 5
			upBtn.MouseButton1Click:Connect(function()
				if idx <= 1 then
					return
				end
				G.PriorityNames[idx], G.PriorityNames[idx - 1] = G.PriorityNames[idx - 1], G.PriorityNames[idx]
				rebuildPrioritySet();
				saveConfig();
				rebuildUI()
			end)
			downBtn.MouseButton1Click:Connect(function()
				if idx >= # G.PriorityNames then
					return
				end
				G.PriorityNames[idx], G.PriorityNames[idx + 1] = G.PriorityNames[idx + 1], G.PriorityNames[idx]
				rebuildPrioritySet();
				saveConfig();
				rebuildUI()
			end)
			removeBtn.MouseButton1Click:Connect(function()
				prioritySet[name] = nil
				table.remove(G.PriorityNames, idx)
				rebuildPrioritySet();
				saveConfig();
				rebuildUI()
			end)
		end
		local availOrder = 0
		for _, name in ipairs(PRIORITY_LIST) do
			if not prioritySet[name] then
				availOrder = availOrder + 1
				local row = Instance.new("TextButton")
				row.Size = UDim2.new(1, - 4, 0, 24);
				row.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
				row.BackgroundTransparency = 0.1;
				row.Text = "";
				row.BorderSizePixel = 0
				row.AutoButtonColor = false;
				row.LayoutOrder = availOrder;
				row.Parent = availFrame
				mkCorner(row, 4)
				local addLbl = Instance.new("TextLabel")
				addLbl.Size = UDim2.new(0, 20, 1, 0);
				addLbl.Position = UDim2.new(0, 4, 0, 0)
				addLbl.BackgroundTransparency = 1;
				addLbl.Text = "+"
				addLbl.TextColor3 = C.green;
				addLbl.Font = Enum.Font.GothamBold
				addLbl.TextSize = 12;
				addLbl.Parent = row
				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, - 28, 1, 0);
				lbl.Position = UDim2.new(0, 24, 0, 0)
				lbl.BackgroundTransparency = 1;
				lbl.Text = name
				lbl.TextColor3 = C.text;
				lbl.Font = Enum.Font.Gotham;
				lbl.TextSize = 11
				lbl.TextXAlignment = Enum.TextXAlignment.Left;
				lbl.Parent = row
				row.MouseButton1Click:Connect(function()
					prioritySet[name] = true
					table.insert(G.PriorityNames, name)
					rebuildPrioritySet();
					saveConfig();
					rebuildUI()
				end)
				row.MouseEnter:Connect(function()
					tw(row, {
						BackgroundColor3 = Color3.fromRGB(35, 28, 48)
					})
				end)
				row.MouseLeave:Connect(function()
					row.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
				end)
			end
		end
	end
	rebuildUI()
	addDivider("Priority")
	addButton("Priority", "Select All", function()
		G.PriorityNames = {}
		for _, name in ipairs(PRIORITY_LIST) do
			prioritySet[name] = true
			table.insert(G.PriorityNames, name)
		end
		rebuildPrioritySet();
		saveConfig();
		rebuildUI()
		notify("All priority brainrots selected", C.green, 2)
	end)
	addButton("Priority", "Deselect All", function()
		G.PriorityNames = {}
		prioritySet = {}
		rebuildPrioritySet();
		saveConfig();
		rebuildUI()
		notify("All priority brainrots cleared", C.red, 2)
	end, Color3.fromRGB(80, 30, 30), Color3.fromRGB(120, 40, 40), Color3.fromRGB(100, 30, 30))
end
task.spawn(function()
	while task.wait(0.1) do
		Camera.FieldOfView = G.FOVValue
	end
end)
connectLoop(function()
	if G.StretchValue ~= 1 then
		Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, G.StretchValue, 0, 0, 0, 1)
	end
end)
do
	local ffParts = {}
	local ffConns = {}
	function isCube(v)
		if not v:IsA("BasePart") then
			return false
		end
		return v.Name:find("Cube") or v.Name:find("Plane")
	end
	function applyFF(v)
		if ffParts[v] then
			return
		end
		ffParts[v] = v.Material
		v.Material = Enum.Material.ForceField
	end
	function removeFF()
		for _, c in ipairs(ffConns) do
			pcall(function()
				c:Disconnect()
			end)
		end
		ffConns = {}
		for part, orig in pairs(ffParts) do
			pcall(function()
				part.Material = orig
			end)
		end
		ffParts = {}
	end
	function refreshFF()
		removeFF()
		if not G.ForceFieldCubes then
			return
		end
		for _, v in ipairs(workspace.Plots:GetDescendants()) do
			if isCube(v) then
				applyFF(v)
			end
		end
		local conn = workspace.Plots.DescendantAdded:Connect(function(v)
			if G.ForceFieldCubes and isCube(v) then
				applyFF(v)
			end
		end)
		table.insert(ffConns, conn)
	end
	task.spawn(function()
		local lastFF = G.ForceFieldCubes
		while task.wait(0.3) do
			if G.ForceFieldCubes ~= lastFF then
				lastFF = G.ForceFieldCubes
				refreshFF()
			end
		end
	end)
end
addLabel("Settings", "KEYBINDS")
local actionButtonBindState = nil
local actionButtonKeybinds = {}
local Keybinds = {
	ToggleSpeed = {
		key = G.KeybindToggleSpeed or "Y",
		fn = function()
			G.Speed = not G.Speed;
			notify("Speed " .. (G.Speed and "Enabled" or "Disabled"), G.Speed and C.green or C.red, 2)
		end,
	},
	ToggleGui = {
		key = G.KeybindToggleGui or "V",
		fn = function()
			mainFrame.Visible = not mainFrame.Visible
		end,
	},
	ManualSemi = {
		key = G.KeybindManualSemi or "B",
		fn = triggerConfiguredSemiInstant,
	},
	ManualDefense = {
		key = G.KeybindManualDefense or "F",
		fn = doAPSpam,
	},
}
addLabel("Settings", "Right Click a button to set a keybind")
addDivider("Settings")
addToggle("Settings", "Show Action Buttons", "ShowActionButtons")
addToggle("Settings", "Show Semi Steal", "ShowBtnSemiSteal")
addToggle("Settings", "Show Insta Reset", "ShowBtnInstaReset")
addToggle("Settings", "Show Setup Desync", "ShowBtnSetupDesync")
addToggle("Settings", "Show AP Spam", "ShowBtnAPSpam")
addToggle("Settings", "Show Leave", "ShowBtnLeave")
addToggle("Settings", "Show Rejoin", "ShowBtnRejoin")
addToggle("Settings", "Show Allow Toggle", "ShowBtnAllowToggle")
addToggle("Settings", "Show Self Ragdoll", "ShowBtnSelfRagdoll")
addToggle("Settings", "use pvp hub button style", "UsePVPActionButtonStyle")
addLabel("Settings", "ACTIONS")
addButton("Settings", "Do Instant Steal", function()
	if Keybinds.ManualSemi.fn then
		Keybinds.ManualSemi.fn()
	end
end)
addButton("Settings", "Insta Reset", function()
	instareset()
end)
addButton("Settings", "Setup Desync", function()
	if G.SetupDesync then
		notify("Desync already active!", C.gold, 2)
		return
	end
	applyFFlags(FFlagsDesync)
	G.SetupDesync = true
	notify("Desync done! Respawning...", C.green, 3)
	respawn(player)
end)
addButton("Settings", "Allow / Disallow", function()
	toggleFriendPanelAllow()
end)
addButton("Settings", "Self Ragdoll", function()
	executeAdminCommands(player, {
		"ragdoll"
	})
end)
UserInputService.InputBegan:Connect(function(inp, gp)
	if actionButtonBindState then
		if inp.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		local bindKey = inp.KeyCode.Name
		local entry = actionButtonBindState
		actionButtonBindState = nil
		if bindKey == "Escape" then
			if entry.button and entry.button.Parent then
				entry.button.Text = entry.displayText
			end
			notify("Action button bind cancelled", C.gold, 2)
			return
		end
		if bindKey == "Backspace" or bindKey == "Delete" then
			G[entry.bindKeyConfig] = ""
			entry.bindKey = ""
			if entry.button and entry.button.Parent then
				entry.button.Text = entry.displayText
			end
			saveConfig()
			notify(entry.displayText .. " bind cleared", C.red, 2)
			return
		end
		G[entry.bindKeyConfig] = bindKey
		entry.bindKey = bindKey
		if entry.button and entry.button.Parent then
			entry.button.Text = entry.displayText
		end
		saveConfig()
		notify(entry.displayText .. " bound to " .. bindKey, C.green, 2)
		return
	end
	if gp then
		return
	end
	if inp.UserInputType == Enum.UserInputType.Keyboard then
		for _, entry in ipairs(actionButtonKeybinds) do
			if entry.bindKey and entry.bindKey ~= "" and inp.KeyCode.Name == entry.bindKey then
				if entry.callback then
					entry.callback()
				end
				return
			end
		end
		for _, kb in pairs(Keybinds) do
			if inp.KeyCode.Name == kb.key then
				kb.fn();
				break
			end
		end
	end
end)
addDivider("Settings")
do
	local ubX = vp.X * 0.5 - 84
	local ubY = 40
	local unlockBar = Instance.new("Frame")
	unlockBar.Size = UDim2.new(0, 190, 0, 42)
	unlockBar.Position = UDim2.new(0, ubX, 0, ubY)
	unlockBar.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
	unlockBar.BorderSizePixel = 0;
	unlockBar.ZIndex = 200
	unlockBar.Active = true;
	unlockBar.Parent = gui
	mkCorner(unlockBar, 8);
	mkStroke(unlockBar, C.border, 1.5)
	local ubDrag, ubDS, ubSP = false, nil, nil
	unlockBar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			ubDrag = true;
			ubDS = i.Position;
			ubSP = unlockBar.Position
		end
	end)
	unlockBar.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			ubDrag = false
		end
	end)
	unlockBar.InputChanged:Connect(function(i)
		if ubDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - ubDS
			unlockBar.Position = UDim2.new(0, ubSP.X.Offset + d.X, 0, ubSP.Y.Offset + d.Y)
		end
	end)
	local ubLayout2 = Instance.new("UIListLayout")
	ubLayout2.FillDirection = Enum.FillDirection.Horizontal;
	ubLayout2.Padding = UDim.new(0, 4)
	ubLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center;
	ubLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
	ubLayout2.SortOrder = Enum.SortOrder.LayoutOrder;
	ubLayout2.Parent = unlockBar
	mkPad(unlockBar, 4, 5, 5, 4)
	local ubColon = Instance.new("TextLabel");
	ubColon.Size = UDim2.new(0, 10, 1, 0)
	ubColon.BackgroundTransparency = 1;
	ubColon.Text = ":";
	ubColon.TextColor3 = C.textMute
	ubColon.Font = Enum.Font.GothamBold;
	ubColon.TextSize = 14;
	ubColon.TextXAlignment = Enum.TextXAlignment.Center
	ubColon.ZIndex = 201;
	ubColon.LayoutOrder = 0;
	ubColon.Parent = unlockBar
	for i = 1, 3 do
		local ubBtn = Instance.new("TextButton")
		ubBtn.Size = UDim2.new(0, 48, 1, 0);
		ubBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
		ubBtn.TextColor3 = C.text;
		ubBtn.Text = tostring(i);
		ubBtn.Font = Enum.Font.GothamBold
		ubBtn.TextSize = 17;
		ubBtn.BorderSizePixel = 0;
		ubBtn.AutoButtonColor = false
		ubBtn.LayoutOrder = i;
		ubBtn.ZIndex = 201;
		ubBtn.Parent = unlockBar
		mkCorner(ubBtn, 6);
		mkStroke(ubBtn, Color3.fromRGB(75, 75, 105), 1.2)
		if not mobile then
			ubBtn.MouseEnter:Connect(function()
				tw(ubBtn, {
					BackgroundColor3 = Color3.fromRGB(65, 65, 95)
				})
			end)
			ubBtn.MouseLeave:Connect(function()
				tw(ubBtn, {
					BackgroundColor3 = Color3.fromRGB(40, 40, 58)
				})
			end)
		end
		local cap = i
		ubBtn.MouseButton1Click:Connect(function()
			unlockBase(cap)
		end)
	end
end
local stealProgressBar = nil
local showProgress = function()
end
local hideProgress = function()
end
do
	local progressFrame = Instance.new("Frame")
	progressFrame.Size = UDim2.new(0, 300, 0, 80);
	progressFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	progressFrame.Position = UDim2.new(0.5, 0, 0.85, 0);
	progressFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	progressFrame.BorderSizePixel = 0;
	progressFrame.Visible = false;
	progressFrame.ZIndex = 100
	progressFrame.Active = true;
	progressFrame.Draggable = true;
	progressFrame.Parent = gui
	mkCorner(progressFrame, 12);
	mkStroke(progressFrame, C.purple, 2)
	local progressNameLbl = Instance.new("TextLabel")
	progressNameLbl.Size = UDim2.new(1, - 20, 0, 25);
	progressNameLbl.Position = UDim2.new(0, 10, 0, 10)
	progressNameLbl.BackgroundTransparency = 1;
	progressNameLbl.Text = "Stealing..."
	progressNameLbl.TextColor3 = C.text;
	progressNameLbl.Font = Enum.Font.GothamBold
	progressNameLbl.TextSize = 14;
	progressNameLbl.TextXAlignment = Enum.TextXAlignment.Left
	progressNameLbl.ZIndex = 101;
	progressNameLbl.Parent = progressFrame
	local progressGenLbl = Instance.new("TextLabel")
	progressGenLbl.Size = UDim2.new(1, - 25, 0, 25);
	progressGenLbl.Position = UDim2.new(0, 10, 0, 35)
	progressGenLbl.BackgroundTransparency = 1;
	progressGenLbl.Text = "0"
	progressGenLbl.TextColor3 = Color3.fromRGB(200, 200, 200);
	progressGenLbl.Font = Enum.Font.Gotham
	progressGenLbl.TextSize = 15;
	progressGenLbl.TextXAlignment = Enum.TextXAlignment.Left
	progressGenLbl.ZIndex = 101;
	progressGenLbl.Parent = progressFrame
	local progressBG = Instance.new("Frame")
	progressBG.Size = UDim2.new(1, - 20, 0, 10);
	progressBG.Position = UDim2.new(0, 10, 1, - 20)
	progressBG.BackgroundColor3 = Color3.fromRGB(40, 40, 50);
	progressBG.BorderSizePixel = 0
	progressBG.ZIndex = 101;
	progressBG.Parent = progressFrame;
	mkCorner(progressBG, 10)
	stealProgressBar = Instance.new("Frame")
	stealProgressBar.Size = UDim2.new(0, 0, 1, 0);
	stealProgressBar.BackgroundColor3 = C.purple
	stealProgressBar.BorderSizePixel = 0;
	stealProgressBar.ZIndex = 102;
	stealProgressBar.Parent = progressBG
	mkCorner(stealProgressBar, 10)
	showProgress = function(name, gen, progress)
		progressFrame.Visible = true
		progressNameLbl.Text = name
		progressGenLbl.Text = gen
		stealProgressBar.Size = UDim2.new(math.clamp(progress, 0, 1), 0, 1, 0)
	end
	hideProgress = function()
		progressFrame.Visible = false
	end
end
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 96, 0, mobile and 34 or 26);
hideBtn.Position = UDim2.new(0.5, - 48, 0, mobile and 0 or 4)
hideBtn.BackgroundColor3 = C.header;
hideBtn.TextColor3 = C.text;
hideBtn.Text = "HIDE/SHOW"
hideBtn.Font = Enum.Font.GothamBold;
hideBtn.TextSize = mobile and 12 or 10;
hideBtn.BorderSizePixel = 0
hideBtn.AutoButtonColor = false;
hideBtn.ZIndex = 100;
hideBtn.Parent = gui
mkCorner(hideBtn, 6);
mkStroke(hideBtn, C.purple, 1.5)
if not mobile then
	hideBtn.MouseEnter:Connect(function()
		tw(hideBtn, {
			BackgroundColor3 = C.purpleDim
		})
	end)
	hideBtn.MouseLeave:Connect(function()
		tw(hideBtn, {
			BackgroundColor3 = C.header
		})
	end)
end
local mainVisible = true
hideBtn.Activated:Connect(function()
	tw(hideBtn, {
		BackgroundColor3 = C.purpleDim
	})
	task.wait(0.1);
	tw(hideBtn, {
		BackgroundColor3 = C.header
	})
	mainVisible = not mainVisible
	if mainVisible then
		mainFrame.Visible = true
		tw(mainFrame, {
			BackgroundTransparency = 0.15
		}, 0.25)
		tw(mainStroke, {
			Transparency = 0
		}, 0.25)
	else
		tw(mainFrame, {
			BackgroundTransparency = 1
		}, 0.25)
		tw(mainStroke, {
			Transparency = 1
		}, 0.25)
		task.delay(0.25, function()
			if not mainVisible then
				mainFrame.Visible = false
			end
		end)
	end
end) ;
(function()
	local actionButtons = {}
	local actionButtonsLocked = G.ActionButtonsLocked ~= false
	local activeDragButton = nil
	local activeDragInput = nil
	local activeDragStart = nil
	local activeDragStartPos = nil
	local activeDragMoved = false
	local allowToggleEntry = nil
	local function getActionButtonStyle()
		if G.UsePVPActionButtonStyle then
			return {
				normalSize = UDim2.new(0, mobile and 108 or 116, 0, mobile and 24 or 26),
				pressedSize = UDim2.new(0, mobile and 108 or 116, 0, mobile and 24 or 26),
				baseColor = Color3.fromRGB(55, 85, 245),
				hoverColor = Color3.fromRGB(85, 110, 255),
				pressColor = Color3.fromRGB(85, 110, 255),
				strokeColor = Color3.fromRGB(140, 155, 255),
				strokeTransparency = 0,
				strokeThickness = mobile and 1.5 or 2,
				gradientRotation = 135,
				gradientOffset = Vector2.new(0, 0),
				gradientColors = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 120, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(68, 82, 205))
				}),
				glossVisible = false,
				pulse = false,
			}
		end
		return {
			normalSize = UDim2.new(0, mobile and 132 or 160, 0, mobile and 28 or 30),
			pressedSize = UDim2.new(0, mobile and 128 or 156, 0, mobile and 26 or 28),
			baseColor = Color3.fromRGB(96, 42, 184),
			hoverColor = Color3.fromRGB(118, 56, 218),
			pressColor = Color3.fromRGB(132, 72, 228),
			strokeColor = Color3.fromRGB(140, 155, 255),
			strokeTransparency = 1,
			strokeThickness = mobile and 1.5 or 2,
			gradientRotation = 25,
			gradientOffset = Vector2.new(- 0.35, 0),
			gradientColors = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(204, 150, 255)),
				ColorSequenceKeypoint.new(0.45, Color3.fromRGB(145, 78, 240)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(86, 36, 176))
			}),
			glossVisible = true,
			pulse = true,
		}
	end
	local function refreshActionButtons()
		local masterVisible = G.ShowActionButtons ~= false
		for _, entry in ipairs(actionButtons) do
			local btn = entry.button
			if btn and btn.Parent then
				local perVisible = entry.toggleKey == nil or G[entry.toggleKey] ~= false
				btn.Visible = masterVisible and perVisible
			end
		end
	end
	local function refreshActionButtonsLockButton()
		for _, entry in ipairs(actionButtons) do
			if entry.isLockButton and entry.button and entry.button.Parent then
				entry.button.Text = actionButtonsLocked and "Click to unlock" or "Click to lock"
				entry.button.BackgroundColor3 = actionButtonsLocked and Color3.fromRGB(96, 42, 184) or C.green
			end
		end
	end
	local function refreshActionButtonText(entry)
		if not (entry and entry.button and entry.button.Parent) then
			return
		end
		if actionButtonBindState == entry then
			entry.button.Text = "PRESS KEY"
			return
		end
		if entry.isLockButton then
			entry.button.Text = actionButtonsLocked and "Click to unlock" or "Click to lock"
			return
		end
		entry.button.Text = entry.displayText
	end
	local function applyActionButtonStyle(entry)
		local btn = entry.button
		if not (btn and btn.Parent) then
			return
		end
		local style = getActionButtonStyle()
		entry.normalSize = style.normalSize
		entry.pressedSize = style.pressedSize
		btn.Size = style.normalSize
		btn.BackgroundColor3 = style.baseColor
		btn.TextSize = mobile and 11 or 13
		entry.stroke.Color = style.strokeColor
		entry.stroke.Thickness = style.strokeThickness
		entry.stroke.Transparency = style.strokeTransparency
		entry.gradient.Color = style.gradientColors
		entry.gradient.Rotation = style.gradientRotation
		entry.gradient.Offset = style.gradientOffset
		entry.gloss.Enabled = style.glossVisible
		if style.pulse then
			pcall(function()
				entry.pulse:Cancel()
			end)
			entry.gradient.Offset = Vector2.new(- 0.35, 0)
			entry.pulse = TweenService:Create( entry.gradient, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, - 1, true), {
				Offset = Vector2.new(0.35, 0)
			})
			entry.pulse:Play()
		else
			pcall(function()
				entry.pulse:Cancel()
			end)
		end
		refreshActionButtonText(entry)
	end
	local function makeActionButton(text, xKey, yKey, toggleKey, callback, bindKeyConfig)
		local btn = Instance.new("TextButton")
		local style = getActionButtonStyle()
		btn.Size = style.normalSize
		btn.Position = UDim2.new(0, G[xKey], 0, G[yKey])
		btn.BackgroundColor3 = style.baseColor
		btn.TextColor3 = C.text
		btn.Text = text
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = mobile and 11 or 13
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		btn.Selectable = false
		btn.ZIndex = 100
		btn.Active = true
		btn:SetAttribute("HubActionButton", true)
		btn.Parent = gui
		btn:SetAttribute("DragXKey", xKey)
		btn:SetAttribute("DragYKey", yKey)
		mkCorner(btn, mobile and 5 or 7)
		local stroke = mkStroke(btn, style.strokeColor, style.strokeThickness)
		stroke.Transparency = style.strokeTransparency
		local gradient = Instance.new("UIGradient")
		gradient.Color = style.gradientColors
		gradient.Rotation = style.gradientRotation
		gradient.Offset = style.gradientOffset
		gradient.Parent = btn
		local gloss = Instance.new("UIGradient")
		gloss.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))
		})
		gloss.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0.00, 0.82),
			NumberSequenceKeypoint.new(0.35, 0.92),
			NumberSequenceKeypoint.new(1.00, 1.00)
		})
		gloss.Rotation = 90
		gloss.Parent = btn
		gloss.Enabled = style.glossVisible
		local pulse = TweenService:Create( gradient, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, - 1, true), {
			Offset = Vector2.new(0.35, 0)
		})
		if style.pulse then
			pulse:Play()
		end
		if not mobile then
			btn.MouseEnter:Connect(function()
				local hoverStyle = getActionButtonStyle()
				tw(btn, {
					BackgroundColor3 = hoverStyle.hoverColor
				})
			end)
			btn.MouseLeave:Connect(function()
				local leaveStyle = getActionButtonStyle()
				tw(btn, {
					BackgroundColor3 = leaveStyle.baseColor
				})
			end)
		end
		local entry
		btn.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton2 then
				if btn:GetAttribute("IsActionLockButton") then
					return
				end
				actionButtonBindState = entry
				activeDragButton = nil
				activeDragInput = nil
				activeDragStart = nil
				activeDragStartPos = nil
				activeDragMoved = false
				refreshActionButtonText(entry)
				notify("Press a key for " .. text .. " or Backspace to clear", C.purple, 3)
				return
			elseif i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				if actionButtonsLocked and not btn:GetAttribute("IsActionLockButton") then
					return
				end
				activeDragButton = btn
				activeDragInput = i
				activeDragStart = i.Position
				activeDragStartPos = btn.Position
				activeDragMoved = false
			end
		end)
		btn.Activated:Connect(function()
			local suppressUntil = btn:GetAttribute("SuppressActivateUntil") or 0
			if tick() < suppressUntil or (activeDragButton == btn and activeDragMoved) then
				return
			end
			local pressStyle = getActionButtonStyle()
			tw(btn, {
				Size = pressStyle.pressedSize,
				BackgroundColor3 = pressStyle.pressColor
			}, 0.08)
			if callback then
				callback()
			end
			task.delay(0.08, function()
				if btn and btn.Parent then
					local releaseStyle = getActionButtonStyle()
					tw(btn, {
						Size = releaseStyle.normalSize,
						BackgroundColor3 = releaseStyle.baseColor
					}, 0.1)
				end
			end)
		end)
		entry = {
			button = btn,
			displayText = text,
			toggleKey = toggleKey,
			callback = callback,
			bindKeyConfig = bindKeyConfig,
			bindKey = bindKeyConfig and G[bindKeyConfig] or "",
			stroke = stroke,
			gradient = gradient,
			gloss = gloss,
			pulse = pulse,
			normalSize = style.normalSize,
			pressedSize = style.pressedSize,
		}
		table.insert(actionButtons, entry)
		if bindKeyConfig then
			table.insert(actionButtonKeybinds, entry)
		end
		applyActionButtonStyle(entry)
		refreshActionButtons()
		refreshActionButtonsLockButton()
		return btn
	end
	UserInputService.InputChanged:Connect(function(i)
		if not activeDragButton then
			return
		end
		if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local d = i.Position - activeDragStart
		local threshold = (i.UserInputType == Enum.UserInputType.Touch) and 3 or 6
		if math.abs(d.X) > threshold or math.abs(d.Y) > threshold then
			activeDragMoved = true
		end
		local nx = math.clamp(activeDragStartPos.X.Offset + d.X, 0, Camera.ViewportSize.X - activeDragButton.AbsoluteSize.X)
		local ny = math.clamp(activeDragStartPos.Y.Offset + d.Y, 0, Camera.ViewportSize.Y - activeDragButton.AbsoluteSize.Y)
		activeDragButton.Position = UDim2.new(0, nx, 0, ny)
	end)
	UserInputService.InputEnded:Connect(function(i)
		if not activeDragButton then
			return
		end
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local btn = activeDragButton
		local xKey = btn:GetAttribute("DragXKey")
		local yKey = btn:GetAttribute("DragYKey")
		if activeDragMoved and xKey and yKey then
			G[xKey] = btn.Position.X.Offset
			G[yKey] = btn.Position.Y.Offset
			saveConfig()
			btn:SetAttribute("SuppressActivateUntil", tick() + 0.2)
		end
		activeDragButton = nil
		activeDragInput = nil
		activeDragStart = nil
		activeDragStartPos = nil
		activeDragMoved = false
	end)
	local actionLockBtn = makeActionButton("Click to unlock", "ActionBtnLockX", "ActionBtnLockY", nil, function()
		actionButtonsLocked = not actionButtonsLocked
		G.ActionButtonsLocked = actionButtonsLocked
		activeDragButton = nil
		activeDragInput = nil
		activeDragStart = nil
		activeDragStartPos = nil
		activeDragMoved = false
		refreshActionButtonsLockButton()
		saveConfig()
	end)
	actionLockBtn:SetAttribute("IsActionLockButton", true)
	for _, entry in ipairs(actionButtons) do
		if entry.button == actionLockBtn then
			entry.isLockButton = true
			break
		end
	end
	refreshActionButtonsLockButton()
	makeActionButton("DO INSTANT STEAL", "ActionBtnSemiStealX", "ActionBtnSemiStealY", "ShowBtnSemiSteal", function()
		if Keybinds.ManualSemi.fn then
			Keybinds.ManualSemi.fn()
		end
	end, "ActionBtnSemiStealKey")
	makeActionButton("INSTA RESET", "ActionBtnInstaResetX", "ActionBtnInstaResetY", "ShowBtnInstaReset", function()
		instareset()
	end, "ActionBtnInstaResetKey")
	makeActionButton("SETUP DESYNC", "ActionBtnSetupDesyncX", "ActionBtnSetupDesyncY", "ShowBtnSetupDesync", function()
		if G.SetupDesync then
			notify("Desync already active!", C.gold, 2)
			return
		end
		applyFFlags(FFlagsDesync)
		G.SetupDesync = true
		notify("Desync done! Respawning...", C.green, 3)
		respawn(player)
	end, "ActionBtnSetupDesyncKey")
	makeActionButton("AP SPAM", "ActionBtnAPSpamX", "ActionBtnAPSpamY", "ShowBtnAPSpam", function()
		doAPSpam()
	end, "ActionBtnAPSpamKey")
	makeActionButton("LEAVE", "ActionBtnLeaveX", "ActionBtnLeaveY", "ShowBtnLeave", function()
		player:Kick("chiraq hub on top :3")
	end, "ActionBtnLeaveKey")
	makeActionButton("REJOIN", "ActionBtnRejoinX", "ActionBtnRejoinY", "ShowBtnRejoin", function()
		Players.LocalPlayer:Kick("\nRejoining...")
		task.wait()
		game:GetService("TeleportService"):Teleport(game.PlaceId, player)
	end, "ActionBtnRejoinKey")
	allowBtn = makeActionButton("ALLOW / DISALLOW", "ActionBtnAllowToggleX", "ActionBtnAllowToggleY", "ShowBtnAllowToggle", function()
		toggleFriendPanelAllow()
	end, "ActionBtnAllowToggleKey")
	for _, entry in ipairs(actionButtons) do
		if entry.button == allowBtn then
			allowToggleEntry = entry
			break
		end
	end
	makeActionButton("SELF RAGDOLL", "ActionBtnSelfRagdollX", "ActionBtnSelfRagdollY", "ShowBtnSelfRagdoll", function()
		executeAdminCommands(player, {
			"ragdoll"
		})
	end, "ActionBtnSelfRagdollKey")
	task.spawn(function()
		local lastState = nil
		while task.wait(0.1) do
			local state = table.concat({
				tostring(G.ShowActionButtons ~= false),
				tostring(G.ShowBtnSemiSteal ~= false),
				tostring(G.ShowBtnManualDef ~= false),
				tostring(G.ShowBtnInstaReset ~= false),
				tostring(G.ShowBtnSetupDesync ~= false),
				tostring(G.ShowBtnAPSpam ~= false),
				tostring(G.ShowBtnLeave ~= false),
				tostring(G.ShowBtnRejoin ~= false),
				tostring(G.ShowBtnAllowToggle ~= false),
				tostring(G.ShowBtnSelfRagdoll ~= false),
				tostring(G.UsePVPActionButtonStyle == true),
				"allow-disallow",
			}, "|")
			if state ~= lastState then
				lastState = state
				for _, entry in ipairs(actionButtons) do
					applyActionButtonStyle(entry)
				end
				refreshActionButtons()
				refreshActionButtonsLockButton()
			end
		end
	end)
end)()
local watermarkname, infoLbl
if not mobile then
	local wm = Instance.new("Frame")
	wm.Size = UDim2.new(0, 260, 0, 68)
	wm.Position = UDim2.new(0.5, - 130, 0, 100)
	wm.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
	wm.BackgroundTransparency = 0.08
	wm.BorderSizePixel = 0
	wm.ZIndex = 200
	wm.Parent = gui
	mkCorner(wm, 10)
	mkStroke(wm, C.purple, 2)
	mkPad(wm, 8, 8, 8, 8)
	watermarkname = Instance.new("TextLabel")
	watermarkname.Size = UDim2.new(1, 0, 0, 18)
	watermarkname.Position = UDim2.new(0, 0, 0, 4)
	watermarkname.BackgroundTransparency = 1
	watermarkname.Text = "CHIRAQ HUB  |  discord.gg/chiraqhub"
	watermarkname.TextColor3 = Color3.fromRGB(255, 255, 255)
	watermarkname.Font = Enum.Font.GothamBold
	watermarkname.TextSize = 12
	watermarkname.TextXAlignment = Enum.TextXAlignment.Center
	watermarkname.ZIndex = 202
	watermarkname.Parent = wm
	local authorLbl = Instance.new("TextLabel")
	authorLbl.Size = UDim2.new(1, 0, 0, 14)
	authorLbl.Position = UDim2.new(0, 0, 0, 22)
	authorLbl.BackgroundTransparency = 1
	authorLbl.Text = "by saturday011201"
	authorLbl.TextColor3 = C.textMute
	authorLbl.Font = Enum.Font.Gotham
	authorLbl.TextSize = 12
	authorLbl.TextXAlignment = Enum.TextXAlignment.Center
	authorLbl.ZIndex = 202
	authorLbl.Parent = wm
	local div = Instance.new("Frame")
	div.Size = UDim2.new(1, - 16, 0, 1)
	div.Position = UDim2.new(0, 8, 0, 39)
	div.BackgroundColor3 = C.border
	div.BorderSizePixel = 0
	div.ZIndex = 202
	div.Parent = wm
	infoLbl = Instance.new("TextLabel")
	infoLbl.Size = UDim2.new(1, 0, 0, 18)
	infoLbl.Position = UDim2.new(0, 0, 0, 43)
	infoLbl.BackgroundTransparency = 1
	infoLbl.Text = "FPS: 0  |  PING: 0ms  |  Desync: OFF"
	infoLbl.TextColor3 = C.textMute
	infoLbl.Font = Enum.Font.Gotham
	infoLbl.TextSize = 10
	infoLbl.TextXAlignment = Enum.TextXAlignment.Center
	infoLbl.ZIndex = 202
	infoLbl.Parent = wm
end
do
	local _fpsUpdateTimer = 0
	if watermarkname then
		watermarkname.Text = "CHIRAQ HUB  |  discord.gg/chiraqhub"
	end
	connectLoop(function(dt)
		if dt > 0 then
			fps = fps * 0.9 + (1 / dt) * 0.1
		end
		local rawPing = Players.LocalPlayer:GetNetworkPing() * 1000
		if rawPing > 0 then
			ping = ping * 0.85 + rawPing * 0.15
		end
		pingvar = math.floor(ping)
		_fpsUpdateTimer = _fpsUpdateTimer + dt
		if _fpsUpdateTimer < 0.5 then
			return
		end
		_fpsUpdateTimer = 0
		if fpsLbl then
			fpsLbl.Text = string.format("%d FPS  |  %d ms", math.floor(fps), math.floor(ping))
		end
		if infoLbl then
			infoLbl.Text = string.format("FPS: %d  |  PING: %dms  |  Desync: %s", math.floor(fps), math.floor(ping), (G.desyncSendHookEnabled or G.SetupDesync) and "ON" or "OFF")
		end
	end, nil, true)
end
local drawings = {}
local espObjs = {}
local IGNORED_ATTRS = {
	RagdollEndTime = true,
	FakeRagdollEndTime = true,
	Ragdoll = true,
	DisplayName = true,
	Name = true,
	Role = true,
	EquippedFishingRod = true,
	__UG_NEW = true,
	__UG = true,
	Web = true,
	SpeedModifier = true,
	JumpModifier = true,
	Stealing = true,
	StealingIndex = true,
	StealingPlayer = true,
	TrapCount = true,
	BlockTools = true,
	__duels_block_steal = true,
	NoMouseLockOffset = true,
}
local MEOWL_PET_NAME = "MeowlGlidePet"
local MEOWL_PET_OFFSET = Vector3.new(3, 1.5, 4)
local MEOWL_PET_FACE_OFFSET = 0
local MEOWL_PET_MIN_GLIDE_SPEED = 0.01
local MEOWL_PET_MAX_GLIDE_SPEED = 0.02
local MEOWL_PET_FLY_BOB_AMPLITUDE = 0.5
local MEOWL_PET_IDLE_BOB_AMPLITUDE = 0.08
local MEOWL_PET_BOB_SPEED = 1
local MEOWL_PET_START_FLY_DISTANCE = 1.05
local MEOWL_PET_STOP_FLY_DISTANCE = 0.8
local MEOWL_PET_FORCE_IDLE_DISTANCE = 1.0
local MEOWL_PET_SETTLE_SNAP_DISTANCE = 0.18
local MEOWL_PET_PLAYER_IDLE_THRESHOLD = 0.75
local meowlPetState = {
	pet = nil,
	idleTrack = nil,
	walkTrack = nil,
	flying = false,
	character = nil,
	scale = nil,
	sourcePet = nil,
	animFolder = nil,
	nextAssetRetry = 0,
	missingAssetsWarned = false,
}
function meowlPetFlatDistance(a, b)
	local dx = a.X - b.X
	local dz = a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end
function meowlPetFlatMagnitude(v)
	return math.sqrt(v.X * v.X + v.Z * v.Z)
end
function destroyMeowlPet()
	if meowlPetState.idleTrack then
		pcall(function()
			meowlPetState.idleTrack:Stop()
		end)
	end
	if meowlPetState.walkTrack then
		pcall(function()
			meowlPetState.walkTrack:Stop()
		end)
	end
	if meowlPetState.pet then
		pcall(function()
			meowlPetState.pet:Destroy()
		end)
	end
	local strayPet = Workspace:FindFirstChild(MEOWL_PET_NAME)
	if strayPet then
		pcall(function()
			strayPet:Destroy()
		end)
	end
	meowlPetState.pet = nil
	meowlPetState.idleTrack = nil
	meowlPetState.walkTrack = nil
	meowlPetState.flying = false
	meowlPetState.character = nil
	meowlPetState.scale = nil
end
function safeLoadPetTrack(animator, animation)
	if not animator or not animation then
		return nil
	end
	local ok, track = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	if not ok or not track then
		return nil
	end
	track.Looped = true
	track:AdjustSpeed(animation:GetAttribute("Speed") or 1)
	return track
end
function findFirstDescendantByName(root, targetName, className)
	if not root then
		return nil
	end
	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant.Name == targetName and (not className or descendant:IsA(className)) then
			return descendant
		end
	end
	return nil
end
function findMeowlPetAssets()
	if meowlPetState.sourcePet and meowlPetState.sourcePet.Parent and meowlPetState.animFolder and meowlPetState.animFolder.Parent then
		return meowlPetState.sourcePet, meowlPetState.animFolder
	end
	local now = os.clock()
	if now < (meowlPetState.nextAssetRetry or 0) then
		return nil, nil
	end
	local modelsFolder = ReplicatedStorage:FindFirstChild("Models")
	local animalsFolder = modelsFolder and modelsFolder:FindFirstChild("Animals")
	local animationsFolder = ReplicatedStorage:FindFirstChild("Animations")
	local animalAnimations = animationsFolder and animationsFolder:FindFirstChild("Animals")
	local sourcePet = animalsFolder and animalsFolder:FindFirstChild("Meowl")
	if not sourcePet then
		sourcePet = findFirstDescendantByName(ReplicatedStorage, "Meowl", "Model")
	end
	local animFolder = animalAnimations and animalAnimations:FindFirstChild("Meowl")
	if not animFolder then
		local fallbackAnimFolder = findFirstDescendantByName(ReplicatedStorage, "Meowl", "Folder")
		if fallbackAnimFolder and fallbackAnimFolder:FindFirstChild("Idle") and fallbackAnimFolder:FindFirstChild("Walk") then
			animFolder = fallbackAnimFolder
		end
	end
	if sourcePet and animFolder then
		meowlPetState.sourcePet = sourcePet
		meowlPetState.animFolder = animFolder
		meowlPetState.nextAssetRetry = 0
		meowlPetState.missingAssetsWarned = false
		return sourcePet, animFolder
	end
	meowlPetState.sourcePet = nil
	meowlPetState.animFolder = nil
	meowlPetState.nextAssetRetry = now + 3
	if not meowlPetState.missingAssetsWarned then
		warn("Meowl pet assets were not found in ReplicatedStorage")
		meowlPetState.missingAssetsWarned = true
	end
	return sourcePet, animFolder
end
function setMeowlPetFlying(state)
	if meowlPetState.flying == state then
		return
	end
	meowlPetState.flying = state
	if state then
		if meowlPetState.idleTrack and meowlPetState.idleTrack.IsPlaying then
			meowlPetState.idleTrack:Stop(0.12)
		end
		if meowlPetState.walkTrack and not meowlPetState.walkTrack.IsPlaying then
			meowlPetState.walkTrack:Play(0.12)
		end
	else
		if meowlPetState.walkTrack and meowlPetState.walkTrack.IsPlaying then
			meowlPetState.walkTrack:Stop(0.12)
		end
		if meowlPetState.idleTrack and not meowlPetState.idleTrack.IsPlaying then
			meowlPetState.idleTrack:Play(0.12)
		end
	end
end
function ensureMeowlPet(character)
	if not G.MeowlPet then
		destroyMeowlPet()
		return nil
	end
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end
	local desiredScale = tonumber(G.MeowlPetScale) or 1
	if meowlPetState.pet and meowlPetState.pet.Parent and meowlPetState.character == character then
		if not meowlPetState.scale or math.abs(meowlPetState.scale - desiredScale) > 0.001 then
			pcall(function()
				meowlPetState.pet:ScaleTo(desiredScale)
			end)
			meowlPetState.scale = desiredScale
		end
		return meowlPetState.pet
	end
	destroyMeowlPet()
	local strayPet = Workspace:FindFirstChild(MEOWL_PET_NAME)
	if strayPet then
		pcall(function()
			strayPet:Destroy()
		end)
	end
	local sourcePet, animFolder = findMeowlPetAssets()
	if not sourcePet or not animFolder then
		return nil
	end
	local pet = sourcePet:Clone()
	pet.Name = MEOWL_PET_NAME
	pet.Parent = Workspace
	pcall(function()
		pet:ScaleTo(desiredScale)
	end)
	for _, item in ipairs(pet:GetDescendants()) do
		if item:IsA("BasePart") then
			item.CanCollide = false
			item.Anchored = true
		end
	end
	local animator = pet:FindFirstChildWhichIsA("Animator", true)
	if not animator then
		local animationController = pet:FindFirstChildWhichIsA("AnimationController", true)
		if not animationController then
			animationController = Instance.new("AnimationController")
			animationController.Name = "MeowlPetAnimationController"
			animationController.Parent = pet
		end
		animator = animationController:FindFirstChildWhichIsA("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = animationController
		end
	end
	local idleTrack = safeLoadPetTrack(animator, animFolder:FindFirstChild("Idle"))
	local walkTrack = safeLoadPetTrack(animator, animFolder:FindFirstChild("Walk"))
	meowlPetState.pet = pet
	meowlPetState.idleTrack = idleTrack
	meowlPetState.walkTrack = walkTrack
	meowlPetState.flying = false
	meowlPetState.character = character
	meowlPetState.scale = desiredScale
	if idleTrack then
		idleTrack:Play(0.12)
	elseif walkTrack then
		walkTrack:Play(0.12)
	end
	return pet
end
function updateMeowlPet(character, currentRoot)
	if not G.MeowlPet then
		destroyMeowlPet()
		return
	end
	if not character or not character.Parent or not currentRoot then
		destroyMeowlPet()
		return
	end
	local pet = ensureMeowlPet(character)
	if not pet or not pet.Parent then
		return
	end
	local baseTargetCFrame = currentRoot.CFrame * CFrame.new(MEOWL_PET_OFFSET.X, MEOWL_PET_OFFSET.Y, MEOWL_PET_OFFSET.Z)
	local targetPos = baseTargetCFrame.Position
	local currentPivot = pet:GetPivot()
	local distanceToSlot = meowlPetFlatDistance(currentPivot.Position, targetPos)
	local playerStill = meowlPetFlatMagnitude(currentRoot.AssemblyLinearVelocity) <= MEOWL_PET_PLAYER_IDLE_THRESHOLD
	if playerStill and distanceToSlot <= MEOWL_PET_FORCE_IDLE_DISTANCE then
		setMeowlPetFlying(false)
	elseif meowlPetState.flying then
		if distanceToSlot <= MEOWL_PET_STOP_FLY_DISTANCE then
			setMeowlPetFlying(false)
		end
	elseif distanceToSlot >= MEOWL_PET_START_FLY_DISTANCE then
		setMeowlPetFlying(true)
	end
	local bobAmplitude = meowlPetState.flying and MEOWL_PET_FLY_BOB_AMPLITUDE or MEOWL_PET_IDLE_BOB_AMPLITUDE
	local bobOffset = math.sin(os.clock() * MEOWL_PET_BOB_SPEED) * bobAmplitude
	local visualPos = targetPos + Vector3.new(0, bobOffset, 0)
	local newPos
	if not meowlPetState.flying and distanceToSlot <= MEOWL_PET_SETTLE_SNAP_DISTANCE then
		newPos = visualPos
	else
		local glideAlpha = math.clamp(distanceToSlot / 6, 0, 1)
		local glideSpeed = MEOWL_PET_MIN_GLIDE_SPEED + (MEOWL_PET_MAX_GLIDE_SPEED - MEOWL_PET_MIN_GLIDE_SPEED) * glideAlpha
		newPos = currentPivot.Position:Lerp(visualPos, glideSpeed)
	end
	local lookTarget = Vector3.new(currentRoot.Position.X, newPos.Y, currentRoot.Position.Z)
	local newCFrame = CFrame.lookAt(newPos, lookTarget) * CFrame.Angles(0, math.rad(MEOWL_PET_FACE_OFFSET), 0)
	pet:PivotTo(newCFrame)
end
function makeESPForPlayer(plr)
	local e = {}
	for _, t in ipairs({
		"box",
		"name",
		"dist",
		"attrs"
	}) do
		e[t] = Drawing.new(t == "box" and "Square" or "Text")
	end
	e.box.Thickness = 1.5;
	e.box.Filled = false;
	e.box.Color = C.purple;
	e.box.Visible = false
	for _, k in ipairs({
		"name",
		"dist",
		"attrs"
	}) do
		e[k].Center = false;
		e[k].Outline = true;
		e[k].OutlineColor = Color3.new(0, 0, 0);
		e[k].Visible = false
	end
	e.name.Color = Color3.fromRGB(255, 255, 255);
	e.name.Size = 15;
	e.name.Font = 3
	e.dist.Color = Color3.fromRGB(150, 200, 255);
	e.dist.Size = 13;
	e.dist.Font = 2
	e.attrs.Color = Color3.fromRGB(150, 255, 200);
	e.attrs.Size = 12;
	e.attrs.Font = 2
	espObjs[plr] = e
end
function removeESP(plr)
	if espObjs[plr] then
		for _, d in pairs(espObjs[plr]) do
			d:Remove()
		end
		espObjs[plr] = nil
	end
end
for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= player then
		makeESPForPlayer(plr)
	end
end
Players.PlayerAdded:Connect(function(plr)
	if plr ~= player then
		makeESPForPlayer(plr)
	end
end)
Players.PlayerRemoving:Connect(removeESP)
function getOrCreate(key, drawType)
	if not drawings[key] then
		local d = Drawing.new(drawType or "Text")
		if drawType == "Square" then
			d.Filled = true;
			d.Transparency = 0.7;
			d.Thickness = 0
		else
			d.Center = true;
			d.Outline = true;
			d.OutlineColor = Color3.fromRGB(0, 0, 0);
			d.Size = 18;
			d.Font = 3
		end
		drawings[key] = d
	end
	return drawings[key]
end
local _cachedEnemyPlots = {}
local _cachedEnemyPlotsTime = 0
function getCachedEnemyPlots()
	local t = tick()
	if t - _cachedEnemyPlotsTime > 1 then
		_cachedEnemyPlots = getEnemyPlots()
		_cachedEnemyPlotsTime = t
	end
	return _cachedEnemyPlots
end
function _randName()
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local out = ""
	for _ = 1, math.random(8, 14) do
		local i = math.random(1, # chars)
		out = out .. chars:sub(i, i)
	end
	return out
end
function makeBeam(color)
	local data = {
		beam = nil,
		p0 = nil,
		p1 = nil,
		color = color
	}
	local function build()
		local a0 = Instance.new("Attachment")
		local a1 = Instance.new("Attachment")
		local p0 = Instance.new("Part")
		p0.Name = _randName();
		p0.Size = Vector3.new(0.1, 0.1, 0.1);
		p0.Anchored = true;
		p0.CanCollide = false;
		p0.Transparency = 1;
		p0.Parent = Workspace
		local p1 = Instance.new("Part")
		p1.Name = _randName();
		p1.Size = Vector3.new(0.1, 0.1, 0.1);
		p1.Anchored = true;
		p1.CanCollide = false;
		p1.Transparency = 1;
		p1.Parent = Workspace
		a0.Parent = p0;
		a1.Parent = p1
		local beam = Instance.new("Beam")
		beam.Name = _randName()
		beam.Attachment0 = a0;
		beam.Attachment1 = a1
		beam.Width0 = 0.15;
		beam.Width1 = 0.15
		beam.Color = ColorSequence.new(data.color)
		beam.FaceCamera = true;
		beam.Enabled = false
		beam.LightEmission = 1;
		beam.LightInfluence = 0
		beam.Transparency = NumberSequence.new(0.3)
		beam.Parent = p0
		data.beam = beam;
		data.p0 = p0;
		data.p1 = p1
	end
	build()
	local function ensure()
		if not data.p0 or not data.p0.Parent or not data.p1 or not data.p1.Parent or not data.beam or not data.beam.Parent then
			pcall(function()
				if data.p0 then
					data.p0:Destroy()
				end
			end)
			pcall(function()
				if data.p1 then
					data.p1:Destroy()
				end
			end)
			build()
		end
	end
	data.ensure = ensure
	return data
end
local beamToBest = makeBeam(C.purple)
local beamToBase = makeBeam(C.green)
local _espFrameSkip = 0
connectLoop(function()
	_espFrameSkip = _espFrameSkip + 1
	if _espFrameSkip < 2 then
		return
	end
	_espFrameSkip = 0
	local visible = {}
	local myChar = player.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	updateMeowlPet(myChar, myHRP)
	if G.PlayerESP and myHRP then
		for plr, esp in pairs(espObjs) do
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChild("Humanoid")
			local head = char and char:FindFirstChild("Head")
			if hrp and hum and hum.Health > 0 and head then
				local hp3, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				if onScreen then
					local headP = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
					local legP = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 5, 0))
					local dist = (hrp.Position - myHRP.Position).Magnitude
					local h = math.abs(headP.Y - legP.Y)
					local w = h / 2
					local ts = math.clamp(h / 6 * math.clamp(100 / dist, 0.7, 1.5), 11, 20)
					esp.box.Size = Vector2.new(w, h);
					esp.box.Position = Vector2.new(hp3.X - w / 2, hp3.Y - h / 2);
					esp.box.Visible = true
					local tx = hp3.X + w / 2 + 10;
					local ty = hp3.Y - h / 2;
					local sp = ts + 3
					esp.name.Text = plr.DisplayName;
					esp.name.Position = Vector2.new(tx, ty);
					esp.name.Size = ts
					esp.name.Color = C.purple;
					esp.name.Visible = true
					esp.dist.Text = math.floor(dist) .. "m";
					esp.dist.Position = Vector2.new(tx, ty + sp);
					esp.dist.Size = ts - 2;
					esp.dist.Visible = true
					local attrLines = {}
					for n in pairs(plr:GetAttributes()) do
						if not IGNORED_ATTRS[n] and not n:lower():find("ragdoll") and not n:lower():find("userid") and not n:lower():find("__ug") then
							table.insert(attrLines, n)
						end
					end
					if # attrLines > 0 then
						esp.attrs.Text = table.concat(attrLines, "\n");
						esp.attrs.Position = Vector2.new(tx, ty + sp * 2);
						esp.attrs.Visible = true
					else
						esp.attrs.Visible = false
					end
				else
					for _, d in pairs(esp) do
						d.Visible = false
					end
				end
			else
				for _, d in pairs(esp) do
					d.Visible = false
				end
			end
		end
	else
		for _, esp in pairs(espObjs) do
			for _, d in pairs(esp) do
				d.Visible = false
			end
		end
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local char = plr.Character
			if char then
				local head = char:FindFirstChild("Head")
				local hl = char:FindFirstChild("StealingHighlight")
				local bb = head and head:FindFirstChild("StealingBB")
				local isStealing = G.StealingESP and plr:GetAttribute("Stealing") ~= nil
				if isStealing and head then
					if not hl then
						hl = Instance.new("Highlight")
						hl.Name = "StealingHighlight"
						hl.FillColor = Color3.fromRGB(255, 0, 0)
						hl.FillTransparency = 0.3
						hl.OutlineColor = Color3.fromRGB(255, 0, 0)
						hl.OutlineTransparency = 0
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						hl.Parent = char
					end
					if not bb then
						bb = Instance.new("BillboardGui")
						bb.Name = "StealingBB"
						bb.Adornee = head
						bb.Size = UDim2.new(0, 200, 0, 50)
						bb.StudsOffset = Vector3.new(0, 3, 0)
						bb.AlwaysOnTop = true
						local tl = Instance.new("TextLabel")
						tl.Name = "Label"
						tl.Size = UDim2.new(1, 0, 1, 0)
						tl.BackgroundTransparency = 1
						tl.Text = "Stealing"
						tl.TextColor3 = Color3.fromRGB(255, 0, 0)
						tl.TextStrokeTransparency = 0
						tl.TextStrokeColor3 = Color3.new(0, 0, 0)
						tl.Font = Enum.Font.GothamBold
						tl.TextScaled = true
						tl.Parent = bb
						bb.Parent = head
					end
				else
					if hl then
						hl:Destroy()
					end
					if bb then
						bb:Destroy()
					end
				end
			end
		end
	end
	local espPlots = {}
	for _, plot in ipairs(getCachedEnemyPlots()) do
		table.insert(espPlots, {
			plot = plot,
			mine = false
		})
	end
	for _, plot in ipairs(getMyPlots()) do
		table.insert(espPlots, {
			plot = plot,
			mine = true
		})
	end
	for _, entry in ipairs(espPlots) do
		local plot = entry.plot
		local isMine = entry.mine
		if G.FriendPanelESP then
			local panel = plot:FindFirstChild("FriendPanel")
			if panel then
				local sp, onScreen = Camera:WorldToViewportPoint(panel.WorldPivot.Position)
				if onScreen then
					local main = panel:FindFirstChild("Main")
					local img = main and main:FindFirstChild("SurfaceGui") and main.SurfaceGui:FindFirstChild("ImageLabel")
					local unallowed = img and img.Image == "rbxassetid://110783679426495"
					local d = getOrCreate("fp_" .. plot.Name)
					d.Text = unallowed and "UNALLOWED" or "ALLOWED"
					d.Color = unallowed and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 100)
					d.Position = Vector2.new(sp.X, sp.Y);
					d.Visible = true
					visible[d] = true
					if not isMine and G.AutoTPonAllow and not unallowed and not adCooldown then
						G.AutoTPonAllow = false
						saveConfig()
						adCooldown = true
						task.spawn(triggerConfiguredSemiInstant)
						task.delay(3, function()
							adCooldown = false
						end)
					end
				end
			end
		end
		if G.TimerESP then
			local purchases = plot:FindFirstChild("Purchases")
			if purchases then
				for _, child in ipairs(purchases:GetChildren()) do
					if child:IsA("Model") then
						local board = child:FindFirstChild("Main") and child.Main:FindFirstChild("BillboardGui")
						local label = board and board:FindFirstChild("RemainingTime")
						if label and label.ContentText ~= "" then
							local sp, onScreen = Camera:WorldToViewportPoint(child.WorldPivot.Position)
							if onScreen then
								local d = getOrCreate("timer_" .. child:GetDebugId())
								d.Text = label.ContentText
								d.Color = isMine and Color3.fromRGB(255, 220, 120) or Color3.fromRGB(100, 255, 200)
								d.Position = Vector2.new(sp.X, sp.Y);
								d.Visible = true
								visible[d] = true
							end
						end
						break
					end
				end
			end
		end
	end
	if G.MineESP then
		local mineIdx = 0
		function drawMineESP(part, label, color)
			mineIdx += 1
			local pos = part.Position
			local sz = part.Size
			local top, topOn = Camera:WorldToViewportPoint(pos + Vector3.new(0, sz.Y / 2, 0))
			local bot, botOn = Camera:WorldToViewportPoint(pos - Vector3.new(0, sz.Y / 2, 0))
			if not topOn and not botOn then
				return
			end
			local center, onScreen = Camera:WorldToViewportPoint(pos)
			if not onScreen then
				return
			end
			local h = math.abs(top.Y - bot.Y)
			local w = h * (sz.X / math.max(sz.Y, 0.1))
			if w < 4 then
				w = 4
			end;
			if h < 4 then
				h = 4
			end
			local boxKey = "mine_box_" .. mineIdx
			local outKey = "mine_out_" .. mineIdx
			if not drawings[boxKey] then
				drawings[boxKey] = Drawing.new("Square");
				drawings[boxKey].Filled = false;
				drawings[boxKey].Thickness = 1.5
				drawings[outKey] = Drawing.new("Square");
				drawings[outKey].Filled = true
				drawings[outKey].Color = Color3.fromRGB(20, 20, 25);
				drawings[outKey].Transparency = 0.7;
				drawings[outKey].Thickness = 0
			end
			drawings[boxKey].Size = Vector2.new(w, h);
			drawings[boxKey].Position = Vector2.new(center.X - w / 2, center.Y - h / 2)
			drawings[boxKey].Color = color;
			drawings[boxKey].Visible = true;
			visible[drawings[boxKey]] = true
			local ts = 14
			local textY = center.Y - h / 2 - ts - 6
			local d = getOrCreate("mine_text_" .. mineIdx)
			d.Text = label;
			d.Color = color;
			d.Size = ts;
			d.Font = 3;
			d.Center = true
			d.Position = Vector2.new(center.X, textY);
			d.Visible = true;
			visible[d] = true
			local tw2 = # label * (ts * 0.5);
			local pad = 6
			local bw, bh = tw2 + pad * 2, ts + pad * 1.8
			drawings[outKey].Size = Vector2.new(bw, bh);
			drawings[outKey].Position = Vector2.new(center.X - bw / 2, textY - pad * 0.9)
			drawings[outKey].Visible = true;
			visible[drawings[outKey]] = true
		end
		pcall(function()
			for _, obj in ipairs(workspace.ToolsAdds:GetChildren()) do
				if obj.Name:lower():find("^subspacetripmine") then
					local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
					if part then
						drawMineESP(part, "Submine", C.purple)
					end
				end
			end
		end)
		pcall(function()
			for _, obj in ipairs(workspace:GetChildren()) do
				if obj.Name == "Trap" then
					local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
					if part then
						drawMineESP(part, "Trap", C.green)
					end
				end
			end
		end)
	end
	if G.BrainrotESP and cachedBrainrots[1] then
		local best = cachedBrainrots[1]
		local bestPart = getPodiumWorldPart(best)
		local bestPos = bestPart and bestPart:GetPivot().Position or best.position
		if bestPos == Vector3.zero then
			bestPos = nil
		end
		local sp, onScreen = bestPos and Camera:WorldToViewportPoint(bestPos) or Vector3.zero, false
		if bestPos then
			sp, onScreen = Camera:WorldToViewportPoint(bestPos)
		end
		if onScreen and bestPos then
			local hrp = getHRP()
			local dist = hrp and (hrp.Position - bestPos).Magnitude or 100
			local ts = math.clamp(19 * math.clamp(50 / dist, 0.7, 1.3), 19, 22)
			local bgKey = "br_bg"
			local outKey = "br_outline"
			if not drawings[bgKey] then
				drawings[bgKey] = Drawing.new("Square");
				drawings[bgKey].Filled = true
				drawings[bgKey].Color = Color3.fromRGB(20, 20, 25);
				drawings[bgKey].Transparency = 0.7;
				drawings[bgKey].Thickness = 0
				drawings[outKey] = Drawing.new("Square");
				drawings[outKey].Filled = false
				drawings[outKey].Color = C.purple;
				drawings[outKey].Thickness = 2
			end
			local d = getOrCreate("br_text")
			d.Text = best.displayName .. " - " .. best.gen
			d.Color = C.purple;
			d.Size = ts;
			d.Font = 3;
			d.Center = true;
			d.Visible = true
			d.Position = Vector2.new(sp.X, sp.Y - ts / 2)
			local tw2 = # d.Text * (ts * 0.5)
			local pad = 10 * math.clamp(50 / dist, 0.7, 1.3)
			local bw, bh = tw2 + pad * 2, ts + pad * 1.8
			drawings[bgKey].Size = Vector2.new(bw, bh);
			drawings[bgKey].Position = Vector2.new(sp.X - bw / 2, sp.Y - bh / 2);
			drawings[bgKey].Visible = true
			drawings[outKey].Size = Vector2.new(bw, bh);
			drawings[outKey].Position = Vector2.new(sp.X - bw / 2, sp.Y - bh / 2);
			drawings[outKey].Visible = true
			visible[d] = true;
			visible[drawings[bgKey]] = true;
			visible[drawings[outKey]] = true
		end
	end
	if G.PriorityESP then
		local prIdx = 0
		local goldColor = Color3.fromRGB(255, 200, 50)
		local prHrp = getHRP()
		local prCandidates = {}
		for _, br in ipairs(cachedBrainrots) do
			if isPriorityBrainrot(br) then
				local prPart = getPodiumWorldPart(br)
				local prPos = prPart and prPart:GetPivot().Position or br.position
				if prPos ~= Vector3.zero then
					local d2 = prHrp and (prHrp.Position - prPos).Magnitude or 9999
					table.insert(prCandidates, {
						br = br,
						dist = d2,
						pos = prPos
					})
				end
			end
		end
		table.sort(prCandidates, function(a, b)
			return a.dist < b.dist
		end)
		local prMax = # prCandidates
		for pi = 1, prMax do
			local br = prCandidates[pi].br
			do
				prIdx += 1
				local sp, onScreen = Camera:WorldToViewportPoint(prCandidates[pi].pos)
				if onScreen then
					local dist = prCandidates[pi].dist
					local ts = math.clamp(18 * math.clamp(50 / dist, 0.7, 1.3), 18, 21)
					local bgKey = "pr_bg_" .. prIdx
					local outKey = "pr_out_" .. prIdx
					if not drawings[bgKey] then
						drawings[bgKey] = Drawing.new("Square");
						drawings[bgKey].Filled = true
						drawings[bgKey].Color = Color3.fromRGB(30, 25, 10);
						drawings[bgKey].Transparency = 0.7;
						drawings[bgKey].Thickness = 0
						drawings[outKey] = Drawing.new("Square");
						drawings[outKey].Filled = false
						drawings[outKey].Color = goldColor;
						drawings[outKey].Thickness = 2
					end
					local d = getOrCreate("pr_text_" .. prIdx)
					d.Text = br.displayName .. " - " .. br.gen
					d.Color = goldColor;
					d.Size = ts;
					d.Font = 3;
					d.Center = true;
					d.Visible = true
					d.Position = Vector2.new(sp.X, sp.Y - ts / 2)
					local tw2 = # d.Text * (ts * 0.5)
					local pad = 10 * math.clamp(50 / dist, 0.7, 1.3)
					local bw, bh = tw2 + pad * 2, ts + pad * 1.8
					drawings[bgKey].Size = Vector2.new(bw, bh);
					drawings[bgKey].Position = Vector2.new(sp.X - bw / 2, sp.Y - bh / 2);
					drawings[bgKey].Visible = true
					drawings[outKey].Size = Vector2.new(bw, bh);
					drawings[outKey].Position = Vector2.new(sp.X - bw / 2, sp.Y - bh / 2);
					drawings[outKey].Visible = true
					visible[d] = true;
					visible[drawings[bgKey]] = true;
					visible[drawings[outKey]] = true
				end
			end
		end
	end
	do
		local hrp = getHRP()
		if G.LineToBest and hrp and cachedBrainrots[1] then
			beamToBest.ensure()
			local best = getBestBrainrot()
			if best then
				local linePart = getPodiumWorldPart(best)
				local linePos = linePart and linePart:GetPivot().Position or best.position
				if linePos and linePos ~= Vector3.zero then
					beamToBest.p0.Position = hrp.Position
					beamToBest.p1.Position = linePos
					beamToBest.beam.Enabled = true
				else
					beamToBest.beam.Enabled = false
				end
			else
				beamToBest.beam.Enabled = false
			end
		else
			beamToBest.beam.Enabled = false
		end
		if G.LineToBase and hrp then
			beamToBase.ensure()
			local myPlots = getMyPlots()
			if myPlots[1] then
				local basePart = myPlots[1].PrimaryPart or myPlots[1]:FindFirstChildWhichIsA("BasePart", true)
				if basePart then
					beamToBase.p0.Position = hrp.Position
					beamToBase.p1.Position = basePart:GetPivot().Position
					beamToBase.beam.Enabled = true
				else
					beamToBase.beam.Enabled = false
				end
			else
				beamToBase.beam.Enabled = false
			end
		else
			beamToBase.beam.Enabled = false
		end
	end
	for _, d in pairs(drawings) do
		if not visible[d] then
			d.Visible = false
		end
	end
end)
do
	local anchorPart = Instance.new("Part")
	anchorPart.Size = Vector3.new(5, 1, 1);
	anchorPart.Anchored = true
	anchorPart.CanCollide = false;
	anchorPart.Transparency = 1
	anchorPart.Position = Vector3.new(0, 500, 0);
	anchorPart.Parent = Workspace
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 600, 0, 200);
	billboard.AlwaysOnTop = true;
	billboard.Parent = anchorPart
	local billboardLbl = Instance.new("TextLabel")
	billboardLbl.Size = UDim2.new(1, 0, 1, 0);
	billboardLbl.BackgroundTransparency = 1
	billboardLbl.Text = "discord.gg/chiraqhub";
	billboardLbl.TextScaled = false;
	billboardLbl.TextSize = 55
	billboardLbl.TextColor3 = Color3.fromRGB(200, 200, 255);
	billboardLbl.TextStrokeTransparency = 0
	billboardLbl.TextStrokeColor3 = Color3.new(0, 0, 0);
	billboardLbl.Font = Enum.Font.GothamBold;
	billboardLbl.Parent = billboard
end
IS_animPlaying = false
IS_tracks = {}
IS_clone = nil
IS_oldRoot = nil
IS_hip = nil
IS_invisConnection = nil
IS_folderConns = {}
IS_serverGhosts = {}
IS_ghostEnabled = true
IS_lagbackCount = 0
IS_lagbackWindowStart = 0
IS_lastLagbackTime = 0
IS_errorOrbActive = false
IS_errorOrb = nil
IS_RecoveryInProgress = false
IS_updateVisualFn = nil
function IS_clearErrorOrb()
	if IS_errorOrb and IS_errorOrb.Parent then
		IS_errorOrb:Destroy()
	end
	IS_errorOrb = nil;
	IS_errorOrbActive = false
end
function IS_clearAllGhosts()
	for _, ghost in pairs(IS_serverGhosts) do
		pcall(function()
			if ghost and ghost.Parent then
				ghost:Destroy()
			end
		end)
	end
	IS_serverGhosts = {};
	IS_clearErrorOrb();
	IS_lagbackCount = 0;
	IS_lastLagbackTime = 0
	pcall(function()
		local pg = player:FindFirstChild("PlayerGui")
		if pg then
			for _, g in pairs(pg:GetChildren()) do
				if g.Name == "LagbackNotification" then
					g:Destroy()
				end
			end
		end
	end)
	pcall(function()
		if Camera then
			for _, c in pairs(Camera:GetChildren()) do
				if c.Name == "LagbackGhost" then
					c:Destroy()
				end
			end
		end
	end)
end
function IS_createErrorOrb()
	if IS_errorOrbActive then
		return
	end
	IS_errorOrbActive = true
	for _, ghost in pairs(IS_serverGhosts) do
		if ghost and ghost.Parent then
			ghost:Destroy()
		end
	end
	IS_serverGhosts = {}
	local sg = Instance.new("ScreenGui")
	sg.Name = "IS_ErrorOrbGui";
	sg.ResetOnSpawn = false;
	sg.Parent = player.PlayerGui
	local fr = Instance.new("Frame")
	fr.Size = UDim2.new(0, 500, 0, 60);
	fr.Position = UDim2.new(0.5, - 250, 0.3, 0)
	fr.BackgroundTransparency = 1;
	fr.BorderSizePixel = 0;
	fr.Parent = sg
	local l1 = Instance.new("TextLabel")
	l1.Size = UDim2.new(1, 0, 0.5, 0);
	l1.BackgroundTransparency = 1
	l1.Text = "ERROR CAUSED BY PLAYER DEATH"
	l1.TextColor3 = Color3.fromRGB(255, 0, 0)
	l1.TextStrokeTransparency = 0;
	l1.TextStrokeColor3 = Color3.new(0, 0, 0)
	l1.Font = Enum.Font.SourceSansBold;
	l1.TextScaled = true;
	l1.Parent = fr
	local l2 = Instance.new("TextLabel")
	l2.Size = UDim2.new(1, 0, 0.5, 0);
	l2.Position = UDim2.new(0, 0, 0.5, 0)
	l2.BackgroundTransparency = 1;
	l2.Text = "MUST RESET TO FIX ERROR"
	l2.TextColor3 = Color3.fromRGB(255, 0, 0)
	l2.TextStrokeTransparency = 0;
	l2.TextStrokeColor3 = Color3.new(0, 0, 0)
	l2.Font = Enum.Font.SourceSansBold;
	l2.TextScaled = true;
	l2.Parent = fr
	IS_errorOrb = sg
end
function IS_createServerGhost(position)
	if not IS_ghostEnabled or IS_errorOrbActive then
		return
	end
	local now = tick()
	if now - IS_lastLagbackTime < 0.3 then
		return
	end
	IS_lastLagbackTime = now
	if now - IS_lagbackWindowStart > 3 then
		IS_lagbackCount = 0;
		IS_lagbackWindowStart = now
	end
	IS_lagbackCount += 1
	if IS_lagbackCount >= 5 then
		IS_createErrorOrb();
		return
	end
	for _, g in pairs(IS_serverGhosts) do
		if g and g.Parent then
			g:Destroy()
		end
	end
	IS_serverGhosts = {}
	local sg = Instance.new("ScreenGui")
	sg.Name = "LagbackNotification";
	sg.ResetOnSpawn = false;
	sg.Parent = player.PlayerGui
	local sl = Instance.new("TextLabel")
	sl.Size = UDim2.new(0, 500, 0, 30);
	sl.Position = UDim2.new(0.5, - 250, 0.15, 0)
	sl.BackgroundTransparency = 1;
	sl.Text = "LAGBACK DETECTED"
	sl.TextColor3 = Color3.fromRGB(255, 0, 0)
	sl.TextStrokeTransparency = 0;
	sl.TextStrokeColor3 = Color3.new(0, 0, 0)
	sl.Font = Enum.Font.SourceSansBold;
	sl.TextScaled = true;
	sl.Parent = sg
	task.delay(1.5, function()
		if sg and sg.Parent then
			sg:Destroy()
		end
	end)
	local ghost = Instance.new("Part")
	ghost.Name = "LagbackGhost";
	ghost.Shape = Enum.PartType.Ball
	ghost.Size = Vector3.new(3, 3, 3);
	ghost.Color = Color3.fromRGB(255, 0, 0)
	ghost.Material = Enum.Material.Glass;
	ghost.Transparency = 0.3
	ghost.CanCollide = false;
	ghost.Anchored = true;
	ghost.CastShadow = false
	ghost.Position = position + Vector3.new(0, 5, 0);
	ghost.Parent = Camera
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 400, 0, 60);
	bb.StudsOffset = Vector3.new(0, 4, 0)
	bb.AlwaysOnTop = true;
	bb.Parent = ghost
	local bl = Instance.new("TextLabel")
	bl.Size = UDim2.new(1, 0, 0, 25);
	bl.BackgroundTransparency = 1
	bl.Text = "LAGBACK DETECTED";
	bl.TextColor3 = Color3.fromRGB(255, 0, 0)
	bl.TextStrokeTransparency = 0;
	bl.TextStrokeColor3 = Color3.new(0, 0, 0)
	bl.Font = Enum.Font.SourceSansBold;
	bl.TextScaled = true;
	bl.Parent = bb
	local bw = Instance.new("TextLabel")
	bw.Size = UDim2.new(1, 0, 0, 25);
	bw.Position = UDim2.new(0, 0, 0, 25)
	bw.BackgroundTransparency = 1
	bw.Text = "DISABLE INVISIBLE STEAL NOW OR YOU WILL BE KILLED BY ANTICHEAT"
	bw.TextColor3 = Color3.fromRGB(200, 200, 200)
	bw.TextStrokeTransparency = 0;
	bw.TextStrokeColor3 = Color3.new(0, 0, 0)
	bw.Font = Enum.Font.SourceSansBold;
	bw.TextScaled = true;
	bw.Parent = bb
	table.insert(IS_serverGhosts, ghost)
end
function IS_removeFolders()
	local pf = Workspace:FindFirstChild(player.Name)
	if not pf then
		return
	end
	local dr = pf:FindFirstChild("DoubleRig")
	if dr then
		local rr = dr:FindFirstChild("HumanoidRootPart") or dr:FindFirstChildWhichIsA("BasePart")
		if rr and IS_ghostEnabled then
			IS_createServerGhost(rr.Position)
		end
		dr:Destroy()
	end
	local cs = pf:FindFirstChild("Constraints")
	if cs then
		cs:Destroy()
	end
	local conn = pf.ChildAdded:Connect(function(child)
		if child.Name == "DoubleRig" then
			task.defer(function()
				local rr = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChildWhichIsA("BasePart")
				if rr and IS_ghostEnabled then
					IS_createServerGhost(rr.Position)
				end
				child:Destroy()
			end)
		elseif child.Name == "Constraints" then
			child:Destroy()
		end
	end)
	table.insert(IS_folderConns, conn)
end
function IS_doClone()
	local character = player.Character
	if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
		IS_hip = character.Humanoid.HipHeight
		IS_oldRoot = character:FindFirstChild("HumanoidRootPart")
		if not IS_oldRoot or not IS_oldRoot.Parent then
			return false
		end
		for _, c in pairs(IS_oldRoot:GetChildren()) do
			if c:IsA("Attachment") and (c.Name:find("Beam") or c.Name:find("Attach")) then
				c:Destroy()
			end
		end
		for _, c in pairs(IS_oldRoot:GetChildren()) do
			if c:IsA("Beam") then
				c:Destroy()
			end
		end
		local tmp = Instance.new("Model");
		tmp.Parent = game
		character.Parent = tmp
		IS_clone = IS_oldRoot:Clone();
		IS_clone.Parent = character
		IS_oldRoot.Parent = Camera
		IS_clone.CFrame = IS_oldRoot.CFrame;
		character.PrimaryPart = IS_clone
		character.Parent = Workspace
		for _, v in pairs(character:GetDescendants()) do
			if v:IsA("Weld") or v:IsA("Motor6D") then
				if v.Part0 == IS_oldRoot then
					v.Part0 = IS_clone
				end
				if v.Part1 == IS_oldRoot then
					v.Part1 = IS_clone
				end
			end
		end
		tmp:Destroy();
		return true
	end
	return false
end
function IS_revertClone()
	local character = player.Character
	if not IS_oldRoot or not IS_oldRoot:IsDescendantOf(Workspace) or not character or character.Humanoid.Health <= 0 then
		return
	end
	local tmp = Instance.new("Model");
	tmp.Parent = game
	character.Parent = tmp
	IS_oldRoot.Parent = character;
	character.PrimaryPart = IS_oldRoot
	character.Parent = Workspace;
	IS_oldRoot.CanCollide = true
	for _, v in pairs(character:GetDescendants()) do
		if v:IsA("Weld") or v:IsA("Motor6D") then
			if v.Part0 == IS_clone then
				v.Part0 = IS_oldRoot
			end
			if v.Part1 == IS_clone then
				v.Part1 = IS_oldRoot
			end
		end
	end
	if IS_clone then
		local p = IS_clone.CFrame
		IS_clone:Destroy();
		IS_clone = nil
		IS_oldRoot.CFrame = p
	end
	IS_oldRoot = nil
	if character and character.Humanoid then
		character.Humanoid.HipHeight = IS_hip
	end
	IS_clearAllGhosts()
end
function IS_animationTrickery()
	local character = player.Character
	if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
		local anim = Instance.new("Animation")
		anim.AnimationId = "http://www.roblox.com/asset/?id=18537363391"
		local humanoid = character.Humanoid
		local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
		local animTrack = animator:LoadAnimation(anim)
		animTrack.Priority = Enum.AnimationPriority.Action4
		animTrack:Play(0, 1, 0);
		anim:Destroy()
		table.insert(IS_tracks, animTrack)
		animTrack.Stopped:Connect(function()
			if IS_animPlaying then
				IS_animationTrickery()
			end
		end)
		task.delay(0, function()
			animTrack.TimePosition = 0.7
			task.delay(0.3, function()
				if animTrack then
					animTrack:AdjustSpeed(math.huge)
				end
			end)
		end)
	end
end
function IS_turnOff()
	IS_clearAllGhosts()
	if not IS_animPlaying then
		return
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	IS_animPlaying = false
	for _, t in pairs(IS_tracks) do
		pcall(function()
			t:Stop()
		end)
	end
	IS_tracks = {}
	if IS_invisConnection then
		IS_invisConnection:Disconnect();
		IS_invisConnection = nil
	end
	for _, c in ipairs(IS_folderConns) do
		if c then
			c:Disconnect()
		end
	end
	IS_folderConns = {}
	IS_revertClone();
	IS_clearAllGhosts()
	if humanoid then
		pcall(function()
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end)
	end
	if IS_updateVisualFn then
		IS_updateVisualFn(false)
	end
end
function IS_handleRagdollState(humanoid, new, isRagdolledRef, skipFramesRef, lastSetPositionRef)
	if new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.Ragdoll then
		if not isRagdolledRef[1] and IS_oldRoot and IS_clone then
			isRagdolledRef[1] = true
			local savedCF = IS_clone.CFrame
			local character = humanoid.Parent
			pcall(function()
				local tmp = Instance.new("Model");
				tmp.Parent = game
				character.Parent = tmp
				IS_oldRoot.Parent = character;
				character.PrimaryPart = IS_oldRoot
				character.Parent = Workspace;
				IS_oldRoot.CanCollide = true
				for _, v in pairs(character:GetDescendants()) do
					if v:IsA("Weld") or v:IsA("Motor6D") then
						if v.Part0 == IS_clone then
							v.Part0 = IS_oldRoot
						end
						if v.Part1 == IS_clone then
							v.Part1 = IS_oldRoot
						end
					end
				end
				if IS_clone then
					IS_clone:Destroy();
					IS_clone = nil
				end
				IS_oldRoot.CFrame = savedCF;
				tmp:Destroy()
			end)
			Camera.CameraSubject = humanoid;
			Camera.CameraType = Enum.CameraType.Custom
		end
	elseif new == Enum.HumanoidStateType.GettingUp or new == Enum.HumanoidStateType.Running or new == Enum.HumanoidStateType.Jumping then
		if isRagdolledRef[1] then
			isRagdolledRef[1] = false;
			task.wait(0.1)
			if not IS_animPlaying then
				return
			end
			if IS_clone then
				pcall(function()
					IS_clone:Destroy()
				end);
				IS_clone = nil
			end
			local reapplySuccess = IS_doClone()
			if reapplySuccess then
				skipFramesRef[1] = 5;
				lastSetPositionRef[1] = nil
			end
		end
	end
end
function IS_turnOn()
	if IS_animPlaying then
		return
	end
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	if not player:GetAttribute("Stealing") then
		return
	end
	IS_animPlaying = true
	if IS_updateVisualFn then
		IS_updateVisualFn(true)
	end
	IS_tracks = {};
	IS_removeFolders()
	local success = IS_doClone()
	if not success then
		IS_animPlaying = false;
		return
	end
	task.wait(0.05);
	IS_animationTrickery()
	local lastSetPositionRef = {
		nil
	};
	local skipFramesRef = {
		5
	};
	local isRagdolledRef = {
		false
	}
	local ragdollStateConn = humanoid.StateChanged:Connect(function(old, new)
		IS_handleRagdollState(humanoid, new, isRagdolledRef, skipFramesRef, lastSetPositionRef)
	end)
	table.insert(IS_folderConns, ragdollStateConn)
	IS_invisConnection = connectLoop(function()
		if isRagdolledRef[1] then
			return
		end
		if not (character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 and IS_oldRoot) then
			return
		end
		local root = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end
		if skipFramesRef[1] > 0 then
			skipFramesRef[1] -= 1;
			lastSetPositionRef[1] = nil
		elseif lastSetPositionRef[1] and IS_ghostEnabled then
			local currentPos = IS_oldRoot.Position
			local jumpDist = (currentPos - lastSetPositionRef[1]).Magnitude
			if jumpDist > 3 and not IS_RecoveryInProgress then
				lastSetPositionRef[1] = nil;
				IS_createServerGhost(currentPos)
				if G.IS_AutoFixLagback then
					IS_RecoveryInProgress = true
					task.spawn(function()
						pcall(IS_turnOff);
						task.wait(1);
						IS_RecoveryInProgress = false
						if player:GetAttribute("Stealing") then
							pcall(IS_turnOn)
						end
					end)
				end
			end
		end
		if IS_clone then
			IS_clone.CanCollide = false
		end
		for _, c in pairs(IS_oldRoot:GetChildren()) do
			if c:IsA("Attachment") or c:IsA("Beam") then
				c:Destroy()
			end
		end
		local rotAngle = G.IS_Angle or 236
		local sa = (G.IS_SinkDepth or 7.4) * 0.5
		local cf = root.CFrame - Vector3.new(0, sa, 0)
		IS_oldRoot.CFrame = cf * CFrame.Angles(math.rad(rotAngle), 0, 0)
		IS_oldRoot.Velocity = root.Velocity
		IS_oldRoot.CanCollide = false
		lastSetPositionRef[1] = IS_oldRoot.Position
	end)
end
function IS_toggle()
	if IS_animPlaying then
		IS_turnOff()
	else
		IS_turnOn()
	end
end
IS_autoWatcher = nil
function IS_startAutoWatcher()
	if IS_autoWatcher then
		return
	end
	IS_autoWatcher = connectLoop(function()
		if not G.IS_AutoOnSteal then
			return
		end
		if IS_RecoveryInProgress then
			return
		end
		if player:GetAttribute("Stealing") then
			if not IS_animPlaying then
				pcall(IS_turnOn)
			end
		else
			if IS_animPlaying then
				pcall(IS_turnOff)
			end
		end
	end)
end
function IS_stopAutoWatcher()
	if IS_autoWatcher then
		IS_autoWatcher:Disconnect();
		IS_autoWatcher = nil
	end
end
IS_startAutoWatcher()
player.CharacterAdded:Connect(function(newChar)
	IS_clearErrorOrb();
	IS_clearAllGhosts();
	IS_lagbackCount = 0
	pcall(function()
		for _, c in pairs(Camera:GetChildren()) do
			if c:IsA("BasePart") and c.Name == "HumanoidRootPart" then
				c:Destroy()
			end
		end
	end)
	if IS_oldRoot then
		pcall(function()
			IS_oldRoot:Destroy()
		end);
		IS_oldRoot = nil
	end
	if IS_clone then
		pcall(function()
			IS_clone:Destroy()
		end);
		IS_clone = nil
	end
	IS_animPlaying = false
	if IS_updateVisualFn then
		IS_updateVisualFn(false)
	end
	task.wait(0.2)
	local h = newChar:FindFirstChildOfClass("Humanoid")
	if h then
		Camera.CameraSubject = h;
		Camera.CameraType = Enum.CameraType.Custom
	end
end)
do
	local invisToggleRow = Instance.new("Frame")
	invisToggleRow.Size = UDim2.new(1, 0, 0, 32);
	invisToggleRow.BackgroundColor3 = C.row;
	invisToggleRow.BackgroundTransparency = 0.3
	invisToggleRow.BorderSizePixel = 0;
	invisToggleRow.Parent = tabFrames["Invis"]
	mkCorner(invisToggleRow, 6)
	local invisStroke = mkStroke(invisToggleRow, C.border, 1.5)
	local invisToggleBtn = Instance.new("TextButton")
	invisToggleBtn.Size = UDim2.new(1, - 26, 1, 0);
	invisToggleBtn.Position = UDim2.new(0, 8, 0, 0)
	invisToggleBtn.BackgroundTransparency = 1;
	invisToggleBtn.Text = "Invisible Steal"
	invisToggleBtn.TextColor3 = C.text;
	invisToggleBtn.Font = Enum.Font.GothamBold
	invisToggleBtn.TextSize = 12;
	invisToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
	invisToggleBtn.BorderSizePixel = 0;
	invisToggleBtn.AutoButtonColor = false
	invisToggleBtn.ZIndex = 15;
	invisToggleBtn.Parent = invisToggleRow
	local invisDot = Instance.new("Frame")
	invisDot.Size = UDim2.new(0, 8, 0, 8);
	invisDot.Position = UDim2.new(1, - 16, 0.5, - 4)
	invisDot.BorderSizePixel = 0;
	invisDot.Parent = invisToggleRow;
	mkCorner(invisDot, 4)
	IS_updateVisualFn = function(on)
		tw(invisStroke, {
			Color = on and C.purple or C.border
		})
		tw(invisToggleRow, {
			BackgroundColor3 = on and C.rowSel or C.row
		})
		tw(invisDot, {
			BackgroundColor3 = on and C.green or Color3.fromRGB(60, 60, 75)
		})
	end
	IS_updateVisualFn(IS_animPlaying)
	invisToggleBtn.MouseButton1Click:Connect(function()
		IS_toggle();
		IS_updateVisualFn(IS_animPlaying)
		notify("Invisible Steal " .. (IS_animPlaying and "Enabled" or "Disabled"), IS_animPlaying and C.green or C.red, 2)
	end)
	invisToggleRow.MouseEnter:Connect(function()
		if not IS_animPlaying then
			tw(invisToggleRow, {
				BackgroundColor3 = C.rowHov
			})
		end
	end)
	invisToggleRow.MouseLeave:Connect(function()
		if not IS_animPlaying then
			tw(invisToggleRow, {
				BackgroundColor3 = C.row
			})
		end
	end)
end
addToggle("Invis", "Auto Invis On Steal", "IS_AutoOnSteal")
do
	local origAutoInvis = G.IS_AutoOnSteal
	task.spawn(function()
		while task.wait(0.5) do
			if G.IS_AutoOnSteal ~= origAutoInvis then
				origAutoInvis = G.IS_AutoOnSteal
				if G.IS_AutoOnSteal then
					IS_startAutoWatcher()
				else
					IS_stopAutoWatcher()
				end
			end
		end
	end)
end
addToggle("Invis", "Auto Fix Lagback", "IS_AutoFixLagback")
addKeybind("Invis", "Invis Keybind", G.IS_KeybindIS or "I", function(k)
	G.IS_KeybindIS = k;
	saveConfig()
end)
addSlider("Invis", "Rotation Angle", "IS_Angle", 180, 360, 1)
addSlider("Invis", "Sink Depth", "IS_SinkDepth", 0.5, 10, 0.1)
function desyncRespawn(plr)
	local rcdEnabled = false
	if gethidden then
		rcdEnabled = gethidden(workspace, 'RejectCharacterDeletions') ~= Enum.RejectCharacterDeletions.Disabled
	end
	if rcdEnabled and replicatesignal then
		replicatesignal(plr.ConnectDiedSignalBackend)
		task.wait(Players.RespawnTime - 0.1)
		replicatesignal(plr.Kill)
	else
		local char = plr.Character
		local hum = char and char:FindFirstChildWhichIsA('Humanoid')
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Dead)
		end
		char:ClearAllChildren()
		local newChar = Instance.new('Model')
		newChar.Parent = workspace
		plr.Character = newChar
		task.wait()
		plr.Character = char
		newChar:Destroy()
	end
end
addLabel("Desync", "DESYNC CONTROLS")
addToggle("Desync", "Desync", "desyncSendHookEnabled")
addToggle("Desync", "Unwalk", "desyncUnwalkEnabled")
addDivider("Desync")
addButton("Desync", "Respawn", function()
	desyncRespawn(player)
end)
do
	task.spawn(function()
		local lastState = nil
		while task.wait(0.1) do
			local enabled = (G.desyncSendHookEnabled or G.SetupDesync) == true
			if enabled ~= lastState then
				lastState = enabled
				ensureRaknetSendHook()
				setRaknetDesyncState(enabled)
			end
		end
	end)
end
_G._sideTPScanning = false
UserInputService.InputBegan:Connect(function(inp, gp)
	if gp then
		return
	end
	if inp.UserInputType == Enum.UserInputType.Keyboard then
		local k = inp.KeyCode.Name
		if k == (G.IS_KeybindIS or "I") then
			IS_toggle()
			if IS_updateVisualFn then
				IS_updateVisualFn(IS_animPlaying)
			end
			notify("Invisible Steal " .. (IS_animPlaying and "Enabled" or "Disabled"), IS_animPlaying and C.green or C.red, 2)
		end
	end
end)

function setupAntiDie()
	if antiDieDisabled then
		return
	end
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	if antiDieConnection then
		pcall(function()
			antiDieConnection:Disconnect()
		end)
	end
	antiDieConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if antiDieDisabled then
			return
		end
		if humanoid.Health <= 0 then
			humanoid.Health = humanoid.MaxHealth
		end
	end)
end

setupAntiDie()
player.CharacterAdded:Connect(function(newChar)
	IS_clearErrorOrb();
	IS_clearAllGhosts();
	IS_lagbackCount = 0
	pcall(function()
		for _, c in pairs(Camera:GetChildren()) do
			if c:IsA("BasePart") and c.Name == "HumanoidRootPart" then
				c:Destroy()
			end
		end
	end)
	if IS_oldRoot then
		pcall(function()
			IS_oldRoot:Destroy()
		end);
		IS_oldRoot = nil
	end
	if IS_clone then
		pcall(function()
			IS_clone:Destroy()
		end);
		IS_clone = nil
	end
	IS_animPlaying = false
	if IS_updateVisualFn then
		IS_updateVisualFn(false)
	end
	task.wait(0.2)
	local h = newChar:FindFirstChildOfClass("Humanoid")
	if h then
		Camera.CameraSubject = h;
		Camera.CameraType = Enum.CameraType.Custom
	end
	task.wait(0.3)
	setupAntiDie()
end)
do
	local _REPLACEMENT = "discord.gg/chiraqhub"
	local _PATTERNS = {
		"discord",
		"%.gg/",
		"hub"
	}
	local function _matches(text)
		local lower = text:lower()
		if lower:find("chiraq") then
			return false
		end
		for _, pat in ipairs(_PATTERNS) do
			if lower:find(pat:lower()) then
				return true
			end
		end
		return false
	end
	local function _scanInst(obj)
		pcall(function()
			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				if obj.Text and # obj.Text > 0 and _matches(obj.Text) then
					obj.Text = _REPLACEMENT
				end
			end
		end)
	end
	local function _scanTree(root)
		pcall(function()
			for _, d in ipairs(root:GetDescendants()) do
				_scanInst(d)
			end
			root.DescendantAdded:Connect(function(d)
				task.wait()
				_scanInst(d)
			end)
		end)
	end
	_scanTree(player.PlayerGui)
	pcall(function()
		if gethui then
			_scanTree(gethui())
		end
	end)
	pcall(function()
		_scanTree(CoreGui)
	end)
end
task.spawn(function()
	while task.wait() do
		if not G.AutoSpam then
			continue
		end
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			continue
		end
		local tool = char:FindFirstChildOfClass("Tool")
		if not tool then
			continue
		end
		local validTools = {
			["Laser Cape"] = true,
			["Paintball Gun"] = true,
			["Web Slinger"] = true,
			["Body Swap Potion"] = true
		}
		if not validTools[tool.Name] then
			continue
		end
		local closestHRP, closestDist = nil, math.huge
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local tHRP = plr.Character:FindFirstChild("HumanoidRootPart")
				if tHRP then
					local d = (hrp.Position - tHRP.Position).Magnitude
					if d < closestDist then
						closestDist = d
						closestHRP = tHRP
					end
				end
			end
		end
		if closestHRP and RealUseItem then
			targetPosition = closestHRP.Position
			targetHRP = closestHRP
			RealUseItem:FireServer(targetPosition, targetHRP)
		end
	end
end)

