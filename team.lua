Team = function()
    local team = {};
    team.x = 10;
    team.y = 230;
    team.listBackToFront = Array();
    team.faceRight = true;
    team.statsIndicator = love.graphics.newImage("img/stats.png");
    team.oddTrumpets = 0;
    team.addNewPet = function(id,pos)
        local newPet = Pet(id);
        team.addExistingPet(newPet,pos);
    end
    team.addExistingPet = function(pet,pos)
        if not pos then pos = 1; end
        if team.listBackToFront[pos] then
            if team.isFull() then
                pet.fling(pos);
            else
                team.listBackToFront.insert(pet,pos);
            end
        else
            team.listBackToFront[pos] = pet;
        end
    end
    team.removePet = function(pet)
        for i=1,5,1 do
            local petCheck = team.listBackToFront[i];
            if petCheck == pet then
                team.listBackToFront[i] = nil;
            end
        end
    end
    team.swapPets = function(pet1,pet2)
        local pet1Index = pet1.getIndex(team);
        local pet2Index = pet2.getIndex(team);
        team.listBackToFront[pet1Index] = pet2;
        team.listBackToFront[pet2Index] = pet1;
    end
    team.replacePet = function(pos,pet)
        team.listBackToFront[pos] = pet;
    end
    team.movePet = function(pet,newPos)
        local petIndex = pet.getIndex(team);
        team.listBackToFront[newPos] = pet;
        team.listBackToFront[petIndex] = nil;
    end
    team.lineUp = function(done)
        for i=4,1,-1 do
            local pet = team.listBackToFront[i];
            if pet and not team.listBackToFront[i+1] then
                team.animateShiftPetForward(pet,function() team.lineUp(done) end);
                return;
            end
        end
        done();
    end
    team.animateShiftPetForward = function(pet,done)
        --first check if it's valid;
        local pos = pet.getIndex(team);
        if pos >= 5 then
            done();
            return;
        end
        if team.listBackToFront[pos+1] then
            done();
            return;
        end
        --okay there's a free space ahead. go for it.
        asyn.doOverTime(0.15,function(percent) 
            local dist = 100 * ((not team.faceRight) and -1 or 1);
            pet.x = math.floor(percent * dist);
        end,function() 
            pet.x = 0;
            team.movePet(pet,pos+1);     
            done();   
        end)
    end
    team.isFull = function()
        for i=1,5,1 do
            if not team.listBackToFront[i] then
                return false;
            end
        end
        return true;
    end
    team.headcount = function()
        local count = 0;
        for i=1,5,1 do
            if team.listBackToFront[i] then
                count = count + 1;
            end
        end
        return count;
    end
    team.getAllPets = function()
        local all = Array();
        for i=1,5,1 do
            if team.listBackToFront[i] then
                all.push(team.listBackToFront[i]);
            end
        end
        return all;
    end
    team.update = function()
        local spacing = team.faceRight and 100 or -100
        for i=1,5,1 do
            local pet = team.listBackToFront[i];
            if pet then
                local xoff = team.x + ((i-1)*spacing);
                pet.inputUpdate(xoff,team.y);
            end
        end
    end
    team.draw = function()
        local spacing = team.faceRight and 100 or -100
        local scale = team.faceRight and 1 or -1
        for i=1,5,1 do
            local pet = team.listBackToFront[i];
            if pet then
                local xoff = team.x + ((i-1)*spacing);
                pet.draw(xoff,team.y,scale);
                --love.graphics.draw(pet.img,xoff + ((scale == -1) and 100 or 0),team.y,0,scale,1);
                --[[love.graphics.draw(team.statsIndicator,xoff + 5, team.y + 90)
                pushColor();
                love.graphics.setColor(0,0,0);
                love.graphics.print("" .. pet.atk,xoff + 24, team.y + 91);
                love.graphics.print("" .. pet.hp,xoff + 72, team.y + 89);
                popColor();
                love.graphics.print("" .. pet.atk,xoff + 22, team.y + 89);
                love.graphics.print("" .. pet.hp,xoff + 70, team.y + 87);]]--
            end
        end
        if team.oddTrumpets > 0 then
            local x = team.x + (spacing*2.5) - 101 + (team.faceRight and 0 or 101)
            love.graphics.draw(tumpet,x,team.y - 140);
            love.graphics.print(team.oddTrumpets,x+95,team.y - 114);
        end
    end
    team.get = function(slot)
        return team.listBackToFront[slot];
    end
    team.getCopy = function()
        local newTeam = Team();
        newTeam.x = team.x;
        newTeam.y = team.y;
        newTeam.faceRight = team.faceRight;
        for i=1,5,1 do
            local pet = team.listBackToFront[i];
            if pet then
                newTeam.listBackToFront[i] = pet.getCopy();
                pet.tempAtk = 0;
                pet.tempHp = 0;
            end
        end
        return newTeam;
    end
    return team;
end