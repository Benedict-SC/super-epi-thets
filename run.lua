Run = function()
    local run = {};
    run.bg = love.graphics.newImage("img/runstats.png");
    run.lives = 5;
    run.turn = 1;
    run.wins = 0;
    run.gold = 10;
    run.extraGoldNextTurn = 0;
    run.goldSpentThisTurn = 0;
    run.shopSlots = 3;
    run.itemSlots = 1;
    run.tier = 1;
    run.healed = false;
    run.endTurn = function()
        run.gold = 0;
    end
    run.newTurn = function()
        run.turn = run.turn + 1;
        run.gold = 10 + run.extraGoldNextTurn;
        run.extraGoldNextTurn = 0;
        if run.turn == 5 then 
            run.shopSlots = 4;
            run.itemSlots = 2;
        end
        if run.turn == 9 then 
            run.shopSlots = 5;
        end
        run.tier = 1 + math.floor((run.turn - 1)/2);
        if run.tier > 6 then run.tier = 6; end
    end
    run.draw = function()
        love.graphics.draw(run.bg,10,10);
        pushColor();
        love.graphics.setColor(0,0,0);
        love.graphics.print("" .. run.gold,74,11);
        love.graphics.print("" .. run.lives,195,11);
        love.graphics.print("" .. run.turn,311,11);
        love.graphics.print("" .. run.wins .. "/10",421,11);
        popColor();
    end
    return run;
end