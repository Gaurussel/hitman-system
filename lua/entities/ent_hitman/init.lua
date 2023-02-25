AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( "models/Humans/Group01/male_02.mdl" )
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal( )
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid( SOLID_BBOX )
	self:CapabilitiesAdd( CAP_ANIMATEDFACE, CAP_TURN_HEAD )
	self:SetUseType( SIMPLE_USE )
	self:DropToFloor()
end
	
function ENT:Use( ply )
	if HITMAN.config.cantOrder[ply:Team()] then
		DarkRP.notify(ply, 1, 4, "У вас нет доступа!")
		return
	end

	net.Start("hitman.OpenMenu")
	net.Send(ply)
end