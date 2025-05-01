AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	local Data = RES_Config.NPCData[self:GetClass()]
	self:SetModel(Data.Model)
	self:SetSolid(SOLID_BBOX);
	self:PhysicsInit(SOLID_BBOX);
	self:SetMoveType(MOVETYPE_NONE);
	self:DrawShadow(true);
	self:SetUseType(SIMPLE_USE);

	self:SetFlexWeight(10, 0)
	self:ResetSequence(3)
end

function ENT:Use(activator, caller )
    if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 2;

	if RES_NoElectionJob() then
		if activator:IsPCandidate() then
			TBFY_Notify(activator, 1, 4, RES_GetLang("AlreadyPCandidate"))
		elseif RES_Phase == 0 then
			net.Start("res_open_application")
			net.Send(activator)
		else
			TBFY_Notify(activator, 1, 4, RES_GetLang("NoSignUp"))
		end
	else
		TBFY_Notify(activator, 1, 4, RES_GetLang("NoSignUp"))
	end
end

function ENT:Think()
end
