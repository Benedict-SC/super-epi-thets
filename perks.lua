Perk = function(id)
    local perk = {};
    perk.id = id or "default";
    perk.imgUrl = "img/perk/" .. perk.id .. ".png";
    perk.img = love.graphics.newImage(perk.imgUrl);
    perk.abilities = Array();
    perk.damageMod = 0;
    perk.isAilment = false;
    perk.copy = function() return Perk(); end --careful- this doesn't preserve the owner. only make the copy in the pet copy where the owner is also manually reassigned to the new pet.
    return perk;
end
DonutGunPerk = function(mult)
    local gun = Perk("donutgun");
    gun.name = "Donut Gun";
    gun.mult = mult;
    gun.damageMod = (2*mult);
    gun.lostPerk = function(done)
        gun.owner.hp = gun.owner.hp + (2*mult);
        done();
    end
    gun.abilities.push({id="lostPerk",func=gun.lostPerk})
    gun.copy = function() return DonutGunPerk(gun.mult); end
    gun.effectText = "Deal " .. gun.damageMod .. " extra damage when attacking. If lost, gain " .. gun.damageMod .. " HP.";
    return gun;
end
HotHotHotPerk = function()
    local hot = Perk("hothothot");
    hot.name = "Hot, Hot, Hot!"
    hot.afterAttack = function(done,opponent)
        local nextOne = hot.owner.getXthOpponentAhead(2);
        if nextOne then
            game.manager.battle.dealDirectDamage(3,hot.owner,nextOne,done);
        else
            done();
        end
    end
    hot.abilities.push({id="afterAttack",func=hot.afterAttack});
    hot.copy = function() return HotHotHotPerk(); end
    hot.effectText = "After attack: Deal 3 damage to the enemy behind.";
    return hot;
end
PepperPerk = function()
    local pepper = Perk("pepper");
    pepper.name = "Pepper";
    --damage reduction isn't an ability- handle in attack logic directly
    pepper.afterAttack = function(done,opponent)
        pepper.owner.losePerk();
        done();
    end
    pepper.abilities.push({id="afterAttack",func=pepper.afterAttack});
    pepper.copy = function() return PepperPerk(); end
    pepper.effectText = "HP cannot go below 1. Remove this on taking damage.";
    return pepper;
end
MelonPerk = function()
    local melon = Perk("melon");
    melon.name = "Melon";
    --damage reduction isn't an ability- handle in defense function directly
    melon.afterAttack = function(done,opponent)
        melon.owner.losePerk();
        done();
    end
    melon.abilities.push({id="afterAttack",func=melon.afterAttack});
    melon.copy = function() return MelonPerk(); end
    melon.effectText = "Blocks 20 damage, once.";
    return melon;
end
CoconutPerk = function()
    local coconut = Perk("coconut");
    coconut.name = "Coconut";
    --damage reduction isn't an ability- handle in defense function directly
    coconut.afterAttack = function(done,opponent)
        coconut.owner.losePerk();
        done();
    end
    coconut.abilities.push({id="afterAttack",func=coconut.afterAttack});
    coconut.copy = function() return CoconutPerk(); end
    coconut.effectText = "Prevents all damage, once.";
    return coconut;
end
HoneyedSnackPerk = function()
    local honey = Perk("honeyedsnack");
    honey.name = "Honeyed Snack";
    honey.faint = function(done)
        local pet = honey.owner;
        local workerbee = Pet("workerbee");
        workerbee.enemy = pet.enemy;
        if pet.id == "wellwatcher" or pet.id == "sylvie" or pet.id == "darkstar" or pet.id == "carcrash" then
            pet.getTeam().summonPetAheadOf(pet,workerbee,done);
        else
            pet.getTeam().replacePet(pet.getIndex(),workerbee);
            done();
        end
    end
    honey.abilities.push({id="faint",func=honey.faint});
    honey.copy = function() return HoneyedSnackPerk(); end
    honey.effectText = "Faint: Summon one 1/1 Worker Bee.";
    return honey;
end
PeanutButterPerk = function()
    local pb = Perk("peanutbutter");
    pb.name = "Peanut Butter";
    --damage is handled separately in the attack logic
    pb.afterAttack = function(done)
        pb.owner.losePerk();
        done();
    end
    pb.abilities.push({id="afterAttack",func=pb.afterAttack});
    pb.copy = function() return PeanutButterPerk(); end
    pb.effectText = "Dealing combat damage to the opponent will knock it out, once.";
    return pb;
end
GrapesPerk = function()
    local grapes = Perk("grapes");
    grapes.name = "Grapes";
    grapes.startOfTurn = function(done)
        game.run.gold = game.run.gold + 1;
        done();
    end
    grapes.abilities.push({id="startOfTurn",func=grapes.startOfTurn});
    grapes.copy = function() return GrapesPerk(); end
    grapes.effectText = "Start of turn: Gain 1 gold.";
    return grapes;
end
SoupOfTheDayPerk = function()
    local sotd = Perk("oftheday");
    sotd.name = "Soup of the Day";
    sotd.randomThingHappens = function(done,inbattle)
        game.manager.animateThrow(sotd.owner,sotd.owner,"img/punch.png",function()
            if inbattle then
                sotd.owner.atk = sotd.owner.atk + 1;
            else
                sotd.owner.tempAtk = sotd.owner.tempAtk + 1;
            end
            done();
        end);
    end
    sotd.abilities.push({id="randomThingHappens",func=sotd.randomThingHappens});
    sotd.copy = function() return SoupOfTheDayPerk(); end
    return sotd;
end
--------ailments
ToastyAilment = function()
    local toast = Perk("toasty");
    toast.name = "Toasty";
    toast.isAilment = true;
    toast.anyoneAttacked = function(done)
        toast.owner.hp = toast.owner.hp - 1;
        toast.owner.triggerOne("hurt",{source=nil,dmg=1},function()
            toast.owner.losePerk();
            done();
        end);
    end
    toast.abilities.push({id="anyoneAttacked",func=toast.anyoneAttacked})
    toast.copy = function() return ToastyAilment(); end
    toast.effectText = "Whenever anyone attacks, lose 1 HP and this ailment.";
    return toast;
end
FragileAilment = function()
    local fragile = Perk("fragile");
    fragile.name = "Fragile";
    fragile.isAilment = true;
    fragile.hurt = function(done,sourceAndAmount)
        fragile.owner.hp = fragile.owner.hp - sourceAndAmount.dmg; --double damage done
        done();
    end
    fragile.abilities.push({id="hurt",func=fragile.hurt});
    fragile.copy = function() return FragileAilment(); end
    fragile.effectText = "This pet takes double damage.";
    return fragile;
end
CursedAilment = function()
    local cursed = Perk("cursed");
    cursed.name = "Cursed";
    cursed.isAilment = true;
    cursed.faint = function(done)
        local team = cursed.owner.getTeam();
        team = team.getAllPets();
        team.removeElement(cursed.owner);
        if #team > 0 then
            local randomTeammate = team[math.random(#team)];
            randomTeammate.gainPerk(CursedAilment(),function()
                game.manager.triggerRandom();
                done();
            end);
        else
            done();
        end
    end
    cursed.abilities.push({id="faint",func=cursed.faint});
    cursed.copy = function() return CursedAilment(); end
    cursed.effectText = "Faint: inflict Cursed on a random teammate.";
    return cursed;
end
DazedAilment = function()
    local dazed = Perk("dazed");
    dazed.name = "Dazed";
    dazed.isAilment = true;
    dazed.copy = function() return DazedAilment(); end
    dazed.effectText = "This pet's ability doesn't activate.";
    return dazed;
end
SpookedAilment = function()
    local spooked = Perk("extremelyspooked");
    spooked.name = "Spooked";
    spooked.isAilment = true;
    spooked.defDown = 1;
    spooked.copy = function() return SpookedAilment(); end
    spooked.effectText = "This pet takes 1 extra damage."
    return spooked;
end
ExtremelySpookedAilment = function()
    local spooked = Perk("extremelyspooked");
    spooked.name = "Extremely Spooked";
    spooked.isAilment = true;
    spooked.defDown = 10;
    spooked.copy = function() return ExtremelySpookedAilment(); end
    spooked.effectText = "This pet takes 10 extra damage."
    return spooked;
end
WeakAilment = function()
    local weak = Perk("weak");
    weak.name = "Weak";
    weak.isAilment = true;
    weak.defDown = 3;
    weak.copy = function() return WeakAilment(); end
    weak.effectText = "This pet takes 3 extra damage.";
    return weak;
end
ColdAilment = function()
    local cold = Perk("cold");
    cold.name = "Cold";
    cold.defDown = 5;
    cold.isAilment = true;
    cold.hurt = function(done,sourceAndAmount)
        cold.owner.losePerk();
        done();
    end
    cold.abilities.push({id="hurt",func=cold.hurt});
    cold.copy = function() return ColdAilment(); end
    cold.effectText = "This pet takes 5 extra damage, once.";
    return cold;
end
Quag = function()
    local quag = Perk("quag");
    quag.name = "Quag";
    quag.isAilment = true;
    quag.isAlsoPerk = true; --whoops this is true for ailments by default until we get a thing that cares
    quag.copy = function() return Quag(); end
    quag.effectText = "Quag is both a perk and an ailment. That's pretty quag, huh?";
    return quag; --it doesn't do anything! yaaaaay!
end
trixieTier1Ailments = ArrayFromRawArray({ToastyAilment,SpookedAilment,Quag});
trixieTier2Ailments = ArrayFromRawArray({ColdAilment,WeakAilment,CursedAilment});
trixieTier3Ailments = ArrayFromRawArray({ExtremelySpookedAilment,DazedAilment,FragileAilment});
