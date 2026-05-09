AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	local Data = TBFY_FAConfig.NPCData[self:GetClass()]
	self:SetModel(Data.Model)
	self:SetSolid(SOLID_BBOX);
	self:PhysicsInit(SOLID_BBOX);
	self:SetMoveType(MOVETYPE_NONE);
	self:DrawShadow(true);
	self:SetUseType(SIMPLE_USE);

	self:SetFlexWeight( 10, 0 )
	self:ResetSequence(3)
end

function ENT:Use( activator, caller )
    if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 2;

	if !FA_Application_Requests[activator:SteamID()] then
		net.Start("fa_application_request_menu")
		net.Send(activator)
	else
		TBFY_Notify(activator, 1, 4, FA_GetLang("ApplicationAlreadyPending"))
	end
end

function ENT:Think()
end
