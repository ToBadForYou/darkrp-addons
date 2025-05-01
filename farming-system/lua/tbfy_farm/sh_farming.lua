hook.Add("ShouldCollide", "NoCollisionPlots", function(ent1,ent2)
    if (ent1:GetClass() == "farming_plot" and ent2:IsPlayer()) or (ent2:GetClass() == "farming_plot" and ent1:IsPlayer()) then 
        return false 
    end
end)