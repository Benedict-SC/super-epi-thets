Ribbons = function()
    local r = {};
    r.bg = love.graphics.newImage("img/ribbonbg.png");
    r.ribbon = love.graphics.newImage("img/ribbon.png");
    r.back = Button("img/xbutton.png");
    r.back.onClick = function()
        game.manager.hideRibbons();
    end
    r.back.x = 757;
    r.back.y = 3;
    r.load = function()
        local savefile = love.filesystem.read("superepithets_save.json");
        local savedCheevos = json.decode(savefile);
        for i=1,6,1 do
            local tier = RibbonTiers[i];
            for j=1,#tier,1 do
                --update ribbon and sticker status from file
                local rpet = tier[j];
                rpet.ribbon = savedCheevos[rpet.id].ribbon;
                rpet.sticker = savedCheevos[rpet.id].sticker;
            end
        end
    end
    r.save = function()
        local prog = {};
        for i=1,6,1 do
            local tier = RibbonTiers[i];
            for j=1,#tier,1 do
                local rpet = tier[j];
                prog[rpet.id] = {
                    ribbon = rpet.ribbon;
                    sticker = rpet.sticker;
                }
            end
        end
        local body = json.encode(prog);
        local hooray, message = love.filesystem.write("superepithets_save.json",body);
		if message then
			error("extreme failure!\n" .. message);		
		end
    end
    r.earnRibbon = function(id)
        for i=1,6,1 do
            local tier = RibbonTiers[i];
            for j=1,#tier,1 do
                local rpet = tier[j];
                if rpet.id == id then
                    rpet.ribbon = true;
                end
            end
        end
    end
    r.earnSticker = function(id)
        for i=1,6,1 do
            local tier = RibbonTiers[i];
            for j=1,#tier,1 do
                local rpet = tier[j];
                if rpet.id == id then
                    rpet.sticker = true;
                end
            end
        end
    end
    r.petSpacingX = 56;
    r.petSpacingY = 85;
    r.gridOffsetX = 195;
    r.gridOffsetY = 0;
    r.foodOffsetX = 687;
    r.stickerScale = 0.58; --percent of the 100px/100px pet/food images to draw them at;
    r.hoverX = 0;
    r.hoverY = 0;
    r.foodHoverX = 0;
    r.update = function()
        r.back.inputUpdate(0,0);
        local mx, my = love.mouse.getPosition();
        r.hoverX = math.floor((mx - r.gridOffsetX)/r.petSpacingX);
        r.hoverY = math.floor((my - r.gridOffsetY)/r.petSpacingY);
        r.foodHoverX = math.floor((mx - r.foodOffsetX)/r.petSpacingX);
    end
    r.draw = function()
        love.graphics.draw(r.bg);
        r.back.draw();

        for i=1,6,1 do
            local tier = RibbonTiers[i];
            local foods = RibbonFoodTiers[i];
            for j=1,#tier,1 do
                local rpet = tier[j];
                pushColor();
                if not rpet.sticker then
                    love.graphics.setColor(0,0,0);
                else
                    love.graphics.setColor(1,1,1);
                end
                love.graphics.draw(rpet.loadedImg,r.gridOffsetX + (r.petSpacingX*j),r.gridOffsetY + (r.petSpacingY*i),0,r.stickerScale);
                if not rpet.ribbon then
                    love.graphics.setColor(0,0,0);
                else
                    love.graphics.setColor(1,1,1);
                end
                love.graphics.draw(r.ribbon,r.gridOffsetX + (r.petSpacingX*j) + 38,r.gridOffsetY + (r.petSpacingY*i) + 35,0,0.8);
                if (r.hoverX == j) and (r.hoverY == i) then
                    --love.graphics.draw(rpet.loadedImg,r.gridOffsetX + (r.petSpacingX*j),r.gridOffsetY + (r.petSpacingY*i),0,r.stickerScale);
                    local text = getAbilityText(rpet.id);
                    love.graphics.setColor(0,0,0);
                    love.graphics.rectangle("fill",10,10,935,100);
                    love.graphics.setColor(1,1,1);
                    love.graphics.rectangle("fill",13,13,929,94);
                    love.graphics.draw(dice[rpet.tier],14,14);
                    love.graphics.setColor(1,0.29,0);
                    love.graphics.print(rpet.name,58,9);
                    love.graphics.setColor(0,0,0);
                    love.graphics.setFont(smallfont_bold);
                    for k=1,3,1 do
                        love.graphics.print(text[k],20,34 + (15*k));
                    end
                    love.graphics.setFont(mainfont);
                end
                popColor();
            end
            for j=1,#foods,1 do
                local rfood = foods[j];
                love.graphics.draw(rfood.loadedImg,r.foodOffsetX + (r.petSpacingX*j),r.gridOffsetY + (r.petSpacingY*i),0,r.stickerScale);
                pushColor();
                if (r.foodHoverX == j) and (r.hoverY == i) then
                    --love.graphics.draw(rpet.loadedImg,r.gridOffsetX + (r.petSpacingX*j),r.gridOffsetY + (r.petSpacingY*i),0,r.stickerScale);
                    local text = rfood.effectText;
                    love.graphics.setColor(0,0,0);
                    love.graphics.rectangle("fill",10,10,1085,40);
                    love.graphics.setColor(1,1,1);
                    love.graphics.rectangle("fill",13,13,1079,34);
                    love.graphics.setColor(0,0,0);
                    love.graphics.setFont(smallfont_bold);
                    love.graphics.print(text,20,15);
                    love.graphics.setFont(mainfont);
                end
                popColor();
            end
        end
    end
    return r;
end