AbilityStack = function()
    local aStack = {}
    aStack.stack = Array(); 
    aStack.registerAbilityTrigger = function(sourcePet,abilityType,abilityFunction,args)
        aStack.stack.push({src=sourcePet,type=abilityType,func=abilityFunction,args=args});
    end
    aStack.allCompleteCallback = function() end
    aStack.callbackSet = false;
    aStack.startProcessing = function(allCompleteCallback)
        if allCompleteCallback and (not aStack.callbackSet) and (not (allCompleteCallback == aStack.processNext)) then
            aStack.allCompleteCallback = allCompleteCallback;
            aStack.callbackSet = true;
        end
        aStack.processNext();
    end
    aStack.processNext = function()
        if #aStack.stack > 0 then
            local ability = aStack.stack.pop();
            ability.func(aStack.processNext,ability.args);
        else
            local completeCallback = aStack.allCompleteCallback;
            aStack.allCompleteCallback = function() end
            aStack.callbackSet = false;
            completeCallback();
        end
    end
    return aStack;
end
