Battle = function(friendly,enemy)
    local battle = {};
    battle.friendly = friendly;
    battle.enemy = enemy;
    battle.begin = function()
        local preCheck = battle.checkOver();
        if preCheck == 2 then
            local enemies = battle.enemy.getAllPets();
            for i=1,#enemies,1 do --mark enemies
                enemies[i].enemy = true;
            end
            battle.beforeBattle();
        else
            battle.finish(preCheck);
        end
    end
    battle.resolveStep = function(next)
        --clear out any dead pets
        local all = battle.allPets();
        for i=1,#all,1 do
            if all[i].fainted then
                battle.removePet(all[i]);
            end
        end
        local allFriendlies = battle.friendly.getAllPets();
        if #allFriendlies == 1 and battle.friendly.oddTrumpets > 0 then
            local survivorIndex = allFriendlies[1].getIndex();
            local craigSlot = survivorIndex + 1;
            if craigSlot <= 5 then  --guard against someone being in the front somehow
                local craig = Pet("craig");
                craig.atk = battle.friendly.oddTrumpets * 2;
                craig.hp = math.ceil(battle.friendly.oddTrumpets / 2);
                battle.friendly.addExistingPet(craig,craigSlot);
                battle.friendly.oddTrumpets = 0;
            end
        end
        local allEnemies = battle.enemy.getAllPets();
        if #allEnemies == 1 and battle.enemy.oddTrumpets > 0 then
            local survivorIndex2 = allEnemies[1].getIndex();
            local craigSlot2 = survivorIndex2 + 1;
            if craigSlot2 <= 5 then  --guard against someone being in the front somehow
                local craig2 = Pet("craig");
                craig2.enemy = true;
                craig2.atk = battle.enemy.oddTrumpets * 2;
                craig2.hp = math.ceil(battle.enemy.oddTrumpets / 2);
                battle.enemy.addExistingPet(craig2,craigSlot2);
                battle.enemy.oddTrumpets = 0;
            end
        end
        battle.lineUp(next);
    end
    battle.lineUp = function(next)
        battle.friendly.lineUp(function() 
            battle.enemy.lineUp(function()
                battle.handleEmptyBackSpaceAbilities(function()
                    asyn.wait(0.12,next);
                end)
            end);
        end);
    end
    battle.handleEmptyBackSpaceAbilities = function(next)
        local teams = {game.team,game.enemyTeam};
        for i=1,#teams,1 do --just the two
            local team = teams[i];
            local emptySpaces = Array();
            for j=1,5,1 do
                if not team.get(j) then
                    emptySpaces.push(j);
                end
            end
            if #emptySpaces > 0 then
                local pets = team.getAllPets();
                table.sort(pets,function(p1,p2) 
                    return p1.atk > p2.atk;
                end);
                local claimedSpace = false;
                for j=1,#pets,1 do
                    local pet = pets[j];
                    pet.allAbilities().forEach(function(el) 
                        if el.id == "emptyBackSpace" then
                            game.abilityStack.registerAbilityTrigger(pet,"emptyBackSpace",el.func);
                            claimedSpace = true;
                        end
                    end);
                    if claimedSpace then 
                        break; 
                    end
                end
            end
        end
        game.abilityStack.startProcessing(next);
    end
    battle.removePet = function(pet)
        if pet.enemy then
            battle.enemy.removePet(pet);
        else
            battle.friendly.removePet(pet);
        end
    end
    battle.beforeBattle = function()
        --activate before battle abilities
        battle.triggerForAll("beforeBattle",nil,function()
            battle.resolveStep(function()
                battle.startBattle();
            end);
        end)
    end
    battle.startBattle = function()
        battle.triggerForAll("startOfBattle",nil,function()
            battle.resolveStep(function()
                battle.roundStart();
            end);
        end)
    end

    battle.roundStart = function()
        local frontFriendly = battle.friendly.get(5);
        local frontEnemy = battle.enemy.get(5);
        local actions = Array();

        if frontFriendly.atk >= frontEnemy.atk then
            frontEnemy.allAbilities().forEach(function(el) 
                if el.id == "beforeAttack" then
                    game.abilityStack.registerAbilityTrigger(frontEnemy,"beforeAttack",el.func,frontFriendly);
                end
            end)
            frontFriendly.allAbilities().forEach(function(el) 
                if el.id == "beforeAttack" then
                    game.abilityStack.registerAbilityTrigger(frontFriendly,"beforeAttack",el.func,frontEnemy);
                end
            end)
        else
            frontFriendly.allAbilities().forEach(function(el) 
                if el.id == "beforeAttack" then
                    game.abilityStack.registerAbilityTrigger(frontFriendly,"beforeAttack",el.func,frontEnemy);
                end
            end)
            frontEnemy.allAbilities().forEach(function(el) 
                if el.id == "beforeAttack" then
                    game.abilityStack.registerAbilityTrigger(frontEnemy,"beforeAttack",el.func,frontFriendly);
                end
            end)
        end
        game.abilityStack.startProcessing(function()
            battle.processFainting(function() 
                battle.resolveStep(function() 
                    if frontFriendly.fainted or frontEnemy.fainted then
                        battle.roundEnd() 
                    else
                        battle.attack() 
                    end
                end); 
            end);
        end)
    end

    battle.attack = function()
        local dist = 40;
        local frontFriendly = battle.friendly.get(5);
        local frontEnemy = battle.enemy.get(5);
        if (not frontFriendly) or (not frontEnemy) then
            battle.processFainting(function() 
                battle.resolveStep(function() 
                    battle.roundEnd();
                end); 
            end);
            return;
        end
        --play a fight animation and then
        asyn.doOverTime(0.3,function(percent) 
            frontFriendly.x = dist*percent;
            frontEnemy.x = -1*dist*percent;
        end,function() 
            local fdmg = frontFriendly.atk + frontFriendly.perk.damageMod;
            if frontFriendly.perk.id == "lavacid" then
                local crit = math.random(13) == 13;
                if crit then fdmg = fdmg * 13; end
            end
            fdmg = fdmg - frontEnemy.defense(); 
            local edmg = frontEnemy.atk + frontEnemy.perk.damageMod;
            if frontEnemy.perk.id == "lavacid" then
                local crit = math.random(13) == 13;
                if crit then edmg = edmg * 13; end
            end
            edmg = edmg - frontFriendly.defense(); 
            if fdmg < 0 then fdmg = 0; end
            if edmg < 0 then edmg = 0; end
            frontFriendly.hp = frontFriendly.hp - edmg;
            frontEnemy.hp = frontEnemy.hp - fdmg;
            if frontFriendly.perk.id == "peanutbutter" and (not frontFriendly.isMollywhopped()) and fdmg > 0 then
                frontEnemy.hp = 0;
            end
            if frontEnemy.perk.id == "peanutbutter" and (not frontEnemy.isMollywhopped()) and edmg > 0 then
                frontFriendly.hp = 0;
            end
            if frontFriendly.perk.id == "pepper" and (not frontFriendly.isMollywhopped()) and frontFriendly.hp < 1 then
                frontFriendly.hp = 1;
            end
            if frontEnemy.perk.id == "pepper" and (not frontEnemy.isMollywhopped()) and frontEnemy.hp < 1 then
                frontEnemy.hp = 1;
            end
            sound.randomSmack();
            asyn.doOverTime(0.3,function(percent)
                frontFriendly.x = dist - (dist*percent);
                frontEnemy.x = (-1*dist) + (dist*percent);
            end,function() 
                frontFriendly.x = 0;
                frontEnemy.x = 0;
                local proceed = function()
                    battle.processFainting(function() 
                        battle.resolveStep(function() 
                            battle.roundEnd() 
                        end); 
                    end);
                end
                --trigger post-attack abilities
                battle.triggerForAll("anyoneAttacked",nil,nil,true)
                battle.triggerForTeammates(frontFriendly,"friendAttacks",frontFriendly,nil,true);
                battle.triggerForTeammates(frontEnemy,"friendAttacks",frontEnemy,nil,true);
                battle.triggerForCombatants({ff=frontFriendly,fe=frontEnemy},"afterAttack",nil,nil,true);
                --trigger hurt abilities if relevant
                if edmg == 0 and fdmg == 0 then
                    game.abilityStack.startProcessing(proceed);
                elseif edmg == 0 then
                    frontEnemy.triggerOne("hurt",{source=frontFriendly,dmg=fdmg},nil,true)
                    battle.triggerForTeammates(frontEnemy,"friendHurt",{friend=frontEnemy,source=frontFriendly},proceed);
                elseif fdmg == 0 then
                    frontFriendly.triggerOne("hurt",{source=frontEnemy,dmg=edmg},nil,true)
                    battle.triggerForTeammates(frontFriendly,"friendHurt",{friend=frontFriendly,source=frontEnemy},proceed);
                else
                    frontEnemy.triggerOne("hurt",{source=frontFriendly,dmg=fdmg},nil,true)
                    frontFriendly.triggerOne("hurt",{source=frontEnemy,dmg=edmg},nil,true)
                    battle.triggerForTeammates(frontFriendly,"friendHurt",{friend=frontFriendly,source=frontEnemy},nil,true);
                    battle.triggerForTeammates(frontEnemy,"friendHurt",{friend=frontEnemy,source=frontFriendly},proceed);
                end
            end);
        end);
    end
    battle.dealDirectDamage = function(amount,source,target,done,defer) 
        local totalDamage = amount - target.defense();
        if totalDamage < 0 then totalDamage = 0; end
        local projectileImage = love.graphics.newImage(source.projectileUrl);
        local origin = source.screenCenter();
        origin.x = origin.x + 20;
        local projectile = {img=projectileImage,x=origin.x,y=origin.y};
        battle.extras.push(projectile);
        local destination = target.screenCenter();
        destination.x = destination.x + 20;
        asyn.doOverTime(0.6,function(percent) 
            local dx = destination.x - origin.x;
            local dy = destination.y - origin.y;
            local arcHeight = 120;
            projectile.x = origin.x + (dx * percent);
            projectile.y = origin.y + (dy * percent) - (4 * arcHeight * percent * (1 - percent));
        end,function() 
            battle.extras.removeElement(projectile);
            target.hp = target.hp - totalDamage;
            if target.perk.id == "pepper" and (not target.isMollywhopped()) then
                if target.hp <= 0 then
                    target.hp = 1;
                end
                target.losePerk();
            elseif ((target.perk.id == "melon") or (target.perk.id == "coconut") or (target.perk.id == "ambrosia")) and (not target.isMollywhopped()) then
                target.losePerk();
            end
            if totalDamage == 0 then
                done();
            else 
                target.triggerOne("hurt",{source=source,dmg=totalDamage},nil,true);
                if not defer then
                    battle.triggerForTeammates(target,"friendHurt",{friend=target,source=source},done)
                else
                    battle.triggerForTeammates(target,"friendHurt",{friend=target,source=source},nil,true)
                    done();
                end
            end
        end);
    end
    battle.processFainting = function(done)
        local all = battle.allPets();
        for i=1,#all,1 do
            if (all[i].hp <= 0) and (not all[i].fainted) then
                local fainter = all[i];
                fainter.fainted = true;
                fainter.allAbilities().forEach(function(el)
                    if el.id == "faint" then
                        game.abilityStack.registerAbilityTrigger(fainter,"faint",el.func);
                    end
                end);
                local teammates = fainter.getTeammates();
                teammates.forEach(function(tm) 
                    tm.allAbilities().forEach(function(el) 
                        if el.id == "friendFaints" then
                            game.abilityStack.registerAbilityTrigger(tm,"friendFaints",el.func,fainter);
                        end
                    end);
                end);
            end
        end
        game.abilityStack.startProcessing(done);
    end
    battle.roundEnd = function()

        local check = battle.checkOver();
        if check == 2 then
            battle.resolveStep(function() battle.roundStart() end);
        else
            battle.finish(check);
        end
    end
    battle.finish = function(won)
        asyn.doOverTime(0.8,function(percent) 
            game.fadeAlpha = percent;
        end,function() 
            --replace teams with original teams;
            game.team = game.savedTeam;
            for i=1,5,1 do
                if game.team.get(i) then
                    game.team.get(i).battlesFought = game.team.get(i).battlesFought + 1;
                end
            end
            game.enemyTeam = game.savedEnemyTeam;
            if won == 1 then
                game.run.wins = game.run.wins + 1;
            elseif won == -1 then
                game.run.lives = game.run.lives - 1;
            end
            game.run.newTurn();
            game.petShop.roll(game.run.tier);
            game.itemShop.roll(game.run.tier);
            --hide UI
            game.manager.hideUI = false;
            game.manager.state = "ANIMATE";
            game.manager.battle = nil;
            --fade back in
            asyn.doOverTime(0.8,function(percent) 
                game.fadeAlpha = 1-percent;
            end,function() 
                game.fadeAlpha = 0;
                game.manager.state = "START";
                game.manager.startTurn();
            end);
        end)
    end

    battle.checkOver = function() --1 win, 0 draw, -1 enemy, 2 not over yet
        local fdead = battle.friendly.headcount() == 0;
        local edead = battle.enemy.headcount() == 0;
        if fdead and edead then 
            return 0;
        elseif fdead then
            return -1;
        elseif edead then
            return 1;
        else
            return 2;
        end

    end
    battle.allPets = function()
        local frien = battle.friendly.getAllPets();
        local enem = battle.enemy.getAllPets();
        local all = frien.concat(enem);
        table.sort(all,function(p1,p2) 
            return p1.atk > p2.atk;
        end);
        return all;
    end
    battle.triggerForAll = function(triggerType,args,done,defer)
        local all = battle.allPets();
        local actions = Array();
        for i=#all,1,-1 do
            local pet = all[i];
            pet.allAbilities().forEach(function(el) 
                if el.id == triggerType then
                    game.abilityStack.registerAbilityTrigger(pet,triggerType,el.func,args);
                end
            end);
        end
        if not defer then
            game.abilityStack.startProcessing(done);
        end
    end
    battle.triggerForTeammates = function(pet,triggerType,args,done,defer)
        local all = pet.getTeammates();
        local actions = Array();
        for i=#all,1,-1 do
            local pet = all[i];
            pet.allAbilities().forEach(function(el) 
                if el.id == triggerType then
                    game.abilityStack.registerAbilityTrigger(pet,triggerType,el.func,args);
                end
            end);
        end
        if not defer then
            game.abilityStack.startProcessing(done);
        end
    end
    battle.triggerForCombatants = function(combatants,triggerType,args,done,defer)
        if not combatants then combatants = {}; end
        local frontFriendly = combatants.ff or battle.friendly.get(5);
        local frontEnemy = combatants.fe or battle.enemy.get(5);
        if frontFriendly.atk >= frontEnemy.atk then
            frontEnemy.allAbilities().forEach(function(el) 
                if el.id == triggerType then
                    game.abilityStack.registerAbilityTrigger(frontEnemy,triggerType,el.func,frontFriendly);
                end
            end)
            frontFriendly.allAbilities().forEach(function(el) 
                if el.id == triggerType then
                    game.abilityStack.registerAbilityTrigger(frontFriendly,triggerType,el.func,frontEnemy);
                end
            end)
        else
            frontFriendly.allAbilities().forEach(function(el) 
                if el.id == triggerType then
                    game.abilityStack.registerAbilityTrigger(frontFriendly,triggerType,el.func,frontEnemy);
                end
            end)
            frontEnemy.allAbilities().forEach(function(el) 
                if el.id == triggerType then
                    game.abilityStack.registerAbilityTrigger(frontEnemy,triggerType,el.func,frontFriendly);
                end
            end)
        end
        if not defer then
            game.abilityStack.startProcessing(done);
        end
    end
    battle.extras = Array();
    battle.draw = function()
        for i=1,#battle.extras,1 do
            local extra = battle.extras[i];
            if not extra then break; end
            love.graphics.draw(extra.img,extra.x,extra.y);
        end
    end

    return battle;
end
