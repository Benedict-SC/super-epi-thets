Clickable = function()
    local clickable = {};
    clickable.x = 0;
    clickable.y = 0;
    clickable.inputUpdate = function(xoff,yoff)
        local mouseDown = love.mouse.isDown(1);
        local img = clickable.img;
        if not img then
            clickable.lastMouseDown = mouseDown;
            return;
        end

        xoff = xoff or 0;
        yoff = yoff or 0;

        local mx, my = love.mouse.getPosition();
        local x = clickable.x + xoff;
        local y = clickable.y + yoff;
        local hovered = mx >= x and my >= y and mx < x + img:getWidth() and my < y + img:getHeight();
        local wasHovered = clickable.hovered;
        local mousePressed = mouseDown and not clickable.lastMouseDown;
        local mouseReleased = clickable.lastMouseDown and not mouseDown;

        if hovered then
            if not wasHovered then
                clickable.hovered = true;
                clickable.onHoverEnter();
            end

            if mousePressed then
                if not clickable.mouseDown then
                    clickable.mouseDown = true;
                    clickable.onMouseDown();
                end
            elseif mouseReleased then --and clickable.mouseDown then
                clickable.mouseDown = false;
                clickable.onMouseUp();
            end
        else
            if wasHovered then
                clickable.hovered = false;
                clickable.onHoverExit();
            end

            if clickable.mouseDown and mouseReleased then
                clickable.mouseDown = false;
                clickable.onMouseUp();
            end
        end

        clickable.lastMouseDown = mouseDown;
    end
    --specific clickables should override the following functions- blank ones are provided here in the base class to avoid crashing when called
    clickable.onHoverEnter = function()
    end
    clickable.onHoverExit = function()
    end
    clickable.onMouseDown = function()
    end
    clickable.onMouseUp = function()
    end
    return clickable;
end
