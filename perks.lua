Perk = function(id)
    local perk = {};
    perk.id = id or "default";
    perk.img = love.graphics.newImage("img/perk/" .. perk.id .. ".png");
    perk.abilities = Array();
    perk.damageMod = 0;
    perk.isAilment = false;
    perk.copy = function() return Perk(); end --careful- this doesn't preserve the owner. only make the copy in the pet copy where the owner is also manually reassigned to the new pet.
    return perk;
end
DonutGunPerk = function(mult)
    local gun = Perk("donutgun");
    gun.damageMod = (2*mult);
    gun.lostPerk = function(done)
        gun.owner.hp = gun.owner.hp + (2*mult);
        done();
    end
    gun.abilities.push({id="lostPerk",func=gun.lostPerk})
    gun.copy = function() return DonutGunPerk(mult); end
    return gun;
end
HotHotHotPerk = function()
    local hot = Perk("hothothot");
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
    return hot;
end
PepperPerk = function()
    local pepper = Perk("pepper");
    --damage reduction isn't an ability- handle in attack logic directly
    pepper.afterAttack = function(done,opponent)
        pepper.owner.losePerk();
        done();
    end
    pepper.abilities.push({id="afterAttack",func=pepper.afterAttack});
    pepper.copy = function() return PepperPerk(); end
    return pepper;
end
MelonPerk = function()
    local melon = Perk("melon");
    --damage reduction isn't an ability- handle in defense function directly
    melon.afterAttack = function(done,opponent)
        melon.owner.losePerk();
        done();
    end
    melon.abilities.push({id="afterAttack",func=melon.afterAttack});
    melon.copy = function() return MelonPerk(); end
    return melon;
end
CoconutPerk = function()
    local coconut = Perk("coconut");
    --damage reduction isn't an ability- handle in defense function directly
    coconut.afterAttack = function(done,opponent)
        coconut.owner.losePerk();
        done();
    end
    coconut.abilities.push({id="afterAttack",func=coconut.afterAttack});
    coconut.copy = function() return CoconutPerk(); end
    return coconut;
end
HoneyedSnackPerk = function()
    local honey = Perk("honeyedsnack");
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
    return honey;
end
PeanutButterPerk = function()
    local pb = Perk("peanutbutter");
    --damage is handled separately in the attack logic
    pb.afterAttack = function(done)
        pb.owner.losePerk();
        done();
    end
    pb.abilities.push({id="afterAttack",func=pb.afterAttack});
    pb.copy = function() return PeanutButterPerk(); end
    return pb;
end
GrapesPerk = function()
    local grapes = Perk("grapes");
    grapes.startOfTurn = function(done)
        game.run.gold = game.run.gold + 1;
        done();
    end
    grapes.abilities.push({id="startOfTurn",func=grapes.startOfTurn});
    grapes.copy = function() return GrapesPerk(); end
    return grapes;
end
--------ailments
ToastyAilment = function()
    local toast = Perk("toasty");
    toast.isAilment = true;
    toast.anyoneAttacked = function(done)
        toast.owner.hp = toast.owner.hp - 1;
        toast.owner.triggerOne("hurt",{source=nil,dmg=1});
        toast.owner.losePerk();
        done();
    end
    toast.abilities.push({id="anyoneAttacked",func=toast.anyoneAttacked})
    toast.copy = function() return ToastyAilment(); end
    return toast;
end
FragileAilment = function()
    local fragile = Perk("fragile");
    fragile.isAilment = true;
    fragile.hurt = function(done,sourceAndAmount)
        fragile.owner.hp = fragile.owner.hp - sourceAndAmount.dmg; --double damage done
        done();
    end
    fragile.abilities.push({id="hurt",func=fragile.hurt});
    fragile.copy = function() return FragileAilment(); end
    return fragile;
end
CursedAilment = function()
    local cursed = Perk("cursed");
    cursed.isAilment = true;
    cursed.faint = function(done)
        local team = cursed.owner.getTeam();
        team = team.getAllPets();
        team.removeElement(cursed.owner);
        if #team > 0 then
            local randomTeammate = team[math.random(#team)];
            randomTeammate.gainPerk(CursedAilment());
            done();
        else
            done();
        end
    end
    cursed.abilities.push({id="faint",func=cursed.faint});
    cursed.copy = function() return CursedAilment(); end
    return cursed;
end
DazedAilment = function()
    local dazed = Perk("dazed");
    dazed.isAilment = true;
    dazed.copy = function() return DazedAilment(); end
    return dazed;
end
SpookedAilment = function()
    local spooked = Perk("extremelyspooked");
    spooked.isAilment = true;
    spooked.defDown = 1;
    spooked.copy = function() return SpookedAilment(); end
    return spooked;
end
ExtremelySpookedAilment = function()
    local spooked = Perk("extremelyspooked");
    spooked.isAilment = true;
    spooked.defDown = 10;
    spooked.copy = function() return ExtremelySpookedAilment(); end
    return spooked;
end
WeakAilment = function()
    local weak = Perk("weak");
    weak.isAilment = true;
    weak.defDown = 3;
    weak.copy = function() return WeakAilment(); end
    return weak;
end
ColdAilment = function()
    local cold = Perk("cold");
    cold.defDown = 5;
    cold.isAilment = true;
    cold.hurt = function(done,sourceAndAmount)
        cold.owner.losePerk();
        done();
    end
    cold.abilities.push({id="hurt",func=cold.hurt});
    cold.copy = function() return ColdAilment(); end
    return cold;
end
Quag = function()
    local quag = Perk("quag");
    quag.isAilment = true;
    quag.isAlsoPerk = true; --whoops this is true for ailments by default until we get a thing that cares
    quag.copy = function() return Quag(); end
    return quag; --it doesn't do anything! yaaaaay!
end
trixieTier1Ailments = ArrayFromRawArray({ToastyAilment,SpookedAilment,Quag});
trixieTier2Ailments = ArrayFromRawArray({ColdAilment,WeakAilment,CursedAilment});
trixieTier3Ailments = ArrayFromRawArray({ExtremelySpookedAilment,DazedAilment,FragileAilment});