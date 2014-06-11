module Octi
	class Pod
		attr_accessor :player,:prongs

		def initialize(player)
			@prongs = Array.new(3) { Array.new(3, false) }
			@prongs[1][1] = 0
			@player = player
		end
		def player
			return @player
		end
	end
end

