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