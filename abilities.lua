giveAbilitiesToPet = function(pet,copying)
    pet.startOfTurn = function(done) done(); end
    pet.endOfTurn = function(done) done(); end
    pet.summoned = function(done) done(); end
    pet.sell = function(done) done(); end
    pet.friendSold = function(done,friend) done(); end
    pet.startOfBattle = function(done) done(); end
    pet.beforeBattle = function(done) done(); end
    pet.beforeAttack = function(done,opponent) done(); end
    pet.hurt = function(done,sourceAndAmount) done(); end
    pet.friendHurt = function(done,friendAndSource) done(); end
    pet.afterAttack = function(done,opponent) done(); end
    pet.faint = function(done) done(); end
    pet.friendFaints = function(done,friend) done(); end
    pet.gainedAilment = function(done,ailment) done(); end
    pet.friendGainedAilment = function(done,friend) done(); end
    pet.opponentGainedAilment = function(done,opponent) done(); end
    pet.spentGoldPastTen = function(done,gold) done(); end
    pet.randomThingHappens = function(done) done(); end
    pet.emptyBackSpace = function(done) done(); end
    pet.friendAteFood = function(done,food) done(); end
    pet.ateFood = function(done,tier) done(); end
    pet.boughtFood = function(done,food) done(); end
    pet.fedToFriend = function(done,friend) done(); end
    pet.friendAttacks = function(done,friend) done(); end
    pet.somethingFlewOverhead = function(done) done(); end
    pet.anyoneAttacked = function(done) done(); end
    pet.abilities = Array();
    pet.abilityText = {
        pet.name .. " isn't implemented yet.",
        pet.name .. " isn't implemented yet.",
        pet.name .. " isn't implemented yet."
    }

    if pet.id == "ben" then
        pet.beforeBattle = function(done)
            local leavesAtOrBelow = 4-pet.level;
            if math.random(6) <= leavesAtOrBelow then
                asyn.doOverTime(0.4,function(percent) 
                    pet.fade = percent;
                end,function() 
                    if pet.enemy then
                        game.enemyTeam.removePet(pet);
                    else
                        game.team.removePet(pet);
                    end
                    game.manager.triggerRandom();
                    done();
                end);
            else
                game.manager.triggerRandom();
                done();
            end
        end
        pet.abilityText = {
            "Before battle: Randomly leaves (1/2 chance).",
            "Before battle: Randomly leaves (1/3 chance).",
            "Before battle: Randomly leaves (1/6 chance)."
        }
        pet.abilities = ArrayFromRawArray({{id="beforeBattle",func = pet.beforeBattle}});
    elseif pet.id == "crapgorps" then
        pet.startOfBattle = function(done)
            local extraHealth = pet.battlesFought;
            if pet.level == 1 then
                extraHealth = math.floor(extraHealth / 2);
            elseif pet.level == 3 then
                extraHealth = extraHealth * 2;
            end
            if extraHealth > 0 then
                game.manager.animateThrow(pet,pet,"img/heart.png",function()
                    pet.hp = pet.hp + extraHealth;
                    done();
                end)
            else
                done();
            end
        end
        pet.abilityText = {
            "Start of battle: Gain 1 health for each 2 battles fought.",
            "Start of battle: Gain 1 health for each battle fought.",
            "Start of battle: Gain 2 health for each battle fought."
        }
        pet.abilities = ArrayFromRawArray({{id="startOfBattle",func = pet.startOfBattle}});
    elseif pet.id == "giovanni" then
        pet.startOfTurn = function(done)
            local types1 = ArrayFromRawArray({"waterysoup","toohot"});
            --local types2 = ArrayFromRawArray({"spellemup","oftheday"});
            --local types3 = ArrayFromRawArray({"cocoasoup","lavacid"});
            local types = types1;
            --[[if pet.level > 1 then
                types = types.concat(types2);
            end
            if pet.level > 2 then
                types = types.concat(types3);
            end]]--
            local soupType = types[math.random(#types)];

            asyn.wait(0.2,function() 
                game.itemShop.stock(soupType,true);
                --game.manager.triggerRandom();
                done();
            end)
        end
        pet.abilityText = {
            "Start of turn: Stock a Random soup up to tier 2.",
            "Start of turn: Stock a Random soup up to tier 4.",
            "Start of turn: Stock a Random soup up to tier 6."
        }
        pet.abilities = ArrayFromRawArray({{id="startOfTurn",func = pet.startOfTurn}})
    elseif pet.id == "flamethrower" then
        pet.projectileUrl = "img/perk/toasty.png";
        pet.beforeAttack = function(done,opponent)
            local sequentialToasts = Array();
            local toasty1 = ToastyAilment();
            local toast1Func = function(next)
                game.manager.animateThrow(pet,opponent,nil,function()
                    opponent.gainPerk(toasty1,next);
                end)
            end
            sequentialToasts.push(toast1Func);
            if pet.level > 1 then
                local opp2 = pet.getXthOpponentAhead(2);
                if opp2 then
                    local toasty2 = ToastyAilment();
                    local toast2Func = function(next)
                        game.manager.animateThrow(pet,opp2,nil,function()
                            opp2.gainPerk(toasty2,next);
                        end)
                    end
                    sequentialToasts.push(toast2Func)
                end
            end
            if pet.level > 2 then
                local opp3 = pet.getXthOpponentAhead(3);
                if opp3 then
                    local toasty3 = ToastyAilment();
                    local toast3Func = function(next)
                        game.manager.animateThrow(pet,opp3,nil,function()
                            opp3.gainPerk(toasty3,next);
                        end)
                    end
                    sequentialToasts.push(toast3Func)
                end
            end
            asyn.runSerial(sequentialToasts,done);
        end
        pet.abilityText = {
            "Before attack: Give Toasty to the first enemy ahead.",
            "Before attack: Give Toasty to the first two enemies ahead.",
            "Before attack: Give Toasty to the first three enemies ahead."
        }
        pet.abilities = ArrayFromRawArray({{id="beforeAttack",func = pet.beforeAttack}})
    elseif pet.id == "martin" then
        pet.friendGainedAilment = function(done,friend)
            if not pet.enemy then
                game.run.extraGoldNextTurn = game.run.extraGoldNextTurn + pet.level;
            end
            local pos = pet.screenCenter();
            local coin = {img=love.graphics.newImage("img/coin.png"),x=pos.x+50,y=pos.y};
            game.manager.extras.push(coin);
            asyn.doOverTime(0.4,function(percent) 
                coin.y = math.floor(pos.y - (percent*60));
            end,function() 
                asyn.wait(0.2,function() 
                    game.manager.extras.removeElement(coin);
                    done();
                end)
            end)
        end
        pet.abilityText = {
            "Friend gained ailment: Gain 1 gold next turn.",
            "Friend gained ailment: Gain 2 gold next turn.",
            "Friend gained ailment: Gain 3 gold next turn.",
        }
        pet.abilities = ArrayFromRawArray({{id="friendGainedAilment",func = pet.friendGainedAilment}})
    elseif pet.id == "gansley" then
        pet.projectileUrl = "img/gansleybuck.png";
        pet.beforeAttack = function(done,opponent)
            local max = 3;
            if pet.level == 2 then
                max = 8;
            elseif pet.level == 3 then
                max = 20;
            end
            local damageAmount = math.random(max);
            local coinflip = math.random(2);
            local target = opponent;
            if coinflip == 1 then
                target = pet;
                sound.play("danuhoh");
            else
                sound.play("danha");
            end
            game.manager.triggerRandom();
            game.manager.battle.dealDirectDamage(damageAmount,pet,target,done);
        end
        pet.abilityText = {
            "Before attack: Deal between 1 and 3 damage to self or enemy ahead, Randomly.",
            "Before attack: Deal between 1 and 8 damage to self or enemy ahead, Randomly.",
            "Before attack: Deal between 1 and 20 damage to self or enemy ahead, Randomly."
        }
        pet.abilities = ArrayFromRawArray({{id="beforeAttack",func=pet.beforeAttack}})
    elseif pet.id == "wellwatcher" then
        pet.startOfBattle = function(done)
            pet.fainted = true;
            sound.play("wellwatch");
            if not pet.enemy then
                game.run.extraGoldNextTurn = game.run.extraGoldNextTurn + pet.level;
            end
            asyn.wait(0.6,function() 
                if pet.perk.faint then
                    pet.perk.faint(function()
                        pet.faint(done);
                    end)
                else
                    pet.faint(done)
                end
            end);
        end
        pet.faint = function(done)
            if not pet.alreadyDied then
                newWatcher = pet.getCopy();
                newWatcher.projectileUrl = "img/lightning.png";
                newWatcher.img = love.graphics.newImage("img/char/wellwatcher2.png");
                newWatcher.abilityText = {
                    "Looks like there's an open spot for Well Watcher...",
                    "Looks like there's an open spot for Well Watcher...",
                    "Looks like there's an open spot for Well Watcher..."
                }
                asyn.wait(0.5,function() 
                    sound.play("thunder");
                end);
                newWatcher.alreadyDied = true;
                newWatcher.summoned = function(newdone)
                    local dmg = pet.level == 3 and 10 or (pet.level == 2 and 6 or 3);
                    game.manager.battle.dealDirectDamage(dmg,newWatcher,newWatcher,newdone);
                end
                newWatcher.hurt = function(newdone,sourceAndAmount)
                    if sourceAndAmount.source == newWatcher then
                        newWatcher.transform("skywatcher");
                        asyn.wait(0.4,newdone);
                    else
                        newdone();
                    end
                end
                newWatcher.abilities = ArrayFromRawArray({{id="summoned",func = newWatcher.summoned},{id="hurt",func = newWatcher.hurt}})
                local spot = pet.getIndex();
                local team = pet.getTeam();
                team.replacePet(spot,newWatcher);
                newWatcher.summoned(done);
            end
        end
        pet.abilityText = {
            "Start of battle: Gain 1 gold, faint, and summon a copy which takes 3 damage and turns into Sky Watcher.",
            "Start of battle: Gain 2 gold, faint, and summon a copy which takes 6 damage and turns into Sky Watcher.",
            "Start of battle: Gain 3 gold, faint, and summon a copy which takes 10 damage and turns into Sky Watcher."
        };
        pet.abilities = ArrayFromRawArray({{id="startOfBattle",func = pet.startOfBattle}})
    elseif pet.id == "skywatcher" then
        pet.somethingFlewOverhead = function(done)
            pet.atk = pet.atk + pet.level;
            pet.hp = pet.hp + pet.level;
            done();
        end
        pet.abilityText = {
            "Something flew overhead: Gain 1 attack and HP.",
            "Something flew overhead: Gain 2 attack and HP.",
            "Something flew overhead: Gain 3 attack and HP."
        }
        pet.abilities = ArrayFromRawArray({{id="somethingFlewOverhead",func = pet.somethingFlewOverhead}})
    elseif pet.id == "gorou" then
        pet.sell = function(done)
            game.itemShop.stock("donutgun" .. pet.level,true);
            done();
        end
        pet.abilityText = {
            "Sell: Stock one Donut Gun.",
            "Sell: Stock one Donut Gun with double effect.",
            "Sell: Stock one Donut Gun with triple effect."
        }
        pet.abilities = ArrayFromRawArray({{id="sell",func = pet.sell}})
    elseif pet.id == "molly" then
        pet.abilityText = {
            "Molly can't receive perks or ailments. Existing perks and ailments have no effect.",
            "Molly and adjacent pets can't receive perks/ailments. Existing perks and ailments have no effect.",
            "Molly and pets within two spaces can't receive perks/ailments. Existing perks and ailments have no effect."
        }
    elseif pet.id == "simphony" then
        pet.friendFaints = function(done,friend)
            pet.hp = pet.hp + 1 + ((pet.level-1)*2);
            done();
        end
        pet.abilityText = {
            "Friend faints: Gain 1 HP.",
            "Friend faints: Gain 3 HP.",
            "Friend faints: Gain 5 HP."
        }
        pet.abilities = ArrayFromRawArray({{id="friendFaints",func = pet.friendFaints}})
    elseif pet.id == "spike" then
        pet.hurt = function(done,sourceAndAmount)
            local amount = 1;
            if pet.level > 1 then
                amount = amount + 2;
            end
            if pet.level > 2 then
                amount = amount + 3;
            end
            game.manager.battle.dealDirectDamage(amount,pet,sourceAndAmount.source,done);
        end
        pet.abilityText = {
            "Hurt: Deal 1 damage to attacker.",
            "Hurt: Deal 3 damage to attacker.",
            "Hurt: Deal 6 damage to attacker."
        }
        pet.abilities = ArrayFromRawArray({{id="hurt",func=pet.hurt}});
    elseif pet.id == "feenie" then
        pet.spentGoldPastTen = function(done,gold)
            local teammates = pet.getTeam().getAllPets();
            teammates.removeElement(pet);
            local randomTeammate = teammates[math.random(#teammates)];
            randomTeammate.hp = randomTeammate.hp + (gold*pet.level);
            done();
        end
        pet.abilityText = {
            "Spent gold past 10: Give that much health to a random teammate.",
            "Spent gold past 10: Give twice that much health to a random teammate.",
            "Spent gold past 10: Give three times that much health to a random teammate."
        }
        pet.abilities = ArrayFromRawArray({{id="spentGoldPastTen",func=pet.spentGoldPastTen}});
    elseif pet.id == "bugsy" then
        pet.ateFood = function(done,tier)
            pet.tempAtk = pet.tempAtk + (pet.level * tier);
            done();
        end
        pet.abilityText = {
            "Ate food: Gain attack equal to its tier until next turn.",
            "Ate food: Gain attack equal to twice its tier until next turn.",
            "Ate food: Gain attack equal to three times its tier until next turn."
        }
        pet.abilities = ArrayFromRawArray({{id="ateFood",func=pet.ateFood}});
    elseif pet.id == "gacha" then
        pet.friendSold = function(done,friend) 
            pet.atk = pet.atk + pet.level;
            pet.hp = pet.hp + pet.level;
            done();
        end
        pet.abilityText = {
            "Friend sold: Gain 1 attack and 1 health.",
            "Friend sold: Gain 2 attack and 2 health.",
            "Friend sold: Gain 3 attack and 3 health."
        }
        pet.abilities = ArrayFromRawArray({{id="friendSold",func=pet.friendSold}});
    elseif pet.id == "darkstar" then
        pet.faint = function(done)
            local rn = math.random(6);
            if pet.level == 1 then
                if rn == 6 then
                    local newStar = Pet("darkstar");
                    local spot = pet.getIndex();
                    local team = pet.getTeam();
                    team.replacePet(spot,newStar);
                end
            elseif pet.level == 2 then
                if rn >= 5 then
                    local newStar = Pet("darkstar");
                    newStar.atk = 6;
                    newStar.hp = 3;
                    local spot = pet.getIndex();
                    local team = pet.getTeam();
                    team.replacePet(spot,newStar);
                end
            else --pet.level == 3
                if rn >= 4 then
                    local newStar = Pet("darkstar");
                    newStar.atk = 9;
                    newStar.hp = 6;
                    newStar.xp = 2;
                    newStar.level = 2;
                    local spot = pet.getIndex();
                    local team = pet.getTeam();
                    team.replacePet(spot,newStar);
                end
            end
            game.manager.triggerRandom();
            done();
        end
        pet.abilityText = {
            "Faint: Randomly (1/6 chance) summon an additional 4/1 Darkstar.",
            "Faint: Randomly (1/3 chance) summon an additional 6/3 Darkstar at level 1.",
            "Faint: Randomly (1/2 chance) summon an additional 9/6 Darkstar at level 2."
        }
        pet.abilities = ArrayFromRawArray({{id="faint",func=pet.faint}});
    elseif pet.id == "crusher" then
        pet.endOfTurn = function(done)
            local slot = pet.getIndex();
            local friendAhead = game.team.get(slot+1);
            if friendAhead then
                friendAhead.hp = friendAhead.hp + (2*pet.level);
            end
            done();
        end
        pet.abilityText = {
            "End of turn: Give friend ahead 2 health.",
            "End of turn: Give friend ahead 4 health.",
            "End of turn: Give friend ahead 6 health."
        }
        pet.abilities = ArrayFromRawArray({{id="endOfTurn",func=pet.endOfTurn}});
    elseif pet.id == "mera" then
        pet.hurt = function(done,sourceAndAmount)
            local selfFragile = FragileAilment();
            pet.gainPerk(selfFragile);
            for i=1,pet.level,1 do
                local opp = pet.getXthOpponentAhead(i);
                if opp then
                    local frag = FragileAilment();
                    opp.gainPerk(frag);
                end
            end
            done();
        end
        pet.abilityText = {
            "Hurt: Apply Fragile to self and first enemy ahead.",
            "Hurt: Apply Fragile to self and first two enemies ahead.",
            "Hurt: Apply Fragile to self and first three enemies ahead."
        }
        pet.abilities = ArrayFromRawArray({{id="hurt",func=pet.hurt}});
    elseif pet.id == "stink" then
        pet.projectileUrl = "img/cursedsword.png";
        pet.startOfBattle = function(done)
            local dmg = 4*pet.level;
            local oppTeam = pet.getEnemyTeam();
            oppTeam = oppTeam.getAllPets();
            oppTeam = oppTeam.filter(function(el)
                return el.gender == "f";
            end);
            local towers = oppTeam.filter(function(el) 
                return el.id == "wizardtower";
            end);
            if #towers > 0 then
                oppTeam = towers;
            end
            if #oppTeam <= 0 then
                done();
            else
                local target = oppTeam[math.random(#oppTeam)];
                if target.id == "trixie" then
                    game.manager.battle.dealDirectDamage(0,pet,target,function()
                        game.manager.battle.dealDirectDamage(dmg,target,pet,function()
                            pet.gainPerk(CursedAilment());
                            game.manager.triggerRandom();
                            done();
                        end)
                    end)
                else
                    game.manager.battle.dealDirectDamage(dmg,pet,target,function()
                        target.gainPerk(CursedAilment());
                        game.manager.triggerRandom();
                        done();
                    end)
                end
            end
        end
        pet.abilityText = {
            "Start of battle: Deal 4 damage to a Random enemy Girl and inflict Cursed.",
            "Start of battle: Deal 8 damage to a Random enemy Girl and inflict Cursed.",
            "Start of battle: Deal 12 damage to a Random enemy Girl and inflict Cursed."
        }
        pet.abilities = ArrayFromRawArray({{id="startOfBattle",func=pet.startOfBattle}});
    elseif pet.id == "poochy" then
        pet.triggersCount = 0;
        pet.twoCounter = 0;
        pet.friendAttacks = function(done,friend)
            if friend.id ~= "craig" then
                pet.twoCounter = pet.twoCounter + 1;
                if pet.twoCounter == 2 then
                    pet.twoCounter = 0;
                    pet.triggersCount = pet.triggersCount + 1;
                    local team = pet.getTeam();
                    team.oddTrumpets = team.oddTrumpets + pet.level;
                    done();
                else
                    done();
                end
            else
                done();
            end
        end
        pet.abilityText = {
            "Two friends attack: Gain 1 Odd Trumpet.",
            "Two friends attack: Gain 2 Odd Trumpets.",
            "Two friends attack: Gain 3 Odd Trumpets."
        }
        pet.abilities = ArrayFromRawArray({{id="friendAttacks",func=pet.friendAttacks}});
    elseif pet.id == "naven" then
        pet.friendAteFood = function(done,food)
            if (food.id == "apple") or (food.id == "betterapple") or (food.id == "bestapple") then
                pet.atk = pet.atk + pet.level;
                pet.hp = pet.hp + pet.level;
                game.run.extraGoldNextTurn = game.run.extraGoldNextTurn + pet.level;
            end
        end
        pet.abilityText = {
            "Friend ate apple: Gain 1 attack and health, and gain 1 gold next turn.",
            "Friend ate apple: Gain 2 attack and health, and gain 2 gold next turn.",
            "Friend ate apple: Gain 3 attack and health, and gain 3 gold next turn."
        }
        pet.abilities = ArrayFromRawArray({{id="friendAteFood",func=pet.friendAteFood}});
    elseif pet.id == "umby" then
        pet.friendHurt = function(done,friendAndSource)
            local friend = friendAndSource.friend;
            local source = friendAndSource.source;
            if source and (friend.getIndex() < pet.getIndex()) then
                game.manager.battle.dealDirectDamage(3*pet.level,pet,source,done);
            else
                done();
            end
        end
        pet.abilityText = {
            "Any friend behind hurt: Deal 3 damage to the attacker.",
            "Any friend behind hurt: Deal 6 damage to the attacker.",
            "Any friend behind hurt: Deal 9 damage to the attacker."
        }
        pet.abilities = ArrayFromRawArray({{id="friendHurt",func=pet.friendHurt}});
    elseif pet.id == "espy" then
        pet.friendHurt = function(done,friendAndSource)
            local friend = friendAndSource.friend;
            local source = friendAndSource.source;
            if source and (friend.getIndex() > pet.getIndex()) then
                game.manager.battle.dealDirectDamage(pet.level,pet,source,done);
            else
                done();
            end
        end
        pet.abilityText = {
            "Any friend ahead hurt: Deal 1 damage to the attacker.",
            "Any friend ahead hurt: Deal 2 damage to the attacker.",
            "Any friend ahead hurt: Deal 3 damage to the attacker."
        }
        pet.abilities = ArrayFromRawArray({{id="friendHurt",func=pet.friendHurt}});
    elseif pet.id == "sylvie" then
        pet.beeftonSummoned = false;
        pet.hurt = function(done,sourceAndAmount)
            if pet.beeftonSummoned then
                done();
            elseif pet.getTeam().isFull() then
                pet.fling(pet.getIndex(),"beefton");
                done();
            else
                pet.beeftonSummoned = true;
                local beefton = Pet("beefton");
                beefton.atk = 5*pet.level;
                beefton.hp = 5*pet.level;
                pet.getTeam().summonPetAheadOf(pet,beefton,done);
            end
        end
        pet.abilityText = {
            "First time hurt: Summon a 5/5 Dr. Beefton ahead.",
            "First time hurt: Summon a 10/10 Dr. Beefton ahead.",
            "First time hurt: Summon a 15/15 Dr. Beefton ahead."
        }
        pet.abilities = ArrayFromRawArray({{id="hurt",func=pet.hurt}});
    elseif pet.id == "beefton" then
        pet.abilityText = {
            "DOCTOR BEEFTON HAS A PhD IN DEATH! As well as a doctorate in philosophy and modern linguistics.",
            "DOCTOR BEEFTON HAS A PhD IN DEATH! As well as a doctorate in philosophy and modern linguistics.",
            "DOCTOR BEEFTON HAS A PhD IN DEATH! As well as a doctorate in philosophy and modern linguistics."
        }
    elseif pet.id == "scaregrow" then
        pet.startOfBattle = function(done)
            local targets = game.manager.battle.allPets();
            local towers = targets.filter(function(el) 
                return (el.id == "wizardtower") and (el.enemy ~= pet.enemy);
            end);
            if #towers > 0 then
                targets = towers;
            end
            local times = 2 + (pet.level*2)
            for i=1,times,1 do
                local cob = Food("corn");
                cob.enemy = pet.enemy;
                cob.multiplier = 1 + pet.level;
                local target = targets[math.random(#targets)];
                cob.eat(target,cob);
            end
            game.manager.triggerRandom();
            done();
        end
        pet.abilityText = {
            "Start of battle: Feed 4 corncobs to Random pets. Double effect on allies.",
            "Start of battle: Feed 6 corncobs to Random pets. Triple effect on allies.",
            "Start of battle: Feed 8 corncobs to Random pets. Quadruple effect on allies."
        }
        pet.abilities = ArrayFromRawArray({{id="startOfBattle",func=pet.startOfBattle}});
    elseif pet.id == "howdy" then
        pet.startOfTurn = function(done)
            game.itemShop.stockAdditionalRandomFood(pet.level);
            game.manager.triggerRandom();
            done();
        end
        pet.abilityText = {
            "Start of turn: Stock an additional Random food and apply a 1-gold senior discount.",
            "Start of turn: Stock an additional Random food and apply a 2-gold senior discount.",
            "Start of turn: Stock an additional Random food and apply a 3-gold senior discount."
        }
        pet.abilities = ArrayFromRawArray({{id="startOfTurn",func = pet.startOfTurn}})
    elseif pet.id == "percy" then
        pet.alreadySummoned = false;
        pet.emptyBackSpace = function(done)
            if not pet.alreadySummoned then
                pet.alreadySummoned = true;
                local wt = Pet("wizardtower");
                local hp = (pet.level == 3) and 30 or ((pet.level == 2) and 15 or 5);
                wt.atk = 1;
                wt.hp = hp;
                wt.enemy = pet.enemy;
                pet.getTeam().addExistingPet(wt,1);
            end
            done();
        end
        pet.abilityText = {
            "Empty back space: Summon a 1/5 Wizard Tower. Triggers once per battle.",
            "Empty back space: Summon a 1/15 Wizard Tower. Triggers once per battle.",
            "Empty back space: Summon a 1/30 Wizard Tower. Triggers once per battle."
        };
        pet.abilities = ArrayFromRawArray({{id="emptyBackSpace",func = pet.emptyBackSpace}})
    elseif pet.id == "wizardtower" then
        pet.abilityText = {
            "Enemy ability targeted randomly: Redirect it to this tower.",
            "Enemy ability targeted randomly: Redirect it to this tower.",
            "Enemy ability targeted randomly: Redirect it to this tower."
        };
    elseif pet.id == "arnold" then
        pet.boughtFood = function(done,food)
            game.itemShop.applyGlobalDiscount(pet.level);
            game.petShop.applyGrahamDiscount(pet.level);
            done();
        end
        pet.abilityText = {
            "Bought food: Discount shop food by 1.",
            "Bought food: Discount shop food by 2.",
            "Bought food: Discount shop food by 3.",
        }
        pet.abilities = ArrayFromRawArray({{id="boughtFood",func = pet.boughtFood}})
    elseif pet.id == "trefor" then
        pet.startOfBattle = function(done)
            local quag = Quag();
            pet.gainPerk(quag);
            if pet.level == 2 then
                local pos = pet.getIndex();
                local behind = pet.getTeam().get(pos-1);
                local ahead = pet.getTeam().get(pos+1);
                if behind and (behind.perk.id == "default" or behind.perk.isAilment) then
                    local q2 = Quag();
                    behind.gainPerk(q2);
                end
                if ahead and (ahead.perk.id == "default" or ahead.perk.isAilment) then
                    local q2 = Quag();
                    ahead.gainPerk(q2);
                end
                done();
            elseif pet.level == 3 then
                local all = pet.getTeam().getAllPets();
                all.forEach(function(el)
                    if el.perk.id == "default" or el.perk.isAilment then
                        local q2 = Quag();
                        el.gainPerk(q2);
                    end
                end)
                done();
            else
                done();
            end
        end
        pet.abilityText = {
            "Start of battle: Gain Quag. (Quag is both a perk and an ailment.)",
            "Start of battle: Self and adjacent perkless friends gain Quag. (Quag is both a perk and an ailment.)",
            "Start of battle: Self and all perkless friends gain Quag. (Quag is both a perk and an ailment.)"
        }
        pet.abilities = ArrayFromRawArray({{id="startOfBattle",func = pet.startOfBattle}})
    elseif pet.id == "ramsey" then
        pet.goldbrickeredYet = false;
        pet.friendSold = function(done,friend) 
            if not pet.goldbrickeredYet then
                game.run.gold = game.run.gold + (5*pet.level);
                game.run.extraGoldNextTurn = game.run.extraGoldNextTurn - (5*pet.level);
                pet.goldbrickeredYet = true;
            end
            done();
        end
        pet.sell = function(done)
            if not pet.goldbrickeredYet then
                game.run.gold = game.run.gold + (5*pet.level);
                game.run.extraGoldNextTurn = game.run.extraGoldNextTurn - (5*pet.level);
                pet.goldbrickeredYet = true;
            end
            done();
        end
        pet.abilityText = {
            "Sell or friend sold: Gain 5 gold. Lose that much next turn. Triggers once per turn.",
            "Sell or friend sold: Gain 10 gold. Lose that much next turn. Triggers once per turn.",
            "Sell or friend sold: Gain 15 gold. Lose that much next turn. Triggers once per turn."
        }
        pet.abilities = ArrayFromRawArray({{id="friendSold",func=pet.friendSold}});
    elseif pet.id == "carcrash" then
        pet.startOfBattle = function(done)
            pet.fainted = true;
            asyn.wait(0.6,function() 
                if pet.perk.faint then
                    pet.perk.faint(function()
                        pet.faint(done);
                    end)
                else
                    pet.faint(done)
                end
            end);
        end
        pet.faint = function(done)
            local bus = Pet("bus");
            bus.atk = 6*pet.level;
            bus.hp = 4*pet.level;
            bus.enemy = pet.enemy;
            local busperk = HotHotHotPerk();
            bus.perk = busperk; --skip gaining- it comes in with it
            busperk.owner = bus;
            local spot = pet.getIndex();
            local team = pet.getTeam();
            team.replacePet(spot,bus);
            done();
        end
        pet.abilityText = {
            "Start of battle: Faint and summon a 6/4 Beat-up Bus with Too Hot.",
            "Start of battle: Faint and summon a 12/8 Beat-up Bus with Too Hot.",
            "Start of battle: Faint and summon a 18/12 Beat-up Bus with Too Hot."
        };
        pet.abilities = ArrayFromRawArray({{id="startOfBattle",func = pet.startOfBattle}})
    elseif pet.id == "bus" then
        pet.abilityText = {
            "It stares with blank eyes. Eyes one might compare... to headlights. They're headlights.",
            "It stares with blank eyes. Eyes one might compare... to headlights. They're headlights.",
            "It stares with blank eyes. Eyes one might compare... to headlights. They're headlights."
        }
    elseif pet.id == "spellingbee" then
        pet.beforeAttack = function(done,opponent)
            local enemyIsAlphabetical = game.enemyTeam.isInAlphabeticalOrder();
            local playerIsAlphabetical = game.team.isInAlphabeticalOrder();
            local dmg = pet.level;
            local damageActions = Array();
            if not enemyIsAlphabetical then
                local allEnemy = game.enemyTeam.getAllPets();
                allEnemy.forEach(function(el) 
                    local action = function(next) 
                        game.manager.battle.dealDirectDamage(dmg,pet,el,next,true);
                    end;
                    damageActions.push(action);
                end);
            end
            if not playerIsAlphabetical then
                local allFriend = game.team.getAllPets();
                allFriend.forEach(function(el) 
                    local action = function(next) 
                        game.manager.battle.dealDirectDamage(dmg,pet,el,next,true);
                    end;
                    damageActions.push(action);
                end);
            end
            asyn.runSerial(damageActions,done);
        end
        pet.abilityText = {
            "Before attack: If either team is out of alphabetical order, deal 1 damage to that team.",
            "Before attack: If either team is out of alphabetical order, deal 2 damage to that team.",
            "Before attack: If either team is out of alphabetical order, deal 3 damage to that team.",
        };
        pet.abilities = ArrayFromRawArray({{id="beforeAttack",func = pet.beforeAttack}})
    elseif pet.id == "indus" then
        pet.startOfBattle = function(done)
            local perk = Perk();
            if pet.level == 1 then
                perk = PepperPerk();
            elseif pet.level == 2 then
                perk = MelonPerk();
            else --pet.level == 3
                perk = CoconutPerk();
            end
            local ownCopy = perk.copy();
            local teammateInFront = pet.getTeam().get(pet.getIndex() + 1);
            if teammateInFront then
                teammateInFront.gainPerk(perk);
            end
            pet.gainPerk(ownCopy);
            done();
        end
        pet.abilityText = {
            "Start of battle: Give Pepper to self and friend ahead.",
            "Start of battle: Give Melon to self and friend ahead.",
            "Start of battle: Give Coconut to self and friend ahead."
        };
        pet.abilities = ArrayFromRawArray({{id="startOfBattle",func = pet.startOfBattle}})
    elseif pet.id == "yoomtah" then
        pet.projectileUrl = "img/lightning.png";
        pet.randomThingHappens = function(done)
            local dmg = pet.level;
            local oppTeam = pet.getEnemyTeam();
            oppTeam = oppTeam.getAllPets();
            local towers = oppTeam.filter(function(el) 
                return el.id == "wizardtower";
            end);
            if #towers > 0 then
                oppTeam = towers;
            end
            if #oppTeam <= 0 then
                done();
            else
                local target = oppTeam[math.random(#oppTeam)];
                game.manager.battle.dealDirectDamage(dmg,pet,target,done);
            end
        end
        pet.abilityText = {
            "Something Random happens: Zap a (lowercase-r) random enemy for 1 damage.",
            "Something Random happens: Zap a (lowercase-r) random enemy for 2 damage.",
            "Something Random happens: Zap a (lowercase-r) random enemy for 3 damage."
        };
        pet.abilities = ArrayFromRawArray({{id="randomThingHappens",func = pet.randomThingHappens}})
    elseif pet.id == "weh" then
        pet.beforeBattle = function(done)
            local pos = pet.getIndex();
            local neighborBehind = pet.getTeam().get(pos-1);
            local neighborAhead = pet.getTeam().get(pos+1);
            if (not neighborAhead) and (not neighborBehind) then
                pet.atk = pet.atk + (6*pet.level);
                pet.hp = pet.hp + (6*pet.level);
            end
            done();
        end
        pet.abilityText = {
            "Before battle: If no adjacent friends, gain 6 attack and HP.",
            "Before battle: If no adjacent friends, gain 12 attack and HP.",
            "Before battle: If no adjacent friends, gain 18 attack and HP."
        };
        pet.abilities = ArrayFromRawArray({{id="beforeBattle",func = pet.beforeBattle}})
    elseif pet.id == "howie" then
        pet.friendGainedAilment = function(done,friend)
            friend.atk = friend.atk + pet.level;
            local honey = HoneyedSnackPerk();
            friend.gainPerk(honey);
            done();
        end
        pet.abilityText = {
            "Friend gained ailment: Replace it with Honeyed Snack and give +1 attack.",
            "Friend gained ailment: Replace it with Honeyed Snack and give +2 attack.",
            "Friend gained ailment: Replace it with Honeyed Snack and give +3 attack."
        };
        pet.abilities = ArrayFromRawArray({{id="friendGainedAilment",func = pet.friendGainedAilment}})
    elseif pet.id == "tannenbaum" then
        pet.falseSwipesUsed = 0;
        pet.beforeAttack = function(done,opponent)
            if pet.falseSwipesUsed <= (2*pet.level) then
                pet.falseSwipesUsed = pet.falseSwipesUsed + 1;
                pet.hp = pet.hp + (2*pet.level);
                opponent.gainPerk(PepperPerk());
            end
            done();
        end
        pet.abilityText = {
            "Before attack: Gain 2 HP and give the opponent Pepper. Triggers 2 times per battle.",
            "Before attack: Gain 4 HP and give the opponent Pepper. Triggers 4 times per battle.",
            "Before attack: Gain 6 HP and give the opponent Pepper. Triggers 6 times per battle."
        };
        pet.abilities = ArrayFromRawArray({{id="beforeAttack",func = pet.beforeAttack}})
    elseif pet.id == "exit" then
        pet.beforeBattle = function(done)
            local enemies = pet.getEnemyTeam().getAllPets();
            local lowEnough = enemies.filter(function(el) 
                return el.tier <= (pet.level*2)
            end);
            if #lowEnough > 0 then
                local picked = lowEnough[math.random(#lowEnough)];
                picked.getTeam().removePet(picked);
                pet.getTeam().removePet(pet);
                if #lowEnough > 1 then
                    game.manager.triggerRandom();
                end
                done();
            else
                pet.getTeam().removePet(pet);
                done();
            end
        end
        pet.abilityText = {
            "Before battle: If no adjacent friends, gain 6 attack and HP.",
            "Before battle: If no adjacent friends, gain 12 attack and HP.",
            "Before battle: If no adjacent friends, gain 18 attack and HP."
        };
        pet.abilities = ArrayFromRawArray({{id="beforeBattle",func = pet.beforeBattle}})
    elseif pet.id == "justy" then
        pet.defaultDefense = pet.defense;
        pet.beforeAttack = function(done,opponent)
            if math.random(6) <= pet.level then
                pet.defense = function() 
                    return 999;
                end
            end
            done();
        end
        pet.afterAttack = function(done,opponent)
            pet.defense = pet.defaultDefense;
            game.manager.triggerRandom();
            done();
        end
        pet.abilityText = {
            "1/6 chance to evade an enemy attack.",
            "1/3 chance to evade an enemy attack.",
            "1/2 chance to evade an enemy attack. He's perfected the Double Team technique...!"
        };
        pet.abilities = ArrayFromRawArray({{id="beforeAttack",func = pet.beforeAttack},{id="afterAttack",func = pet.afterAttack}})
    elseif pet.id == "jorge" then
        pet.beforeBattle = function(done)
            local possibilities = {"vampirebat","vampiresquid","vampireparrot"};
            local picked = possibilities[math.random(#possibilities)];
            pet.transform(picked);
            game.manager.triggerRandom();
            done();
        end
        pet.abilityText = {
            "Before battle: Randomly transform into a level 1 Vampire Bat, Parrot, or Squid.",
            "Before battle: Randomly transform into a level 2 Vampire Bat, Parrot, or Squid.",
            "Before battle: Randomly transform into a level 3 Vampire Bat, Parrot, or Squid."
        };
        pet.abilities = ArrayFromRawArray({{id="beforeBattle",func = pet.beforeBattle}})
    elseif pet.id == "vampireparrot" then
        pet.startOfBattle = function(done)
            local teammates = pet.getTeam().getAllPets();
            local ailmentTypes = Array();
            teammates.forEach(function(tm) 
                if tm.perk.isAilment and (not ailmentTypes.contains(tm.perk.id)) then
                    ailmentTypes.push(tm.perk.id);
                end
            end);
            pet.atk = pet.atk + (#ailmentTypes * pet.level);
            pet.hp = pet.hp + (#ailmentTypes * 2 * pet.level);
            done();
        end
        pet.abilityText = {
            "Start of battle: Gain 1 HP and 2 attack for each unique friendly ailment.",
            "Start of battle: Gain 2 HP and 4 attack for each unique friendly ailment.",
            "Start of battle: Gain 3 HP and 6 attack for each unique friendly ailment."
        };
        pet.abilities = ArrayFromRawArray({{id="startOfBattle",func = pet.startOfBattle}})
    elseif pet.id == "vampirebat" then
        pet.opponentGainedAilment = function(done,opponent)
            game.manager.battle.dealDirectDamage(4*pet.level,pet,opponent,function()
                local ddealt = (4*pet.level)-opponent.defense();
                if ddealt < 0 then ddealt = 0; end
                pet.hp = pet.hp + ddealt;
                done();
            end)
        end
        pet.abilityText = {
            "Enemy gained ailment: Deal 4 damage to it and gain damage as HP. Works 2 times per battle.",
            "Enemy gained ailment: Deal 8 damage to it and gain damage as HP. Works 2 times per battle.",
            "Enemy gained ailment: Deal 12 damage to it and gain damage as HP. Works 2 times per battle."
        };
        pet.abilities = ArrayFromRawArray({{id="opponentGainedAilment",func = pet.opponentGainedAilment}})
    elseif pet.id == "vampiresquid" then
        pet.startOfBattle = function(done)
            local teammates = pet.getTeam().getAllPets();
            local ailmentTypes = Array();
            local afflictedPets = Array();
            teammates.forEach(function(tm) 
                if tm.perk.isAilment and (not ailmentTypes.contains(tm.perk.id)) then
                    ailmentTypes.push(tm.perk.id);
                    afflictedPets.push(tm);
                end
            end);
            afflictedPets.forEach(function(ap) 
                ap.atk = ap.atk + pet.level;
                ap.hp = ap.hp + (2*pet.level);
                ap.original.atk = ap.original.atk + pet.level;
                ap.original.hp = ap.original.hp + (2*pet.level);
            end);
            done();
        end
        pet.abilityText = {
            "Start of battle: Permanently give 1 attack and 2 HP to each friend with a different ailment.",
            "Start of battle: Permanently give 2 attack and 4 HP to each friend with a different ailment.",
            "Start of battle: Permanently give 3 attack and 6 HP to each friend with a different ailment."
        };
        pet.abilities = ArrayFromRawArray({{id="startOfBattle",func = pet.startOfBattle}})
    elseif pet.id == "jolteon" then
        pet.friendFaints = function(done,friend)
            if pet.level == 1 then
                local pb = PeanutButterPerk();
                pet.gainPerk(pb);
            end
            done();
        end
        pet.friendHurt = function(done,friend)
            if pet.level > 1 then
                local pb = PeanutButterPerk();
                pet.gainPerk(pb);
            end
            if pet.level == 3 then
                pet.hp = pet.hp + 10;
            end
            done();
        end
        pet.abilityText = {
            "Friend faints: Gain Peanut Butter.",
            "Friend hurt: Gain Peanut Butter.",
            "Friend hurt: Gain Peanut Butter and 10 HP."
        }
        pet.abilities = ArrayFromRawArray({{id="friendFaints",func = pet.friendFaints},{id="friendHurt",func = pet.friendHurt}})
    elseif pet.id == "zora" then
        pet.afterAttack = function(done,opponent)
            opponent.loseExp(pet.level);
            if pet.level == 3 then 
                opponent.loseExp(1);
            end
            game.run.extraGoldNextTurn = game.run.extraGoldNextTurn + 1;
            done();
        end
        pet.abilityText = {
            "After attack: Remove 1 EXP from the opponent and gain 1 gold.",
            "After attack: Remove 2 EXP from the opponent and gain 1 gold.",
            "After attack: Remove 4 EXP from the opponent and gain 1 gold."
        };
        pet.abilities = ArrayFromRawArray({{id="afterAttack",func = pet.afterAttack}})
    elseif pet.id == "trixie" then
        pet.startOfBattle = function(done)
            local pool = trixieTier1Ailments;
            local targets = Array();
            targets.push(pet);
            targets.push(pet.getXthOpponentAhead(1));
            targets.push(pet.getXthOpponentAhead(2));
            if pet.level > 1 then
                pool = pool.concat(trixieTier2Ailments);
                targets.push(pet.getXthOpponentAhead(3));
            end
            if pet.level > 2 then
                pool = pool.concat(trixieTier3Ailments);
                targets.push(pet.getXthOpponentAhead(4));
            end
            targets.forEach(function(p) 
                local randomAilmentFunc = pool[math.random(#pool)];
                local ailment = randomAilmentFunc();
                p.gainPerk(ailment);
            end);
            game.manager.triggerRandom();
            done();
        end
        pet.abilityText = {
            "Start of battle: Apply a Random tier 2 or lower ailment to the 2 nearest enemies and self.",
            "Start of battle: Apply a Random tier 4 or lower ailment to the 3 nearest enemies and self.",
            "Start of battle: Apply a Random tier 6 or lower ailment to the 4 nearest enemies and self."
        };
        pet.abilities = ArrayFromRawArray({{id="startOfBattle",func = pet.startOfBattle}})
    elseif pet.id == "graham" then
        pet.abilityText = {
            "Eaten: Eater gains 3 attack and 3 HP.",
            "Eaten: Eater gains 10 attack and 10 HP.",
            "Eaten: Eater gains this pet's attack and HP."
        };
    elseif pet.id == "greenpikachu" then
        pet.beforeBattle = function(done)
            local mates = pet.getTeammates();
            if #mates == 0 then
                done();
                return;
            end
            local highest = mates[1];
            if #mates > 1 then
                for i=2,#mates,1 do
                    if mates[i].tier > highest.tier then
                        highest = mates[i];
                    end
                end
            end
            pet.transform(highest.id);
            if pet.level > 1 then
                if highest.atk > pet.atk then
                    pet.atk = highest.atk;
                end
            end
            if pet.level > 2 then
                if highest.hp > pet.hp then
                    pet.hp = highest.hp;
                end
            end
            pet.gainPerk(ExtremelySpookedAilment());
            done();
        end
        pet.abilityText = {
            "Before battle: Transform into the highest-tier friend and gain Extremely Spooked.",
            "Before battle: Transform into the highest-tier friend (including their attack, if higher) and gain Extremely Spooked.",
            "Before battle: Transform into the highest-tier friend (including their attack and HP, if higher) and gain Extremely Spooked.",
        };
        pet.abilities = ArrayFromRawArray({{id="beforeBattle",func = pet.beforeBattle}})
    elseif pet.id == "wound" then
        pet.beforeBattle = function(done)
            local pos = pet.getIndex();
            local neighborBehind = pet.getTeam().get(pos-1);
            local neighborAhead = pet.getTeam().get(pos+1);
            if (not neighborAhead) and (not neighborBehind) and (pos ~= 1) then
                pet.woundActive = true;
            else
                pet.woundActive = false;
            end
            done();
        end
        pet.startOfBattle = function(done)
            if pet.woundActive then
                local et = pet.getEnemyTeam().getAllPets();
                local target = et[1];
                target.enemy = not target.enemy;
                pet.getEnemyTeam().removePet(target);
                pet.getTeam().summonPetAheadOf(pet,target,done);
            else
                done();
            end
        end
        pet.abilityText = {
            "Start of battle: If this had no adjacent pets before battle, and wasn't in the back, steal the rearmost enemy pet.",
            "Start of battle: If this had no adjacent pets before battle, and wasn't in the back, steal the rearmost enemy pet.",
            "Start of battle: If this had no adjacent pets before battle, and wasn't in the back, steal the rearmost enemy pet."
        }
        pet.abilities = ArrayFromRawArray({{id="startOfBattle",func = pet.startOfBattle},{id="beforeBattle",func = pet.beforeBattle}})
    elseif pet.id == "lorelai" then
        if not pet.oldDefense then
            pet.oldDefense = pet.defense;
        end
        pet.defense = function()
            if pet.getIndex() ~= 5 then
                return pet.oldDefense() + (10*pet.level);
            else 
                return pet.oldDefense();
            end
        end
        pet.abilityText = {
            "If not in front: Takes 10 less damage and can't gain ailments.",
            "If not in front: Takes 20 less damage and can't gain ailments.",
            "If not in front: Takes 30 less damage and can't gain ailments."
        }
    elseif pet.id == "craig" then
        pet.abilityText = {
            "Please: KILL ME!!!",
            "WHY AM I NOT DEAD!!!",
            "I YEARN FOR THE SWEET EMBRACE OF OBLIVION!!!"
        }
    end
end
