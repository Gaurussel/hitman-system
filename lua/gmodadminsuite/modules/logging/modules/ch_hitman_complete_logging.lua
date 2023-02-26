local MODULE = GAS.Logging:MODULE()

MODULE.Category = "DarkRP"
MODULE.Name = "Hits"
MODULE.Colour = Color(255,0,0)

MODULE:Setup(function()
	MODULE:Hook("AddHitmanOrder", "addorder", function( victim, ply, price )
		MODULE:Log("{1} made an order for a person {2}. Price = {3}", GAS.Logging:FormatPlayer( ply ), GAS.Logging:FormatPlayer( victim ), GAS.Logging:FormatMoney( price ) )
	end)

	MODULE:Hook("HitmanOrderComplete", "completeorder", function( victim, ply, price )
		MODULE:Log("{1} completed order for {2}. Price = {3}", GAS.Logging:FormatPlayer( ply ), GAS.Logging:FormatPlayer( victim ), GAS.Logging:FormatMoney( price ) )
	end)

	MODULE:Hook("HitmanOrderRemove", "removeorder", function( ply )
		MODULE:Log("{1} removed order because he left from the server", GAS.Logging:FormatPlayer( ply ))
	end)
end)

GAS.Logging:AddModule(MODULE)