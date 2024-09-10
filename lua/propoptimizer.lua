local function checkEntitiesForCollisions()
    while true do
        local allEntities = ents.FindByClass("prop_physics")
        table.Add(allEntities, ents.FindByClass("prop_ragdoll"))
        for i = 1, #allEntities do
            local ent1 = allEntities[i]

            if IsValid(ent1) then
                local ent1Min, ent1Max = ent1:GetCollisionBounds()
                local ent1Pos = ent1:GetPos()
                local ent1Bounds = {
                    min = ent1:LocalToWorld(ent1Min),
                    max = ent1:LocalToWorld(ent1Max)
                }
                for j = i + 1, #allEntities do
                    local ent2 = allEntities[j]

                    if IsValid(ent2) then
                        local ent2Min, ent2Max = ent2:GetCollisionBounds()
                        local ent2Pos = ent2:GetPos()
                        local ent2Bounds = {
                            min = ent2:LocalToWorld(ent2Min),
                            max = ent2:LocalToWorld(ent2Max)
                        }
                        if not (
                            ent1Bounds.max.x < ent2Bounds.min.x or ent1Bounds.min.x > ent2Bounds.max.x or
                            ent1Bounds.max.y < ent2Bounds.min.y or ent1Bounds.min.y > ent2Bounds.max.y or
                            ent1Bounds.max.z < ent2Bounds.min.z or ent1Bounds.min.z > ent2Bounds.max.z
                        ) then
                            ent1:SetCollisionGroup(COLLISION_GROUP_WORLD)
                            ent2:SetCollisionGroup(COLLISION_GROUP_WORLD)
                        end
                    end
                end
            end


            if i % 50 == 0 then
                coroutine.yield()
            end
        end

        coroutine.yield()
    end
end

local checkCollisionCoroutine = coroutine.create(checkEntitiesForCollisions)

hook.Add("Think", "CheckEntityCollisions", function()
    if coroutine.status(checkCollisionCoroutine) ~= "dead" then
        local success, errorMessage = coroutine.resume(checkCollisionCoroutine)
        if not success then
            print("Error in collision check coroutine: " .. errorMessage)
        end
    end
end)
