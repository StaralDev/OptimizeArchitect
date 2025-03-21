--!nolint LocalShadow

local Dynamics = {}
Dynamics.__index = Dynamics

export type Dynamics = typeof(setmetatable({} :: {

	xPrevious : number,

	y : number,
	yDerivative : number,

	k1 : number,
	k2 : number,
	k3 : number,

}, {__index = Dynamics}))

function Dynamics.new(Frequency : number, Decay : number, Attack : number, Initial : number) : Dynamics
	local self : Dynamics = setmetatable({
		k1 = Decay / (math.pi * Frequency),
		k2 = 1/( (2 * math.pi * Frequency) * (2 * math.pi * Frequency) ),
		k3 = Attack * Decay/(2 * math.pi * Frequency),
		
		xPrevious = Initial,
		
		y = Initial,
		yDerivative = Initial
	}, {__index = Dynamics})
	
	return self
end

function Dynamics.Update(self : Dynamics, t : number, x : number, xDerivative : number?) : number
	local xDerivative : number = xDerivative :: number
	
	if not (xDerivative) then
		xDerivative = (x - self.xPrevious)
		self.xPrevious = x
	end
	
	local k2 = math.max(
		self.k2, 
		t*t/2 + t*self.k1/2, 
		t*self.k1
	)
	
	self.y = self.y + t * self.yDerivative
	self.yDerivative = self.yDerivative + t * (x + self.k3*xDerivative - self.y - self.k1*self.yDerivative) / k2
	return self.y
end

return Dynamics