EmptySlot = function(index)
    local slot = Clickable();
    slot.img = love.graphics.newImage("img/empty.png");
    slot.pos = index;
    slot.x = 0;
    slot.y = 0;
    slot.onMouseUp = function()
        if game.manager.state == "SHOP" then
            if game.manager.draggingPet then
                local pet = game.manager.draggingPet;
                if not pet.fromShop then
                    game.team.movePet(pet,slot.pos)
                    pet.inputState = "IDLE";
                else
                    local success = game.manager.buyPet(pet);
                    if (success) then
                        pet.frozen = false;
                        game.team.addExistingPet(pet,slot.pos);
                        game.petShop.buy(pet)
                        pet.inputState = "IDLE";
                    end
                end
                game.manager.cleanupDrag();
            elseif game.manager.selectedPet then
                local pet = game.manager.selectedPet;
                if not pet.fromShop then
                    game.team.addExistingPet(pet,slot.pos)
                    pet.inputState = "IDLE";
                else
                    local success = game.manager.buyPet(pet);
                    if (success) then
                        pet.frozen = false;
                        game.team.addExistingPet(pet,slot.pos);
                        game.petShop.buy(pet)
                        pet.inputState = "IDLE";
                    end
                end
                game.manager.clearSelection();
            end
        end
    end
    slot.draw = function()
        love.graphics.draw(slot.img,slot.x,slot.y);
    end
    return slot;
end