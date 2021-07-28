
rdg_MultiShop = Mod:init()
rdg_MultiShop.Items ={}
rdg_MultiShop.Shops = {}
rdg_MultiShop.ActiveShop=-1

function rdg_MultiShop:loadMap(savegame)
	self.debugMode = true
	self:printDebug("loadMap Entered")
	self:init()
	

end


function rdg_MultiShop:init()
	self.debugMode = true
	self.printDebug ("Init Entered version 2")
	
	
	self:cloneStoreItemList()
	-- self:removeItems()
	self:LoadShops()
	
	--self:rdg_DebugOutputStuff()
	--local list = self:CreateItemList("Category", "CARS")
	
	--local list = self:CreateItemList("Brand", "Lizard")
	--self:AddItems(list)
	--printCallstack()
end

function rdg_MultiShop:rdg_DebugOutputStuff()
	DebugUtil.printTableRecursively(g_currentMission.shopMenu.shopController.displayVehicleCategories,".",0,1) --Go as deep as possible into g_currentMission to find if there's any Shop/Store stuff like "Update/Refresh"
end

function rdg_MultiShop:cloneStoreItemList()

	for _, item in pairs(g_storeManager:getItems()) do
		table.insert(rdg_MultiShop.Items, item)
    end

	--rdg_MultiShop.Items = g_storeManager:getItems()

end

function rdg_MultiShop:LoadShops()

--table.insert(rdg_MultiShop.Shops,{2752, "Brand", "Lizard"})
--table.insert(rdg_MultiShop.Shops,{38761, "Brand", "Lizard"})
table.insert(rdg_MultiShop.Shops,{"Shop 1", "Category", "CARS"})
table.insert(rdg_MultiShop.Shops,{"Shop 2", "Brand", "Lizard"})



end

function rdg_MultiShop:removeItems()
	self:printDebug("Removing Items")
	-- switched g_storeManager to g_currentMission.shopMenu.storeManager.
	local numIndex = table.getn(g_currentMission.shopMenu.storeManager:getItems())
	self:printDebug("Number of Items (g_storeManager) = "..numIndex )
	
	numIndex = table.getn(rdg_MultiShop.Items)
	self:printDebug("Number of Items (MultiShop) = "..numIndex )

	for _, item in pairs(g_currentMission.shopMenu.storeManager.items) do
		g_currentMission.shopMenu.storeManager.items[_] = nil
    end

	numIndex = table.getn(g_currentMission.shopMenu.storeManager:getItems())
	self:printDebug("Number of Items (g_storeManager) = "..numIndex )

end

function rdg_MultiShop:CreateItemList(itemType, itemTypeName)
--itemTypes = "Category", "Brand", "Species"
-- usage = rdg_MultiShop:CreateItemList("Category","Cars") --> Add the car category to the shop
--         rdg_MultiShop:CreateItemList("Brand","John Deere")  --> Add the JD Brand to the shop
--         rdg_MultiShop:CreateItemList("Species","Placeables")  --> Add PLaceables
--         rdg_MultiShop:CreateItemList("Specific",{1,2,3,4})  --> Add specific Item numbers (Might be better with names, IDs will change?)
-- Return Type - IDs of relevant lines in the StoreItemCopy table to be added.
	local brandID = 0
	if itemType=="Brand" then
		brandID = g_brandManager:getBrandIndexByName(itemTypeName)
	end
	
	local itemIDs = {}
	self:printDebug("Creating id List")
	local numIndex = table.getn(rdg_MultiShop.Items)
	--self:printDebug("Number of Items (MultiShop) = "..numIndex )
	for itemid = 1, numIndex do
		local item = rdg_MultiShop.Items[itemid]
		--self:printDebug("Item being checked = "..item.id.." "..item.name)
		if itemType=="Category" then 
			if item.categoryName==itemTypeName then
				--self:printDebug("Item being added to list = "..item.id.." "..item.name)
				table.insert(itemIDs, item.id)
			end
		elseif itemType=="Brand" then
			if item.brandIndex==brandID then
				--self:printDebug("Item being added to list = "..item.id.." "..item.name)
				table.insert(itemIDs, item.id)
			end
		elseif itemType=="Species" then
			if item.species==itemTypeName then
				--self:printDebug("Item being added to list = "..item.id.." "..item.name)
				table.insert(itemIDs, item.id)
			end
		elseif itemType=="Specific" then
			for id=1, #itemTypeName do
				if item.id ==itemTypeName[id] then
					--self:printDebug("Item being added to list = "..item.id.." "..item.name)
					table.insert(itemIDs, item.id)
				end
			end
		end
    end



	return itemIDs


end

function rdg_MultiShop:AddItems(itemIDs)

	self:printDebug("Attempting to add Items to list")
	for k,v in pairs(itemIDs) do
		
		local item = rdg_MultiShop.Items[v]
		--self:printDebug("Item being added to list = "..item.id.." "..item.name)
		
		--table.insert(g_storeManager.items, item)
		table.insert(g_currentMission.shopMenu.storeManager.items, item)
		
		local numIndex = table.getn(g_currentMission.shopMenu.storeManager:getItems())
		self:printDebug("Number of Items (g_storeManager) = "..numIndex )		
		item.id = numIndex
	end

end

-- function rdg_MultiShop:AddItems(itemIDs)

	-- self:printDebug("Attempting to add Items to list")
	-- for k,v in pairs(itemIDs) do
		
		-- local item = rdg_MultiShop.Items[v]
		

		-- --self:printDebug("Item being added to list = "..item.id.." "..item.name)
		
		-- g_currentMission.shopMenu.storeManager:addItem(item)
		
		-- local numIndex = table.getn(g_currentMission.shopMenu.storeManager:getItems())
		-- self:printDebug("Number of Items (g_storeManager) = "..numIndex )		
		-- item.id = numIndex
	-- end

-- end


function rdg_MultiShop:GetWhichShop()
	
	local playerPosX, playerPosY, playerPosZ = rdg_MultiShop:GetPlayerPos()
	
	for shopIndex=1, #rdg_MultiShop.Shops do
		local shop = rdg_MultiShop.Shops[shopIndex]
		local shopNode = rdg_MultiShop:findNodeByName(getRootNode(),shop[1])
		local shopPosX, shopPosY, shopPosZ = getWorldTranslation(shopNode)
		local distance = math.sqrt(math.pow((playerPosX - shopPosX), 2) + math.pow((playerPosZ - shopPosZ), 2))
		
			if distance<=10 then
				--self:printDebug("Shop within 10")
				return shopIndex
			end	
	end
	--self:printDebug("No Shop within 10")
	return 0

end

function rdg_MultiShop:GetPlayerPos()
--Ripped from Stockman
--Returns XYZ position of player, or player driven vehicle

	if g_currentMission.controlledVehicle ~= nil then
		if g_currentMission.controlledVehicle.steeringAxleNode ~= nil then
			return getWorldTranslation(g_currentMission.controlledVehicle.steeringAxleNode)
		end
	else
		return g_currentMission.player:getPositionData()
	end
end

function rdg_MultiShop:update(dt)
	local shopIndex = self:GetWhichShop()
	g_currentMission:addExtraPrintText("You are near Shop "..shopIndex)
	if rdg_MultiShop.ActiveShop~=shopIndex then
		self:SetShop(shopIndex)
	end 
end

function rdg_MultiShop:findNodeByName(nodeId, name)
if getName(nodeId) == name then
	return nodeId;
end
	for i=0, getNumOfChildren(nodeId)-1 do
		local tmp = rdg_MultiShop:findNodeByName(getChildAt(nodeId, i), name);
		if tmp ~= nil then
			return tmp
		end;
	end;
return nil;
end;


function rdg_MultiShop:SetShop(ShopId)
	rdg_MultiShop.ActiveShop = ShopId
	self:removeItems()
	if ShopId~=0 then 
		local shop = rdg_MultiShop.Shops[ShopId]
		local itemType = shop[2]
		local itemTypeName = shop[3]
		local list = self:CreateItemList(itemType, itemTypeName)
		self:AddItems(list)
		--DebugUtil.printTableRecursively(g_currentMission.shopMenu.shopController.displayVehicleCategories,".",0,1)
	end
end

--Possible alternative using the node structure

-- function rdg_MultiShop:indexToNode(rootNode, indexString)
    -- local node = rootNode or getRootNode()
    -- local childIndexs = StringUtil.splitString("|", indexString)

    -- for i = 1, #childIndexs do
        -- local index = tonumber(childIndexs[i])
        -- if getNumOfChildren(node) >= index then
            -- node = getChildAt(node, index)
        -- else
            -- break
        -- end
    -- end

    -- return node
-- end

