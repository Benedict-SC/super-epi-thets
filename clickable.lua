Clickable = function()
    local clickable = {};
    clickable.x = 0;
    clickable.y = 0;
    clickable.inputUpdate = function(xoff,yoff)
        local mouseDown = love.mouse.isDown(1);
        local rightMouseDown = love.mouse.isDown(2);
        local img = clickable.img;
        if not img then
            clickable.lastMouseDown = mouseDown;
            clickable.lastRightMouseDown = rightMouseDown;
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
        local rightMousePressed = rightMouseDown and not clickable.lastRightMouseDown;
        local rightMouseReleased = clickable.lastRightMouseDown and not rightMouseDown;

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
            elseif mouseReleased then--and clickable.mouseDown then
                clickable.mouseDown = false;
                clickable.onMouseUp();
            end

            if rightMousePressed then
                if not clickable.rightMouseDown then
                    clickable.rightMouseDown = true;
                    clickable.onRightMouseDown();
                end
            elseif rightMouseReleased then--and clickable.rightMouseDown then
                clickable.rightMouseDown = false;
                clickable.onRightMouseUp();
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

            if clickable.rightMouseDown and rightMouseReleased then
                clickable.rightMouseDown = false;
                clickable.onRightMouseUp();
            end
        end

        clickable.lastMouseDown = mouseDown;
        clickable.lastRightMouseDown = rightMouseDown;
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
    clickable.onRightMouseDown = function()
    end
    clickable.onRightMouseUp = function()
    end
    return clickable;
end
