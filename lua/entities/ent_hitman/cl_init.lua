include( "shared.lua" )

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:DrawTranslucent()
	if LocalPlayer():GetPos():Distance( self:GetPos() ) > 500 then return end	
	-- Basic setups
	local Pos = self:GetPos()
    local Ang = LocalPlayer():EyeAngles()
	Ang:RotateAroundAxis( Ang:Forward(), 90 )
	Ang:RotateAroundAxis( Ang:Right(), 90 )

	cam.Start3D2D(self:GetPos()+self:GetUp()*80, Ang, 0.1)
		draw.SimpleText("Заказ на убийство", "htRoboto70", 0, 0, Color(0, 184, 148), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	cam.End3D2D()
end