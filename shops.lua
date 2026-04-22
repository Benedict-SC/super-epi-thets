PetShop = function()
    local shop = {};
    shop.contents = Array();
    shop.x = 78;
    shop.y = 420;
    shop.roll = function(tier)
        local frozen = shop.getFrozenPets();
        local slotsLeftOver = game.run.shopSlots - #frozen;
        if slotsLeftOver >= 1 then
            shop.contents = Array();
            shop.contents = shop.contents.concat(frozen);
            for i=1,slotsLeftOver,1 do
                local pickedTier = math.random(tier);
                local idsAvailable = PetTiers[pickedTier];
                local petId = idsAvailable[math.random(#idsAvailable)];
                local pet = Pet(petId);
                pet.fromShop = true;
                --pet.x = ((i-1) * 100);
                shop.contents.push(pet);
            end
        end
    end
    shop.update = function()
        for i=1,#shop.contents,1 do
            local pet = shop.contents[i];
            pet.inputUpdate(shop.x + ((i-1) * 100),shop.y);
        end
    end
    shop.draw = function()
        for i=1,#shop.contents,1 do
            local pet = shop.contents[i];
            pet.draw(shop.x + ((i-1) * 100),shop.y,1);
        end
    end
    shop.buy = function(pet)
        shop.contents.removeElement(pet);
    end
    shop.stock = function(id)
        shop.contents.push(Pet(id));
    end
    shop.getFrozenPets = function()
        local frozen = Array();
        for i=1,#shop.contents,1 do
            local pet = shop.contents[i];
            if pet.frozen then
                frozen.push(pet);
            end
        end
        return frozen;
    end

    return shop;
end

ItemShop = function()
    local shop = {};
    shop.contents = Array();
    shop.x = 780;
    shop.y = 430;
    shop.roll = function(tier)
        local frozen = shop.getFrozenFood();
        local slotsLeftOver = game.run.itemSlots - #frozen;
        if slotsLeftOver >= 1 then
            shop.contents = Array();
            shop.contents = shop.contents.concat(frozen);
            for i=1,slotsLeftOver,1 do
                local pickedTier = math.random(tier);
                local idsAvailable = FoodTiers[pickedTier];
                local foodId = idsAvailable[math.random(#idsAvailable)];
                local food = Food(foodId);
                shop.contents.push(food);
            end
        end
    end
    shop.update = function()
        for i=1,#shop.contents,1 do
            local food = shop.contents[i];
            food.inputUpdate(shop.x + ((i-1) * 100),shop.y);
        end
    end
    shop.draw = function()
        for i=1,#shop.contents,1 do
            local food = shop.contents[i];
            food.draw(shop.x + ((i-1) * 100),shop.y,1);
        end
    end
    shop.buy = function(food)
        shop.contents.removeElement(food);
    end
    shop.stock = function(id)
        shop.contents.push(Food(id));
    end
    shop.getFrozenFood = function()
        local frozen = Array();
        for i=1,#shop.contents,1 do
            local food = shop.contents[i];
            if food.frozen then
                frozen.push(food);
            end
        end
        return frozen;
    end
    shop.stockAdditionalRandomFood = function(discount)
        local pickedTier = math.random(game.run.tier);
        local idsAvailable = FoodTiers[pickedTier];
        local foodId = idsAvailable[math.random(#idsAvailable)];
        local food = Food(foodId);
        shop.contents.push(food);
    end
    return shop;
end