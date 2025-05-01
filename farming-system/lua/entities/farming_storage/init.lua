AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/Items/item_item_crate.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )
end

function ENT:Use(activator, caller)
    if !activator:IsPlayer() then return end
    if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 2;

	net.Start("Farming_BoxMenu")
	net.Send(activator)
	activator.lastFarmingBox = self
end

function ENT:EatFruit(Player)
	if self.ID and self:Getcount() > 0 then
		self:Setcount(self:Getcount() - 1)
		DarkRP.notify(Player, 1, 4, "You ate a " .. self.ID .. ".")
		local energy = Player:getDarkRPVar("Energy")
		Player:setSelfDarkRPVar("Energy", energy and math.Clamp(energy + FarmingDatabase[self.ID].Hunger, 0, 100))
		if self:Getcount() < 1 then
			self:Setcontents("Empty")
			self.ID = nil
		end
	end
end

function ENT:Harvest()
	for k,v in pairs(ents.FindInSphere(self:GetPos(),100)) do
		if (v:GetClass() == "farming_plot" or v:GetClass() == "farming_pot") and !v.Dead and v.DGrowing then
	    local HAmount = v.FruitAmount
			if !self.ID then
				self.ID = v.ID
				self:Setcontents(v.ID)
			end

			if v.ID == self.ID then
				local Amount = self:Getcount() + HAmount
				self:Setcount(Amount)
				v:Harvested()
				DarkRP.notify(activator, 1, 4, "You successfully harvested " .. HAmount .. " " .. v.ID .. ".")
				break
			end
		end
	end
end

function ENT:Think()
end

function ENT:Touch(TouchEnt)
end
