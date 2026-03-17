local ScriptSetup = select(1, ...) or {
    JoinTeam = "Pirates",
    Translator = true
}
if not game.IsLoaded then
    game.Loaded:Wait()
end
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalizationService = game:GetService("LocalizationService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local CurrentCamera = workspace.CurrentCamera
local SteppedEvent = RunService.Stepped
local LocalPlayer = Players.LocalPlayer
local PlayerData = LocalPlayer:WaitForChild("Data")
PlayerData:WaitForChild("LastSpawnPoint")
PlayerData:WaitForChild("SpawnPoint")
local PlayerFragments = PlayerData:WaitForChild("Fragments")
local PlayerSubclass = PlayerData:WaitForChild("Subclass")
local PlayerFruitCap = PlayerData:WaitForChild("FruitCap")
local PlayerLevel = PlayerData:WaitForChild("Level")
local PlayerBeli = PlayerData:WaitForChild("Beli")
local MapWorkspace = workspace:WaitForChild("Map")
local NPCsWorkspace = workspace:WaitForChild("NPCs")
local BoatsWorkspace = workspace:WaitForChild("Boats")
local SeaBeastsWorkspace = workspace:WaitForChild("SeaBeasts")
local EnemiesWorkspace = workspace:WaitForChild("Enemies")
local CharactersWorkspace = workspace:WaitForChild("Characters")
local WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local WorldLocations = WorldOrigin:WaitForChild("Locations")
WorldOrigin:WaitForChild("PlayerSpawns")
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local ModulesFolder = ReplicatedStorage:WaitForChild("Modules")
local NetModules = ModulesFolder:WaitForChild("Net")
local GlobalEnv = (getgenv or (getrenv or getfenv))()
local HttpGetFunc = game.HttpGet
local UIToggles = {}
local RawEnabledOptions = {}
local GlobalRzFunctions = GlobalEnv.rz_Functions or {}
local GlobalRzFarmFunctions = GlobalEnv.rz_FarmFunctions or {}
local GlobalSettings = GlobalEnv.rz_Settings or {
    AutoBuso = true,
    BringMobs = true,
    BringDistance = 250,
    FarmMode = "Up",
    FarmTool = "Melee",
    FarmDistance = 15,
    FarmPos = Vector3.new(0, 15, 0),
    SeaSkills = {},
    boatSelected = {},
    fishSelected = {}
}
local ActiveOptions = GlobalEnv.rz_EnabledOptions or setmetatable({}, {
    __newindex = function(_, key, value)
        rawset(RawEnabledOptions, key, value or nil)
        table.clear(GlobalRzFarmFunctions)
        local iterFunc, iterTable, iterKey = ipairs(GlobalRzFunctions)
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if rawget(RawEnabledOptions, iterVal.Name) then
                table.insert(GlobalRzFarmFunctions, iterVal)
            end
        end
    end,
    __index = RawEnabledOptions
})
local PlayerGui = LocalPlayer.PlayerGui
if not (LocalPlayer.Team or LocalPlayer:FindFirstChild("Main")) then
    local TeamJoinTime = 0
    local function JoinTeamFunction(teamString)
        local teamUI = PlayerGui["Main (minimal)"]:WaitForChild("ChooseTeam")
        local selectedTeamName = teamString:find("pirate") and "Pirates" or "Marines"
        local buttonConnections = getconnections(teamUI.Container[selectedTeamName].Frame.TextButton.Activated)
        for connIndex = 1, # buttonConnections do
            buttonConnections[connIndex].Function()
        end
    end
    while not (LocalPlayer.Team or LocalPlayer:FindFirstChild("Main")) do
        if tick() - TeamJoinTime >= 0.5 then
            pcall(JoinTeamFunction, string.lower(ScriptSetup.JoinTeam or "Pirates"))
            TeamJoinTime = tick()
        end
        task.wait()
    end
end
if GlobalEnv.redz_hub_error then
    GlobalEnv.redz_hub_error:Destroy()
end
local RepoConfig = {
    Owner = "https://raw.githubusercontent.com/newredz/"
}
RepoConfig.Repository = RepoConfig.Owner .. "BloxFruits/refs/heads/main/"
local function GetExecutorName()
    return identifyexecutor and identifyexecutor() or "Null"
end
local function HandleLoadError(errMsg)
    GlobalEnv.loadedFarm = nil
    GlobalEnv.OnFarm = false
    local errMessageObj = Instance.new("Message", workspace)
    errMessageObj.Text = string.gsub(errMsg, RepoConfig.Owner, "")
    GlobalEnv.redz_hub_error = errMessageObj
    return error(errMsg, 2)
end
function __httpget(url, _)
    local repFunc, repTable, repKey = pairs(RepoConfig)
    while true do
        local repVal
        repKey, repVal = repFunc(repTable, repKey)
        if repKey == nil then
            break
        end
        local pattern = "{" .. repKey .. "}"
        if url:find(pattern) then
            url = url:gsub(pattern, repVal)
        end
    end
    local success, result = pcall(HttpGetFunc, game, url)
    if success then
        return result, url
    else
        return HandleLoadError((("[1] [%s] Failed to load script: %s\n{{ %s }}"):format(GetExecutorName(), url, result)))
    end
end
function __loadstring(scriptUrl, extraSuffix, execArgs)
    local scriptContent, contentUrl = __httpget(scriptUrl)
    local loadedFunc, loadErr = loadstring(scriptContent .. (extraSuffix or ""))
    if type(loadedFunc) ~= "function" then
        return HandleLoadError((("[2] [%s] sintaxe error: %s\n{{ %s }}"):format(GetExecutorName(), contentUrl, loadErr)))
    end
    local execSuccess, execResult
    if execArgs then
        execSuccess, execResult = pcall(loadedFunc, unpack(execArgs))
    else
        execSuccess, execResult = pcall(loadedFunc)
    end
    if execSuccess then
        return execResult
    end
    if type(execResult) == "string" then
        ("[3] [%s] Execute error: %s\n{{ %s }}"):format(GetExecutorName(), contentUrl, execResult)
    end
end
GlobalEnv.rz_Functions = GlobalRzFunctions
GlobalEnv.rz_Settings = GlobalSettings
GlobalEnv.rz_EnabledOptions = ActiveOptions
GlobalEnv.rz_FarmFunctions = GlobalRzFarmFunctions
local ScriptConnections = rz_connections or {}
GlobalEnv.rz_connections = ScriptConnections
local connFunc, connTable, connKey = ipairs(ScriptConnections)
while true do
    local connVal
    connKey, connVal = connFunc(connTable, connKey)
    if connKey == nil then
        break
    end
    connVal:Disconnect()
end
table.clear(ScriptConnections)
local UILibrary = nil
local MainModule = nil
local TeleportFunc = nil
local TeamManager = {
    Marines = function()
        MainModule.FireRemote("SetTeam", "Marines")
    end,
    Pirates = function()
        MainModule.FireRemote("SetTeam", "Pirates")
    end
}
local function TrackTaggedItems(tagName)
    local taggedItems = CollectionService:GetTagged(tagName)
    table.insert(ScriptConnections, CollectionService:GetInstanceAddedSignal(tagName):Connect(function(addedInst)
        table.insert(taggedItems, addedInst)
    end))
    return taggedItems
end
local ChestsList = TrackTaggedItems("_ChestTagged")
local BerryBushesList = TrackTaggedItems("BerryBush")
local MiscUtils = {
    RemoveFog = function()
        if Lighting:FindFirstChild("LightingLayers") then
            Lighting.LightingLayers:Remove()
        end
    end,
    AllCodes = function()
        local codesData = __httpget("{Repository}Utils/Codes.txt")
        local codesList = string.gsub(codesData, "\n", ""):split(" ")
        for codeIdx = 1, # codesList do
            RemotesFolder.Redeem:InvokeServer(codesList[codeIdx])
        end
    end,
    GetTimer = function(totalSeconds)
        local totalSecsInt = math.floor(totalSeconds)
        local mins = math.floor(totalSeconds / 60)
        local hours = math.floor(totalSeconds / 60 / 60)
        local remSecs = totalSecsInt - mins * 60
        local remMins = mins - hours * 60
        if remMins < 10 then
            remMins = "0" .. tostring(remMins) or remMins
        end
        local separator = ":"
        if remSecs < 10 then
            remSecs = "0" .. tostring(remSecs) or remSecs
        end
        return remMins .. separator .. remSecs
    end
}
local App = {
    Managers = {}
}
local AppManagers = App.Managers
local TweenModule = loadstring("\n    local module = {}\n    module.__index = module\n    \n    local TweenService = game:GetService(\"TweenService\")\n    \n    local tweens = {}\n    local EasingStyle = Enum.EasingStyle.Linear\n    \n    function module.new(obj, time, prop, value)\n      local self = setmetatable({}, module)\n      \n      self.tween = TweenService:Create(obj, TweenInfo.new(time, EasingStyle), { [prop] = value })\n      self.tween:Play()\n      self.value = value\n      self.object = obj\n      \n      if tweens[obj] then\n        tweens[obj]:destroy()\n      end\n      \n      tweens[obj] = self\n      return self\n    end\n    \n    function module:destroy()\n      self.tween:Pause()\n      self.tween:Destroy()\n      \n      tweens[self.object] = nil\n      setmetatable(self, nil)\n    end\n    \n    function module:stop(obj)\n      if tweens[obj] then\n        tweens[obj]:destroy()\n      end\n    end\n    \n    return module\n  ")()
function AppManagers.PlayerTeleport()
    local TeleportManager = {
        lastCF = nil,
        lastTP = 0,
        nextNum = 1,
        BypassCooldown = 0,
        GreatTree = CFrame.new(28610, 14897, 105),
        SpawnVector = Vector3.new(0, - 25.2, 0)
    }
    local UnlockedInventory = MainModule.Inventory.Unlocked
    local CurrentSea = MainModule.GameData.Sea
    local IsPlayerAlive = MainModule.IsAlive
    local FireRemote = MainModule.FireRemote
    local PortalsData = ({
        {
            ["Sky Island 1"] = Vector3.new(- 4652, 873, - 1754),
            ["Sky Island 2"] = Vector3.new(- 7895, 5547, - 380),
            ["Under Water Island"] = Vector3.new(61164, 15, 1820),
            ["Under Water Island Entrace"] = Vector3.new(3865, 20, - 1926)
        },
        {
            ["Flamingo Mansion"] = Vector3.new(- 317, 331, 597),
            ["Flamingo Room"] = Vector3.new(2283, 15, 867),
            ["Cursed Ship"] = Vector3.new(923, 125, 32853),
            ["Zombie Island"] = Vector3.new(- 6509, 83, - 133)
        },
        {
            Mansion = Vector3.new(- 12464, 376, - 7566),
            ["Hydra Island"] = Vector3.new(5651, 1015, - 350),
            ["Temple of Time"] = Vector3.new(28286, 14897, 103),
            ["Sea Castle"] = Vector3.new(- 5090, 319, - 3146),
            ["Great Tree"] = Vector3.new(2953, 2282, - 7217)
        }
    })[CurrentSea]
    local function HandleNpcDebounce()
        TeleportManager.NpcDebounce = false
    end
    function TeleportManager.talkNpc(_, npcPart, npcAction, ...)
        if LocalPlayer:DistanceFromCharacter(npcPart.Position) < 5 then
            if type(npcAction) ~= "function" then
                FireRemote(npcAction, ...)
            else
                npcAction()
            end
        end
    end
    function TeleportManager.hasUnlocked(_, portalTarget)
        if CurrentSea == 3 and (portalTarget == "Hydra Island" or (portalTarget == "Sea Castle" or portalTarget == "Mansion")) then
            return UnlockedInventory["Valkyrie Helm"]
        end
        if CurrentSea == 2 then
            if portalTarget == "Flamingo Mansion" or portalTarget == "Flamingo Room" then
                return UnlockedInventory["Swan Glasses"] or PlayerLevel.Value >= 1750
            end
            if portalTarget == "Zombie Island" or portalTarget == "Cursed Ship" then
                return PlayerLevel.Value >= 1000
            end
        end
        return true
    end
    function TeleportManager.GetNearestPortal(self, targetPos)
        local minDist = math.huge
        local iterFunc, iterTable, iterKey = pairs(PortalsData)
        local bestPortalPos = nil
        local bestPortalName = nil
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if self:hasUnlocked(iterKey) then
                local distanceToPortal = (targetPos - iterVal).Magnitude
                if distanceToPortal < minDist then
                    bestPortalName = iterKey
                    bestPortalPos = iterVal
                    minDist = distanceToPortal
                end
            end
        end
        return bestPortalPos, bestPortalName
    end
    function TeleportManager.TeleportToGreatTree(self)
        self.new(self.GreatTree, nil, true)
        self:talkNpc(self.GreatTree, "RaceV4Progress", "TeleportBack")
    end
    function TeleportManager.NPCs(self, npcList, bring)
        if IsPlayerAlive(LocalPlayer.Character) then
            if self.NpcDebounce and npcList[self.nextNum] then
                TeleportFunc(npcList[self.nextNum] + self.SpawnVector)
                return nil
            end
            local playerRoot = LocalPlayer.Character.PrimaryPart
            if # npcList ~= 1 then
                if # npcList > 1 then
                    if self.nextNum > # npcList then
                        self.nextNum = 1
                    end
                    local targetNpc = npcList[self.nextNum]
                    if playerRoot and (playerRoot.Position - targetNpc.Position).Magnitude < 5 then
                        self.nextNum = self.nextNum + 1
                        self.NpcDebounce = true
                        task.delay(1, HandleNpcDebounce)
                    else
                        self.new(targetNpc, bring)
                    end
                end
            else
                self.new(npcList[1], bring)
            end
        end
    end
    function TeleportManager.new(targetCFrame, speedMultiplier, ignoreLastPos, bypassY)
        local self = TeleportManager
        if IsPlayerAlive(LocalPlayer.Character) and (tick() - self.lastTP >= 1 or targetCFrame ~= self.lastCF) then
            if LocalPlayer.Character.PrimaryPart then
                if not speedMultiplier then
                    self.lastPosition = targetCFrame.Position
                end
                self.lastTP = tick()
                self.lastCF = targetCFrame
                local playerHumanoid = LocalPlayer.Character.Humanoid
                local playerRoot = LocalPlayer.Character.PrimaryPart
                if playerHumanoid.Sit then
                    playerHumanoid.Sit = false
                    return
                elseif playerRoot.Anchored then
                    TweenModule:stop(playerRoot)
                else
                    local tweenSpeed = GlobalSettings.TweenSpeed or 220
                    local targetPos = targetCFrame.Position
                    local distance = (playerRoot.Position - targetPos).Magnitude
                    if distance < 150 and not ignoreLastPos then
                        TweenModule:stop(playerRoot)
                        playerRoot.CFrame = targetCFrame
                    end
                    local nearestPortalPos, nearestPortalName = self:GetNearestPortal(targetPos)
                    local portalDist
                    if nearestPortalPos then
                        portalDist = (targetPos - nearestPortalPos).Magnitude + 300
                    else
                        portalDist = nearestPortalPos
                    end
                    if nearestPortalPos and (tick() - self.BypassCooldown >= 8 and portalDist < distance) then
                        if nearestPortalName == "Great Tree" then
                            self:TeleportToGreatTree()
                        else
                            TweenModule:stop(playerRoot)
                            task.wait(0.2)
                            if (targetPos - nearestPortalPos).Magnitude >= 50 then
                                targetPos = nearestPortalPos + (targetPos - playerRoot.Position).Unit * 40
                            end
                            FireRemote("requestEntrance", targetPos)
                            BypassCooldown = tick()
                        end
                    elseif ignoreLastPos then
                        TweenModule.new(playerRoot, distance / ignoreLastPos, "CFrame", targetCFrame)
                    else
                        if not bypassY then
                            local rootPos = playerRoot.Position
                            local bypassCFrame = CFrame.new(rootPos.X, targetPos.Y, rootPos.Z)
                            if (rootPos - bypassCFrame.Position).Magnitude > 75 then
                                TweenModule:stop(playerRoot)
                                task.wait(0.1)
                                playerRoot.CFrame = bypassCFrame
                                task.wait(0.5)
                            end
                        end
                        if distance < 380 then
                            TweenModule.new(playerRoot, distance / (tweenSpeed * 2), "CFrame", targetCFrame)
                        else
                            TweenModule.new(playerRoot, distance / tweenSpeed, "CFrame", targetCFrame)
                        end
                    end
                end
            else
                return nil
            end
        else
            return nil
        end
    end
    MainModule.Tween:GetPropertyChangedSignal("Parent"):Connect(function()
        if not MainModule.Tween.Parent and IsPlayerAlive(LocalPlayer.Character) then
            TweenModule:stop(LocalPlayer.Character.PrimaryPart)
        end
    end)
    TeleportFunc = TeleportManager.new
    return TeleportManager
end
function AppManagers.QuestManager()
    local QuestManagerObj = {
        QuestList = {},
        EnemyList = {},
        QuestPos = {},
        Crafts = {},
        Sea = MainModule.GameData.Sea,
        takeQuestDebounce = false,
        _Position = CFrame.new(0, 0, 2.5)
    }
    local QuestUI = LocalPlayer.PlayerGui:WaitForChild("Main").Quest
    local QuestTitle = QuestUI.Container.QuestTitle.Title
    local ModulesRepoUrl = "https://raw.githubusercontent.com/newredzBloxFruits/refs/heads/main/GameModules/"
    local CoreGameModules = {
        GuideModule = ReplicatedStorage:WaitForChild("GuideModule"),
        Quests = ReplicatedStorage:WaitForChild("Quests"),
        SkinUtil = ModulesFolder:WaitForChild("SkinUtil")
    }
    local function LoadCoreModule(moduleName)
        local success, result = pcall(function()
            return require(CoreGameModules[moduleName])
        end)
        if not success then
            warn(("falha a o carregar Module [ %s ] [ %s ]"):format(moduleName, result))
        end
        return success and result and result or loadstring(HttpGetFunc(workspace, ModulesRepoUrl .. moduleName .. ".lua"))()
    end
    local GuideModule = LoadCoreModule("GuideModule")
    local QuestsModule = LoadCoreModule("Quests")
    local SkinUtilModule = LoadCoreModule("SkinUtil")
    local AuraSkins = SkinUtilModule.AuraSkins or SkinUtilModule
    local EnemyLocations = MainModule.EnemyLocations
    local _ = MainModule.EnemySpawned
    local IsBoss = MainModule.IsBoss
    local ColorsQuery = {
        Colors = {
            Context = "GetSkinsInventory"
        }
    }
    local function PopulateEnemies(questInfo)
        local iterFunc = next
        local questTasks = questInfo.Task
        local iterKey = nil
        local taskList = {}
        local locationList = {}
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(questTasks, iterKey)
            if iterKey == nil then
                break
            end
            locationList = EnemyLocations[iterKey] or {}
            EnemyLocations[iterKey] = locationList
            table.insert(taskList, iterKey)
        end
        return taskList, locationList
    end
    task.spawn(function()
        if GuideModule.Data.IsFakeData then
            return nil
        end
        local iterFunc, iterTable, iterKey = pairs(GuideModule.Data.NPCList)
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            QuestManagerObj.QuestPos[iterVal.NPCName] = CFrame.new(iterVal.Position)
        end
        local NpcListMeta = {
            __newindex = function(self, npcIndex, npcData)
                QuestManagerObj.QuestPos[npcData.NPCName] = CFrame.new(npcData.Position)
                return rawset(self, npcIndex, npcData)
            end
        }
        setmetatable(GuideModule.Data.NPCList, NpcListMeta)
    end)
    task.spawn(MainModule.RunFunctions.Quests, QuestManagerObj, QuestsModule, PopulateEnemies)
    function QuestManagerObj.GetUnlockedHakiColors(self)
        if not self.haki_colors or tick() - self.haki_colors.last_update >= 30 then
            self.haki_colors = NetModules["RF/FruitCustomizerRF"]:InvokeServer(ColorsQuery.Colors)
            self.haki_colors.last_update = tick()
        end
        return self.haki_colors
    end
    function QuestManagerObj.GetQuest(self)
        if self.oldLevel ~= PlayerLevel.Value or not self.CurrentQuest then
            self.oldLevel = PlayerLevel.Value
            local currentSea = self.Sea
            local levelCap = math.clamp(PlayerLevel.Value, 0, currentSea == 1 and 700 or (currentSea == 2 and 1500 or PlayerLevel.Value))
            local iterFunc, iterTable, iterKey = ipairs(self.QuestList)
            local targetBossName = nil
            local bestBossQuest = nil
            local bestNormalQuest = nil
            while true do
                local iterVal
                iterKey, iterVal = iterFunc(iterTable, iterKey)
                if iterKey == nil then
                    break
                end
                local questLevel = iterVal.Enemy.Level
                local enemyName = iterVal.Enemy.Name[1]
                if IsBoss(enemyName) then
                    if questLevel <= levelCap and levelCap - 50 <= questLevel then
                        targetBossName = enemyName
                    else
                        targetBossName = false
                    end
                    bestBossQuest = iterVal
                else
                    if levelCap < questLevel then
                        self.CurrentQuest = bestNormalQuest
                        self.oldBossQuest = bestBossQuest
                        self.oldBoss = targetBossName
                        return bestNormalQuest
                    end
                    bestNormalQuest = iterVal
                end
            end
            self.CurrentQuest = bestNormalQuest
            self.oldBossQuest = bestBossQuest
            self.oldBoss = targetBossName
            return bestNormalQuest
        elseif self.oldBoss and MainModule.Enemies.IsSpawned(self.oldBoss) then
            return self.oldBossQuest
        else
            return self.CurrentQuest
        end
    end
    function QuestManagerObj.GetQuestPosition(self, npcName)
        if not GuideModule.Data.IsFakeData then
            return self.QuestPos[GuideModule.Data.LastClosestNPC]
        end
        local targetNpcStr = GuideModule.Data.NPCs[npcName]
        if targetNpcStr then
            targetNpcStr = NPCsWorkspace:FindFirstChild(targetNpcStr) or ReplicatedStorage.NPCs:FindFirstChild(targetNpcStr)
        end
        if targetNpcStr then
            targetNpcStr = targetNpcStr:GetPivot()
        end
        return targetNpcStr
    end
    function QuestManagerObj.VerifyQuest(_, questQuery)
        if not QuestUI.Visible then
            return false
        end
        local titleClean = string.gsub(QuestTitle.Text, "-", ""):lower()
        if type(questQuery) == "string" then
            return string.find(titleClean, string.gsub(questQuery, "-", ""):lower())
        end
        local iterFunc, iterTable, iterKey = ipairs(questQuery)
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if string.find(titleClean, string.gsub(iterVal, "-", ""):lower()) then
                return iterVal
            end
        end
    end
    function QuestManagerObj.StartQuest(self, questName, questLevel, npcCFrame)
        if npcCFrame and LocalPlayer:DistanceFromCharacter(npcCFrame.Position) >= 5 then
            TeleportFunc(npcCFrame * self._Position)
            return "Teleporting to NPC: " .. questName
        end
        if not self.takeQuestDebounce then
            task.wait(0.5)
            MainModule.FireRemote("StartQuest", questName, questLevel)
            return "Getting Quest: " .. questName, task.wait(0.5)
        end
        if self.Debounce and (tick() - self.Debounce < 75 and self.InDebounceQuest == questLevel .. questName) then
            return "Quest Debounce: " .. MiscUtils.GetTimer(75 - (tick() - self.Debounce))
        end
        GlobalSettings.RunningMethod = "Getting Quest: " .. questName
        task.wait(0.5)
        MainModule.FireRemote("StartQuest", questName, questLevel)
        local combinedQuestKey = questLevel .. questName
        self.Debounce = tick()
        self.InDebounceQuest = combinedQuestKey
        return GlobalSettings.RunningMethod, task.wait(0.5)
    end
    function QuestManagerObj.GetAuraCraft(_, auraName)
        return (AuraSkins[auraName] or {}).EtcItems
    end
    function QuestManagerObj.GetColorsList(_)
        local iterFunc, iterTable, iterKey = pairs(AuraSkins)
        local colorsOutput = {}
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if iterVal.EtcItems then
                table.insert(colorsOutput, iterKey)
            end
        end
        return colorsOutput
    end
    return QuestManagerObj
end
function AppManagers.FarmManager()
    local FarmManagerObj = {
        NPCs = {},
        CanFarm = {},
        EnemyLocation = {},
        ClickPosition = Vector2.new(),
        axisDebounce = 0
    }
    local IsPlayerAlive = MainModule.IsAlive
    local GetEnemySpawned = MainModule.EnemySpawned
    local EnemiesLoc = MainModule.EnemyLocations
    local EquipToolRemote = MainModule.EquipTool
    local LastToolEquip = 0
    FarmManagerObj.Materials = ({
        {
            "Leather + Scrap Metal",
            "Magma Ore",
            "Fish Tail",
            "Angel Wings"
        },
        {
            "Leather + Scrap Metal",
            "Magma Ore",
            "Mystic Droplet",
            "Radiactive Material",
            "Vampire Fang"
        },
        {
            "Leather + Scrap Metal",
            "Fish Tail",
            "Gunpowder",
            "Mini Tusk",
            "Conjured Cocoa",
            "Dragon Scale"
        }
    })[MainModule.GameData.Sea]
    FarmManagerObj.Enemies = {
        Elites = {
            "Deandre",
            "Diablo",
            "Urban"
        },
        Bones = {
            "Reborn Skeleton",
            "Living Zombie",
            "Demonic Soul",
            "Posessed Mummy"
        },
        Katakuri = {
            "Head Baker",
            "Baking Staff",
            "Cake Guard",
            "Cookie Crafter"
        },
        Ectoplasm = {
            "Ship Deckhand",
            "Ship Engineer",
            "Ship Steward",
            "Ship Officer"
        }
    }
    FarmManagerObj.FarmModes = {
        Star = function(self, rootPart)
            local targetPos = rootPart.CFrame + self:GetNextAxis()
            if LocalPlayer:DistanceFromCharacter(targetPos.Position) >= 5 then
                TeleportFunc(targetPos)
            end
        end,
        Orbit = function(_, rootPart, mode)
            local enemyChar = rootPart.Parent
            local taskDelay = task.wait()
            local runningOption = GlobalSettings.RunningOption
            local orbitSpeed = 3.5
            local orbitAngle = 0
            while (mode or GlobalSettings.FarmMode) == "Orbit" and (ActiveOptions[runningOption] and (rootPart and IsPlayerAlive(enemyChar))) do
                if tick() - LastToolEquip >= 1 then
                    EquipToolRemote()
                end
                EnableBuso()
                local farmDist = GlobalSettings.FarmDistance
                orbitAngle = orbitAngle + orbitSpeed * taskDelay
                TeleportFunc(CFrame.new(math.cos(orbitAngle) * farmDist, 8, math.sin(orbitAngle) * farmDist) + rootPart.Position)
                taskDelay = task.wait(GlobalSettings.SmoothMode and 0.1 or 0)
            end
        end,
        Up = function(_, rootPart)
            local targetPos = rootPart.CFrame + GlobalSettings.FarmPos
            if LocalPlayer:DistanceFromCharacter(targetPos.Position) >= 5 then
                TeleportFunc(targetPos)
            end
        end
    }
    local MaterialSpawns = {
        ["Angel Wings"] = {
            CFrame.new(- 7742, 5634, - 1564)
        },
        ["Leather + Scrap Metal"] = {
            CFrame.new(- 1257, 54, 4091),
            CFrame.new(- 1100, 77, 1152),
            CFrame.new(- 364, 116, 5692)
        },
        ["Magma Ore"] = {
            CFrame.new(- 5408, 11, 8456),
            CFrame.new(- 5241, 50, - 4713)
        },
        ["Fish Tail"] = {
            CFrame.new(60931, 19, 1574),
            false,
            CFrame.new(- 10679, 398, - 8975)
        },
        ["Mystic Droplet"] = {
            false,
            CFrame.new(- 3350, 282, - 10527)
        },
        ["Radiactive Material"] = {
            false,
            CFrame.new(- 73, 149, - 112)
        },
        ["Vampire Fang"] = {
            false,
            CFrame.new(- 6030, 6, - 1281)
        },
        Gunpowder = {
            false,
            false,
            CFrame.new(- 394, 135, 5981)
        },
        ["Mini Tusk"] = {
            false,
            false,
            CFrame.new(- 13510, 584, - 6986)
        },
        ["Conjured Cocoa"] = {
            false,
            false,
            CFrame.new(400, 81, - 12257)
        },
        ["Dragon Scale"] = {
            false,
            false,
            CFrame.new(6689, 378, 331)
        }
    }
    local MaterialEnemies = {
        ["Leather + Scrap Metal"] = {
            {
                "Pirate",
                "Brute",
                "Scrap Metal",
                "Pirate Millionaire"
            },
            {
                true,
                true,
                true
            }
        },
        ["Angel Wings"] = {
            {
                "Royal Soldier",
                "Royal Squad"
            },
            {
                true,
                false,
                false
            }
        },
        ["Magma Ore"] = {
            {
                "Military Soldier",
                "Lava Pirate"
            },
            {
                true,
                true,
                false
            }
        },
        ["Fish Tail"] = {
            {
                "Fishman Warrior",
                "Fishman Captain",
                "Fishman Raider"
            },
            {
                true,
                false,
                true
            }
        },
        ["Conjured Cocoa"] = {
            {
                "Cocoa Warrior",
                "Chocolate Bar Battler"
            },
            {
                false,
                false,
                true
            }
        },
        ["Mystic Droplet"] = {
            {
                "Water Fighter"
            },
            {
                false,
                true,
                false
            }
        },
        ["Radiactive Material"] = {
            {
                "Factory Staff"
            },
            {
                false,
                true,
                false
            }
        },
        ["Vampire Fang"] = {
            {
                "Vampire"
            },
            {
                false,
                true,
                false
            }
        },
        Gunpowder = {
            {
                "Pistol Billionaire"
            },
            {
                false,
                false,
                true
            }
        },
        ["Mini Tusk"] = {
            {
                "Mythological Pirate"
            },
            {
                false,
                false,
                true
            }
        },
        ["Dragon Scale"] = {
            {
                "Dragon Crew Archer"
            },
            {
                false,
                false,
                true
            }
        }
    }
    function FarmManagerObj.ToolDebounce()
        LastToolEquip = tick()
    end
    function FarmManagerObj.TargetPosition(targetPos)
        if typeof(targetPos) == "CFrame" then
            TeleportFunc(targetPos)
            EnableBuso()
            EquipToolRemote()
        end
    end
    function FarmManagerObj.GetNextAxis(self)
        if tick() - self.axisDebounce <= 0.4 then
            return self.nextAxis
        end
        local newAxis = Vector3[math.random() <= 0.5 and "xAxis" or "zAxis"] * (math.random() <= 0.5 and GlobalSettings.FarmDistance or - GlobalSettings.FarmDistance) + Vector3.yAxis * 8
        local nextTick = tick()
        self.nextAxis = newAxis
        self.axisDebounce = nextTick
        return newAxis
    end
    function FarmManagerObj.Mastery(_, enemyPart, enemyHumanoid)
        local curHealth = enemyHumanoid.Health
        local allEnemies = EnemiesWorkspace
        local iterFunc, iterTable, iterKey = ipairs(allEnemies:GetChildren())
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if iterVal.PrimaryPart then
                local foundHumanoid = iterVal:FindFirstChild("Humanoid")
                if foundHumanoid and (foundHumanoid.Health > 0 and foundHumanoid.Health <= curHealth) then
                    curHealth = foundHumanoid.Health
                    enemyPart = iterVal.PrimaryPart
                    enemyHumanoid = foundHumanoid
                end
            end
        end
        local masteryFarmPos = enemyPart.CFrame + GlobalSettings.FarmPos
        local healthPercentage = enemyHumanoid.Health / enemyHumanoid.MaxHealth * 100
        EquipToolRemote(healthPercentage <= GlobalSettings.mHealth and GlobalSettings.mTool or "Melee", true)
        MainModule:BringEnemies(enemyPart.Parent)
        EnableBuso()
        if LocalPlayer:DistanceFromCharacter(masteryFarmPos.Position) >= 2.5 then
            TeleportFunc(masteryFarmPos)
        end
        if healthPercentage <= GlobalSettings.mHealth and LocalPlayer:DistanceFromCharacter(masteryFarmPos.Position) < 5 then
            MainModule.Hooking:SetTarget(enemyPart, enemyPart.Parent, true)
            MainModule.UseSkills(enemyPart, GlobalSettings.MasterySkills)
        end
    end
    function FarmManagerObj.attack(self, enemyChar, bring, bringDist, mode)
        local enemyHumanoid = enemyChar:FindFirstChild("Humanoid")
        if not enemyHumanoid then
            return nil
        end
        if ActiveOptions.Mastery and enemyHumanoid.MaxHealth < 40000 then
            FarmManagerObj:Mastery(enemyChar.PrimaryPart, enemyHumanoid)
            return true
        end
        if bring then
            MainModule:BringEnemies(enemyChar, bringDist)
        end
        if tick() - LastToolEquip >= 1 then
            EquipToolRemote()
        end
        EnableBuso()
        FarmManagerObj.FarmModes[mode or GlobalSettings.FarmMode](FarmManagerObj, enemyChar.PrimaryPart, mode)
        if GlobalSettings.SmoothMode and ((mode or GlobalSettings.FarmMode) ~= "Orbit" and (task.wait(0.1) and (IsPlayerAlive(enemyChar) and (enemyChar.PrimaryPart and ActiveOptions[GlobalSettings.RunningOption])))) then
            local cachedSettings = GlobalSettings
            local cachedGlobal = GlobalEnv
            local attackLabel = "Killing: " .. enemyChar.Name
            cachedGlobal.OnFarm = true
            cachedSettings.RunningMethod = attackLabel
            FarmManagerObj.attack(enemyChar, bring, bringDist, mode)
        end
        return true
    end
    function FarmManagerObj.Material(self, materialName)
        local matSpawn = MaterialSpawns[materialName]
        if matSpawn then
            matSpawn = MaterialSpawns[materialName][MainModule.GameData.Sea]
        end
        local matEnemyData = MaterialEnemies[materialName]
        if matEnemyData then
            local enemyLocs = self.EnemyLocation
            local canFarmMat = self.CanFarm
            if canFarmMat[materialName] == nil then
                if matEnemyData[2][MainModule.GameData.Sea] then
                    canFarmMat[materialName] = true
                else
                    canFarmMat[materialName] = false
                end
            end
            if not canFarmMat[materialName] then
                return nil
            end
            if enemyLocs[materialName] == nil then
                local iterFunc, iterTable, iterKey = ipairs(matEnemyData[1])
                while true do
                    local iterVal
                    iterKey, iterVal = iterFunc(iterTable, iterKey)
                    if iterKey == nil then
                        break
                    end
                    local locData = EnemiesLoc[iterVal]
                    if locData and # locData > 0 then
                        enemyLocs[materialName] = locData
                    end
                end
                if not enemyLocs[materialName] then
                    enemyLocs[materialName] = false
                end
            end
            local iterFunc2, iterTable2, iterKey2 = ipairs(matEnemyData[1])
            while true do
                local iterVal2
                iterKey2, iterVal2 = iterFunc2(iterTable2, iterKey2)
                if iterKey2 == nil then
                    break
                end
                local spawnedEnemy = GetEnemySpawned(iterVal2)
                if spawnedEnemy and spawnedEnemy.PrimaryPart then
                    self.attack(spawnedEnemy, true, true)
                    return "Killing: " .. iterVal2
                end
            end
            if enemyLocs[materialName] then
                AppManagers.PlayerTeleport:NPCs(enemyLocs[materialName])
            else
                TeleportFunc(matSpawn)
            end
            return "Farming Material: " .. materialName
        end
    end
    function FarmManagerObj.GetNpcPosition(self, npcName)
        if self.NPCs[npcName] then
            return self.NPCs[npcName]:GetPivot()
        end
        local npcInst = NPCsWorkspace:FindFirstChild(npcName) or ReplicatedStorage.NPCs:FindFirstChild(npcName)
        if npcInst then
            self.NPCs[npcName] = npcInst
            local _ = npcInst.GetPivot
        end
    end
    return FarmManagerObj
end
function AppManagers.RaidManager()
    if MainModule.GameData.Sea ~= 2 and MainModule.GameData.Sea ~= 3 then
        return nil
    end
    local RaidManagerObj = {}
    local _ = MainModule.GameData.Sea ~= 2
    RaidManagerObj.RaidPosition = CFrame.new(- 5033, 315, - 2950)
    RaidManagerObj.requests = {}
    RaidManagerObj.Require = 0
    RaidManagerObj.Timer = LocalPlayer.PlayerGui:WaitForChild("Main").Timer
    RaidManagerObj.Button = MainModule.GameData.Sea == 2 and "CircleIsland.RaidSummon2.Button.Main" or (MainModule.GameData.Sea == 3 and "Boat Castle.RaidSummon2.Button.Main" or false)
    function RaidManagerObj.IsRaiding(_)
        local raidStatus = ActiveOptions.Raid
        if raidStatus then
            raidStatus = LocalPlayer:GetAttribute("IslandRaiding")
        end
        return raidStatus
    end
    function RaidManagerObj.GetRaidIsland(_)
        return MainModule:GetRaidIsland()
    end
    function RaidManagerObj.CanStartRaid(_)
        local canStart
        if PlayerLevel.Value < 1200 then
            canStart = false
        else
            canStart = VerifyTool("Special Microchip")
        end
        return canStart
    end
    function RaidManagerObj.start(self)
        if not self:IsRaiding() and self:CanStartRaid() then
            local buttonPath = self.Button:split(".")
            local currentObj = MapWorkspace
            for i = 1, # buttonPath do
                if currentObj then
                    currentObj = currentObj:FindFirstChild(buttonPath[i])
                end
            end
            if currentObj and currentObj:FindFirstChild("ClickDetector") then
                fireclickdetector(currentObj.ClickDetector)
                task.wait(1)
            else
                local _ = self.RaidPosition
            end
        end
    end
    function RaidManagerObj.requestFragment(self, reqType, amount)
        if self.requests[reqType] then
            return nil
        end
        self.Require = self.Require + (amount or 0)
    end
    return RaidManagerObj
end
function AppManagers.ItemsQuests()
    local ItemsManager = {
        CursedDualKatana = {},
        SkullGuitar = {}
    }
    local IsEnemySpawned = MainModule.Enemies.IsSpawned
    local GetEnemySpawned = MainModule.EnemySpawned
    local EnemyLocations = MainModule.EnemyLocations
    local EquipToolRemote = MainModule.EquipTool
    local FireRemoteCmd = MainModule.FireRemote
    if MainModule.GameData.Sea == 3 then
        local CurrentQuestHaze = nil
        local function GetClosestQuestHaze()
            if CurrentQuestHaze and CurrentQuestHaze.Value > 0 then
                return CurrentQuestHaze
            end
            local minHazeDist = math.huge
            local iterFunc, iterTable, iterKey = ipairs(LocalPlayer.QuestHaze:GetChildren())
            local bestHaze = nil
            while true do
                local iterVal
                iterKey, iterVal = iterFunc(iterTable, iterKey)
                if iterKey == nil then
                    break
                end
                if iterVal.Value > 0 then
                    local hazeTargetPos = iterVal:GetAttribute("Position")
                    local hazeDist
                    if typeof(hazeTargetPos) ~= "Vector3" then
                        hazeDist = false
                    else
                        hazeDist = LocalPlayer:DistanceFromCharacter(hazeTargetPos)
                    end
                    if hazeDist then
                        if hazeDist <= minHazeDist then
                            bestHaze = iterVal
                            minHazeDist = hazeDist
                        end
                    end
                end
            end
            CurrentQuestHaze = bestHaze
            return bestHaze
        end
        local function GetHellTorch(dimensionInst)
            for i = 1, 3 do
                local torchInst = dimensionInst:FindFirstChild("Torch" .. i)
                if torchInst then
                    if torchInst:FindFirstChild("ProximityPrompt") then
                        if torchInst.ProximityPrompt.Enabled then
                            return torchInst
                        end
                    end
                end
            end
        end
        local function GetCursedPedestal(turtleCursedInst)
            for i = 1, 3 do
                local pedestalInst = turtleCursedInst:FindFirstChild("Pedestal" .. i)
                if pedestalInst then
                    if pedestalInst:FindFirstChild("ProximityPrompt") then
                        if pedestalInst.ProximityPrompt.Enabled then
                            return pedestalInst
                        end
                    end
                end
            end
        end
        local function GetClosestBoatDealer(dealersCache)
            local minDealerDist = math.huge
            local iterFunc, iterTable, iterKey = ipairs(ReplicatedStorage.NPCs:GetChildren())
            local bestDealer = nil
            while true do
                local iterVal
                iterKey, iterVal = iterFunc(iterTable, iterKey)
                if iterKey == nil then
                    break
                end
                if iterVal.Name == "Luxury Boat Dealer" and not dealersCache[iterVal] then
                    local dealerRoot = iterVal.PrimaryPart
                    if dealerRoot and LocalPlayer:DistanceFromCharacter(dealerRoot.Position) <= minDealerDist then
                        minDealerDist = LocalPlayer:DistanceFromCharacter(dealerRoot.Position)
                        bestDealer = iterVal
                    end
                end
            end
            return bestDealer
        end
        local YamaQuestsList = {
            function(self, _)
                if VerifyTool("Yama") then
                    EquipToolRemote("Yama")
                    local forestPirateSpawn = GetEnemySpawned("Forest Pirate")
                    if forestPirateSpawn and forestPirateSpawn.PrimaryPart then
                        MainModule.AttackCooldown = tick()
                        TeleportFunc(forestPirateSpawn.PrimaryPart.CFrame * CFrame.new(0, 0, - 2))
                    else
                        TeleportFunc(self.ForestPirate)
                    end
                else
                    FireRemoteCmd("LoadItem", "Yama")
                end
                return true
            end,
            function(_, _)
                local currentHaze = LocalPlayer:FindFirstChild("QuestHaze") and GetClosestQuestHaze()
                if currentHaze then
                    local hazeEnemyName = currentHaze.Name
                    local targetHazeEnemy = GetEnemySpawned(hazeEnemyName)
                    if targetHazeEnemy and targetHazeEnemy.PrimaryPart then
                        AppManagers.FarmManager.attack(targetHazeEnemy, true)
                    elseif EnemyLocations[hazeEnemyName] then
                        AppManagers.PlayerTeleport:NPCs(EnemyLocations[hazeEnemyName])
                    else
                        TeleportFunc(currentHaze:GetAttribute("Position"))
                    end
                    return true
                end
            end,
            function(self, farmHelpers)
                local hellDim = MapWorkspace:FindFirstChild("HellDimension")
                if hellDim then
                    local activeTorch = GetHellTorch(hellDim) or hellDim:FindFirstChild("Exit")
                    if activeTorch and LocalPlayer:DistanceFromCharacter(activeTorch.Position) <= 600 then
                        local targetHellNpc = GetEnemySpawned(self.Hell)
                        if targetHellNpc and targetHellNpc.PrimaryPart then
                            TeleportFunc(targetHellNpc.PrimaryPart.CFrame + GlobalSettings.FarmPos)
                            return true, MainModule.KillAura(125)
                        end
                        if activeTorch.Name == "Exit" or LocalPlayer:DistanceFromCharacter(activeTorch.Position) >= 5 then
                            TeleportFunc(activeTorch.CFrame)
                        else
                            fireproximityprompt(activeTorch.ProximityPrompt)
                        end
                    end
                    return true
                end
                if not IsEnemySpawned("Soul Reaper") then
                    return farmHelpers.SoulReaper() or farmHelpers.Bones()
                end
                local reaperSpawn = GetEnemySpawned("Soul Reaper")
                if reaperSpawn and reaperSpawn.PrimaryPart and LocalPlayer:DistanceFromCharacter(reaperSpawn.PrimaryPart.Position) > 6 then
                    TeleportFunc(reaperSpawn.PrimaryPart.CFrame * CFrame.new(0, 0, - 2))
                    return true
                end
            end
        }
        ItemsManager.CursedDualKatana.Yama = YamaQuestsList
        local TushitaQuestsList = {
            function(self, _)
                if LocalPlayer:FindFirstChild("BoatQuest") then
                    local currentDealer = self.CurrentDealer
                    if not currentDealer or self.BoatsDealer[currentDealer] then
                        currentDealer = NPCsWorkspace:FindFirstChild("Luxury Boat Dealer")
                        if not currentDealer or (not currentDealer.PrimaryPart or self.BoatsDealer[currentDealer]) then
                            currentDealer = GetClosestBoatDealer(self.BoatsDealer)
                        end
                    end
                    if currentDealer and currentDealer.PrimaryPart then
                        if self.CurrentDealer ~= currentDealer then
                            self.CurrentDealer = currentDealer
                        end
                        if LocalPlayer:DistanceFromCharacter(currentDealer.PrimaryPart.Position) >= 5 then
                            return true, TeleportFunc(currentDealer.PrimaryPart.CFrame)
                        end
                        if FireRemoteCmd("CDKQuest", "BoatQuest", currentDealer, "Check") then
                            FireRemoteCmd("CDKQuest", "BoatQuest", currentDealer)
                        end
                        self.BoatsDealer[currentDealer] = true
                    else
                        task.wait(0.5)
                    end
                end
            end,
            function(_, farmHelpers)
                return farmHelpers.PirateRaid()
            end,
            function(self, _)
                local heavenDim = MapWorkspace:FindFirstChild("HeavenlyDimension")
                if heavenDim then
                    local activeTorch = GetHellTorch(heavenDim) or heavenDim:FindFirstChild("Exit")
                    if activeTorch and LocalPlayer:DistanceFromCharacter(activeTorch.Position) <= 600 then
                        local targetHeavenNpc = GetEnemySpawned(self.Heaven)
                        if targetHeavenNpc and targetHeavenNpc.PrimaryPart then
                            TeleportFunc(targetHeavenNpc.PrimaryPart.CFrame + GlobalSettings.FarmPos)
                            return true, MainModule.KillAura(125)
                        end
                        if activeTorch.Name == "Exit" or LocalPlayer:DistanceFromCharacter(activeTorch.Position) >= 5 then
                            TeleportFunc(activeTorch.CFrame)
                        else
                            fireproximityprompt(activeTorch.ProximityPrompt)
                        end
                    end
                    return true
                end
                if IsEnemySpawned("Cake Queen") then
                    local queenSpawn = GetEnemySpawned("Cake Queen")
                    if queenSpawn and queenSpawn.PrimaryPart then
                        AppManagers.FarmManager.attack(queenSpawn)
                    else
                        TeleportFunc(self.CakeQueen)
                    end
                    return true
                end
            end
        }
        ItemsManager.CursedDualKatana.Tushita = TushitaQuestsList
        function ItemsManager.CursedDualKatana.FinalQuest(self, _)
            if VerifyTool("Tushita") or VerifyTool("Yama") then
                if IsEnemySpawned("Cursed Skeleton Boss") then
                    local skelBossSpawn = GetEnemySpawned("Cursed Skeleton Boss")
                    if not (skelBossSpawn and skelBossSpawn.PrimaryPart) then
                        return nil
                    end
                    EquipToolRemote("Sword", true)
                    AppManagers.FarmManager.ToolDebounce()
                    AppManagers.FarmManager.attack(skelBossSpawn)
                    return true
                end
                if LocalPlayer.PlayerGui.Main.Dialogue.Visible then
                    VirtualUser:ClickButton1(Vector2.new(10000, 10000))
                end
                local cursedPedestal = GetCursedPedestal(MapWorkspace.Turtle.Cursed)
                if cursedPedestal then
                    if LocalPlayer:DistanceFromCharacter(cursedPedestal.Position) >= 5 then
                        TeleportFunc(cursedPedestal.CFrame)
                    else
                        fireproximityprompt(cursedPedestal.ProximityPrompt)
                    end
                    return true
                end
                local distanceToSkel1 = LocalPlayer:DistanceFromCharacter(self.CursedSkeleton[1].Position)
                if distanceToSkel1 > 6 then
                    TeleportFunc(self.CursedSkeleton[1], distanceToSkel1 <= 100 and 40 or false)
                else
                    TeleportFunc(self.CursedSkeleton[2])
                end
                task.wait(0.5)
                return true
            end
            FireRemoteCmd("LoadItem", "Yama")
        end
    end
    if MainModule.GameData.Sea == 3 then
        local DojoLocation = CFrame.new(5867, 1208, 872)
        local WizardLocation = CFrame.new(5771, 1209, 804)
        local DragonQuestRemote = NetModules:WaitForChild("RF/InteractDragonQuest")
        local InventoryCounts = MainModule.Inventory.Count
        local UnlockedItems = MainModule.Inventory.Unlocked
        local BeltManager = {
            Progress = {},
            CurrentBelt = "Null",
            YellowQuest = ToDictionary({
                "Piranha",
                "Shark"
            }),
            RedQuest = ToDictionary({
                "Terrorshark",
                "Sea Beast"
            })
        }
        local WizardCommands = {
            CheckStart = {
                "CanTransform",
                "CanLearnTether",
                "TetherLearned",
                "AvailableVQuest"
            },
            Complete = {
                NPC = "Dragon Wizard",
                Command = "Ascension",
                Action = "Complete"
            },
            Begin = {
                NPC = "Dragon Wizard",
                Command = "Ascension",
                Action = "Begin"
            },
            LearnTether = {
                NPC = "Dragon Wizard",
                Command = "LearnTether"
            },
            BuyDraco = {
                NPC = "Dragon Wizard",
                Command = "DragonRace"
            }
        }
        local DojoCommands = {
            DojoClaim = {
                NPC = "Dojo Trainer",
                Command = "ClaimQuest"
            },
            DojoProgress = {
                NPC = "Dojo Trainer",
                Command = "RequestQuest"
            },
            SpeakWizard = {
                NPC = "Dragon Wizard",
                Command = "Speak"
            },
            RaceV3 = ToDictionary({
                "Terrorshark",
                "Sea Beast"
            })
        }
        function BeltManager.CollectReward(_, beltColor)
            if UnlockedItems["Dojo Belt (" .. beltColor .. ")"] then
                BeltManager.Progress[beltColor] = nil
                return nil
            else
                if LocalPlayer:DistanceFromCharacter(DojoLocation.Position) > 3 then
                    TeleportFunc(DojoLocation)
                else
                    DragonQuestRemote:InvokeServer(DojoCommands.DojoClaim)
                    ItemsManager.CurrentBeltQuest = nil
                end
                return true
            end
        end
        function BeltManager.White(self, helpers)
            if self.Progress.White < 20 then
                return helpers.Level()
            else
                return self:CollectReward("White")
            end
        end
        function BeltManager.Green(self)
            if self.Progress.Green >= 330 then
                return self:CollectReward("Green")
            end
            if LocalPlayer:GetAttribute("DangerLevel") >= 500 and self.GreenTimer then
                self.Progress.Green = self.Progress.Green + (tick() - self.GreenTimer)
            end
            self.GreenTimer = tick()
            if AppManagers.SeaManager:GetPlayerBoat() then
                AppManagers.SeaManager:RandomTeleport("inf")
            else
                AppManagers.SeaManager:BuyNewBoat()
            end
            return true
        end
        function BeltManager.Purple(self, helpers)
            if self.Progress.Purple >= 3 then
                return self:CollectReward("Purple")
            end
            if self.PurpleProgress then
                if helpers.EliteHunter() then
                    return true
                end
                local mainModuleRef = MainModule
                self.Progress.Purple = self.StartPurpleProgress + (mainModuleRef:GetProgress("EliteProgress", "EliteHunter", "Progress") - self.PurpleProgress)
            else
                self.StartPurpleProgress = self.Progress.Purple
                self.PurpleProgress = MainModule:GetProgress("EliteProgress", "EliteHunter", "Progress")
            end
        end
        function BeltManager.Red(self, helpers)
            if self.Progress.Red < 1 then
                return helpers.Sea(self.RedQuest)
            else
                return self:CollectReward("Red")
            end
        end
        function BeltManager.Yellow(self, helpers)
            if self.Progress.Yellow < 5 then
                return helpers.Sea(self.YellowQuest)
            else
                return self:CollectReward("Yellow")
            end
        end
        function BeltManager.Blue(self, helpers)
            if self.Progress.Blue >= 1 then
                return self:CollectReward("Blue")
            end
            if LocalPlayer.Character then
                local heldTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if heldTool and (heldTool:FindFirstChild("Fruit") and (heldTool.ToolTip ~= "Blox Fruit" and heldTool:GetAttribute("DroppedBy"))) and heldTool:GetAttribute("DroppedBy"):len() > 0 then
                    self.Progress.Blue = 1
                    return nil
                end
                local iterFunc, iterTable, iterKey = ipairs(LocalPlayer.Backpack:GetChildren())
                while true do
                    local iterVal
                    iterKey, iterVal = iterFunc(iterTable, iterKey)
                    if iterKey == nil then
                        break
                    end
                    if iterVal:IsA("Tool") and (iterVal:FindFirstChild("Fruit") and (iterVal.ToolTip ~= "Blox Fruit" and heldTool:GetAttribute("DroppedBy"))) and heldTool:GetAttribute("DroppedBy"):len() > 0 then
                        self.Progress.Blue = 1
                        return nil
                    end
                end
                local _ = helpers.Fruits
            end
        end
        function BeltManager.Black(self, helpers)
            if self.Progress.Black < 3 then
                if self.BlackProgress then
                    self.Progress.Black = InventoryCounts["Dinosaur Bones"] - self.BlackProgress
                    return helpers.LavaGolem() or (helpers.PrehistoricBones() or helpers.PrehistoricIsland())
                else
                    self.BlackProgress = self.Progress.Black - InventoryCounts["Dinosaur Bones"]
                    return true
                end
            else
                return self:CollectReward("Black")
            end
        end
        function ItemsManager.BeltProgress(self, beltColor, amountAdded)
            if BeltManager.CurrentBelt ~= beltColor then
                if self.CurrentDracoQuest and self.CurrentDracoQuest.AvailableVQuest == "V3InProgress" then
                    self.KilledTerrorshark = true
                end
            else
                BeltManager.Progress[beltColor] = BeltManager.Progress[beltColor] + amountAdded
            end
        end
        function ItemsManager.BeltQuest(self, questData, helpers)
            local targetBeltName = questData.BeltName
            if BeltManager[targetBeltName] then
                if UnlockedItems["Dojo Belt (" .. targetBeltName .. ")"] then
                    return self:GetNextBeltQuest()
                end
                if not (BeltManager.Progress[targetBeltName] and questData.UpdatedProgress) then
                    local beltProgressCache = BeltManager.Progress
                    local questProgress = questData.Progress
                    questData.UpdatedProgress = true
                    beltProgressCache[targetBeltName] = questProgress
                end
                BeltManager.CurrentBelt = targetBeltName
                if BeltManager[targetBeltName](BeltManager, helpers) then
                    return "Belt Quest: " .. targetBeltName
                end
            end
        end
        function ItemsManager.GetNextBeltQuest(self)
            if LocalPlayer:DistanceFromCharacter(DojoLocation.Position) > 5 then
                TeleportFunc(DojoLocation)
            else
                self.CurrentBeltQuest = DragonQuestRemote:InvokeServer(DojoCommands.DojoProgress)
            end
            return "Getting Belt Quest"
        end
        function ItemsManager.BeltQuests(self, helpers)
            local curBeltQuest = self.CurrentBeltQuest
            if type(curBeltQuest) ~= "table" then
                local _ = self.GetNextBeltQuest
            else
                if curBeltQuest.Timeout or curBeltQuest.Completed then
                    return nil
                end
                if curBeltQuest.Quest then
                    return self:BeltQuest(curBeltQuest.Quest, helpers)
                end
            end
        end
        function ItemsManager.SpeakWizard(self)
            if LocalPlayer:DistanceFromCharacter(WizardLocation.Position) > 5 then
                TeleportFunc(WizardLocation)
            else
                self.CurrentDracoQuest = DragonQuestRemote:InvokeServer(DojoCommands.SpeakWizard)
            end
            return "Teleporting to NPC: Dragon Wizard"
        end
        function ItemsManager.TalkNpc(self, npcCFrame, commandData, questKeyToClear)
            if LocalPlayer:DistanceFromCharacter(npcCFrame.Position) > 5 then
                TeleportFunc(npcCFrame)
            elseif DragonQuestRemote:InvokeServer(commandData) and questKeyToClear then
                self[questKeyToClear] = nil
            end
            return "Teleporting to NPC: " .. (commandData.NPC or "???")
        end
        function ItemsManager.GetDracoRace(self, helpers)
            if not UnlockedItems["Dojo Belt (Black)"] then
                return helpers.DojoTrainer()
            end
            local curDracoQ = self.CurrentDracoQuest
            if type(curDracoQ) ~= "table" then
                local _ = self.SpeakWizard
            else
                if not (curDracoQ.TetherLearned or curDracoQ.CanLearnTether) then
                    return nil
                end
                if not curDracoQ.FoundPrehistoric then
                    return helpers.PrehistoricBones() or helpers.PrehistoricEgg() or (helpers.LavaGolem() or helpers.PrehistoricIsland())
                end
                if PlayerData.Race.Value ~= "Draco" then
                    if curDracoQ.CanTransform or curDracoQ.CanTransformFree then
                        return self:TalkNpc(WizardLocation, WizardCommands.BuyDraco, "CurrentDracoQuest")
                    elseif curDracoQ.TetherLearned then
                        if UnlockedItems["Dragon Egg"] then
                            return self:TalkNpc(WizardLocation, WizardCommands.BuyDraco, "CurrentDracoQuest")
                        else
                            return helpers.PrehistoricBones() or helpers.PrehistoricEgg() or (helpers.LavaGolem() or helpers.PrehistoricIsland())
                        end
                    else
                        return self:TalkNpc(WizardLocation, WizardCommands.LearnTether, "CurrentDracoQuest")
                    end
                end
                local availableQ = curDracoQ.AvailableVQuest
                if availableQ == "V2" or availableQ == "V3" then
                    return self:TalkNpc(WizardLocation, WizardCommands.Begin, "CurrentDracoQuest")
                end
                if availableQ == "V2InProgress" then
                    if InventoryCounts["Fire Flower"] < 5 then
                        return ActiveOptions.EliteHunter and helpers.EliteHunter() or (ActiveOptions.BerryBush and ActiveOptions.BerryBush() or helpers.FireFlowers(5))
                    else
                        return self:TalkNpc(WizardLocation, WizardCommands.Complete, "CurrentDracoQuest")
                    end
                end
                if availableQ == "V3InProgress" then
                    if self.KilledTerrorshark then
                        return self:TalkNpc(WizardLocation, WizardCommands.Complete, "CurrentDracoQuest")
                    else
                        return helpers.Sea(DojoCommands.RaceV3)
                    end
                end
                if availableQ == "V2TurnInReady" then
                    if PlayerData.Level.Value < 1000000 then
                        return helpers.Level()
                    else
                        return self:TalkNpc(WizardLocation, WizardCommands.Complete, "CurrentDracoQuest")
                    end
                end
                if availableQ == "V3TurnInReady" then
                    if PlayerData.Level.Value < 3000000 then
                        return helpers.Level()
                    else
                        return self:TalkNpc(WizardLocation, WizardCommands.Complete, "CurrentDracoQuest")
                    end
                end
            end
        end
    end
    return ItemsManager
end
function AppManagers.IslandManager()
    return {
        Islands = {},
        GetMirageFruitDealer = function(self)
            if self.MirageFruitDealer then
                return self.MirageFruitDealer
            end
            local dealerInst = NPCsWorkspace:FindFirstChild("Advanced Fruit Dealer") or ReplicatedStorage.NPCs:FindFirstChild("Advanced Fruit Dealer")
            if dealerInst then
                self.MirageFruitDealer = dealerInst
                return dealerInst
            end
        end,
        GetMirageGear = function(self, mysticIslandModel)
            if self.MirageGear and self.MirageGear.Parent then
                return self.MirageGear
            end
            local iterFunc, iterTable, iterKey = ipairs(mysticIslandModel:GetChildren())
            while true do
                local iterVal
                iterKey, iterVal = iterFunc(iterTable, iterKey)
                if iterKey == nil then
                    break
                end
                if iterVal:IsA("MeshPart") and iterVal.MeshId == "rbxassetid://10153114969" then
                    self.MirageGear = iterVal
                    return iterVal
                end
            end
        end,
        GetMirageTop = function(self, mysticIslandModel)
            if self.MirageTop and self.MirageTop.Parent then
                return self.MirageTop
            end
            local iterFunc, iterTable, iterKey = ipairs(mysticIslandModel:GetChildren())
            while true do
                local iterVal
                iterKey, iterVal = iterFunc(iterTable, iterKey)
                if iterKey == nil then
                    break
                end
                local cubeObj = iterVal:FindFirstChild("dbz_map1_Cube.012")
                if cubeObj then
                    self.MirageTop = cubeObj
                    return cubeObj
                end
            end
        end,
        GetPrehistoricActivationPrompt = function(self, prehistoricIslandModel)
            local prePrompt = self.PrehistoricPrompt
            if prePrompt and prePrompt:IsDescendantOf(MapWorkspace) then
                return prePrompt
            end
            local coreObj = prehistoricIslandModel:FindFirstChild("Core")
            if coreObj and coreObj:FindFirstChild("ActivationPrompt") then
                self.PrehistoricPrompt = coreObj.ActivationPrompt
                return coreObj.ActivationPrompt
            end
        end,
        GetSpawnedIsland = function(self, islandName)
            local islandCache = self.Islands[islandName]
            if islandCache and islandCache.Parent == MapWorkspace then
                return islandCache
            end
            local islandInst = MapWorkspace:FindFirstChild(islandName)
            if islandInst then
                self.Islands[islandName] = islandInst
                return islandInst
            end
        end
    }
end
function AppManagers.EspManager()
    local EspClass = {}
    EspClass.__index = EspClass
    function EspClass.__newindex(self, key, value)
        if key == "Enabled" then
            return task.spawn(self.toggle, self, value)
        else
            return rawset(self, key, value)
        end
    end
    local function GetEspTarget(baseObj)
        if baseObj:FindFirstChild("Humanoid") then
            return baseObj.PrimaryPart or baseObj
        elseif baseObj:FindFirstChild("Handle") then
            return baseObj.Handle
        else
            return baseObj
        end
    end
    local function DestroyEsp(espObj)
        if espObj.Object and espObj.Section.List[espObj.Object] then
            espObj.Section.List[espObj.Object] = nil
        end
        if espObj.EspHandle then
            espObj.EspHandle:Destroy()
        end
    end
    local FruitsName = MainModule.FruitsName
    local EspTextFormat = "%s<font color=\'rgb(160, 160, 160)\'> [ %im ]</font>\n<font color=\'rgb(25, 240, 25)\'>[%i/%i]</font>"
    local EspFolder = Instance.new("Folder", CoreGui)
    EspFolder.Name = "rz_EspFolder"
    local prevEspFolder = CoreGui:FindFirstChild(EspFolder.Name)
    if prevEspFolder and prevEspFolder ~= EspFolder then
        prevEspFolder:Destroy()
    end
    function EspClass.new(name, instance, isEspObjFunc, isEnabledFunc)
        local newEsp = setmetatable({}, EspClass)
        local categoryFolder = Instance.new("Folder", EspFolder)
        categoryFolder.Name = name
        newEsp.List = {}
        newEsp.Name = name
        newEsp.Folder = categoryFolder
        newEsp.IsEnabled = isEnabledFunc
        newEsp.Instance = instance
        newEsp.IsEspObject = isEspObjFunc
        return newEsp
    end
    function EspClass.clear(self)
        self.Folder:ClearAllChildren()
        table.clear(self.List)
    end
    function EspClass.add(self, targetObj, color, nameStr, _)
        local espItemData = {
            Section = self,
            Color = color or Color3.fromRGB(255, 255, 255),
            Name = nameStr or targetObj.Name,
            Object = targetObj,
            EspHandle = nil
        }
        local boxAdorn = Instance.new("BoxHandleAdornment")
        boxAdorn.Size = Vector3.new(1, 0, 1, 0)
        boxAdorn.AlwaysOnTop = true
        boxAdorn.ZIndex = 10
        boxAdorn.Transparency = 0
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Adornee = targetObj
        billboardGui.Size = UDim2.new(0, 100, 0, 150)
        billboardGui.StudsOffset = Vector3.new(0, 2, 0)
        billboardGui.AlwaysOnTop = true
        local textLbl = Instance.new("TextLabel")
        textLbl.BackgroundTransparency = 1
        textLbl.Position = UDim2.new(0, 0, 0, - 50)
        textLbl.Size = UDim2.new(0, 100, 0, 100)
        textLbl.TextSize = 10
        textLbl.TextColor3 = espItemData.Color
        textLbl.TextStrokeTransparency = 0
        textLbl.TextYAlignment = Enum.TextYAlignment.Bottom
        textLbl.Text = "..."
        textLbl.ZIndex = 15
        textLbl.RichText = true
        textLbl.Parent = billboardGui
        billboardGui.Parent = boxAdorn
        boxAdorn.Parent = self.Folder
        espItemData.EspHandle = boxAdorn
        task.spawn(function()
            local isEnabledFunc = self.IsEnabled
            local espHandle = espItemData.EspHandle
            local espObj = espItemData.Object
            while true do
                if not (GlobalSettings.SmoothMode and task.wait(0.25)) then
                    SteppedEvent:Wait()
                end
                if not espObj or (not espObj:IsDescendantOf(workspace) or (not espHandle or isEnabledFunc and not isEnabledFunc(espObj))) then
                    return DestroyEsp(espItemData)
                end
                local espTargetPos = GetEspTarget(espObj)
                if not espTargetPos then
                    return DestroyEsp(espItemData)
                end
                if espTargetPos:IsA("Model") then
                    espTargetPos = espTargetPos:GetPivot()
                end
                local playerRef = LocalPlayer
                local distance = math.floor(playerRef:DistanceFromCharacter(espTargetPos.Position) / 5)
                local targetHumanoid = espObj:FindFirstChildOfClass("Humanoid")
                if targetHumanoid then
                    textLbl.Text = EspTextFormat:format(espItemData.Name, distance, math.floor(targetHumanoid.Health), math.floor(targetHumanoid.MaxHealth))
                elseif espObj.Parent ~= workspace or espObj.Name ~= "Fruit " then
                    textLbl.Text = ("%s < %i >"):format(espItemData.Name, distance)
                else
                    textLbl.Text = "Fruit [ ??? ]"
                    textLbl.Text = ("%s < %i >"):format(FruitsName[espObj], distance)
                end
            end
        end)
        return espItemData
    end
    function EspClass.toggle(self, toggleState)
        local genvEspKey = "Esp" .. self.Name
        GlobalEnv[genvEspKey] = toggleState
        local isEnabledFunc = self.IsEnabled
        local targetInstance = self.Instance
        local isEspObjectFunc = self.IsEspObject
        while GlobalEnv[genvEspKey] do
            local childrenList
            if type(targetInstance) ~= "table" or not targetInstance then
                childrenList = targetInstance:GetChildren()
            else
                childrenList = targetInstance
            end
            for idx = 1, # childrenList do
                local childObj = childrenList[idx]
                if not self.List[childObj] then
                    local isValid, colorVal, nameVal, overrideObj = isEspObjectFunc(childObj)
                    if isValid then
                        self.List[childObj] = self:add(overrideObj or childObj, colorVal, nameVal, isEnabledFunc)
                    end
                end
            end
            task.wait(0.25)
        end
        self:clear()
    end
    return EspClass
end
function AppManagers.SeaManager()
    if MainModule.GameData.Sea == 1 then
        return nil
    end
    local SeaManagerObj = {
        oldTool = "Melee",
        SeaEvents = {},
        BoatTweenDebounce = 0,
        randomNumber = 1,
        toolDebounce = 0,
        rdDebounce = 0,
        nextNum = 1,
        SeaEnemyVector = Vector3.new(0, 32, 0),
        DodgeVector = Vector3.new(0, 160, 0),
        nextTool = {
            Melee = "Blox Fruit",
            ["Blox Fruit"] = "Sword",
            Sword = "Gun",
            Gun = "Melee"
        },
        BuyBoat = {
            Position = MainModule.GameData.Sea == 2 and CFrame.new(94, 10, 2951) or CFrame.new(- 6123, 16, - 2247),
            TikiIsland = CFrame.new(- 16917, 9, 510),
            BoatName = "BeastHunter",
            OthersBoats = {
                "BeastHunter",
                "Guardian",
                "Lantern",
                "Sleigh",
                "PirateGrandBrigade",
                "MarineGrandBrigade"
            }
        },
        RandomPosition = ({
            false,
            {
                CFrame.new(- 43, 21, 5054),
                CFrame.new(1744, 21, 4393),
                CFrame.new(1003, 21, 3598),
                CFrame.new(- 935, 21, 3813)
            },
            {
                inf = - 100000000,
                ["6"] = - 43200,
                ["5"] = - 38200,
                ["4"] = - 34000,
                ["3"] = - 30000,
                ["2"] = - 26000,
                ["1"] = - 22000
            }
        })[MainModule.GameData.Sea],
        Directions = {
            Vector3.new(60, 0, 0),
            Vector3.new(0, 0, 60),
            Vector3.new(- 60, 0, 0),
            Vector3.new(0, 0, - 60),
            Vector3.new(0, 0, 0)
        },
        TerrorSkills = {
            "FinalSpinAttachment",
            "GroundExplosionSplashStart",
            "SpinSlash",
            "SpinSlash3",
            "SpinSlash4"
        }
    }
    local _ = MainModule.Inventory.Unlocked
    local InventoryCount = MainModule.Inventory.Count
    local IsPlayerAlive = MainModule.IsAlive
    local UseSkillsRemote = MainModule.UseSkills
    local EquipToolRemote = MainModule.EquipTool
    local FireRemoteCmd = MainModule.FireRemote
    local TargetHumanoid = nil
    local SubclassNetworkRemote = RemotesFolder:WaitForChild("SubclassNetwork")
    if MainModule.GameData.Sea == 3 then
        local randomPosData = SeaManagerObj.RandomPosition
        local iterFunc, iterTable, iterKey = pairs(randomPosData)
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            randomPosData[iterKey] = {
                CFrame.new(iterVal, 21, 500),
                CFrame.new(iterVal - 3000, 21, 500),
                CFrame.new(iterVal - 3000, 21, 2000),
                CFrame.new(iterVal, 21, - 1000)
            }
        end
    end
    function SeaManagerObj.IsOwner(self, boatInst)
        local ownerObj = self:FindFirstChild("Owner")
        if ownerObj then
            ownerObj = self.Owner.Value.Name == LocalPlayer.Name
        end
        return ownerObj
    end
    function SeaManagerObj.GetPlayerBoat(self)
        if IsPlayerAlive(LocalPlayer.Character) then
            local playerBoatCache = self.PlayerBoat
            if playerBoatCache and (not playerBoatCache:FindFirstChild("Health") or IsPlayerAlive(playerBoatCache)) and playerBoatCache:IsDescendantOf(BoatsWorkspace) then
                return playerBoatCache
            end
            local seatPart = LocalPlayer.Character.Humanoid.SeatPart
            if seatPart and seatPart.Name == "VehicleSeat" then
                self.PlayerBoat = seatPart.Parent
                return self.PlayerBoat
            end
            local allBoats = BoatsWorkspace
            local iterFunc, iterTable, iterKey = ipairs(allBoats:GetChildren())
            while true do
                local iterVal
                iterKey, iterVal = iterFunc(iterTable, iterKey)
                if iterKey == nil then
                    break
                end
                if (not iterVal:FindFirstChild("Health") or IsPlayerAlive(iterVal)) and self.IsOwner(iterVal) then
                    if iterVal.Name ~= self.BuyBoat.BoatName then
                        self.BuyBoat.BoatName = iterVal.Name
                    end
                    self.PlayerBoat = iterVal
                    return iterVal
                end
            end
        end
    end
    function SeaManagerObj.BuyNewBoat(self)
        if not MainModule.IsAlive(LocalPlayer.Character) then
            return nil
        end
        local buyBoatData = self.BuyBoat
        local boatPos = buyBoatData.Position
        if MainModule.GameData.Sea == 3 then
            local playerRef = LocalPlayer
            if LocalPlayer:DistanceFromCharacter(buyBoatData.TikiIsland.Position) < playerRef:DistanceFromCharacter(boatPos.Position) then
                boatPos = buyBoatData.TikiIsland
            end
        end
        if LocalPlayer:DistanceFromCharacter(boatPos.Position) >= 10 then
            TeleportFunc(boatPos)
        elseif FireRemoteCmd("BuyBoat", buyBoatData.BoatName) ~= 1 then
            for idx = 1, # buyBoatData.OthersBoats do
                local otherBoatName = buyBoatData.OthersBoats[idx]
                if otherBoatName ~= buyBoatData.BoatName then
                    if FireRemoteCmd("BuyBoat", otherBoatName) == 1 then
                        break
                    end
                end
            end
        end
    end
    function SeaManagerObj.teleportBoat(self, boatRoot, targetCFrame, speedOverride)
        if tick() - self.BoatTweenDebounce >= 0.5 then
            local direction = (targetCFrame.Position - boatRoot.Position).Unit
            MainModule.Tween.Velocity = direction * (speedOverride or GlobalSettings.BoatSpeed)
            MainModule:RemoveBoatCollision(boatRoot.Parent)
            self.BoatTweenDebounce = tick()
        end
    end
    function SeaManagerObj.StopBoat(_)
        MainModule.Tween.Velocity = Vector3.zero
    end
    function SeaManagerObj.GetSelectedLevel(self, levelKey)
        return self.RandomPosition[levelKey or GlobalSettings.SeaLevel]
    end
    function SeaManagerObj.RandomTeleport(self, levelKey)
        if not TargetHumanoid or TargetHumanoid.Health <= 0 then
            local playerChar = LocalPlayer.Character
            if playerChar then
                playerChar = LocalPlayer.Character:FindFirstChild("Humanoid")
            end
            TargetHumanoid = playerChar
            return nil
        end
        if not TargetHumanoid.SeatPart then
            return self:TeleportToBoat()
        end
        local boatRoot = self:GetPlayerBoat().PrimaryPart
        if not boatRoot then
            return nil
        end
        local boatPos = boatRoot.Position
        local targetPosData = MainModule.GameData.Sea == 3 and self:GetSelectedLevel(levelKey) or self.RandomPosition
        if # targetPosData ~= 1 then
            if # targetPosData > 1 then
                if self.nextNum > # targetPosData then
                    self.nextNum = 1
                end
                local specificTarget = targetPosData[self.nextNum]
                if (boatPos - specificTarget.Position).Magnitude >= 100 then
                    self:teleportBoat(boatRoot, specificTarget)
                else
                    self.nextNum = self.nextNum + 1
                end
            end
        else
            self:teleportBoat(boatRoot, targetPosData[1])
        end
    end
    function SeaManagerObj.RandomTool(self)
        if tick() - self.toolDebounce < 2 then
            return self.oldTool
        end
        self.toolDebounce = tick()
        local nxtTool = self.nextTool[self.oldTool]
        local attemptCount = 0
        while not VerifyToolTip(nxtTool) do
            nxtTool = self.nextTool[nxtTool]
            attemptCount = attemptCount + 1
            if attemptCount >= 3 then
                self.oldTool = nxtTool
                return nxtTool
            end
        end
        self.oldTool = nxtTool
        return nxtTool
    end
    function SeaManagerObj.GetSeaEvent(_, eventName)
        local allEnemies = EnemiesWorkspace
        local iterFunc, iterTable, iterKey = ipairs(allEnemies:GetChildren())
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if iterVal.Name == eventName and IsPlayerAlive(iterVal) then
                return iterVal
            end
        end
    end
    function SeaManagerObj.attackBoat(self, boatInst)
        local boatRoot = boatInst.PrimaryPart
        if not boatRoot then
            return nil
        end
        local attackCFrame = boatRoot.CFrame + Vector3.new(0, 20, 0)
        EnableBuso()
        TeleportFunc(attackCFrame)
        self:StopBoat()
        if LocalPlayer:DistanceFromCharacter(attackCFrame.Position) < 50 then
            UseSkillsRemote(boatRoot, GlobalSettings.SeaSkills)
            EquipToolRemote(self:RandomTool(), true)
        end
    end
    function SeaManagerObj.attackFish(self, fishInst)
        local fishRoot = fishInst.PrimaryPart
        if fishRoot then
            if (fishInst.Name == "Terrorshark" or fishInst.Name == "Shark") and GlobalSettings.DodgeShark then
                local dodgeSkills = self.TerrorSkills
                for idx = 1, # dodgeSkills do
                    local dodgeTarget = WorldOrigin:FindFirstChild(dodgeSkills[idx])
                    if dodgeTarget then
                        if (dodgeTarget.Position - fishRoot.Position).Magnitude <= 100 then
                            return TeleportFunc(fishRoot.CFrame + self.DodgeVector)
                        end
                    end
                end
            end
            TeleportFunc(fishRoot.CFrame + self.SeaEnemyVector)
            EquipToolRemote()
            EnableBuso()
            self:StopBoat()
        end
    end
    function SeaManagerObj.StartHolding(_, toolInst)
        if not toolInst:GetAttribute("Repairing") then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            print("Segurando o mouse")
            toolInst.AncestryChanged:Wait()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            print("Parou de segurar")
        end
    end
    function SeaManagerObj.RepairBoat(self, boatInst)
        local isShipwright = GlobalSettings.RepairBoat and PlayerSubclass.Value == "Shipwright" and (InventoryCount["Wooden Plank"] > 0 and boatInst:FindFirstChild("Humanoid"))
        if isShipwright and (boatInst:GetAttribute("__Repair") or isShipwright.Value < (boatInst:GetAttribute("MaxHealth") or isShipwright.Value) / 1.2) then
            local repairHammer = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):FindFirstChild("_RepairHammer")
            if isShipwright.Value >= (boatInst:GetAttribute("MaxHealth") or isShipwright.Value) then
                boatInst:SetAttribute("__Repair", nil)
            else
                boatInst:SetAttribute("__Repair", true)
            end
            if not (repairHammer and repairHammer:WaitForChild("Marker")) then
                if boatInst:FindFirstChild("VehicleSeat") then
                    local boatSeatCFrame = boatInst.VehicleSeat.CFrame + Vector3.yAxis * 20
                    if LocalPlayer:DistanceFromCharacter(boatSeatCFrame.Position) > 5 then
                        TeleportFunc(boatSeatCFrame)
                    else
                        SubclassNetworkRemote.UseSubclass:InvokeServer({
                            Action = "RequestHammer"
                        })
                    end
                end
                return true, self:StopBoat(boatInst)
            end
            TeleportFunc(repairHammer.Marker.Value.WorldCFrame + Vector3.xAxis * 10)
            task.spawn(self.StartHolding, self, repairHammer)
            return true
        end
        if PlayerSubclass.Value == "Shipwright" and (GlobalSettings.RepairBoat and LocalPlayer.Character) and LocalPlayer.Character:FindFirstChild("_RepairHammer") then
            SubclassNetworkRemote.UseSubclass:InvokeServer({
                Action = "RequestHammer"
            })
        end
    end
    function SeaManagerObj.attackSeaEvent(self, seaEventInst)
        if seaEventInst:GetAttribute("IsBoat") then
            self:attackBoat(seaEventInst)
        else
            self:attackFish(seaEventInst)
        end
    end
    function SeaManagerObj.RandomDirection(self)
        if tick() - self.rdDebounce < 1.5 then
            return self.Directions[self.randomNumber]
        end
        self.rdDebounce = tick()
        self.randomNumber = math.random(# self.Directions)
        return self.Directions[self.randomNumber]
    end
    function SeaManagerObj.attackSeaBeast(self, seaBeastInst)
        local attackDir = self:RandomDirection()
        local beastRoot = seaBeastInst:FindFirstChild("HumanoidRootPart")
        if not beastRoot then
            return nil
        end
        local beastPos = beastRoot.Position
        local attackCFrame = CFrame.new(beastPos.X, 25, beastPos.Z) + attackDir
        EnableBuso()
        TeleportFunc(attackCFrame)
        self:StopBoat()
        EquipToolRemote(self:RandomTool(), true)
        UseSkillsRemote(attackCFrame, GlobalSettings.SeaSkills)
    end
    function SeaManagerObj.GetSeaBeast(self)
        local beastCache = self.SeaBeast
        if beastCache and (beastCache.Parent == SeaBeastsWorkspace and IsPlayerAlive(beastCache)) then
            return beastCache
        end
        local minDist = math.huge
        local allSeaBeasts = SeaBeastsWorkspace
        local iterFunc, iterTable, iterKey = ipairs(allSeaBeasts:GetChildren())
        local bestBeast = nil
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if iterVal:IsA("Model") then
                local distToPlayer = LocalPlayer:DistanceFromCharacter(iterVal:GetPivot().Position)
                if IsPlayerAlive(iterVal) then
                    if distToPlayer < minDist then
                        bestBeast = iterVal
                        minDist = distToPlayer
                    end
                end
            end
        end
        self.SeaBeast = bestBeast
        return bestBeast
    end
    function SeaManagerObj.TeleportToBoat(self)
        if not TargetHumanoid or TargetHumanoid.Health <= 0 or not TargetHumanoid:IsDescendantOf(CharactersWorkspace) then
            local playerChar = LocalPlayer.Character
            if playerChar then
                playerChar = LocalPlayer.Character:FindFirstChild("Humanoid")
            end
            TargetHumanoid = playerChar
            return nil
        end
        local vSeat = self.VehicleSeat
        if vSeat and vSeat:IsDescendantOf(self.PlayerBoat) then
            if TargetHumanoid.SeatPart and TargetHumanoid.SeatPart ~= vSeat then
                TargetHumanoid.Sit = false
            elseif LocalPlayer:DistanceFromCharacter(vSeat.Position) >= 150 then
                TeleportFunc(vSeat.CFrame)
            else
                vSeat:Sit(TargetHumanoid)
            end
            task.wait(0.25)
        elseif self.PlayerBoat then
            self.VehicleSeat = self.PlayerBoat:FindFirstChild("VehicleSeat")
        end
    end
    return SeaManagerObj
end
function AppManagers.FruitManager()
    local FruitManagerObj = {
        RandomDebounce = 0,
        MoneyToReroll = 0
    }
    local IsPlayerAlive = MainModule.IsAlive
    local _ = MainModule.FruitsName
    local InventoryCount = MainModule.Inventory.Count
    local _ = MainModule.Inventory.Unlocked
    function FruitManagerObj.GetRealFruitName(_, fruitTool)
        local fruitClean = string.gsub(fruitTool.Name, " Fruit", "")
        return fruitClean .. "-" .. fruitClean
    end
    function FruitManagerObj.CanStoreFruit(self, fruitObj)
        return InventoryCount[self:GetRealFruitName(fruitObj)] < PlayerFruitCap.Value
    end
    function FruitManagerObj.StoreFruit(self, fruitToStore)
        return MainModule.FireRemote("StoreFruit", self:GetRealFruitName(fruitToStore), fruitToStore)
    end
    function FruitManagerObj.IsFruit(_, fruitItem)
        local isFruitObj
        if string.sub(fruitItem.Name, - 6, - 1) ~= " Fruit" then
            isFruitObj = false
        else
            isFruitObj = fruitItem:GetAttribute("DroppedBy")
        end
        return isFruitObj
    end
    function FruitManagerObj.GetInventoryItems(_)
        local itemsList = LocalPlayer.Backpack:GetChildren()
        local equippedTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if equippedTool then
            table.insert(itemsList, equippedTool)
        end
        return itemsList
    end
    function FruitManagerObj.CanBuyMicrochip(self)
        if not IsPlayerAlive(LocalPlayer.Character) then
            return false
        end
        if LocalPlayer:GetAttribute("IslandRaiding") then
            return false
        end
        if LocalPlayer.Backpack:FindFirstChild("Microchip") or LocalPlayer.Character:FindFirstChild("Microchip") then
            return false
        end
        local iterFunc, iterTable, iterKey = ipairs(self:GetInventoryItems())
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if iterVal:IsA("Tool") and self:IsFruit(iterVal) then
                return true
            end
        end
        return - 1
    end
    function FruitManagerObj.GetStorableFruit(self, excludeFruitName)
        if not IsPlayerAlive(LocalPlayer.Character) then
            return false
        end
        local iterFunc, iterTable, iterKey = ipairs(self:GetInventoryItems())
        repeat
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
        until iterKey == nil or iterVal.Name ~= excludeFruitName and not IsPlayerAlive(LocalPlayer.Character)
    end
    function FruitManagerObj.RerollRandomFruit(self)
        if PlayerLevel.Value < 50 then
            return PlayerLevel:GetPropertyChangedSignal("Value"):Wait()
        end
        if PlayerBeli.Value < self.MoneyToReroll then
            return PlayerBeli:GetPropertyChangedSignal("Value"):Wait()
        end
        if tick() - self.RandomDebounce >= 1 then
            local buyResult = MainModule.FireRemote("Cousin", "Buy")
            if buyResult == 1 then
                self.RandomDebounce = tick() + 7200
            elseif buyResult == 2 then
                local _, _, priceResult = MainModule.FireRemote("Cousin", "Check")
                self.MoneyToReroll = priceResult or 0
            elseif type(buyResult) ~= "string" or not buyResult:match("%d%d:%d%d") then
                self.RandomDebounce = tick() + 5
            else
                local hrs, mins = buyResult:match("(%d+):(%d+)")
                local hrsInt = tonumber(hrs)
                local minsInt = tonumber(mins)
                if hrsInt and minsInt then
                    local hrsToSec = hrsInt * 60 * 60
                    local minsToSec = minsInt * 60
                    self.RandomDebounce = tick() + (hrsToSec + minsToSec)
                end
            end
        end
    end
    return FruitManagerObj
end
function App.RunModules(self)
    local iterFunc = next
    local iterTable = self.Managers
    local iterKey = nil
    while true do
        local iterVal
        iterKey, iterVal = iterFunc(iterTable, iterKey)
        if iterKey == nil then
            break
        end
        local success, result = pcall(iterVal)
        if success then
            self.Managers[iterKey] = result
            GlobalEnv[iterKey] = result
        else
            GlobalEnv[iterKey] = nil
            warn("falha ao carregar Module [ redz hub ]: " .. iterKey .. " : " .. result)
        end
    end
end
function App.Initialize(self)
    UILibrary = __loadstring(ScriptSetup.LibraryUrl or "{Owner}RedzLibV5/refs/heads/main/Source.lua")
    MainModule = __loadstring(ScriptSetup.ModuleUrl or "{Repository}Utils/Module.luau", " return Module", {
        GlobalSettings,
        ScriptConnections
    })
    self.IsCustomUrl = (ScriptSetup.LibraryUrl or (ScriptSetup.ModuleUrl or ScriptSetup.CustomFunctions)) and true or false
    App:RunModules()
end
function App.LoadTabs(_, Window)
    return {
        Discord = Window:MakeTab({
            "Discord",
            "Info"
        }),
        MainFarm = Window:MakeTab({
            "Farm",
            "Home"
        }),
        Sea = Window:MakeTab({
            "Sea",
            "Waves"
        }),
        RaceV4 = Window:MakeTab({
            "Race-V4",
            ""
        }),
        Islands = Window:MakeTab({
            "Islands",
            "PalmTree"
        }),
        Items = Window:MakeTab({
            "Quests/Items",
            "Swords"
        }),
        FruitRaid = Window:MakeTab({
            "Fruit/Raid",
            "Cherry"
        }),
        Stats = Window:MakeTab({
            "Stats",
            "Signal"
        }),
        Teleport = Window:MakeTab({
            "Teleport",
            "Locate"
        }),
        Status = Window:MakeTab({
            "Status",
            "scroll"
        }),
        Visual = Window:MakeTab({
            "Visual",
            "User"
        }),
        Shop = Window:MakeTab({
            "Shop",
            "ShoppingCart"
        }),
        Misc = Window:MakeTab({
            "Misc",
            "Settings"
        })
    }
end
function App.InstallPlugin(_)
    return {
        Toggle = MainModule.RunFunctions.LibraryToggle(ActiveOptions, UIToggles)
    }
end
function App.GetTranslation(_, langCode)
    local langFiles = {
        BR = "Portuguese.json",
        VN = "Vietnamese.json",
        TH = "Thai.json"
    }
    if langFiles[langCode] then
        local _ = HttpService.JSONDecode
        local _ = __httpget
        local _ = "{Owner}BloxFruits/refs/heads/main/Translator/" .. langFiles[langCode]
    end
end
function App.Translator(self, targetWindow)
    if not ScriptSetup.Translator then
        return targetWindow
    end
    local success, result, cacheResult = pcall(function()
        local readFunc = readfile
        if readFunc then
            readFunc = pcall(readfile, "PlayerCountry.txt")
        end
        local cachedCountry = nil
        if readFunc and type(cachedCountry) == "string" then
            return cachedCountry, true
        else
            return LocalizationService:GetCountryRegionForPlayerAsync(LocalPlayer)
        end
    end)
    if success and (result and (cacheResult ~= true and writefile)) then
        pcall(writefile, "PlayerCountry.txt", result)
    end
    if success then
        success = self:GetTranslation(result)
    end
    if success then
        local _ = MainModule.RunFunctions.Translator
    end
    return targetWindow
end
function App.DisableOption(_)
    if GlobalSettings.RunningOption and UIToggles[GlobalSettings.RunningOption] then
        UIToggles[GlobalSettings.RunningOption]:Set(false, true)
    end
end
function App.LoadLibrary(self)
    local MainUI = UILibrary:MakeWindow({
        "redz Hub : Blox Fruits",
        "by real_redz",
        "redzHub-BloxFruits.json"
    })
    self:Translator(MainUI)
    local PluginToggles = self:InstallPlugin(MainUI)
    local Tabs = self:LoadTabs(MainUI)
    local FruitMgr = self.Managers.FruitManager
    local QuestMgr = self.Managers.QuestManager
    local FarmMgr = self.Managers.FarmManager
    local FireRemoteCmd = MainModule.FireRemote
    local InventoryCount = MainModule.Inventory.Count
    local UnlockedItems = MainModule.Inventory.Unlocked
    local currentSeaLvl = MainModule.GameData.Sea
    local toggleFunc = PluginToggles.Toggle
    MainUI:SelectTab(Tabs.MainFarm)
    MainUI:AddMinimizeButton({
        Button = {
            Image = "rbxassetid://15298567397",
            BackgroundTransparency = 0
        },
        Corner = {
            CornerRadius = UDim.new(0, 6)
        }
    })
    local DiscordTab = Tabs.Discord
    DiscordTab:AddDiscordInvite({
        Name = "redz Hub | Community",
        Description = "Join our discord community to receive information about the next update",
        Logo = "rbxassetid://17382040552",
        Invite = "https://discord.gg/7aR7kNVt4g"
    })
    DiscordTab:AddSection("")
    DiscordTab:AddParagraph({
        "Mentions:\n Honorable Mention: acsu123\n Honorable Mention 2: XFister"
    })
    local FarmTab = Tabs.MainFarm
    local uiScales = {
        Bigger = 380,
        Large = 450,
        Medium = 620,
        Small = 760
    }
    local multiSelectData = {
        {
            "Z",
            "X",
            "C",
            "V",
            "F"
        },
        ToDictionary({
            "Z",
            "X",
            "C",
            "V"
        })
    }
    local function setScaleFunc(scaleKey)
        pcall(UILibrary.SetScale, UILibrary, uiScales[scaleKey] or 450)
    end
    local function tradeBonesFunc(state)
        GlobalEnv.TradeBones = state
        while GlobalEnv.TradeBones do
            task.wait()
            local boneCount = InventoryCount.Bones
            if boneCount >= 50 then
                FireRemoteCmd("Bones", "Buy", 1, 1)
                if boneCount == InventoryCount.Bones then
                    task.wait(5)
                end
            else
                task.wait(0.5)
            end
        end
    end
    local bossListDropdown = nil
    local function updateBossListFunc()
        local iterFunc, iterTable, iterKey = pairs(MainModule.Bosses)
        local bossNames = {}
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if MainModule.Enemies.IsSpawned(iterKey) then
                table.insert(bossNames, iterKey)
            end
        end
        bossListDropdown:Set(bossNames)
    end
    FarmTab:AddDropdown({
        "Select Tool",
        {
            "Melee",
            "Sword",
            "Blox Fruit",
            "Gun"
        },
        "Melee",
        {
            GlobalSettings,
            "FarmTool"
        },
        "FarmTool"
    })
    FarmTab:AddDropdown({
        "UI Scale",
        {
            "Small",
            "Medium",
            "Large",
            "Bigger"
        },
        "Large",
        setScaleFunc,
        "UIScale"
    })
    FarmTab:AddSection("Farm")
    toggleFunc(FarmTab, {
        "Auto Farm Level",
        "Level Farm"
    }, "Level")
    toggleFunc(FarmTab, {
        "Auto Farm Nearest",
        "Farm Nearest Mobs"
    }, "Nearest")
    if currentSeaLvl ~= 1 then
        if currentSeaLvl == 2 then
            toggleFunc(FarmTab, {
                "Auto Factory",
                "Spawns Every 1:30 [hours, minutes]"
            }, "Factory")
            FarmTab:AddSection("Ectoplasm")
            toggleFunc(FarmTab, {
                "Auto Farm Ectoplasm"
            }, "Ectoplasm")
        elseif currentSeaLvl == 3 then
            toggleFunc(FarmTab, {
                "Auto Pirates Sea",
                "Auto Finish Pirate Raid in Sea Castle"
            }, "PirateRaid")
            FarmTab:AddSection("Bones")
            toggleFunc(FarmTab, {
                "Auto Farm Bones"
            }, "Bones")
            toggleFunc(FarmTab, {
                "Auto Kill Soul Reaper"
            }, "SoulReaper")
            FarmTab:AddToggle({
                "Auto Trade Bones",
                false,
                tradeBonesFunc,
                "TradeBones"
            })
        end
    end
    FarmTab:AddSection("Chest")
    toggleFunc(FarmTab, {
        "Auto Chest [ Tween ]"
    }, "ChestTween")
    FarmTab:AddSection("Bosses")
    FarmTab:AddButton({
        "Update Boss List",
        updateBossListFunc
    })
    bossListDropdown = FarmTab:AddDropdown({
        "Boss List",
        {},
        false,
        {
            GlobalSettings,
            "BossSelected"
        },
        "B-Selected"
    })
    updateBossListFunc()
    toggleFunc(FarmTab, {
        "Auto Kill Boss Selected",
        "Kill boss Selected"
    }, "BossSelected")
    toggleFunc(FarmTab, {
        "Auto Farm All Bosses",
        "Kill all bosses Spawned"
    }, "AllBosses")
    FarmTab:AddToggle({
        "Take Boss Quest",
        true,
        {
            GlobalSettings,
            "BossQuest"
        },
        "B-Quest"
    })
    FarmTab:AddSection("Material")
    local addDropdownFunc1 = FarmTab.AddDropdown
    local matListObj1 = {}
    local matDataObj1 = {
        GlobalSettings,
        "fMaterial"
    }
    __set_list(matListObj1, 1, {
        "Material List",
        FarmMgr.Materials,
        false,
        matDataObj1,
        "S-Material"
    })
    addDropdownFunc1(FarmTab, matListObj1)
    toggleFunc(FarmTab, {
        "Auto Farm Material",
        "Farm material Selected"
    }, "Material")
    FarmTab:AddSection("Mastery")
    FarmTab:AddSlider({
        "Select Enemy Health [ % ]",
        10,
        100,
        1,
        25,
        {
            GlobalSettings,
            "mHealth"
        },
        "M-Health"
    })
    FarmTab:AddDropdown({
        "Select Tool",
        {
            "Blox Fruit",
            "Gun"
        },
        {
            "Blox Fruit"
        },
        {
            GlobalSettings,
            "mTool"
        },
        "M-Tool"
    })
    local addDropdownFunc2 = FarmTab.AddDropdown
    local skillListObj1 = {}
    local skillData1 = multiSelectData[1]
    local skillData2 = multiSelectData[2]
    local skillTarget1 = {
        GlobalSettings,
        "MasterySkills"
    }
    skillListObj1.MultiSelect = true
    __set_list(skillListObj1, 1, {
        "Select Skills",
        skillData1,
        skillData2,
        skillTarget1,
        "M-Skills"
    })
    addDropdownFunc2(FarmTab, skillListObj1)
    toggleFunc(FarmTab, {
        "Auto Farm Mastery"
    }, "Mastery")
    local SeaTab = Tabs.Sea
    if currentSeaLvl == 1 then
        SeaTab:Destroy()
    elseif currentSeaLvl == 2 then
        local seaEnemiesData1 = {
            {
                "Sea Beast",
                "PirateBrigade"
            },
            ToDictionary({
                "Sea Beast"
            })
        }
        local seaSkillsData1 = {
            {
                "Z",
                "X",
                "C",
                "V",
                "F"
            },
            ToDictionary({
                "Z",
                "X",
                "C",
                "V"
            })
        }
        SeaTab:AddSection("Farm")
        toggleFunc(SeaTab, {
            "Auto Farm Sea"
        }, "Sea")
        SeaTab:AddSection("Farm Select")
        local addDropdownFunc3 = SeaTab.AddDropdown
        local enemyListObj1 = {}
        local eData1 = seaEnemiesData1[1]
        local eData2 = seaEnemiesData1[2]
        local eTarget1 = {
            GlobalSettings,
            "seaEnemy"
        }
        enemyListObj1.MultiSelect = true
        __set_list(enemyListObj1, 1, {
            "Enemies",
            eData1,
            eData2,
            eTarget1,
            "S-Enemies"
        })
        addDropdownFunc3(SeaTab, enemyListObj1)
        local addDropdownFunc4 = SeaTab.AddDropdown
        local sListObj2 = {}
        local sData3 = seaSkillsData1[1]
        local sData4 = seaSkillsData1[2]
        local sTarget2 = {
            GlobalSettings,
            "SeaSkills"
        }
        sListObj2.MultiSelect = true
        __set_list(sListObj2, 1, {
            "Select Skills",
            sData3,
            sData4,
            sTarget2,
            "S-Skills"
        })
        addDropdownFunc4(SeaTab, sListObj2)
        SeaTab:AddSection("Configs")
        SeaTab:AddSlider({
            "Boat Tween Speed",
            100,
            300,
            10,
            250,
            {
                GlobalSettings,
                "BoatSpeed"
            },
            "S-BoatSpeed"
        })
        SeaTab:AddToggle({
            "Auto Repair Boat [ BETA ]",
            false,
            {
                GlobalSettings,
                "RepairBoat"
            },
            "S-RepairBoat"
        })
    elseif currentSeaLvl == 3 then
        local seaSkillsData2 = {
            {
                "Z",
                "X",
                "C",
                "V",
                "F"
            },
            ToDictionary({
                "Z",
                "X",
                "C",
                "V"
            })
        }
        local seaFishData1 = {
            {
                "Sea Beast",
                "Terrorshark",
                "Fish Crew Member",
                "Piranha",
                "Shark"
            },
            ToDictionary({
                "Terrorshark",
                "Fish Crew Member",
                "Piranha",
                "Shark"
            })
        }
        local npcTpToggle = nil
        local npcTpLocs = {
            ["Shipwright Teacher"] = CFrame.new(- 16526, 76, 309),
            ["Shark Hunter"] = CFrame.new(- 16526, 108, 752),
            ["Beast Hunter"] = CFrame.new(- 16281, 73, 263),
            Spy = CFrame.new(- 16471, 528, 539)
        }
        local function teleportNpcFunc(state)
            GlobalEnv.teleporting = state
            while GlobalEnv.teleporting do
                task.wait()
                if GlobalSettings.selectedNpc then
                    TeleportFunc(npcTpLocs[GlobalSettings.selectedNpc])
                end
            end
            if state and npcTpToggle then
                npcTpToggle:Set(false, true)
            end
        end
        local function verifyNpcTpFunc(state)
            if state then
                local tpManager = self.Managers.PlayerTeleport
                local tpDist = math.huge
                while true do
                    task.wait()
                    if tpManager.lastPosition then
                        tpDist = LocalPlayer:DistanceFromCharacter(tpManager.lastPosition)
                    end
                    if not GlobalEnv.teleporting or tpDist < 15 then
                        GlobalEnv.teleporting = false
                    end
                end
            else
                return
            end
        end
        SeaTab:AddSection("Sea")
        toggleFunc(SeaTab, {
            "Auto Farm Sea"
        }, "Sea")
        SeaTab:AddToggle({
            "Auto Drive Boat",
            true,
            {
                GlobalSettings,
                "aTweenBoat"
            },
            "A-TweenBoat"
        })
        SeaTab:AddSection("Farm Select")
        local addDropdownFunc5 = SeaTab.AddDropdown
        local fishListObj1 = {}
        local fishData1 = seaFishData1[1]
        local fishData2 = seaFishData1[2]
        local fishTarget1 = {
            GlobalSettings,
            "fishSelected"
        }
        fishListObj1.MultiSelect = true
        __set_list(fishListObj1, 1, {
            "Fish",
            fishData1,
            fishData2,
            fishTarget1,
            "S-Fish"
        })
        addDropdownFunc5(SeaTab, fishListObj1)
        local addDropdownFunc6 = SeaTab.AddDropdown
        local boatListObj1 = {}
        local boatTarget1 = {
            GlobalSettings,
            "boatSelected"
        }
        boatListObj1.MultiSelect = true
        __set_list(boatListObj1, 1, {
            "Boats",
            {
                "PirateBrigade",
                "PirateGrandBrigade",
                "GhostShip",
                "FishBoat"
            },
            nil,
            boatTarget1,
            "S-Boat"
        })
        addDropdownFunc6(SeaTab, boatListObj1)
        local addDropdownFunc7 = SeaTab.AddDropdown
        local sListObj3 = {}
        local sData5 = seaSkillsData2[1]
        local sData6 = seaSkillsData2[2]
        local sTarget3 = {
            GlobalSettings,
            "SeaSkills"
        }
        sListObj3.MultiSelect = true
        __set_list(sListObj3, 1, {
            "Select Skills",
            sData5,
            sData6,
            sTarget3,
            "S-Skills"
        })
        addDropdownFunc7(SeaTab, sListObj3)
        SeaTab:AddSection("Configs")
        SeaTab:AddDropdown({
            "Sea Level",
            {
                "1",
                "2",
                "3",
                "4",
                "5",
                "6",
                "inf"
            },
            "6",
            {
                GlobalSettings,
                "SeaLevel"
            },
            "S-SeaLevel"
        })
        SeaTab:AddSlider({
            "Boat Tween Speed",
            100,
            300,
            10,
            250,
            {
                GlobalSettings,
                "BoatSpeed"
            },
            "S-BoatSpeed"
        })
        SeaTab:AddToggle({
            "Auto Repair Boat [ BETA ]",
            false,
            {
                GlobalSettings,
                "RepairBoat"
            },
            "S-RepairBoat"
        })
        SeaTab:AddSection("NPCs")
        SeaTab:AddDropdown({
            "Select NPC",
            {
                "Shipwright Teacher",
                "Shark Hunter",
                "Beast Hunter",
                "Spy"
            },
            "Spy",
            {
                GlobalSettings,
                "selectedNpc"
            }
        })
        npcTpToggle = SeaTab:AddToggle({
            "Teleport to NPC",
            false,
            teleportNpcFunc
        })
        local npcTpToggleRef = npcTpToggle
        npcTpToggle.Callback(npcTpToggleRef, verifyNpcTpFunc)
        SeaTab:AddSection("Quests/Items")
        toggleFunc(SeaTab, {
            "Auto Unlock Shipwright Subclass [ BETA ]"
        }, "Shipwright")
    end
    local StatsTab = Tabs.Stats
    if PlayerLevel.Value >= MainModule.GameData.MaxLevel then
        StatsTab:Destroy()
    else
        local statsSelected = {}
        local statPoints = PlayerData:WaitForChild("Points")
        local statData = PlayerData:WaitForChild("Stats")
        local function autoStatsFunc(state)
            GlobalEnv.AutoStats = state
            while task.wait() and GlobalEnv.AutoStats do
                local curPoints = statPoints.Value
                if curPoints > 0 then
                    local iterFunc, iterTable, iterKey = pairs(statsSelected)
                    while true do
                        local iterVal
                        iterKey, iterVal = iterFunc(iterTable, iterKey)
                        if iterKey == nil then
                            break
                        end
                        if iterVal and statData[iterKey].Level.Value < MainModule.GameData.MaxLevel then
                            FireRemoteCmd("AddPoint", iterKey, (math.clamp(math.clamp(GlobalSettings.StatsPoints or 3, 0, curPoints), 0, MainModule.GameData.MaxLevel)))
                        end
                    end
                end
            end
        end
        local function addStatToggle(_, statName)
            StatsTab:AddToggle({
                statName,
                false,
                {
                    statsSelected,
                    statName
                },
                "Stats-" .. statName
            })
        end
        StatsTab:AddSlider({
            "Points Amount",
            1,
            100,
            1,
            3,
            {
                GlobalSettings,
                "StatsPoints"
            },
            "P-Stats"
        })
        StatsTab:AddToggle({
            "Auto Stats",
            false,
            autoStatsFunc,
            "A-Stats"
        })
        StatsTab:AddSection("Select Stats")
        table.foreach({
            "Melee",
            "Defense",
            "Gun",
            "Sword",
            "Demon Fruit"
        }, addStatToggle)
    end
    local RaceTab = Tabs.RaceV4
    if currentSeaLvl == 4 then
        RaceTab:AddSection("Race V4")
        toggleFunc(RaceTab, {
            "Auto Finish Trial"
        }, "TrialV4")
        toggleFunc(RaceTab, {
            "Auto Kill Players in Trial"
        }, "KillPlayersV4")
        toggleFunc(RaceTab, {
            "Auto Train Race"
        }, "TrainV4")
    else
        RaceTab:Destroy()
    end
    local IslandsTab = Tabs.Islands
    if currentSeaLvl == 3 then
        local function lookMoonFunc(state)
            GlobalEnv.LookMoon = state
            while GlobalEnv.LookMoon do
                local lightMod = Lighting
                CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position, lightMod:GetMoonDirection() + CurrentCamera.CFrame.Position)
                task.wait()
            end
        end
        local function tradeAzureFunc(state)
            GlobalEnv.TradeAzure = state
            while GlobalEnv.TradeAzure do
                if Lighting:GetAttribute("IsBlueMoon") and (not Lighting:GetAttribute("BlueMoonEnded") and InventoryCount["Azure Ember"] >= GlobalSettings.Azure) then
                    NetModules["RF/KitsuneStatuePray"]:InvokeServer()
                end
                task.wait(1)
            end
        end
        local function monitorIslandFunc(islandTitle, islandKey)
            local islandLabel = IslandsTab:AddParagraph({
                islandTitle .. " : not Spawn"
            })
            while task.wait() do
                local islandObj = MapWorkspace:FindFirstChild(islandKey)
                if islandObj then
                    local pRef = LocalPlayer
                    islandLabel:SetTitle(islandTitle .. " : Spawned | Distance : " .. math.floor(pRef:DistanceFromCharacter(islandObj.WorldPivot.Position) / 5))
                else
                    islandLabel:SetTitle(islandTitle .. " : not Spawn")
                    MapWorkspace.ChildAdded:Wait()
                end
            end
        end
        IslandsTab:AddSection("Islands Stats")
        task.spawn(monitorIslandFunc, "Mirage Island", "MysticIsland")
        task.spawn(monitorIslandFunc, "Kitsune Island", "KitsuneIsland")
        task.spawn(monitorIslandFunc, "Prehistoric Island", "PrehistoricIsland")
        IslandsTab:AddSection("Prehistoric Island")
        toggleFunc(IslandsTab, {
            "Auto Craft Volcanic Magnet"
        }, "CraftVolcanicMagnet")
        toggleFunc(IslandsTab, {
            "Auto Prehistoric Island"
        }, "PrehistoricIsland")
        toggleFunc(IslandsTab, {
            "Auto Kill Lava Golem"
        }, "LavaGolem")
        toggleFunc(IslandsTab, {
            "Auto Collect Dinosaur Bones"
        }, "PrehistoricBones")
        toggleFunc(IslandsTab, {
            "Auto Collect Dragon Egg"
        }, "PrehistoricEgg")
        IslandsTab:AddToggle({
            "Reset after finishing",
            false,
            {
                GlobalSettings,
                "ResetPrehistoric"
            },
            "P-Reset"
        })
        IslandsTab:AddSection("Leviathan [ BETA ]")
        toggleFunc(IslandsTab, {
            "Auto Attack Leviathan"
        }, "Leviathan")
        IslandsTab:AddSection("Kitsune Island")
        IslandsTab:AddSlider({
            "Trade Azure Ember Amount",
            10,
            25,
            5,
            20,
            {
                GlobalSettings,
                "Azure"
            },
            "A-Amount"
        })
        IslandsTab:AddToggle({
            "Auto Trade Azure Ember",
            false,
            tradeAzureFunc
        }, "Trade-Azure")
        toggleFunc(IslandsTab, {
            "Auto Kitsune Island"
        }, "KitsuneIsland")
        IslandsTab:AddSection("Mirage Island")
        toggleFunc(IslandsTab, {
            "Teleport To Gear"
        }, "MirageGear")
        toggleFunc(IslandsTab, {
            "Teleport To Mirage"
        }, "TeleportMirage")
        toggleFunc(IslandsTab, {
            "Teleport To Fruit Dealer"
        }, "MirageFruitDealer")
        toggleFunc(IslandsTab, {
            "Collect Mirage Chests"
        }, "MirageChests")
        IslandsTab:AddToggle({
            "Look To Moon",
            false,
            lookMoonFunc,
            "MirageLookMoon"
        })
    else
        IslandsTab:Destroy()
    end
    local FruitRaidTab = Tabs.FruitRaid
    local CommonFruitsList = {
        "Rocket",
        "Spin",
        "Blade",
        "Spring",
        "Bomb",
        "Smoke",
        "Spike"
    }
    local SeaRequirementStr = "Only on Sea 2 and 3"
    local storeEnabled = true
    local fruitToStoreGlobal = nil
    local function autoStoreFunc(state)
        GlobalEnv.auto_store = state
        while GlobalEnv.auto_store do
            task.wait(GlobalSettings.SmoothMode and 0.3 or 0.2)
            storeEnabled = false
            local shouldUnstore = not LocalPlayer:GetAttribute("IslandRaiding") and GlobalEnv.unstore_common_fruits
            if shouldUnstore then
                shouldUnstore = fruitToStoreGlobal
            end
            local validFruit = FruitMgr:GetStorableFruit(shouldUnstore)
            if validFruit then
                FruitMgr:StoreFruit(validFruit)
                fruitToStoreGlobal = nil
            else
                storeEnabled = true
            end
        end
        storeEnabled = true
    end
    local function autoRerollFunc(state)
        GlobalEnv.random_fruit = state
        while GlobalEnv.random_fruit do
            FruitMgr:RerollRandomFruit()
            task.wait(0.1)
        end
    end
    local function autoBuyChipFunc(state)
        GlobalEnv.raid_microchip = state
        while GlobalEnv.raid_microchip do
            if storeEnabled then
                if FruitMgr:CanBuyMicrochip() then
                    FireRemoteCmd("RaidsNpc", "Select", GlobalSettings.SelectedChip)
                else
                    task.wait(0.1)
                end
            else
                task.wait()
            end
        end
    end
    local function unstoreFruitsFunc(state)
        GlobalEnv.unstore_common_fruits = state
        while GlobalEnv.unstore_common_fruits do
            if FruitMgr:CanBuyMicrochip() == - 1 and storeEnabled then
                for idx = 1, # CommonFruitsList do
                    local fruitName = CommonFruitsList[idx]
                    local fullName = fruitName .. "-" .. fruitName
                    if LocalPlayer.Character:FindFirstChild(fullName) or LocalPlayer.Backpack:FindFirstChild(fullName) then
                        break
                    end
                end
            end
            task.wait(0.25)
        end
    end
    FruitRaidTab:AddSection("Fruits")
    FruitRaidTab:AddToggle({
        "Auto Store Fruits",
        false,
        autoStoreFunc,
        "F-AutoStore"
    })
    toggleFunc(FruitRaidTab, {
        "Teleport To Fruits"
    }, "Fruits")
    FruitRaidTab:AddToggle({
        "Auto Random Fruit",
        false,
        autoRerollFunc,
        "F-RandomFruit"
    })
    FruitRaidTab:AddSection("Raid")
    if currentSeaLvl == 2 or currentSeaLvl == 3 then
        local addDropdownFunc8 = FruitRaidTab.AddDropdown
        local raidListObj1 = {}
        local raidTarget1 = {
            GlobalSettings,
            "SelectedChip"
        }
        __set_list(raidListObj1, 1, {
            "Select Chip",
            MainModule.RaidList,
            "",
            raidTarget1,
            "R-RaidChip"
        })
        addDropdownFunc8(FruitRaidTab, raidListObj1)
        toggleFunc(FruitRaidTab, {
            "Auto Farm Raid",
            "Kill Aura, Start & Awaken"
        }, "Raid")
        FruitRaidTab:AddToggle({
            "Auto Buy Chip",
            false,
            autoBuyChipFunc,
            "R-BuyChip"
        })
        FruitRaidTab:AddToggle({
            "Unstore Common Fruits",
            false,
            unstoreFruitsFunc,
            "R-Unstore"
        })
    else
        FruitRaidTab:AddParagraph({
            SeaRequirementStr
        })
    end
    local TeleportTab = Tabs.Teleport
    local islandTpToggle = nil
    local TempleOfTimeLoc = CFrame.new(28286, 14897, 103)
    local IslandNamesList = ({
        {
            "WindMill",
            "Marine",
            "Middle Town",
            "Jungle",
            "Pirate Village",
            "Desert",
            "Snow Island",
            "MarineFord",
            "Colosseum",
            "Sky Island 1",
            "Sky Island 2",
            "Sky Island 3",
            "Prison",
            "Magma Village",
            "Under Water Island",
            "Fountain City"
        },
        {
            "The Cafe",
            "Frist Spot",
            "Dark Area",
            "Flamingo Mansion",
            "Flamingo Room",
            "Green Zone",
            "Zombie Island",
            "Two Snow Mountain",
            "Punk Hazard",
            "Cursed Ship",
            "Ice Castle",
            "Forgotten Island",
            "Ussop Island"
        },
        {
            "Mansion",
            "Port Town",
            "Great Tree",
            "Castle On The Sea",
            "Hydra Island",
            "Floating Turtle",
            "Haunted Castle",
            "Ice Cream Island",
            "Peanut Island",
            "Cake Island",
            "Candy Cane Island",
            "Tiki Outpost"
        }
    })[currentSeaLvl]
    local IslandCFramesList = {
        ["Middle Town"] = CFrame.new(- 688, 15, 1585),
        MarineFord = CFrame.new(- 4810, 21, 4359),
        Marine = CFrame.new(- 2728, 25, 2056),
        WindMill = CFrame.new(889, 17, 1434),
        Desert = CFrame.new(1054, 53, 4490),
        ["Snow Island"] = CFrame.new(1298, 87, - 1344),
        ["Pirate Village"] = CFrame.new(- 1173, 45, 3837),
        Jungle = CFrame.new(- 1614, 37, 146),
        Prison = CFrame.new(4870, 6, 736),
        ["Under Water Island"] = CFrame.new(61164, 5, 1820),
        Colosseum = CFrame.new(- 1535, 7, - 3014),
        ["Magma Village"] = CFrame.new(- 5290, 9, 8349),
        ["Sky Island 1"] = CFrame.new(- 4814, 718, - 2551),
        ["Sky Island 2"] = CFrame.new(- 4652, 873, - 1754),
        ["Sky Island 3"] = CFrame.new(- 7895, 5547, - 380),
        ["Fountain City"] = CFrame.new(5041, 1, 4101),
        ["The Cafe"] = CFrame.new(- 382, 73, 290),
        ["Frist Spot"] = CFrame.new(- 11, 29, 2771),
        ["Dark Area"] = CFrame.new(3494, 13, - 3259),
        ["Flamingo Mansion"] = CFrame.new(- 317, 331, 597),
        ["Flamingo Room"] = CFrame.new(2285, 15, 905),
        ["Green Zone"] = CFrame.new(- 2258, 73, - 2696),
        ["Zombie Island"] = CFrame.new(- 5552, 194, - 776),
        ["Two Snow Mountain"] = CFrame.new(752, 408, - 5277),
        ["Punk Hazard"] = CFrame.new(- 5897, 18, - 5096),
        ["Cursed Ship"] = CFrame.new(919, 125, 32869),
        ["Ice Castle"] = CFrame.new(5505, 40, - 6178),
        ["Forgotten Island"] = CFrame.new(- 3050, 240, - 10178),
        ["Ussop Island"] = CFrame.new(4816, 8, 2863),
        Mansion = CFrame.new(- 12471, 374, - 7551),
        ["Port Town"] = CFrame.new(- 334, 7, 5300),
        ["Castle On The Sea"] = CFrame.new(- 5073, 315, - 3153),
        ["Hydra Island"] = CFrame.new(5666, 1013, - 310),
        ["Great Tree"] = CFrame.new(2683, 275, - 7008),
        ["Floating Turtle"] = CFrame.new(- 12528, 332, - 8658),
        ["Haunted Castle"] = CFrame.new(- 9517, 142, 5528),
        ["Ice Cream Island"] = CFrame.new(- 902, 79, - 10988),
        ["Peanut Island"] = CFrame.new(- 2062, 50, - 10232),
        ["Cake Island"] = CFrame.new(- 1897, 14, - 11576),
        ["Candy Cane Island"] = CFrame.new(- 1038, 10, - 14076),
        ["Tiki Outpost"] = CFrame.new(- 16224, 9, 439)
    }
    local function teleportTempleOfTimeFunc()
        for _ = 1, 10 do
            task.wait()
            LocalPlayer.Character:SetPrimaryPartCFrame(TempleOfTimeLoc)
        end
    end
    local function executeIslandTpFunc(state)
        GlobalEnv.teleporting = state
        while GlobalEnv.teleporting do
            task.wait()
            if IslandCFramesList[GlobalEnv.SelectedIsland] then
                TeleportFunc(IslandCFramesList[GlobalEnv.SelectedIsland])
            end
        end
        if state and islandTpToggle then
            islandTpToggle:Set(false, true)
        end
    end
    local function checkIslandTpDistFunc(state)
        if state then
            local tpManager = self.Managers.PlayerTeleport
            local tpDist = math.huge
            while true do
                task.wait()
                if tpManager.lastPosition then
                    tpDist = LocalPlayer:DistanceFromCharacter(tpManager.lastPosition)
                end
                if not GlobalEnv.teleporting or tpDist < 15 then
                    GlobalEnv.teleporting = false
                end
            end
        else
            return
        end
    end
    TeleportTab:AddSection("Travel")
    local addBtnFunc1 = TeleportTab.AddButton
    local btnDataObj1 = {}
    local function tpSea1Func()
        MainModule:TravelTo(1)
    end
    btnDataObj1.Desc = "Main"
    __set_list(btnDataObj1, 1, {
        "Teleport to Sea 1",
        tpSea1Func
    })
    addBtnFunc1(TeleportTab, btnDataObj1)
    local addBtnFunc2 = TeleportTab.AddButton
    local btnDataObj2 = {}
    local function tpSea2Func()
        MainModule:TravelTo(2)
    end
    btnDataObj2.Desc = "Dressrosa"
    __set_list(btnDataObj2, 1, {
        "Teleport to Sea 2",
        tpSea2Func
    })
    addBtnFunc2(TeleportTab, btnDataObj2)
    local addBtnFunc3 = TeleportTab.AddButton
    local btnDataObj3 = {}
    local function tpSea3Func()
        MainModule:TravelTo(3)
    end
    btnDataObj3.Desc = "Zou"
    __set_list(btnDataObj3, 1, {
        "Teleport to Sea 3",
        tpSea3Func
    })
    addBtnFunc3(TeleportTab, btnDataObj3)
    TeleportTab:AddSection("Islands")
    TeleportTab:AddDropdown({
        "Select Island",
        IslandNamesList,
        "",
        {
            GlobalEnv,
            "SelectedIsland"
        }
    })
    islandTpToggle = TeleportTab:AddToggle({
        "Teleport to Island",
        false,
        executeIslandTpFunc
    })
    local islandTpToggleRef = islandTpToggle
    islandTpToggle.Callback(islandTpToggleRef, checkIslandTpDistFunc)
    if currentSeaLvl == 3 then
        TeleportTab:AddSection("Race V4")
        TeleportTab:AddButton({
            "Teleport to Temple of Time",
            teleportTempleOfTimeFunc
        })
    end
    local StatusTab = Tabs.Status
    local activeSea = currentSeaLvl
    local _ = FarmMgr.Enemies.Elites
    local IsEnemySpawnedCheck = MainModule.Enemies.IsSpawned
    local eliteSpawnTimer = nil
    local errorSign = "\239\191\189\239\191\189\239\191\189\239\191\189\239\191\189"
    local errorSign2 = "\239\191\189\239\191\189\239\191\189\239\191\189\239\191\189"
    local statusUpdates = {}
    local lastStatusTick = 0
    local function appendStatusFunc(statusProvider, isSeaValid)
        if isSeaValid or isSeaValid == nil then
            local insertFunc = table.insert
            local listTarget = statusUpdates
            local updateObj = {
                Paragraph = StatusTab:AddParagraph({
                    ""
                }),
                Function = statusProvider
            }
            insertFunc(listTarget, updateObj)
        end
    end
    appendStatusFunc(function()
        local eliteProgress = MainModule:GetProgress("EliteProgress", "EliteHunter", "Progress")
        local eliteInst = MainModule.Enemies:GetEnemyByTag("Elite")
        if eliteInst then
            return ("Elite Progress: %i\nElite Hunter: %s %s"):format(eliteProgress, eliteInst.Name, errorSign)
        else
            return ("Elite Progress: %i\nElite Hunter: %s"):format(eliteProgress, (eliteSpawnTimer and 600 - (tick() - eliteSpawnTimer) >= 0 and (MiscUtils.GetTimer(600 - (tick() - eliteSpawnTimer) or "00:00") or "") or "") .. errorSign2)
        end
    end, activeSea == 3)
    appendStatusFunc(function()
        local kataName = IsEnemySpawnedCheck("Cake Prince") and "Cake Prince"
        if not kataName then
            local doughKingInst = IsEnemySpawnedCheck("Dough King")
            kataName = doughKingInst and "Dough King" or doughKingInst
        end
        if kataName then
            return ("Katakuri: %s %s"):format(kataName, errorSign)
        end
        local moduleRef = MainModule
        local kataSpawns = string.gsub(moduleRef:GetProgress("Katakuri", "CakePrinceSpawner", true), "%D", "")
        return "Katakuri: " .. (kataSpawns:len() == 0 and ("0" or kataSpawns) or kataSpawns)
    end, activeSea == 3)
    appendStatusFunc(function()
        local swordDealerState = MainModule:GetProgress("Sword Dealer", "LegendarySwordDealer", "1")
        if type(swordDealerState) ~= "string" then
            return ("Sword Dealer: %s"):format(errorSign2)
        else
            return ("Sword Dealer: %s %s"):format(swordDealerState, errorSign)
        end
    end, activeSea == 2)
    appendStatusFunc(function()
        local colorDealerState, colorDealerLvl = MainModule:GetProgress("BaristaCousin", "ColorsDealer", "1")
        if type(colorDealerState) ~= "string" then
            return "Barista Cousin: " .. errorSign2
        else
            return ("Barista Cousin: %s [ %s ] %s"):format(colorDealerState, 3 <= colorDealerLvl and "LEGENDARY" or "Rare", errorSign)
        end
    end)
    appendStatusFunc(function()
        if workspace:FindFirstChild("Fruit ") then
            return ("Devil Fruit: %s %s"):format(MainModule.FruitsName[workspace["Fruit "] ], errorSign)
        else
            return "Devil Fruit: " .. errorSign2
        end
    end)
    appendStatusFunc(function()
        local berryFoundList = {}
        for idx = 1, # BerryBushesList do
            if idx % 10 == 0 then
                task.wait(0.1)
            end
            local bushInst = BerryBushesList[idx]
            local iterFunc, iterTable, iterKey = pairs(bushInst:GetAttributes())
            while true do
                local iterVal
                iterKey, iterVal = iterFunc(iterTable, iterKey)
                if iterKey == nil then
                    break
                end
                table.insert(berryFoundList, iterVal)
            end
        end
        if # berryFoundList <= 0 then
            return "Berries: " .. errorSign2
        else
            return ("Berries: #%i [ %s ] %s"):format(# berryFoundList, table.concat(berryFoundList, ", "), errorSign)
        end
    end)
    appendStatusFunc(function()
        return "Players: " .. # Players:GetPlayers() .. "/12"
    end)
    appendStatusFunc(function()
        return ("Enabled Options: %i/%i\nFarm Status: %s [ %s ]"):format(# GlobalRzFarmFunctions, # GlobalRzFunctions, GlobalSettings.RunningOption or "Null", GlobalSettings.RunningMethod or "Null")
    end)
    appendStatusFunc(function()
        return "Is Private Server: " .. (ReplicatedStorage.PrivateServerOwnerId.Value ~= 0 and errorSign or errorSign2)
    end)
    local curStatusIndex = 1
    local statusLoopConn = nil
    statusLoopConn = SteppedEvent:Connect(function()
        if not (StatusTab and StatusTab.Cont) then
            return statusLoopConn:Disconnect()
        end
        if activeSea == 3 and (curStatusIndex == 1 and tick() - lastStatusTick >= 1) then
            if not StatusTab.Cont.Parent then
                lastStatusTick = tick()
            end
            if MainModule.Enemies:GetEnemyByTag("Elite") then
                eliteSpawnTimer = tick()
            end
        end
        if tick() - lastStatusTick >= 1 and StatusTab.Cont.Parent then
            local currentUpdate = statusUpdates[curStatusIndex]
            curStatusIndex = (curStatusIndex >= # statusUpdates and 0 or curStatusIndex) + 1
            if curStatusIndex >= # statusUpdates then
                lastStatusTick = tick()
            end
            if currentUpdate and not currentUpdate.Updating then
                currentUpdate.Updating = true
                currentUpdate.Paragraph:SetTitle(currentUpdate.Function())
                currentUpdate.Updating = false
            end
        end
    end)
    local VisualTab = Tabs.Visual
    local EspMgr = self.Managers.EspManager
    local EspColorConfig = ScriptSetup.EspColors or {
        Players = Color3.fromRGB(220, 220, 220),
        Fruits = Color3.fromRGB(255, 0, 0),
        Islands = Color3.fromRGB(0, 255, 255),
        Berries = Color3.fromRGB(255, 255, 0),
        Chests = {
            Chest1 = Color3.fromRGB(150, 150, 150),
            Chest2 = Color3.fromRGB(255, 255, 0),
            Chest3 = Color3.fromRGB(0, 255, 255),
            Null = Color3.fromRGB(150, 0, 255)
        }
    }
    local EspObjectsData = {
        Players = EspMgr.new("Player", CharactersWorkspace, function(playerChar)
            if playerChar ~= LocalPlayer.Character then
                return true, EspColorConfig.Players
            end
        end),
        Islands = EspMgr.new("Island", WorldLocations, function(locInst)
            if locInst.Name ~= "Sea" then
                return true, EspColorConfig.Islands
            end
        end),
        Fruits = EspMgr.new("Fruit", workspace, function(fruitInst)
            if fruitInst:IsA("Model") and fruitInst:GetPivot().Position == Vector3.zero then
                return nil
            end
            if string.sub(fruitInst.Name, - 6, - 1) == " Fruit" or fruitInst.Name == "Fruit " then
                return true, EspColorConfig.Fruits, fruitInst:FindFirstChild("Handle") or fruitInst
            end
        end),
        Flowers = EspMgr.new("Flower", workspace, function(flowerInst)
            if flowerInst:IsA("BasePart") and flowerInst.Name:find("Flower") then
                return true, flowerInst.Color
            end
        end),
        Chests = EspMgr.new("Chests", ChestsList, function(chestInst)
            return not chestInst:GetAttribute("IsDisabled"), EspColorConfig.Chests[chestInst.Name]
        end, function(chestInst)
            return not chestInst:GetAttribute("IsDisabled")
        end),
        Berries = EspMgr.new("Berries", BerryBushesList, function(berryInst)
            local iterFunc, iterTable, iterKey = pairs(berryInst:GetAttributes())
            local foundKey, foundVal = iterFunc(iterTable, iterKey)
            if foundKey ~= nil then
                return true, EspColorConfig.Berries, foundVal, berryInst.Parent
            end
        end, function(berryInst)
            if berryInst:FindFirstChild("Berries") then
                local iterFunc, iterTable, iterKey = pairs(berryInst.Berries:GetAttributes())
                local foundKey, _ = iterFunc(iterTable, iterKey)
                if foundKey ~= nil then
                    return true
                end
            end
        end)
    }
    if not MainModule:IsBlacklistedExecutor() then
        VisualTab:AddSection("Aimbot Nearest")
        VisualTab:AddToggle({
            "Aimbot Gun",
            false,
            {
                GlobalEnv,
                "AimBot_Gun"
            }
        })
        VisualTab:AddToggle({
            "Aimbot Tap",
            false,
            {
                GlobalEnv,
                "AimBot_Tap"
            }
        })
        VisualTab:AddToggle({
            "Aimbot Skills",
            false,
            {
                GlobalEnv,
                "AimBot_Skills"
            }
        })
        VisualTab:AddToggle({
            "Ignore Mobs",
            true,
            {
                GlobalSettings,
                "NoAimMobs"
            }
        })
    end
    VisualTab:AddSection("ESP")
    if currentSeaLvl == 2 then
        VisualTab:AddToggle({
            "ESP Flowers",
            false,
            {
                EspObjectsData.Flowers,
                "Enabled"
            },
            "Esp-Flower"
        })
    end
    VisualTab:AddToggle({
        "ESP Players",
        false,
        {
            EspObjectsData.Players,
            "Enabled"
        },
        "Esp-Players"
    })
    VisualTab:AddToggle({
        "ESP Fruits",
        false,
        {
            EspObjectsData.Fruits,
            "Enabled"
        },
        "Esp-Fruits"
    })
    VisualTab:AddToggle({
        "ESP Berries",
        false,
        {
            EspObjectsData.Berries,
            "Enabled"
        },
        "Esp-Berry"
    })
    VisualTab:AddToggle({
        "ESP Chests",
        false,
        {
            EspObjectsData.Chests,
            "Enabled"
        },
        "Esp-Chests"
    })
    VisualTab:AddToggle({
        "ESP Islands",
        false,
        {
            EspObjectsData.Islands,
            "Enabled"
        },
        "Esp-Island"
    })
    VisualTab:AddSection("Visual")
    VisualTab:AddButton({
        "Meteor Rain",
        function()
            require(game:GetService("ReplicatedStorage").Effect.Container.UzothSpec)({
                Position = LocalPlayer.Character.PrimaryPart.Position
            })
        end
    })
    VisualTab:AddButton({
        "Remove Portal Dash Cooldown",
        function()
            local portalTool = LocalPlayer.Backpack:FindFirstChild("Portal-Portal") or LocalPlayer.Character:FindFirstChild("Portal-Portal")
            if portalTool then
                local iterFunc = next
                local connTable1, connKey1 = getconnections(portalTool.Activated)
                while true do
                    local connVal1
                    connKey1, connVal1 = iterFunc(connTable1, connKey1)
                    if connKey1 == nil then
                        break
                    end
                    if # debug.getupvalues(connVal1.Function) == 9 then
                        while task.wait() and (portalTool and portalTool:IsDescendantOf(game)) do
                            debug.setupvalue(connVal1.Function, 2, 0)
                        end
                    end
                end
            end
        end
    })
    local ShopTab = Tabs.Shop
    local iterFuncShop, iterTableShop, iterKeyShop = ipairs(MainModule.Shop)
    local fireRemoteStore = FireRemoteCmd
    while true do
        local iterValShop
        iterKeyShop, iterValShop = iterFuncShop(iterTableShop, iterKeyShop)
        if iterKeyShop == nil then
            break
        end
        ShopTab:AddSection(iterValShop[1])
        local iterFuncShop2, iterTableShop2, iterKeyShop2 = ipairs(iterValShop[2])
        while true do
            local iterValShop2
            iterKeyShop2, iterValShop2 = iterFuncShop2(iterTableShop2, iterKeyShop2)
            if iterKeyShop2 == nil then
                break
            end
            local rawFuncAction = iterValShop2[2]
            local wrappedFuncAction = type(iterValShop2[2]) == "table" and function()
                fireRemoteStore(unpack(iterValShop2[2]))
            end or rawFuncAction
            ShopTab:AddButton({
                iterValShop2[1],
                wrappedFuncAction
            })
        end
    end
    local MiscTab = Tabs.Misc
    local cachedWaterSize = nil
    local function executeClipboardFunc()
        loadstring((getclipboard or fromclipboard)())()
    end
    local function formatJobIdFunc(rawJobId)
        local cleanedId = rawJobId:gsub("\n", ""):gsub("`", "")
if cleanedId:find("-") then
            return cleanedId
        else
            return cleanedId:gsub("v", "-"):gsub("q", "00"):gsub("x", "22"):gsub("f", "11"):gsub("d", "44"):gsub("a", "55"):gsub("h", "66"):gsub("s", "77"):gsub("j", "88"):gsub("g", "99"):gsub("i", "33"):gsub("y", "1"):gsub("p", "2"):gsub("u", "3"):gsub("z", "4"):gsub("o", "5"):gsub("l", "6"):gsub("r", "7"):gsub("k", "8"):gsub("t", "9"):gsub("e", "0"):lower()
        end
    end
    local function changeJobIdInputFunc(textInput)
        return formatJobIdFunc(textInput)
    end
    local function tpServerFunc(targetJobId)
        ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", targetJobId)
    end
    local function joinCopiedServerFunc()
        tpServerFunc((getclipboard or fromclipboard)())
    end
    local speedHackEnabled = nil
    local currentSpeed = nil
    local function enableSpeedHackFunc(state)
        if state then
            MainModule.Hooking:EnableBypass()
        end
        local gEnv = GlobalEnv
        local activeSpeed = state and currentSpeed or false
        speedHackEnabled = state
        gEnv.WalkSpeedBypass = activeSpeed
    end
    local function changeSpeedFunc(newSpeed)
        local gEnv = GlobalEnv
        local actSpeed = speedHackEnabled and newSpeed and newSpeed or false
        currentSpeed = newSpeed
        gEnv.WalkSpeedBypass = actSpeed
    end
    local function toggleWaterWalkFunc(state)
        GlobalEnv.WalkOnWater = state
        local waterPlane = MapWorkspace:WaitForChild("WaterBase-Plane", 9000000000)
        local baseSize = cachedWaterSize or waterPlane.Size
        local elevatedSize = Vector3.new(baseSize.X, 113, baseSize.Z)
        cachedWaterSize = baseSize
        while task.wait(0.25) and GlobalEnv.WalkOnWater do
            if MainModule.IsAlive(LocalPlayer.Character) and LocalPlayer.Character.Humanoid.Sit then
                waterPlane.Size = baseSize
            else
                waterPlane.Size = elevatedSize
            end
        end
        waterPlane.Size = baseSize
    end
    local function toggleAntiAFKFunc(state)
        GlobalEnv.AntiAFK = state
        while GlobalEnv.AntiAFK do
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(math.huge, math.huge))
            task.wait(600)
        end
    end
    local function activeRaceV3Func(state)
        GlobalEnv.ActiveRaceV3 = state
        while GlobalEnv.ActiveRaceV3 do
            if PlayerData.Race:FindFirstChild("Evolved") then
                RemotesFolder.CommE:FireServer("ActivateAbility")
            else
                PlayerData.Race.ChildAdded:Wait()
            end
            task.wait(GlobalSettings.SmoothMode and 2.5 or 1)
        end
    end
    local function activeRaceV4Func(state)
        GlobalEnv.ActiveRaceV4 = state
        local playerChar = LocalPlayer.Character
        while GlobalEnv.ActiveRaceV4 do
            playerChar = playerChar or LocalPlayer.CharacterAdded:Wait()
            local isTransformed = playerChar:FindFirstChild("RaceTransformed")
            local raceEnergy = playerChar:FindFirstChild("RaceEnergy")
            if raceEnergy and (raceEnergy.Value >= 1 and (isTransformed and not isTransformed.Value)) then
                local awakeTool = LocalPlayer.Backpack:FindFirstChild("Awakening") or playerChar:FindFirstChild("Awakening")
                if awakeTool:FindFirstChild("RemoteFunction") then
                    awakeTool.RemoteFunction:InvokeServer(true)
                end
            end
            task.wait(GlobalSettings.SmoothMode and 1 or 0.5)
        end
    end
    if IsOwner then
        MiscTab:AddSection("Executor")
        MiscTab:AddButton({
            "Execute Clipboard",
            executeClipboardFunc
        })
    end
    if MainModule.JobIds then
        MiscTab:AddSection("Join Server")
        MiscTab:AddTextBox({
            "Input Job Id",
            "1",
            true,
            tpServerFunc,
            "JobId"
        }).OnChanging = changeJobIdInputFunc
        MiscTab:AddButton({
            "Join Clipboard",
            joinCopiedServerFunc
        })
    end
    MiscTab:AddSection("Settings")
    MiscTab:AddDropdown({
        "Farm Mode",
        {
            "Up",
            "Orbit",
            "Star"
        },
        "Up",
        {
            GlobalSettings,
            "FarmMode"
        },
        "S-FarmMode"
    })
    MiscTab:AddSlider({
        "Farm Distance",
        5,
        30,
        1,
        15,
        function(newDist)
            GlobalSettings.FarmPos = Vector3.new(0, newDist, 0)
            GlobalSettings.FarmDistance = newDist
        end,
        "S-Distance"
    })
    MiscTab:AddSlider({
        "Tween Speed",
        50,
        300,
        5,
        200,
        {
            GlobalSettings,
            "TweenSpeed"
        },
        "S-TweenSpeed"
    })
    MiscTab:AddSlider({
        "Bring Mobs Distance",
        50,
        400,
        10,
        250,
        {
            GlobalSettings,
            "BringDistance"
        },
        "S-BringDistance"
    })
    MiscTab:AddToggle({
        "Bring Mobs",
        true,
        {
            GlobalSettings,
            "BringMobs"
        },
        "S-BringMobs"
    })
    MiscTab:AddToggle({
        "Auto Haki",
        true,
        {
            GlobalSettings,
            "AutoBuso"
        },
        "S-AutoBuso"
    })
    MiscTab:AddToggle({
        "Auto Attack",
        true,
        {
            GlobalSettings,
            "AutoClick"
        },
        "S-AutoClick"
    })
    MiscTab:AddToggle({
        "Auto Shoot",
        false,
        {
            GlobalSettings,
            "AutoShoot"
        },
        "S-AutoShoot"
    })
    local addToggleFunc1 = MiscTab.AddToggle
    local toggleDataObj1 = {}
    local toggleTargetObj1 = {
        self.Managers.QuestManager,
        "takeQuestDebounce"
    }
    toggleDataObj1.Desc = "Wait 75 seconds to take the next mission"
    __set_list(toggleDataObj1, 1, {
        "Take Quest Debounce",
        false,
        toggleTargetObj1,
        "S-QuestDenounce"
    })
    addToggleFunc1(MiscTab, toggleDataObj1)
    MiscTab:AddSection("Codes")
    MiscTab:AddButton({
        "Redeem all Codes",
        MiscUtils.AllCodes
    })
    MiscTab:AddSection("Server")
    MiscTab:AddButton({
        "Server Hop",
        function()
            MainModule:ServerHop()
        end
    })
    MiscTab:AddButton({
        "Rejoin",
        function()
            MainModule.Rejoin()
        end
    })
    MiscTab:AddSection("Team")
    MiscTab:AddButton({
        "Join Pirates Team",
        TeamManager.Pirates
    })
    MiscTab:AddButton({
        "Join Marines Team",
        TeamManager.Marines
    })
    MiscTab:AddSection("Race")
    MiscTab:AddToggle({
        "Auto Active Race V3",
        false,
        activeRaceV3Func,
        "S-RaceV3"
    })
    MiscTab:AddToggle({
        "Auto Active Race V4",
        false,
        activeRaceV4Func,
        "S-RaceV4"
    })
    MiscTab:AddSection("Menu")
    MiscTab:AddButton({
        "Devil Fruit Shop",
        function()
            require(LocalPlayer.PlayerGui.Main.UIController.FruitShop):Open("FruitDealer")
        end
    })
    MiscTab:AddButton({
        "Advanced Fruit Dealer",
        function()
            require(LocalPlayer.PlayerGui.Main.UIController.FruitShop):Open("AdvancedFruitDealer")
        end
    })
    MiscTab:AddButton({
        "Titles",
        function()
            fireRemoteStore("getTitles")
            LocalPlayer.PlayerGui.Main.Titles.Visible = true
        end
    })
    MiscTab:AddButton({
        "Haki Color",
        function()
        end
    })
    if not MainModule:IsBlacklistedExecutor() then
        MiscTab:AddSection("Local-Player")
        MiscTab:AddToggle({
            "Enable Speed Hack",
            false,
            enableSpeedHackFunc,
            "M-WalkSpeed:A"
        })
        MiscTab:AddSlider({
            "Walk Speed",
            10,
            300,
            5,
            150,
            changeSpeedFunc,
            "M-WalkSpeed:B"
        })
    end
    MiscTab:AddSection("Visual")
    MiscTab:AddButton({
        "Remove Fog",
        MiscUtils.RemoveFog
    })
    MiscTab:AddSection("More FPS")
    local addToggleFunc2 = MiscTab.AddToggle
    local toggleDataObj2 = {}
    local toggleTargetObj2 = {
        GlobalSettings,
        "SmoothMode"
    }
    toggleDataObj2.Desc = "Reduces calculation speed to improve FPS"
    __set_list(toggleDataObj2, 1, {
        "Smooth Farm Mode",
        false,
        toggleTargetObj2,
        "SmoothFarm"
    })
    addToggleFunc2(MiscTab, toggleDataObj2)
    MiscTab:AddToggle({
        "Remove Damage",
        false,
        function(state)
            ReplicatedStorage.Assets.GUI.DamageCounter.Enabled = not state
        end,
        "M-DamageCounter"
    })
    MiscTab:AddToggle({
        "Remove Notifications",
        false,
        function(state)
            LocalPlayer.PlayerGui.Notifications.Enabled = not state
        end,
        "M-Notifications"
    })
    MiscTab:AddSection("Others")
    MiscTab:AddToggle({
        "Walk On Water",
        true,
        toggleWaterWalkFunc,
        "M-WalkOnWater"
    })
    MiscTab:AddToggle({
        "Anti AFK",
        true,
        toggleAntiAFKFunc,
        "M-AntiAFK"
    })
    local ItemsTab = Tabs.Items
    if currentSeaLvl ~= 3 then
        if currentSeaLvl ~= 2 then
            if currentSeaLvl == 1 then
                ItemsTab:AddSection("Second Sea")
                toggleFunc(ItemsTab, {
                    "Auto Second Sea",
                    "Automatically unlocks access to the Second Sea"
                }, "SecondSea")
                ItemsTab:AddSection("Swords")
                toggleFunc(ItemsTab, {
                    "Auto Unlock Saber",
                    "Automatically unlocks the Saber Sword"
                }, "Saber")
                toggleFunc(ItemsTab, {
                    "Auto Pole V1",
                    "Kill Thunder God"
                }, "PoleV1")
                toggleFunc(ItemsTab, {
                    "Auto Saw Sword",
                    "Kill The Saw"
                }, "TheSaw")
            end
        else
            local function buyLegendarySwordFunc(state)
                GlobalEnv.LegendSword = state
                while task.wait() and GlobalEnv.LegendSword do
                    local lSwordData = fireRemoteStore("LegendarySwordDealer", "1")
                    if type(lSwordData) ~= "string" then
                        task.wait(5)
                    elseif UnlockedItems[lSwordData] then
                        task.wait(13500)
                    elseif PlayerBeli.Value < 2000000 then
                        PlayerBeli:GetPropertyChangedSignal("Value"):Wait()
                    else
                        fireRemoteStore("LegendarySwordDealer", "2")
                    end
                end
            end
            ItemsTab:AddSection("Third Sea")
            toggleFunc(ItemsTab, {
                "Auto Third Sea",
                "Automatically unlocks access to the Third Sea"
            }, "ThirdSea")
            toggleFunc(ItemsTab, {
                "Auto Kill Don Swan",
                "Automatically defeats Don Swan"
            }, "DonSwan")
            ItemsTab:AddSection("Bosses")
            toggleFunc(ItemsTab, {
                "Auto Darkbeard",
                "Automatically spawns and defeats Darkbeard"
            }, "Darkbeard")
            toggleFunc(ItemsTab, {
                "Auto Cursed Captain",
                "Automatically summons and defeats the Cursed Captain"
            }, "CursedCaptain")
            ItemsTab:AddSection("Law")
            toggleFunc(ItemsTab, {
                "Auto Kill Law",
                "Automatically spawns and defeats Law (Order)"
            }, "Order")
            local addToggleFunc3 = ItemsTab.AddToggle
            local toggleDataObj3 = {}
            local toggleTargetObj3 = {
                GlobalSettings,
                "FullyLawRaid"
            }
            toggleDataObj3.Desc = "Buy the raid law Microchip"
            __set_list(toggleDataObj3, 1, {
                "Auto Buy Microchip",
                false,
                toggleTargetObj3,
                "S-FullyLaw"
            })
            addToggleFunc3(ItemsTab, toggleDataObj3)
            ItemsTab:AddSection("Sword")
            ItemsTab:AddToggle({
                Desc = "Automatically purchases Legendary Swords when available",
                "Auto Buy Legendary Sword",
                false,
                buyLegendarySwordFunc,
                "LegendSword"
            })
            toggleFunc(ItemsTab, {
                "Auto Rengoku",
                "Automatically kill Ice Admiral to unlock the Rengoku sword"
            }, "Rengoku")
            ItemsTab:AddSection("Race")
            toggleFunc(ItemsTab, {
                "Auto Race V2",
                "Automatically evolves the Race to V2"
            }, "RaceV2")
            toggleFunc(ItemsTab, {
                "Auto Race V3",
                "Mink, Human & Shark"
            }, "RaceV3")
            ItemsTab:AddSection("Bartilo")
            toggleFunc(ItemsTab, {
                "Auto Bartilo Quest",
                "Req: Level 850"
            }, "Bartilo")
        end
    else
        ItemsTab:AddSection("Dragon Dojo")
        toggleFunc(ItemsTab, {
            "Auto Dojo Trainer Quest",
            "Automatically completes Dojo Trainer quests"
        }, "DojoTrainer")
        toggleFunc(ItemsTab, {
            "Auto Dragon Hunter Quest",
            "Automatically completes Dragon Hunter quests"
        }, "DragonHunter")
        toggleFunc(ItemsTab, {
            "Auto Draco V2 & V3",
            "Evolves the Draco Race to V2 and V3"
        }, "DracoV2V3")
        ItemsTab:AddSection("Farm")
        toggleFunc(ItemsTab, {
            "Auto Elite Hunter",
            "Automatically completes Elite Hunter quests"
        }, "EliteHunter")
        toggleFunc(ItemsTab, {
            "Auto Rip Indra",
            "Activates the plates and summons Rip Indra"
        }, "RipIndra")
        toggleFunc(ItemsTab, {
            "Auto Cake Prince",
            "Automatically summons the Cake Prince"
        }, "CakePrince")
        toggleFunc(ItemsTab, {
            "Auto Dough King",
            "Automatically summons the Dough King"
        }, "DoughKing")
        ItemsTab:AddSection("Sword")
        toggleFunc(ItemsTab, {
            "Auto Collect Yama",
            "Automatically collects the Yama sword after defeating 30 Elite Hunters"
        }, "Yama")
        toggleFunc(ItemsTab, {
            "Auto Tushita",
            "Solves the Tushita puzzle and defeats Longma"
        }, "Tushita")
        toggleFunc(ItemsTab, {
            "Auto Cursed Dual Katana",
            "Complete the Cursed Dual Katana puzzle"
        }, "CursedDualKatana")
        ItemsTab:AddSection("Quest")
        toggleFunc(ItemsTab, {
            "Auto Citizen Quest"
        }, "Citizen")
        toggleFunc(ItemsTab, {
            "Auto Rainbow Haki"
        }, "RainbowHaki")
    end
    ItemsTab:AddSection("Berries")
    toggleFunc(ItemsTab, {
        "Auto Collect Berries"
    }, "BerryBush")
    ItemsTab:AddToggle({
        "Auto Berry Hop",
        false,
        {
            GlobalSettings,
            "BerryHop"
        },
        "S-BerryHop"
    })
    if currentSeaLvl ~= 1 and QuestMgr.GetColorsList then
        local function autoBaristaFunc(state)
            GlobalEnv.barista_cousin = state
            while GlobalEnv.barista_cousin do
                local cDealerState, _ = fireRemoteStore("BaristaCousin", "ColorsDealer", "1")
                if type(cDealerState) ~= "string" then
                    task.wait(5)
                else
                    local buyColorState = fireRemoteStore("ColorsDealer", "2")
                    if buyColorState == 1 or buyColorState == 2 then
                        task.wait(250)
                    elseif buyColorState == 0 then
                        PlayerBeli:GetPropertyChangedSignal("Value"):Wait()
                    end
                end
            end
        end
        ItemsTab:AddSection("Aura Color")
        local addDropdownFunc9 = ItemsTab.AddDropdown
        local auraListObj1 = {}
        local auraTargetObj1 = {
            GlobalSettings,
            "CraftAura"
        }
        __set_list(auraListObj1, 1, {
            "Select Aura",
            QuestMgr:GetColorsList(),
            false,
            auraTargetObj1,
            "S-Aura"
        })
        addDropdownFunc9(ItemsTab, auraListObj1)
        toggleFunc(ItemsTab, {
            "Auto Craft Aura Color"
        }, "AuraColor")
        ItemsTab:AddToggle({
            "Auto Craft Hop",
            false,
            {
                GlobalSettings,
                "CraftHop"
            },
            "S-CraftHop"
        })
        ItemsTab:AddToggle({
            "Auto Barista Cousin",
            false,
            autoBaristaFunc,
            "B-Cousin"
        })
    end
end
function App.StartFarm(_)
    if not GlobalEnv.loadedFarm then
        GlobalEnv.loadedFarm = true
        task.spawn(MainModule.RunFunctions.FarmQueue, GlobalRzFarmFunctions)
    end
end
function App.StartFunctions(self)
    table.clear(GlobalRzFunctions)
    local FuncRegistry = {}
    local function RegisterFunc(funcName, funcLogic, shouldRegister)
        if shouldRegister == false then
            return
        end
        if not FuncRegistry[funcName] then
            FuncRegistry[funcName] = funcLogic
            table.insert(GlobalRzFunctions, {
                Name = funcName,
                Function = funcLogic
            })
            return nil
        end
        FuncRegistry[funcName] = funcLogic
        local iterFunc, iterTable, iterKey = ipairs(GlobalRzFunctions)
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if iterVal.Name == funcName then
                iterVal.Function = funcLogic
                break
            end
        end
    end
    local _ = self.Managers.FightingStyle
    local IslandMgr = self.Managers.IslandManager
    local QuestMgr = self.Managers.QuestManager
    local FarmMgr = self.Managers.FarmManager
    local RaidMgr = self.Managers.RaidManager
    local ItemQuestMgr = self.Managers.ItemsQuests
    local SeaMgr = self.Managers.SeaManager
    local TeleportMgr = self.Managers.PlayerTeleport
    local _ = MainModule.GameData.MaxMastery
    local maxLvlData = MainModule.GameData.MaxLevel
    local curSeaData = MainModule.GameData.Sea
    local isAliveData = MainModule.IsAlive
    local invData = MainModule.Inventory
    local equipToolData = MainModule.EquipTool
    local fireRemoteData = MainModule.FireRemote
    local unlockedInvData = invData.Unlocked
    local invCountData = invData.Count
    local invMasteryData = invData.Mastery
    local isSpawnedData = MainModule.Enemies.IsSpawned
    local getSpawnedData = MainModule.EnemySpawned
    local enemyLocsData = MainModule.EnemyLocations
    local eliteEnemiesData = FarmMgr.Enemies.Elites
    local _ = FarmMgr.Enemies.Bones
    local _ = FarmMgr.Enemies.Katakuri
    local ectoplasmEnemiesData = FarmMgr.Enemies.Ectoplasm
    local farmAttackData = FarmMgr.attack
    local posOffset1 = Vector3.new(0, 3, 0)
    local posOffset2 = Vector3.new(0, 5, 0)
    local posOffset3 = Vector3.new(0, 50, 0)
    local posOffset4 = Vector3.new(0, - 10, 0)
    local tpPos1 = CFrame.new(- 1926, 13, 1738)
    local tpPos2 = CFrame.new(- 5556, 300, - 2988)
    local tpPos3 = CFrame.new(914, 126, 33100)
    local tpPos4 = CFrame.new(- 5410, 314, - 2628)
    local tpPos5 = CFrame.new(- 5561, 314, - 2663)
    local tpPos6 = CFrame.new(- 8932.85, 142.87, 6063.31)
    local tpPos7 = CFrame.new(1346, 37, - 1329)
    local tpPos8 = CFrame.new(- 2103, 70, - 12165)
    local tpPos9 = CFrame.new(224, 25, - 12771)
    local tpPos10 = CFrame.new(3779, 16, - 3500)
    local tpPos11 = CFrame.new(912, 186, 33591)
    local tpPos12 = CFrame.new(- 5417, 313, - 2822)
    local tpPos13 = CFrame.new(- 9513, 164, 5786)
    local tpPos14 = CFrame.new(- 1461, 30, - 51)
    local tpPos15 = CFrame.new(5864, 1209, 810)
    local tpPos16 = CFrame.new(5251, 20, 454)
    local tpPos17 = CFrame.new(- 7739, 5657, - 2289)
    local tpPos18 = CFrame.new(- 690, 15, 1583)
    local tpPos19 = CFrame.new(- 26952, 21, 329)
    local tpPos20 = CFrame.new(- 462, 73, 300)
    local tpPos21 = CFrame.new(2289, 15, 808)
    local tpPos22 = CFrame.new(- 2777, 73, - 3570)
    local tpPos23 = CFrame.new(- 1988, 124, - 70)
    local tpPos24 = CFrame.new(- 12512, 340, - 9872)
    local tpPos25 = CFrame.new(- 12445, 332, - 7676)
    local tpPos26 = CFrame.new(- 12445, 332, - 7676)
    local subclassQuestRemote = NetModules:WaitForChild("RF/InteractSubclassQuest")
    NetModules:WaitForChild("RF/InteractDragonQuest")
    local startSubclassRemote = NetModules:WaitForChild("RF/StartSubclassQuest")
    local kitsuneStatueRemote = NetModules:WaitForChild("RE/TouchKitsuneStatue")
    NetModules:WaitForChild("RE/DragonDojoEmber")
    local juiceNetworkRemote = NetModules:WaitForChild("RF/JuiceNetworkRF")
    local dragonHunterRemote = NetModules:WaitForChild("RF/DragonHunter")
    local claimBerryRemote = NetModules:WaitForChild("RF/ClaimBerry")
    local subclassNetwork = RemotesFolder:WaitForChild("SubclassNetwork")
    RemotesFolder:WaitForChild("QuestUpdate")
    local currentBossSpawn = nil
    local lastTickUpdate = 0
    local dhQuestInfo = nil
    local nearestEnemyToFarm = nil
    local volcanoRockObj = nil
    local preTreeObj = nil
    local masteryCacheList = {}
    local raceV3Cache = {}
    local leviathanData = {
        SegmentVector = Vector3.new(0, 75, 0),
        Segment = nil
    }
    local pirateCFrameList = {
        ["Forest Pirate"] = {
            CFrame.new(- 13335, 380, - 7660),
            CFrame.new(- 13138, 380, - 7713),
            CFrame.new(- 13298, 380, - 7876),
            CFrame.new(- 13512, 380, - 7983),
            CFrame.new(- 13632, 380, - 7815)
        },
        ["Swan Pirate"] = {
            CFrame.new(778, 110, 1129),
            CFrame.new(1018, 110, 1128),
            CFrame.new(1020, 110, 1366),
            CFrame.new(1016, 110, 1115)
        }
    }
    local swordQuestsData = {
        Quests = {
            Evil = "Yama",
            Good = "Tushita"
        },
        CurrentQuest = {
            Quest = false,
            Frags = - 1
        },
        BoatsDealer = {},
        CakeQueen = CFrame.new(- 710, 382, - 11150),
        DoorNpc = CFrame.new(- 12131, 578, - 6707),
        ForestPirate = CFrame.new(- 13350, 332, - 7645),
        Heaven = {
            "Heaven\'s Guardian",
            "Cursed Skeleton"
        },
        Hell = {
            "Hell\'s Messenger",
            "Cursed Skeleton"
        },
        CursedSkeleton = {
            CFrame.new(- 12360, 603, - 6551),
            CFrame.new(- 12331, 603, - 6551)
        },
        OpenedDoor = false
    }
    local rainbowHakiEnemies = {
        "Stone",
        "Hydra Leader",
        "Kilo Admiral",
        "Captain Elephant",
        "Beautiful Pirate"
    }
    local soulGuitarData = {
        GravestoneEvent = CFrame.new(- 8654, 141, 6169),
        Gravestones = CFrame.new(- 8760, 142, 6018),
        BuySkullGuitar = CFrame.new(- 9680, 6, 6346),
        Zombies = CFrame.new(- 10139, 154, 6001),
        Trophies = CFrame.new(- 9529, 6, 6039),
        Ghost = CFrame.new(- 9758, 270, 6291),
        Pipes = CFrame.new(- 9576, 6, 6230)
    }
    local flowerContextData = {
        FireFlower = {
            "Forest Pirate",
            "Mythological Pirate"
        },
        RequestQuest = {
            Context = "RequestQuest"
        },
        Check = {
            Context = "Check"
        }
    }
    local raceV3Enemies = {
        Human = {
            "Fajita",
            "Diamond",
            "Jeremy"
        },
        Shark = ToDictionary({
            "Sea Beast"
        })
    };
    ({}).Races = ToDictionary({
        "Human",
        "Skypiea",
        "Fishman",
        "Mink",
        "Cyborg",
        "Ghoul"
    })
    local hakiColorsList = {
        ["Really red"] = "Pure Red",
        Oyster = "Snow White",
        ["Hot pink"] = "Winter Sky",
        Hot_Green = BrickColor.new("Lime green")
    }
    local shipwrightRequirements = {
        Shipwright = ToDictionary({
            "Shark"
        }),
        SharkAnchor = ToDictionary({
            "Terrorshark"
        })
    }
    local function GetNextBoss()
        if currentBossSpawn and isSpawnedData(currentBossSpawn) then
            return currentBossSpawn
        end
        local iterFunc, iterTable, iterKey = pairs(MainModule.Bosses)
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if isSpawnedData(iterKey) then
                currentBossSpawn = iterKey
                return iterKey
            end
        end
    end
    local function SetupHakiColorFunc()
        local hakiColorData = QuestMgr:GetUnlockedHakiColors()
        local ciclePath = MapWorkspace["Boat Castle"].Summoner.Circle
        local tgtColor = hakiColorsList.Hot_Green
        local iterFunc, iterTable, iterKey = ipairs(ciclePath:GetChildren())
        local colorCount = 0
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if iterVal:IsA("BasePart") and iterVal:FindFirstChild("Part") then
                local foundColor = hakiColorsList[iterVal.BrickColor.Name]
                local colorPos = iterVal.Position
                if iterVal.Part.BrickColor ~= tgtColor then
                    if hakiColorData[foundColor] then
                        if LocalPlayer:DistanceFromCharacter(colorPos) > 3 then
                            TeleportFunc(iterVal.CFrame)
                        else
                            TeleportFunc(place.CFrame + posOffset2)
                            NetModules:FindFirstChild("RF/FruitCustomizerRF"):InvokeServer({
                                StorageName = place_color_name,
                                Type = "AuraSkin",
                                Context = "Equip"
                            })
                        end
                    end
                else
                    colorCount = colorCount + 1
                end
            end
        end
        return colorCount
    end
    local function ClickKatanaDoorFunc()
        fireclickdetector(MapWorkspace.Waterfall.SealedKatana.Hitbox.ClickDetector)
    end
    local function KillBossByInfo(bossInfo, bossName, overrideBoss)
        local bossQuestData = bossInfo.Quest
        if bossQuestData and (overrideBoss == false or not overrideBoss and GlobalSettings.BossQuest) and PlayerLevel.Value >= bossInfo.Level and not QuestMgr:VerifyQuest(bossName) then
            QuestMgr:StartQuest(bossQuestData[1], bossQuestData[3] or 3, bossQuestData[2])
            return "Getting Boss Quest: " .. bossName
        end
        local bossSpawnInst = getSpawnedData(bossName)
        if bossSpawnInst and bossSpawnInst.PrimaryPart then
            return "Killing: " .. bossName, farmAttackData(bossSpawnInst)
        end
        if bossInfo.Position then
            return "Waiting for: " .. bossName, TeleportFunc(bossInfo.Position)
        end
    end
    local function GetEmberTemplate()
        local minDist = math.huge
        local iterFunc, iterTable, iterKey = ipairs(workspace:GetChildren())
        local bestEmber = nil
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if iterVal.Name == "EmberTemplate" and (iterVal:FindFirstChild("Part") and iterVal.Part.Position.Y > 0) then
                local distToPlayer = LocalPlayer:DistanceFromCharacter(iterVal.Part.Position)
                if distToPlayer < minDist then
                    bestEmber = iterVal.Part
                    minDist = distToPlayer
                end
            end
        end
        return bestEmber
    end
    local function VerifyBlackbeardChip()
        if PlayerFragments.Value >= 1000 and not VerifyTool("Microchip") then
            fireRemoteData("BlackbeardReward", "Microchip", "2")
            local initTick = tick()
            repeat
                task.wait()
            until VerifyTool("Microchip") or tick() - initTick > 5
        end
    end
    local function GetTreeGroup()
        if preTreeObj and preTreeObj:IsDescendantOf(MapWorkspace) then
            return preTreeObj
        end
        local waterfallIslands = MapWorkspace.Waterfall.IslandModel:GetChildren()
        local iterFunc, iterTable, iterKey = ipairs(waterfallIslands)
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if iterVal:IsA("Model") and iterVal.Name == "Tree" then
                local treeGrp = iterVal:FindFirstChild("Group")
                if treeGrp then
                    treeGrp = treeGrp:FindFirstChild("Meshes/bambootree")
                end
                if treeGrp and treeGrp.Anchored then
                    preTreeObj = treeGrp
                    return treeGrp
                end
            end
        end
    end
    local function BreakTree()
        local treeInst = GetTreeGroup()
        if treeInst and LocalPlayer:DistanceFromCharacter(treeInst.Position) <= 3 then
            if unlockedInvData["Skull Guitar"] then
                if VerifyTool("Skull Guitar") then
                    MainModule.Hooking:SetTarget(treeInst)
                    equipToolData("Skull Guitar")
                    MainModule.FastAttack:ShootInTarget(treeInst.Position + posOffset4)
                else
                    fireRemoteData("LoadItem", "Skull Guitar")
                end
                return nil
            end
            equipToolData(SeaMgr:RandomTool(), true)
            MainModule.UseSkills(treeInst, GlobalSettings.SeaSkills)
        elseif treeInst then
            local _ = treeInst.CFrame
        end
    end
    local function FarmZombies()
        if LocalPlayer:DistanceFromCharacter(soulGuitarData.Zombies) >= 10 then
            return TeleportFunc(soulGuitarData.Zombies)
        end
        local gatheredCount = 0
        local pChar = LocalPlayer.Character
        local pRoot
        if pChar then
            pRoot = pChar.PrimaryPart
        else
            pRoot = pChar
        end
        if not pRoot then
            return nil
        end
        local allEnemies = EnemiesWorkspace
        local iterFunc, iterTable, iterKey = ipairs(allEnemies:GetChildren())
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            local enemyRoot = iterVal.PrimaryPart
            if iterVal.Name == "Living Zombie" and (isAliveData(iterVal) and enemyRoot) then
                gatheredCount = gatheredCount + 1
                enemyRoot.CFrame = pRoot.CFrame * CFrame.new(0, - 15, - 15)
                enemyRoot.CanCollide = false
                enemyRoot.Size = Vector3.new(60, 60, 60)
                iterVal.Humanoid.WalkSpeed = 0
                iterVal.Humanoid.JumpPower = 0
                iterVal.Humanoid:ChangeState(14)
            end
        end
        pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", math.huge)
        if gatheredCount > 5 then
            equipToolData()
            EnableBuso()
        elseif pChar:FindFirstChildOfClass("Tool") then
            pChar:FindFirstChildOfClass("Tool").Parent = LocalPlayer.Backpack
        end
    end
    local function GetCursedDualKatanaTask()
        if LocalPlayer:FindFirstChild("QuestHaze") then
            return "Yama", 2
        end
        if LocalPlayer:FindFirstChild("BoatQuest") then
            return "Tushita", 1
        end
        if MapWorkspace:FindFirstChild("HellDimension") then
            return "Yama", 3
        end
        if MapWorkspace:FindFirstChild("HeavenlyDimension") then
            return "Tushita", 3
        end
        if invCountData["Alucard Fragment"] == 6 then
            return "FinalQuest"
        end
        local iterFunc, iterTable, iterKey = pairs(swordQuestsData.Quests)
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            local questState = fireRemoteData("CDKQuest", "Progress", iterKey)[iterKey]
            if questState < - 2 then
                return iterVal, (questState + 2) * - 1
            end
            if 0 <= questState and questState < 3 then
                fireRemoteData("CDKQuest", "StartTrial", iterKey)
                return iterVal, questState + 1
            end
        end
    end
    local function CheckSpecsEnabled(instObj)
        local specsObj = instObj:FindFirstChild("Specs")
        if specsObj then
            specsObj = instObj.Specs.Enabled
        end
        return specsObj
    end
    local function GetVolcanoRock(preIslandInst)
        if volcanoRockObj and (volcanoRockObj:IsDescendantOf(preIslandInst) and CheckSpecsEnabled(volcanoRockObj)) then
            return volcanoRockObj
        end
        local iterFunc, iterTable, iterKey = ipairs(preIslandInst.Core.VolcanoRocks:GetChildren())
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            local layerFx = iterVal:FindFirstChild("VFXLayer")
            if layerFx and CheckSpecsEnabled(layerFx) then
                volcanoRockObj = layerFx
                return layerFx
            end
        end
    end
    local function AttackSegment(segInst)
        EnableBuso()
        SeaMgr:StopBoat()
        if segInst.Name == "Leviathan Segment" and segInst:FindFirstChild("Head") then
            equipToolData(SeaMgr:RandomTool(), true)
            MainModule.UseSkills(segInst.Head.CFrame + leviathanData.SegmentVector, GlobalSettings.SeaSkills)
            return true, TeleportFunc(segInst.Head.CFrame + leviathanData.SegmentVector)
        end
        if segInst:FindFirstChild("Head") then
            local headTarget = CFrame.new(segInst.Head.Position.X, 60, segInst.Head.Position.Z)
            EnableBuso()
            SeaMgr:StopBoat()
            equipToolData(SeaMgr:RandomTool(), true)
            MainModule.UseSkills(headTarget, GlobalSettings.SeaSkills)
            return true, TeleportFunc(headTarget)
        end
    end
    RegisterFunc("Tushita", function()
        if unlockedInvData.Tushita then
            if not isSpawnedData("rip_indra True Form") then
                return nil
            end
            local indraSpawn = getSpawnedData("rip_indra True Form")
            if indraSpawn and indraSpawn.PrimaryPart then
                farmAttackData(indraSpawn)
            else
                TeleportFunc(tpPos4)
            end
            return true
        else
            local tushitaProgress = MainModule:GetProgress("Tushita", "TushitaProgress")
            if tushitaProgress.OpenedDoor then
                if isSpawnedData("Longma") then
                    return KillBossByInfo(MainModule.Bosses.Longma, "Longma")
                else
                    return nil
                end
            elseif VerifyTool("Holy Torch") then
                for tIdx = 1, # tushitaProgress.Torches do
                    if not tushitaProgress.Torches[tIdx] then
                        fireRemoteData("TushitaProgress", "Torch", tIdx)
                    end
                end
                return true
            elseif isSpawnedData("rip_indra True Form") then
                TeleportFunc(CFrame.new(5713, 38, 255))
                return true
            else
                local tryElite
                if ActiveOptions.EliteHunter then
                    tryElite = false
                else
                    tryElite = FuncRegistry.EliteHunter()
                end
                return tryElite
            end
        end
    end, curSeaData == 3)
    RegisterFunc("Darkbeard", function()
        if isSpawnedData("Darkbeard") then
            local dbSpawn = getSpawnedData("Darkbeard")
            if dbSpawn and dbSpawn.PrimaryPart then
                farmAttackData(dbSpawn)
            else
                TeleportFunc(tpPos10)
            end
            return true
        end
        if VerifyTool("Fist of Darkness") then
            equipToolData("Fist of Darkness")
            TeleportFunc(tpPos10)
            return true
        end
    end, curSeaData == 2)
    RegisterFunc("CursedCaptain", function()
        if isSpawnedData("Cursed Captain") then
            local ccSpawn = getSpawnedData("Cursed Captain")
            if ccSpawn and ccSpawn.PrimaryPart then
                farmAttackData(ccSpawn)
            else
                TeleportFunc(tpPos11)
            end
            return true
        end
    end, curSeaData == 2)
    RegisterFunc("Factory", function()
        local factoryCore = EnemiesWorkspace:FindFirstChild("Core") or ReplicatedStorage:FindFirstChild("Core")
        if factoryCore and (isAliveData(factoryCore) and factoryCore.PrimaryPart) then
            return "Defeating Factory", FarmMgr.TargetPosition(factoryCore.PrimaryPart.CFrame)
        end
    end, curSeaData == 2)
    RegisterFunc("SkullGuitar", function()
        if PlayerLevel.Value < 2300 or (Lighting:GetAttribute("MoonPhase") ~= 5 or unlockedInvData["Skull Guitar"]) then
            return nil
        else
            local puzzleState = MainModule:GetProgress("SkullGuitar", "GuitarPuzzleProgress", "Check")
            if puzzleState then
                local _ = puzzleState.CraftedOnce
                local graveVal = puzzleState.Gravestones
                local trophyVal = puzzleState.Trophies
                local swampVal = puzzleState.Swamp
                local ghostVal = puzzleState.Ghost
                if puzzleState.Pipes then
                    if LocalPlayer:DistanceFromCharacter(soulGuitarData.BuySkullGuitar.Position) then
                        fireRemoteData("soulGuitarBuy", true)
                    else
                        TeleportFunc(soulGuitarData.BuySkullGuitar)
                    end
                    return true
                else
                    if trophyVal then
                        TeleportFunc(soulGuitarData.Pipes)
                        TeleportMgr:NPCTalk(soulGuitarData.Pipes, "GuitarPuzzleProgress", "Pipes")
                    elseif ghostVal then
                        TeleportFunc(soulGuitarData.Trophies)
                        TeleportMgr:NPCTalk(soulGuitarData.Trophies, "GuitarPuzzleProgress", "Trophies")
                    elseif graveVal then
                        TeleportFunc(soulGuitarData.Ghost)
                        TeleportMgr:NPCTalk(soulGuitarData.Ghost, "GuitarPuzzleProgress", "Ghost")
                    elseif swampVal then
                        TeleportFunc(soulGuitarData.Gravestones)
                        TeleportMgr:NPCTalk(soulGuitarData.Gravestones, "GuitarPuzzleProgress", "Gravestones")
                    else
                        FarmZombies()
                    end
                    return true
                end
            else
                if LocalPlayer:DistanceFromCharacter(soulGuitarData.GravestoneEvent.Position) then
                    fireRemoteData("gravestoneEvent", 2, true)
                else
                    TeleportFunc(soulGuitarData.GravestoneEvent)
                end
                return true
            end
        end
    end, curSeaData == 3)
    RegisterFunc("CursedDualKatana", function()
        if unlockedInvData["Cursed Dual Katana"] then
            return nil
        end
        if not unlockedInvData.Tushita then
            return FuncRegistry.Tushita()
        end
        if not unlockedInvData.Yama then
            return FuncRegistry.Yama() or FuncRegistry.EliteHunter()
        end
        local masteryT = invMasteryData.Tushita
        local masteryY = invMasteryData.Yama
        if 350 > masteryT or 350 > masteryY then
            local swordToMaster = masteryT < 350 and "Tushita" or "Yama"
            if not VerifyTool(swordToMaster) then
                fireRemoteData("LoadItem", swordToMaster)
                return "Getting 350 in: " .. swordToMaster
            end
            equipToolData(swordToMaster)
            FarmMgr.ToolDebounce()
            return ActiveOptions.PirateRaid and FuncRegistry.PirateRaid() or ActiveOptions.Fruits and FuncRegistry.Fruits() or (ActiveOptions.EliteHunter and FuncRegistry.EliteHunter() or FuncRegistry.Bones())
        end
        local curCdkQuest = swordQuestsData.CurrentQuest
        local _ = MapWorkspace.Turtle.Cursed
        if not swordQuestsData.OpenedDoor then
            local openDoorRes = fireRemoteData("CDKQuest", "OpenDoor")
            if openDoorRes == "opened" or openDoorRes == "can" and fireRemoteData("CDKQuest", "OpenDoor", true) then
                swordQuestsData.OpenedDoor = true
                setclipboard("Destruindo porta")
                if MapWorkspace.Turtle.Cursed:FindFirstChild("Breakable") then
                    MapWorkspace.Turtle.Cursed.Breakable:Destroy()
                end
            end
            return nil
        end
        if not curCdkQuest.Quest or curCdkQuest.Frags ~= invCountData["Alucard Fragment"] then
            local aluFrags = invCountData["Alucard Fragment"]
            curCdkQuest.Quest = {
                GetCursedDualKatanaTask()
            }
            curCdkQuest.Frags = aluFrags
        end
        local cdkItemData = ItemQuestMgr.CursedDualKatana
        local cdkQ1 = curCdkQuest.Quest[1]
        local cdkQ2 = curCdkQuest.Quest[2]
        if cdkQ1 then
            if cdkQ2 then
                if cdkItemData[cdkQ1][cdkQ2](swordQuestsData, FuncRegistry) then
                    return cdkQ1 .. cdkQ2
                end
            elseif cdkItemData[cdkQ1](swordQuestsData, FuncRegistry) then
                return cdkQ1
            end
        end
    end, curSeaData == 3)
    RegisterFunc("Raid", function()
        local awakenerInst = WorldLocations:FindFirstChild("l\'\195\137glise de Proph\195\169tie")
        if awakenerInst and LocalPlayer:DistanceFromCharacter(awakenerInst.Position) <= 150 then
            local awakeCheck = fireRemoteData("Awakener", "Check")
            if type(awakeCheck) ~= "table" then
                if awakeCheck ~= 0 then
                    return true, fireRemoteData("Awakener", "Teleport")
                end
            else
                if PlayerFragments.Value < (awakeCheck.Cost or 0) then
                    return true, fireRemoteData("Awakener", "Teleport")
                end
                fireRemoteData("Awakener", "Awaken")
                fireRemoteData("Awakener", "Teleport")
            end
        end
        if RaidMgr:IsRaiding() then
            local rIsland = MainModule:GetRaidIsland()
            if not rIsland then
                return true
            end
            local raidEnemies = EnemiesWorkspace
            local iterFunc, iterTable, iterKey = ipairs(raidEnemies:GetChildren())
            while true do
                local iterVal
                iterKey, iterVal = iterFunc(iterTable, iterKey)
                if iterKey == nil then
                    break
                end
                local reRoot = iterVal.PrimaryPart
                if isAliveData(iterVal) and (reRoot and ((rIsland.Position - reRoot.Position).Magnitude <= 1000 and reRoot.Position.Y > 0)) then
                    return true, farmAttackData(iterVal, true, true, GlobalSettings.FarmMode ~= "Up" and GlobalSettings.FarmMode or "Star")
                end
            end
            if LocalPlayer:DistanceFromCharacter(rIsland.Position) <= 3000 then
                TeleportFunc(rIsland.CFrame + posOffset3)
            end
            return true
        end
        if VerifyTool("Special Microchip") then
            return true, RaidMgr:start()
        end
    end, curSeaData == 2 or curSeaData == 3)
    RegisterFunc("Leviathan", function()
        if not MapWorkspace:FindFirstChild("FrozenHeart") then
            local currentSeg = leviathanData.Segment
            if currentSeg and (isAliveData(currentSeg) and currentSeg:GetAttribute("HealthEnabled")) then
                return AttackSegment(currentSeg)
            end
            local sbChildren = SeaBeastsWorkspace:GetChildren()
            for idx = 1, # sbChildren do
                local childInst = sbChildren[idx]
                if childInst.name:find("Leviathan") then
                    if isAliveData(childInst) then
                        if childInst:GetAttribute("HealthEnabled") then
                            leviathanData.Segment = childInst
                            return AttackSegment(childInst)
                        end
                    end
                end
            end
        end
    end, curSeaData == 3)
    RegisterFunc("PirateRaid", function()
        local raidEnemies = MainModule.Enemies:GetTagged("PirateRaid")
        if # raidEnemies > 0 or tick() - MainModule.PirateRaid <= 10 then
            for idx = 1, # raidEnemies do
                if raidEnemies[idx].PrimaryPart then
                    return true, farmAttackData(raidEnemies[idx], true, true)
                end
            end
            return true, TeleportFunc(tpPos2)
        end
    end, curSeaData == 3)
    RegisterFunc("Fruits", function()
        local fruitInst = workspace:FindFirstChild("Fruit ") or workspace:FindFirstChildOfClass("Tool")
        if fruitInst and (fruitInst:IsA("Model") or fruitInst:IsA("Tool")) then
            local fHandle = fruitInst:FindFirstChild("Handle")
            if fHandle then
                fHandle = fruitInst.Handle.CFrame
            end
            local finalFruitPos
            if fHandle or not fruitInst:IsA("Model") then
                finalFruitPos = fHandle
            else
                finalFruitPos = fruitInst:GetPivot()
                if finalFruitPos.Position == Vector3.zero then
                    finalFruitPos = fHandle
                end
            end
            if finalFruitPos then
                if LocalPlayer:DistanceFromCharacter(finalFruitPos.Position) > 2 then
                    TeleportFunc(finalFruitPos)
                else
                    TeleportFunc(finalFruitPos + posOffset1)
                end
                return true
            end
        end
    end)
    RegisterFunc("FireFlowers", function(reqAmount)
        local flowerFolder = workspace:FindFirstChild("FireFlowers")
        if flowerFolder then
            local flowerChildren = flowerFolder:GetChildren()
            for idx = 1, # flowerChildren do
                local flInst = flowerChildren[idx]
                local isModel = flInst:IsA("Model")
                if isModel then
                    isModel = flInst.PrimaryPart or flInst:FindFirstChildOfClass("MeshPart")
                end
                if isModel then
                    if LocalPlayer:DistanceFromCharacter(isModel.Position) > 3 then
                        TeleportFunc(isModel.CFrame)
                    elseif flInst:FindFirstChild("ProximityPrompt") and flInst.ProximityPrompt.Enabled then
                        fireproximityprompt(flInst.ProximityPrompt)
                        task.wait(0.5)
                    end
                    return "Collecting Fire Flower"
                end
            end
        end
        local fEnemy = getSpawnedData(flowerContextData.FireFlower)
        if fEnemy and fEnemy.PrimaryPart then
            farmAttackData(fEnemy, true)
        else
            TeleportMgr:NPCs(pirateCFrameList["Forest Pirate"])
        end
        return ("Getting Fire Flowers: %i/%i"):format(invCountData["Fire Flower"], reqAmount or 99)
    end, curSeaData == 3)
    RegisterFunc("DracoV2V3", function()
        return ItemQuestMgr:GetDracoRace(FuncRegistry)
    end, curSeaData == 3)
    RegisterFunc("DojoTrainer", function()
        local talonM = masteryCacheList["Dragon Talon"]
        if talonM and talonM >= 500 then
            return ItemQuestMgr:BeltQuests(FuncRegistry)
        end
        if VerifyTool("Dragon Talon") then
            if talonM then
                masteryCacheList["Dragon Talon"] = GetToolMastery("Dragon Talon")
                equipToolData("Dragon Talon")
                FarmMgr.ToolDebounce()
                return FuncRegistry.Bones()
            end
            masteryCacheList["Dragon Talon"] = GetToolMastery("Dragon Talon")
        else
            fireRemoteData("BuyDragonTalon")
        end
        return true
    end, curSeaData == 3)
    RegisterFunc("DragonHunter", function()
        if dhQuestInfo == "Locked" then
            return nil
        end
        local dhTarget = GetEmberTemplate()
        if dhTarget then
            TeleportFunc(dhTarget.CFrame)
            return "Colleting Blaze Ember"
        end
        if not (dhQuestInfo and dhQuestInfo.Text) then
            if LocalPlayer:DistanceFromCharacter(tpPos15.Position) >= 5 then
                TeleportFunc(tpPos15)
            else
                dhQuestInfo = dragonHunterRemote:InvokeServer(flowerContextData.Check)
                if dhQuestInfo and not dhQuestInfo.Text then
                    pcall(dragonHunterRemote.InvokeServer, dragonHunterRemote, flowerContextData.RequestQuest)
                end
            end
            return "Getting Dragon Hunter Quest"
        end
        local dhText = dhQuestInfo.Text
        if dhText:find("Defeat") then
            local tgtEnemyStr = dhText:find("Venomous") and "Venomous Assailant" or "Hydra Enforcer"
            local eSpawn = getSpawnedData(tgtEnemyStr)
            local eLocs = enemyLocsData[tgtEnemyStr]
            if eSpawn and eSpawn.PrimaryPart then
                farmAttackData(eSpawn, true)
            elseif eLocs then
                TeleportMgr:NPCs(eLocs)
            end
            return "Killing: " .. tgtEnemyStr
        end
        if dhText:find("Destroy") then
            BreakTree()
            return "Breaking Hydra Island Tree\'s"
        end
    end, curSeaData == 3)
    RegisterFunc("MirageFruitDealer", function()
        if IslandMgr:GetSpawnedIsland("MysticIsland") then
            local mDealer = IslandMgr:GetMirageFruitDealer()
            if mDealer and mDealer.PrimaryPart then
                TeleportFunc(mDealer.PrimaryPart.CFrame)
                return true
            end
        end
    end, curSeaData == 3)
    RegisterFunc("MirageGear", function()
        local mIsland = MapWorkspace:FindFirstChild("MysticIsland")
        if mIsland then
            local mGear = IslandMgr:GetMirageGear(mIsland)
            if mGear and mGear.Transparency < 1 then
                TeleportFunc(mGear.CFrame)
                return true
            end
        end
    end, curSeaData == 3)
    RegisterFunc("MirageChests", function()
        if MapWorkspace:FindFirstChild("MysticIsland") then
            local _ = FuncRegistry.ChestTween
            local _ = MapWorkspace.MysticIsland
        end
    end)
    RegisterFunc("TeleportMirage", function()
        local mysticIsle = MapWorkspace:FindFirstChild("MysticIsland")
        if mysticIsle then
            mysticIsle = IslandMgr:GetMirageTop(mysticIsle)
        end
        if mysticIsle then
            TeleportFunc(mysticIsle.CFrame * CFrame.new(0, 211.8, 0))
            return true
        end
    end, curSeaData == 3)
    RegisterFunc("CraftVolcanicMagnet", function()
        if not (unlockedInvData["Volcanic Magnet"] or MapWorkspace:FindFirstChild("PrehistoricIsland")) then
            if invCountData["Scrap Metal"] < 10 then
                return FarmMgr:Material("Leather + Scrap Metal")
            end
            if invCountData["Blaze Ember"] < 15 then
                return FuncRegistry.DragonHunter()
            end
            if LocalPlayer:DistanceFromCharacter(tpPos15.Position) >= 3 then
                TeleportFunc(tpPos15)
            else
                fireRemoteData("CraftItem", "Craft", "Volcanic Magnet")
            end
            return true
        end
    end, curSeaData == 3)
    RegisterFunc("PrehistoricBones", function()
        if invCountData["Dinosaur Bones"] >= 99 then
            return nil
        end
        if LocalPlayer:GetAttribute("PrehistoricIslandParticipant") and workspace:FindFirstChild("PrehistoricIsland") then
            local wrkChildren = workspace:GetChildren()
            for idx = 1, # wrkChildren do
                local wrkInst = wrkChildren[idx]
                if wrkInst.Name == "DinoBone" then
                    if wrkInst:IsA("BasePart") then
                        if (wrkInst.Position - workspace.PrehistoricIsland:GetPivot().Position).Magnitude <= 1500 then
                            if LocalPlayer:DistanceFromCharacter(wrkInst.Position) > 3 then
                                TeleportFunc(wrkInst.CFrame)
                            else
                                TeleportFunc(wrkInst.CFrame + posOffset2)
                            end
                            lastTickUpdate = tick()
                            return "Collecting Dinosaur Bones"
                        end
                    end
                end
            end
        end
    end, curSeaData == 3)
    RegisterFunc("PrehistoricEgg", function()
        local preIsle = IslandMgr:GetSpawnedIsland("PrehistoricIsland")
        if preIsle then
            local coreInst = preIsle:FindFirstChild("Core")
            if coreInst then
                coreInst = coreInst:FindFirstChild("SpawnedDragonEggs")
            end
            if coreInst and # coreInst:GetChildren() > 0 then
                local eggInst = coreInst:FindFirstChild("DragonEgg")
                if eggInst then
                    eggInst = eggInst:FindFirstChild("Molten")
                end
                if eggInst and (eggInst:FindFirstChild("ProximityPrompt") and eggInst.ProximityPrompt.Enabled) then
                    if LocalPlayer:DistanceFromCharacter(eggInst.Position) >= 3 then
                        TeleportFunc(eggInst.CFrame)
                    else
                        fireproximityprompt(eggInst.ProximityPrompt)
                        task.wait(0.5)
                    end
                    lastTickUpdate = tick()
                    return "Collecting Dragon Egg"
                end
            end
        end
    end, curSeaData == 3)
    RegisterFunc("LavaGolem", function()
        local preIsle = IslandMgr:GetSpawnedIsland("PrehistoricIsland")
        if preIsle and preIsle:GetAttribute("IsMinigameActive") then
            local eGroup = EnemiesWorkspace
            local iterFunc, iterTable, iterKey = ipairs(eGroup:GetChildren())
            while true do
                local iterVal
                iterKey, iterVal = iterFunc(iterTable, iterKey)
                if iterKey == nil then
                    break
                end
                local eRoot = iterVal.PrimaryPart
                if iterVal.Name == "Lava Golem" and (eRoot and eRoot.Position.Y > 0) then
                    farmAttackData(iterVal, true)
                    lastTickUpdate = tick()
                    return "Defeating Lava Golem"
                end
            end
        end
    end, curSeaData == 3)
    RegisterFunc("PrehistoricIsland", function()
        local pIsle = IslandMgr:GetSpawnedIsland("PrehistoricIsland")
        if pIsle then
            local pPrompt = IslandMgr:GetPrehistoricActivationPrompt(pIsle)
            if not pPrompt then
                return true, SeaMgr:StopBoat()
            end
            if pPrompt.Parent:FindFirstChild("InteriorLava") then
                pPrompt.Parent.InteriorLava:Destroy()
            end
            if pIsle:GetAttribute("IsMinigameActive") then
                local tNow = tick()
                RemoveCanTouch = tick()
                lastTickUpdate = tNow
                local vRock = GetVolcanoRock(pIsle)
                if vRock then
                    if LocalPlayer:DistanceFromCharacter(vRock.Position) >= 5 then
                        TeleportFunc(vRock.CFrame, false, false, true)
                    else
                        equipToolData(SeaMgr:RandomTool(), true)
                        MainModule.UseSkills(vRock, GlobalSettings.SeaSkills)
                    end
                else
                    TeleportFunc(pPrompt.CFrame, false, false, true)
                end
                return "Volcano Patch"
            end
            if LocalPlayer:DistanceFromCharacter(pPrompt.Position) > 3 then
                lastTickUpdate = tick()
                TeleportFunc(pPrompt.CFrame)
                return "Teleporting to Prehistoric Island"
            end
            if pPrompt:FindFirstChild("ProximityPrompt") and pPrompt.ProximityPrompt.Enabled then
                lastTickUpdate = tick()
                fireproximityprompt(pPrompt.ProximityPrompt)
                task.wait(0.5)
                return "Waiting..."
            end
            if GlobalSettings.ResetPrehistoric and (tick() - lastTickUpdate >= 8 and isAliveData(LocalPlayer.Character)) then
                LocalPlayer.Character.Humanoid.Health = 0
                return "Reseting..."
            end
        end
        if ActiveOptions.Sea and GlobalSettings.aTweenBoat or ActiveOptions.KitsuneIsland and MapWorkspace:FindFirstChild("KitsuneIsland") then
            return nil
        end
        if SeaMgr:GetPlayerBoat() then
            SeaMgr:RandomTeleport("inf")
        else
            SeaMgr:BuyNewBoat()
        end
        return "Finding Prehistoric Island"
    end, curSeaData == 3)
    RegisterFunc("KitsuneIsland", function()
        local kIsle = MapWorkspace:FindFirstChild("KitsuneIsland")
        if not kIsle or Lighting:GetAttribute("MoonPhase") ~= 5 then
            if ActiveOptions.Sea then
                return nil
            end
            if SeaMgr:GetPlayerBoat() then
                SeaMgr:RandomTeleport("6")
            else
                SeaMgr:BuyNewBoat()
            end
            return true
        end
        if Lighting:GetAttribute("IsBlueMoon") and Lighting:GetAttribute("BlueMoonEnded") then
            return nil
        end
        local tEmber = GetEmberTemplate()
        if tEmber then
            TeleportFunc(tEmber.CFrame)
            return true
        end
        local kShrine = kIsle:FindFirstChild("ShrineDialogPart")
        if kShrine then
            if LocalPlayer:DistanceFromCharacter(kShrine.Position) > 3 then
                TeleportFunc(kShrine.CFrame)
            elseif Lighting:GetAttribute("MoonPhase") == 5 and not Lighting:GetAttribute("IsBlueMoon") then
                kitsuneStatueRemote:FireServer()
            end
        elseif kIsle.WorldPivot then
            TeleportFunc(kIsle.WorldPivot)
        end
        return true
    end, curSeaData == 3)
    RegisterFunc("Shipwright", function()
        if PlayerSubclass.Value == "Shipwright" then
            return nil
        end
        local sqStep, sqAmt = subclassQuestRemote:InvokeServer("Shipwright")
        if sqStep == 1 then
            startSubclassRemote:InvokeServer("Shipwright")
        elseif sqStep == 3 then
            if (tonumber(sqAmt) or 0) < 20 then
                return FuncRegistry.Sea(shipwrightRequirements.Shipwright)
            end
        elseif sqStep == 4 or sqStep == 2 then
            if subclassNetwork.GetPlayerData:InvokeServer().Purchased.Shipwright == nil then
                if PlayerFragments.Value >= 3000 then
                    subclassNetwork.PurchaseSubclass:InvokeServer("Shipwright")
                end
            else
                subclassNetwork.EquipSubclass:InvokeServer("Shipwright")
            end
        end
    end, curSeaData == 3)
    RegisterFunc("RaceV2", function()
        if PlayerData.Race.Value == "Draco" or not unlockedInvData["Warrior Helmet"] or PlayerData.Race:FindFirstChild("Evolved") then
            return nil
        end
        local alcState = MainModule:GetProgress("RaceV2", "Alchemist", "1")
        if alcState == 0 or alcState == 2 then
            if alcState ~= 2 or PlayerBeli.Value >= 500000 then
                if LocalPlayer:DistanceFromCharacter(tpPos22.Position) >= 5 then
                    TeleportFunc(tpPos22)
                else
                    fireRemoteData("Alchemist", alcState == 0 and "2" or "3")
                end
                return true
            end
        elseif alcState == 1 then
            for fIdx = 1, 2 do
                local fItem = workspace:FindFirstChild("Flower" .. fIdx)
                if fItem then
                    if fItem.Transparency ~= 1 then
                        if not VerifyTool("Flower " .. fIdx) then
                            return "Collecting Flower: " .. fIdx, TeleportFunc(fItem.CFrame)
                        end
                    end
                end
            end
            if not VerifyTool("Flower 3") then
                local sEnemy = getSpawnedData("Swan Pirate")
                if sEnemy and sEnemy.PrimaryPart then
                    farmAttackData(sEnemy)
                else
                    TeleportMgr:NPCs(pirateCFrameList["Swan Pirate"])
                end
                return "Getting Flower: 3"
            end
        end
    end, curSeaData == 2)
    RegisterFunc("RaceV3", function()
        local curRace = PlayerData.Race.Value
        if curRace == "Draco" or (not PlayerData.Race:FindFirstChild("Evolved") or raceV3Cache.RaceV3 and raceV3Cache.RaceV3[curRace]) then
            return nil
        end
        local wtState = MainModule:GetProgress("RaceV3", "Wenlocktoad", "1")
        if wtState == - 2 then
            if raceV3Cache.RaceV3 then
                raceV3Cache.RaceV3[curRace] = true
            else
                raceV3Cache.RaceV3 = {
                    [curRace] = true
                }
            end
            return nil
        end
        if wtState == 0 or wtState == 2 then
            if wtState ~= 2 or PlayerBeli.Value >= 2000000 then
                if LocalPlayer:DistanceFromCharacter(tpPos23.Position) >= 5 then
                    TeleportFunc(tpPos23)
                else
                    fireRemoteData("Wenlocktoad", wtState == 0 and "2" or "3")
                end
                return true
            end
        elseif wtState == 1 then
            if curRace == "Fishman" then
                return FuncRegistry.Sea(raceV3Enemies.Shark)
            end
            if curRace == "Human" then
                local iterFunc, iterTable, iterKey = ipairs(raceV3Enemies.Human)
                while true do
                    local iterVal
                    iterKey, iterVal = iterFunc(iterTable, iterKey)
                    if iterKey == nil then
                        break
                    end
                    if isSpawnedData(iterVal) then
                        return KillBossByInfo(MainModule.Bosses[iterVal], iterVal)
                    end
                end
            elseif curRace == "Mink" then
                local _ = FuncRegistry.ChestTween
            end
        end
    end, curSeaData == 2)
    RegisterFunc("Sea", function(sOverrideEnemy)
        local curBoat = SeaMgr:GetPlayerBoat()
        if not curBoat then
            SeaMgr:BuyNewBoat()
            return true
        end
        local sTgt = sOverrideEnemy or GlobalSettings.seaEnemy
        if not sTgt then
            return nil
        end
        local sBrigade = sTgt.PirateBrigade and SeaMgr:GetSeaEvent("PirateBrigade")
        if sBrigade then
            SeaMgr:attackSeaEvent(sBrigade)
            return true
        end
        local sBeast = sTgt["Sea Beast"] and SeaMgr:GetSeaBeast()
        if sBeast then
            SeaMgr:attackSeaBeast(sBeast)
            return true
        end
        if SeaMgr:RepairBoat(curBoat) then
            return true
        end
        if curBoat then
            SeaMgr:RandomTeleport()
            return true
        end
    end, curSeaData == 2)
    RegisterFunc("Sea", function(optTgt1, optTgt2)
        local curBoat2 = SeaMgr:GetPlayerBoat()
        if not curBoat2 then
            SeaMgr:BuyNewBoat()
            return true
        end
        local sBoatOpts = optTgt2 or GlobalSettings.boatSelected
        local sFishOpts = optTgt1 or GlobalSettings.fishSelected
        local sBeast2 = sFishOpts["Sea Beast"] and SeaMgr:GetSeaBeast()
        if sBeast2 then
            SeaMgr:attackSeaBeast(sBeast2)
            return true
        end
        local iterFunc, iterTable, iterKey = pairs(sFishOpts)
        while true do
            local iterVal
            iterKey, iterVal = iterFunc(iterTable, iterKey)
            if iterKey == nil then
                break
            end
            if iterVal and iterKey ~= "Sea Beast" then
                local sEvt = SeaMgr:GetSeaEvent(iterKey)
                if sEvt then
                    SeaMgr:attackSeaEvent(sEvt)
                    return true
                end
            end
        end
        local iterFunc2, iterTable2, iterKey2 = pairs(sBoatOpts)
        while true do
            local iterVal2
            iterKey2, iterVal2 = iterFunc2(iterTable2, iterKey2)
            if iterKey2 == nil then
                break
            end
            if iterVal2 then
                local bEvt = SeaMgr:GetSeaEvent(iterKey2)
                if bEvt then
                    SeaMgr:attackSeaEvent(bEvt)
                    return true
                end
            end
        end
        if SeaMgr:RepairBoat(curBoat2) then
            return true
        end
        if GlobalSettings.aTweenBoat and curBoat2 then
            SeaMgr:RandomTeleport()
            return true
        end
    end, curSeaData == 3)
    RegisterFunc("Rengoku", function()
        if unlockedInvData.Rengoku or ActiveOptions.Level and PlayerLevel.Value < 1350 then
            return nil
        end
        if VerifyTool("Library Key") then
            return fireRemoteData("OpenLibrary")
        end
        if VerifyTool("Hidden Key") then
            return fireRemoteData("OpenRengoku")
        end
        if isSpawnedData("Awakened Ice Admiral") then
            return KillBossByInfo(MainModule.Bosses["Awakened Ice Admiral"], "Awakened Ice Admiral")
        end
        if PlayerLevel.Value >= 1425 or not ActiveOptions.Level then
            local rEnemy = getSpawnedData("Arctic Warrior", "Snow Lurker")
            if rEnemy and rEnemy.PrimaryPart then
                farmAttackData(rEnemy)
                return true
            end
        end
    end, curSeaData == 2)
    RegisterFunc("Bartilo", function()
        if PlayerLevel.Value < 850 or unlockedInvData["Warrior Helmet"] then
            return nil
        end
        local bState = MainModule:GetProgress("Bartilo", "BartiloQuestProgress")
        if bState.KilledSpring then
            fireRemoteData("BartiloQuestProgress", "DidPlates")
        elseif bState.KilledBandits then
            if isSpawnedData("Jeremy") then
                local jSpawn = getSpawnedData("Jeremy")
                if jSpawn and jSpawn.PrimaryPart then
                    farmAttackData(jSpawn)
                else
                    TeleportFunc(CFrame.new(2316, 449, 787))
                end
                return true
            end
        elseif not bState.KilledBandits then
            local swanValid = QuestMgr:VerifyQuest("Swan Pirate")
            if swanValid then
                swanValid = QuestMgr:VerifyQuest("50")
            end
            if swanValid then
                local sEnemy = getSpawnedData("Swan Pirate")
                if sEnemy and sEnemy.PrimaryPart then
                    farmAttackData(sEnemy)
                else
                    TeleportMgr:NPCs(pirateCFrameList["Swan Pirate"])
                end
            else
                QuestMgr:StartQuest("BartiloQuest", 1, tpPos20)
            end
            return true
        end
    end, curSeaData == 2)
    RegisterFunc("Yama", function()
        if unlockedInvData.Yama then
            return nil
        end
        if MainModule:GetProgress("EliteProgress", "EliteHunter", "Progress") >= 30 then
            if LocalPlayer:DistanceFromCharacter(tpPos16.Position) >= 5 then
                TeleportFunc(tpPos16)
            else
                pcall(ClickKatanaDoorFunc)
                task.wait(1)
            end
            return true
        end
    end, curSeaData == 3)
    RegisterFunc("Citizen", function()
        if PlayerLevel.Value < 1800 or unlockedInvData["Musketeer Hat"] then
            return nil
        end
        local cState = MainModule:GetProgress("Citizen", "CitizenQuestProgress")
        if cState.FoundTreasure then
            return nil
        end
        if cState.KilledBoss then
            TeleportFunc(tpPos24)
            return true
        end
        if not cState.KilledBandits then
            local fpValid = QuestMgr:VerifyQuest("Forest Pirate")
            if fpValid then
                fpValid = QuestMgr:VerifyQuest("50")
            end
            if not fpValid then
                if LocalPlayer:DistanceFromCharacter(tpPos26.Position) < 5 then
                    TeleportFunc(tpPos26)
                else
                    fireRemoteData("CitizenQuest", 1)
                end
                return true
            end
            local fpEnemy = getSpawnedData("Forest Pirate")
            if fpEnemy and fpEnemy.PrimaryPart then
                farmAttackData(fpEnemy, true)
            else
                TeleportMgr:NPCs(pirateCFrameList["Forest Pirate"])
            end
            return true
        end
        if isSpawnedData("Captain Elephant") then
            if not QuestMgr:VerifyQuest("Captain Elephant") then
                if LocalPlayer:DistanceFromCharacter(tpPos26.Position) < 5 then
                    TeleportFunc(tpPos26)
                else
                    fireRemoteData("CitizenQuestProgress", "Citizen")
                end
                return true
            end
            local eEnemy = getSpawnedData("Captain Elephant")
            if eEnemy and eEnemy.PrimaryPart then
                farmAttackData(eEnemy)
            else
                TeleportFunc(tpPos25)
            end
            return true
        end
    end, curSeaData == 3)
    RegisterFunc("RainbowHaki", function()
        local rHakiTgt = QuestMgr:VerifyQuest(rainbowHakiEnemies)
        if rHakiTgt then
            if isSpawnedData(rHakiTgt) then
                return KillBossByInfo(MainModule.Bosses[rHakiTgt], rHakiTgt, true)
            end
        else
            fireRemoteData("HornedMan", "Bet")
        end
    end, curSeaData == 3)
    RegisterFunc("EliteHunter", function()
        local ehTgt = QuestMgr:VerifyQuest(eliteEnemiesData)
        if (ActiveOptions.DoughKing or (ActiveOptions.CakePrince or ActiveOptions.RipIndra)) and (isSpawnedData("rip_indra True Form") or (isSpawnedData("Dough King") or (isSpawnedData("Cake Prince") or (VerifyTool("God\'s Chalice") or VerifyTool("Sweet Chalice"))))) then
            return nil
        end
        if ehTgt then
            local ehSpawn = getSpawnedData(ehTgt)
            if ehSpawn and ehSpawn.PrimaryPart then
                return "Killing Elite Hunter: " .. ehTgt, farmAttackData(ehSpawn)
            end
        else
            local ehInst = MainModule.Enemies:GetEnemyByTag("Elite")
            if ehInst then
                TeleportFunc(tpPos12)
                TeleportMgr:talkNpc(tpPos12, "EliteHunter")
                return "Getting Elite Quest: " .. ehInst.Name
            end
        end
    end, curSeaData == 3)
    RegisterFunc("AuraColor", function()
        local tgtAura = GlobalSettings.CraftAura
        if tgtAura and not unlockedInvData[tgtAura] then
            local aCraftData = QuestMgr:GetAuraCraft(tgtAura)
            if not type(aCraftData) ~= "table" then
                return nil
            end
            local iterFunc, iterTable, iterKey = ipairs(aCraftData)
            local missingMats = {}
            while true do
                local iterVal
                iterKey, iterVal = iterFunc(iterTable, iterKey)
                if iterKey == nil then
                    break
                end
                if invCountData[iterVal.Name] < iterVal.Amount then
                    table.insert(missingMats, iterVal.Name)
                end
            end
            if # missingMats <= 0 then
                local bPos = FarmMgr:GetNpcPosition("Barista")
                if LocalPlayer:DistanceFromCharacter(bPos.Position) >= 3 then
                    TeleportFunc(bPos)
                else
                    juiceNetworkRemote:InvokeServer({
                        StorageName = tgtAura,
                        Type = "AuraSkin",
                        Context = "Craft"
                    })
                end
                return true
            end
            if ActiveOptions.BerryBush then
                missingMats = nil
            end
            if FuncRegistry.BerryBush(missingMats, GlobalSettings.CraftHop) then
                return true
            end
            task.wait(0.3)
        end
    end, curSeaData ~= 1)
    RegisterFunc("BerryBush", function(reqBerries, shouldHop)
        local bInst = MainModule.Berry(reqBerries)
        if bInst and bInst.Parent then
            local iterFunc, iterTable, iterKey = pairs(bInst:GetAttributes())
            local bKey, bVal = iterFunc(iterTable, iterKey)
            if bKey ~= nil then
                local bParent = bInst.Parent
                local bTargetPos = bParent:GetPivot() * bParent:GetAttribute(bKey)
                if LocalPlayer:DistanceFromCharacter(bTargetPos.Position) >= 3 then
                    TeleportFunc(bTargetPos)
                else
                    claimBerryRemote:InvokeServer(bParent.Name, bKey)
                end
                return "Collecting Berry: " .. bVal
            end
        elseif shouldHop or shouldHop == nil and GlobalSettings.BerryHop then
            MainModule:ServerHop()
        end
    end)
    RegisterFunc("ThirdSea", function()
        if PlayerLevel.Value < 1500 or PlayerLevel.Value >= 1850 then
            return nil
        else
            local zState = MainModule:GetProgress("Zou1", "ZQuestProgress")
            if raceV3Cache.Zou2 or MainModule:GetProgress("Zou2", "ZQuestProgress", "Check") then
                if not raceV3Cache.Zou2 then
                    raceV3Cache.Zou2 = true
                end
                if LocalPlayer:DistanceFromCharacter(tpPos19.Position) < 1200 then
                    local zIndra = EnemiesWorkspace:FindFirstChild("rip_indra")
                    if zIndra and (zIndra.PrimaryPart and zIndra.PrimaryPart.Position.Y > 0) then
                        farmAttackData(zIndra)
                    end
                    return true
                end
                if zState.KilledIndraBoss then
                    return MainModule:TravelTo(3)
                end
                if LocalPlayer:DistanceFromCharacter(tpPos1.Position) < 5 then
                    fireRemoteData("ZQuestProgress", "Begin")
                    GlobalEnv.OnFarm = false
                    repeat
                        task.wait()
                    until LocalPlayer:DistanceFromCharacter(tpPos19.Position) < 1200 or not ActiveOptions[GlobalSettings.RunningOption]
                    return true
                end
                TeleportFunc(tpPos1)
                return
            elseif MainModule:GetProgress("Unlockables", "GetUnlockables").FlamingoAccess then
                return FuncRegistry.DonSwan()
            else
                return nil
            end
        end
    end, curSeaData == 2)
    RegisterFunc("DonSwan", function()
        if not unlockedInvData["Warrior Helmet"] then
            return nil
        end
        if isSpawnedData("Don Swan") then
            local dsEnemy = getSpawnedData("Don Swan")
            if dsEnemy and dsEnemy.PrimaryPart then
                farmAttackData(dsEnemy)
            else
                TeleportFunc(tpPos21)
            end
            return true
        end
    end, curSeaData == 2)
    RegisterFunc("SecondSea", function()
        if PlayerLevel.Value < 700 then
            return nil
        end
