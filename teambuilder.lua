TeamBuilder = function()
    local tb = {};
    tb.init = function()
        tb.winPoints = 30; 
        tb.lossPenalties = 0;
    end
    tb.generateEnemyTeam = function(turn,wins,losses)
        local draws = turn - (wins + losses);
        tb.init();
        tb.winPoints = tb.winPoints + wins;
        tb.lossPenalties = tb.lossPenalties + losses;
        local eteam = Team();
        for i=1,turn,1 do
            tb.takeTurn(i,eteam);
        end
        tb.finalize(eteam,turn);
        return eteam;
    end
    tb.takeTurn = function(turn,team)
        local pool = tb.getPoolForTurn(turn);
        local gold = tb.getGoldForTurn(team);
        while gold > 0 do
            local shop = tb.getShop(turn,pool);
            if (team.size() < 5) and gold >= 3 then --if there's empty space, buy something random
                local randomBuy = tb.buySomethingGood(team,shop);
                team.addNewPet(randomBuy.id,1);
                team.get(1).enemy = true;
                gold = gold - 3;
            else
                local dupes = tb.shopDupes(shop,team);
                if (#dupes > 0) and gold >= 3 then --if you can upgrade something, do it
                    local randomBuy = dupes[math.random(#dupes)];
                    for i=1,5,1 do
                        local pet = team.get(i);
                        if pet.id == randomBuy.id then
                            pet.xp = pet.xp + 1;
                            if pet.xp == 2 then pet.level = 2; end
                            if pet.xp == 5 then pet.level = 3; end
                            pet.atk = pet.atk + 1;
                            pet.hp = pet.hp + 1;
                            break;
                        end
                    end
                    gold = gold - 3;
                else
                    if (math.random(5) == 5) and team.size() == 5 then
                        local weakest = tb.getWeakestThing(team);
                        team.removePet(weakest);
                        gold = gold + weakest.level;
                    else
                        --TODO: try buying something from the item shop
                        shop = tb.getShop(turn,pool);
                        gold = gold - 1;
                    end
                end
            end
        end
    end
    tb.finalize = function(team,turn) --apply win points and loss penalties
        for i=1,tb.winPoints,1 do
            tb.applyRandomBuff(team,turn);
        end
        for i=1,tb.lossPenalties,1 do
            tb.applyRandomPenalty(team,turn);
        end

        if team.hasA("feenie") then
            --distribute 2xturn count extra hp to random pets
            local amt = (turn-2)*2;
            local pets = team.getAllPets();
            for i=1,amt,1 do
                local pet = pets[math.random(#pets)];
                pet.hp = pet.hp + 1;
            end
        end
        if team.hasA("naven") then
            local estTurnsWithNaven = math.ceil((turn - 2)/2)
            local getn = team.findFirst("naven");
            getn.atk = getn.atk + estTurnsWithNaven;
            getn.hp = getn.hp + estTurnsWithNaven;
        end
        local all = team.getAllPets();
        all.forEach(function(el) 
            el.enemy = true; 
        end);
        team.faceRight = false;
        team.x = 960;
    end
    tb.applyRandomBuff = function(team,turn)
        local rand = math.random(2); --update this to be bigger as we add more variance
        if rand == 1 then
            --do nothing- sometimes you get lucky and the enemy team's a bit behind the curve
        elseif rand == 2 then --they get some exp
            local all = team.getAllPets();
            local randpet = all[math.random(#all)];
            randpet.addExp(1);
        end
    end
    tb.applyRandomPenalty = function(team,turn)
        local rand = math.random(2); --update this to be bigger as we add more variance
        if rand == 1 then
            --do nothing- sometimes you get unlucky and the enemy team's a bit ahead of the curve
        elseif rand == 2 then --they lose some exp
            local all = team.getAllPets();
            local randpet = all[math.random(#all)];
            randpet.loseExp(1);
        end
    end
    tb.buySomethingGood = function(team,shop)
        local highestTierInShop = 1;
        for i=1,#shop,1 do
            local ptemp = shop[i];
            if ptemp.tier > highestTierInShop then
                highestTierInShop = ptemp.tier;
            end
        end
        local highTierShop = shop.filter(function(x) 
            return x.tier == highestTierInShop;
        end);
        local randomBuy = highTierShop[math.random(#highTierShop)];
        return randomBuy;
    end
    tb.getWeakestThing = function(team)
        local pets = team.getAllPets();
        local weakest = pets[1];
        local lowestPower = weakest.level * weakest.tier;
        for i=2,#pets,1 do
            local p = pets[i];
            local power = p.level * p.tier;
            if power < lowestPower then
                weakest = p;
            end
        end
        return weakest;
    end
    tb.getGoldForTurn = function(team)
        local gold = 10;
        if team.hasA("ramsey") then
            local goldChange = (10*math.random(2)) - 15;
            gold = gold + goldChange;
        end
        if team.hasA("wellwatcher") or team.hasA("martin") then
            gold = gold + 1;
        end
        if team.hasA("zora") or team.hasA("naven") then
            gold = gold + 2;
        end
        return gold;
    end
    tb.shopDupes = function(shop,team)
        return shop.filter(function(opt) 
            return team.hasA(opt.id,true);
        end);
    end
    tb.getShop = function(turn,pool)
        local shopSize = 3;
        --local itemSize = 1;
        if turn > 4 then 
            shopSize = shopSize + 1;
            --itemSize = itemSize + 1; 
        end
        if turn > 8 then 
            shopSize = shopSize + 1; 
        end
        local options = Array();
        for i=1,shopSize,1 do
            options.push(pool[math.random(#pool)]);
        end
        return options;
    end
    tb.getPoolForTurn = function(stepNo)
        local maxTier = math.ceil(stepNo/2);
        if maxTier > 6 then maxTier = 6; end
        local pool = Array();
        for i=1,maxTier,1 do
            pool = pool.concat(PetTiers[i]);
        end
        pool = pool.map(function(x) return PetMap[x] end);
        return pool;
    end
    return tb;
end