Field = function()
    local field = {};
    field.TEAM_HEIGHT = 250;
    field.leftbg = love.graphics.newImage("img/bg_museum.png");
    field.rightbg = love.graphics.newImage("img/bg_redwood.png");
    field.leftCanvas = love.graphics.newCanvas(gamewidth/2,gameheight);
    field.pedestal = love.graphics.newImage("img/pedestal.png");
    love.graphics.pushCanvas(field.leftCanvas);
    love.graphics.draw(field.leftbg,0,0);
    love.graphics.popCanvas();
    field.draw = function()
        love.graphics.draw(field.rightbg,200,0);
        love.graphics.draw(field.leftCanvas,0,0);
        pushColor();
        love.graphics.setColor(0,0,0);
        love.graphics.rectangle("fill",(gamewidth/2) - 10,0,10,gameheight)
        popColor();
        for i=1,5,1 do
            love.graphics.draw(field.pedestal,10 + ((i-1)*100),field.TEAM_HEIGHT);
        end
        for i=1,5,1 do
            love.graphics.draw(field.pedestal,560 + ((i-1)*100),field.TEAM_HEIGHT);
        end
        for i=1,game.run.shopSlots,1 do
            love.graphics.draw(field.pedestal,80 + ((i-1)*100),field.TEAM_HEIGHT + 200);
        end
        for i=1,game.run.itemSlots,1 do
            love.graphics.draw(field.pedestal,780 + ((i-1)*100),field.TEAM_HEIGHT + 200);
        end
    end
    
    return field;
end