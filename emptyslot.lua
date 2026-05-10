EmptySlot = function(index)
    local slot = Clickable();
    slot.img = love.graphics.newImage("img/empty.png");
    slot.pos = index;
    slot.x = 0;
    slot.y = 0;
    slot.placePet = function(pet)
        if not pet.fromShop then
            game.team.movePet(pet,slot.pos)
            pet.inputState = "IDLE";
            return true;
        end

        if pet.isFromFoodShop then
            local success = game.manager.buyFood(pet);
            if success then
                pet.frozen = false;
                game.team.addExistingPet(pet,slot.pos);
                game.itemShop.buy(pet)
                pet.fromShop = false;
                pet.isFromFoodShop = false;
                pet.inputState = "IDLE";
                return true;
            end
            return false;
        end

        local success = game.manager.buyPet(pet);
        if success then
            pet.frozen = false;
            game.team.addExistingPet(pet,slot.pos);
            game.petShop.buy(pet)
            pet.inputState = "IDLE";
            return true;
        end
        return false;
    end
    slot.onClick = function()
        if game.manager.state == "SHOP" then
            if game.manager.selectedPet then
                local pet = game.manager.selectedPet;
                if slot.placePet(pet) then
                    game.manager.clearSelection();
                end
            end
        end
    end
    slot.onDrop = function(source)
        if game.manager.state ~= "SHOP" then
            return false;
        end
        if source.dragKind ~= "pet" then
            return false;
        end
        return slot.placePet(source);
    end
    slot.draw = function()
        love.graphics.draw(slot.img,slot.x,slot.y);
    end
    return slot;
end
