include('shared.lua')

function ENT:Initialize ()
end

function ENT:Draw()
	if IsValid(self.Pile) then
		local mat = Matrix()
		mat:Scale(Vector(1, 1, 52))
		self.Pile:EnableMatrix("RenderMultiply",mat)
	end	
	
	self:DrawModel()
end

function ENT:Think()
	if !self.Pile or !IsValid(self.Pile) then		
		self.Pile = ClientsideModel("models/school/paper.mdl", RENDERGROUP_OPAQUE);
		self.Pile:SetAngles(self:GetAngles())
		self.Pile:SetPos(self:GetPos()+self:GetUp()*-1.5)
		self.Pile:SetMaterial("models/debug/debugwhite")
		self.Pile:SetParent(self.Entity)		
	end		
end

function ENT:OnRemove()
	if IsValid(self.Pile) then
		self.Pile:Remove()
	end
end	