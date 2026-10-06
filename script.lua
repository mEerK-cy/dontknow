local CollectionService = game:GetService('CollectionService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Items = ReplicatedStorage:WaitForChild('Items')
local Tycoons = game.Workspace:WaitForChild('Tycoons')

local PlaceholderTycoon = ReplicatedStorage:WaitForChild('Tycoon')

--  Clear out all items from tycoons
for _, Tycoon in CollectionService:GetTagged('Tycoon') do 
	if Tycoon:IsDescendantOf(ReplicatedStorage) then continue end
	Tycoon.Items:ClearAllChildren()
end 

local function getItemInTycoonById(itemId)
	for _, Item in PlaceholderTycoon.Items:GetChildren() do
		if Item:GetAttribute('Id') == itemId then
			return Item
		end
	end
end

local function getItem(itemId)
	for _, Item in Items:GetChildren() do
		if Item:GetAttribute('Id') == itemId then
			return Item
		end
	end
end

local function assignTycoon(player)
	for _, Tycoon in Tycoons:GetChildren() do
		if Tycoon:GetAttribute("Taken") then continue end
		Tycoon:SetAttribute("Taken", true)
		Tycoon:SetAttribute("UserId", player.UserId)
		return Tycoon
	end
end

local function getRelativeSFrame(itemId)
	local Item = getItemInTycoonById(itemId)
	
	local relativeCF = PlaceholderTycoon.PrimaryPart.CFrame:toObjectSpace(Item:GetPivot())
	return relativeCF
end

local function getTycoon(player)
	for _, tycoon in game.Workspace.Tycoons:GetChildren() do
		if tycoon:GetAttribute("UserId") == player.UserId then
			return tycoon
		end
	end
end

local function unlockItem(player, itemId)
	local tycoon = getTycoon(player)
	if not tycoon then return end
	
	local Item = getItem(itemId):Clone()
	local Cost = Item:GetAttribute('Cost')
	
	if player.leaderstats.Cash.Value < Cost then
		return false
	end
	
	player.leaderstats.Cash.Value -= Cost
	
	local RelativeCF = getRelativeSFrame(itemId) -- CF of item in tycoon relative to the Tycoon
	-- how far away from the tycoon is the item? object Space (10, 0, 2)
	
	local WorldCF =tycoon.PrimaryPart.CFrame:toWorldSpace(RelativeCF)
	
	Item:PivotTo(WorldCF)
	Item.Parent = tycoon.Items
	
	return true
end
	
for _, Button in CollectionService:GetTagged('Button') do
	Button.Touched:Connect(function(hit)
		if Button:GetAttribute('Unlocked') then return end
		
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)
		if not player then return end
		
		local tycoon = getTycoon(player)
		if not tycoon then return end
		
		if not Button:IsDescendantOf(tycoon) then return end
		
		local success = unlockItem(player, Button:GetAttribute('itemId'))
		if not success then return end
		
		Button.Transparency = 1
		Button.BillboardGui.Enable = false
		Button:SetAttribute('Unlocked', true)
	end)
end

game.Players.PlayerAdded:Connect(function(player)	
	local Tycoon = assignTycoon(player)
	if not Tycoon then warn("Could not assign tycoon to "..player.Name) return end
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local Cash = Instance.new("IntValue")
	Cash.Name = "Cash"
	Cash.Value = 50
	Cash.Parent = leaderstats
end)

20:29
