module Octi
	class Position
		def initialize(pods, comp, human)
			@pods = pods.clone
			@comp = comp
			@human = human
			@podLocs = Array.new() { Array.new() }
			@podLocs[@comp.index] = find_pods_for_player(@comp)
			@podLocs[@human.index] = find_pods_for_player(@human)
			@prongs = Array.new() { Array.new() }
			@prongs[@comp.index] = @comp.prong_reserve
			@prongs[@human.index] = @human.prong_reserve		
		end

		def podLocs
			return @podLocs
		end

		def pods
			return @pods
		end

		def comp
			return @comp
		end

		def human
			return @human
		end

		def legal_moves(player)
			return [prong_inserts(player), hops(player), jumps(player)]
		end

		def has_prongs(pod, i, j)
			if pod.prongs[i][j] == true && pod.prongs[i][j] != 0
				return true
			elsif pod.prongs[i][j] == 0
				return 0
			else
				return false
			end
		end

		def on_board(x,y)
			if (0..5)===(x) && (0..6)===(y)
				return true
			else
				return false
			end
		end

		def prong_inserts(player)
			#returns coordinates of a new prong 
			inserts = []
			for l in @podLocs[player.index]
				pod = @pods[l.x][l.y]
				pod.prongs.each_with_index do |col, i|
					col.each_with_index do |has_prong, j|
						if !has_prong && !(i == 1 && j == 1)
							inserts << Insert.new(l,i,j, player)				
						end
					end
				end	
			end	
			return inserts	
		end

		def hops(player)
			#returns origin and destination
			hops_total = []
			for l in @podLocs[player.index]
				pod = @pods[l.x][l.y]  # pod of playerb
				pod.prongs.each_with_index do |col, i|
					col.each_with_index do |has_prong, j|
						if has_prong && !(i == 1 && j == 1)
							delta_x = i -1
							delta_y = j-1
							delta_i = delta_x + 1
							delta_j = delta_y + 1
							d = Location.new(l.x+delta_i, l.y+delta_j) # destination
							if (on_board(d.x,d.y) && @pods[d.x][d.y] == nil)
								from = Location.new(l.x,l.y)
								to = Location.new(l.x+i, l.y+j)
								hops_total << Hop.new(l, d)
							end
						end
					end
				end
			end
			return hops_total
		end


		def jumps(player)
			#returns origin and destination
			jumped = []
			jumps = []
			for l in @podLocs[player.index]
				pod = @pods[l.x][l.y]
				jumps << jumpy(pod, jumped, l,l, player)
			end
			ap jumps
			return jumps.flatten#captured(jumps.flatten)
		end

		def jumpy(pod, jumped_p, s, c, player)
			results = Array.new
			avoid = []
			pod.prongs.each_with_index do |col, i|
				col.each_with_index do |has_prong, j|

					if (has_prong && !(i == 1 && j == 1)) #on board
						#on_board(curr_x+2*i, curr_y+2*j
						delta_x = i -1
						delta_y = j-1
						delta_i = delta_x*2
						delta_j = delta_y*2
						d = Location.new(c.x+delta_i, c.y+delta_j) #destination 
						pod_loc = Location.new(c.x+delta_x, c.y+delta_y)
						if on_board(d.x, d.y) && @pods[c.x+delta_x][c.y+delta_y].is_a?(Pod)&& 
							@pods[d.x][d.y] == nil && !(avoid.include? (pod_loc ))
							
							#from is origin before jump sequence
							from = Location.new(s.x,s.y)
							
							#to is a jump destination in sequence
							to = Location.new(d.x,d.y) 

							#player can jump oppenent's pods and his own pods
							jumped_p << pod_loc
							avoid << pod_loc 

							results << Jump.new(from, to, jumped_p)
							results << jumpy(pod, jumped_p, s, d, player)
					
						end
					end
				end
			end
			return results.flatten
		end

		def captured(jumps)
			puts jumps
			if jumps.empty?
				return jumps
			end
			for jump in jumps
				for i in 0..(jump.jumped_pods.length) do
					ap i
					new_jump = jump.clone
					new_jump.jumped_pods.combination(i).to_a
					idx = jumps.index(jump)
					jumps.insert(idx, new_jump)
					jumps << new_jump
				end
			end
			puts "returning..."
			return jumps
		end

		#return array of player's pod locations 
		def find_pods_for_player(player)
			results = []
			@pods.each_with_index do |col, i|
				col.each_with_index do |row, j|	
					
					if @pods[i][j].is_a?(Pod) &&  @pods[i][j].player == player
					
						results << Location.new(i,j) #consider returning just location
					end
				end
			end
			return results#.flatten
		end

		
		def heuristic_value(player)
			c_number_of_pods = 0
			h_number_of_pods = 0
			distance_to_base = 100
			c_prongs_on_board = 0
			h_prongs_on_board = 0
			c_mobility_arr = hops(@comp)
			h_mobility_arr = hops(@human)

			for l in @podLocs[@comp.index]
				if @pods[l.x][l.y].is_a?(Pod)
					pod = @pods[l.x][l.y]
					c_number_of_pods =c_number_of_pods +1
					c_distance_to_base = distance(l, player, distance_to_base)
					pod.prongs.each_with_index do |col, i|
						col.each_with_index do |has_prong, j|
							if has_prong && !(i == 1 && j == 1)
								c_prongs_on_board = c_prongs_on_board + 1
							end
						end
					end
				end
			end
			for l in @podLocs[@human.index]
				if @pods[l.x][l.y].is_a?(Pod)
					pod = @pods[l.x][l.y]
					h_number_of_pods = h_number_of_pods + 1
					h_distance_to_base = distance(l, player, distance_to_base)
					pod.prongs.each_with_index do |col, i|
						col.each_with_index do |has_prong, j|
							if has_prong && !(i == 1 && j == 1)
								h_prongs_on_board = h_prongs_on_board+1
							end
						end
					end
				end
			end


			prong_count = (@comp.prong_reserve - c_prongs_on_board) - (@human.prong_reserve - h_prongs_on_board)
			mobility = c_mobility_arr.length + h_mobility_arr.length
			number_of_pods = c_number_of_pods - h_number_of_pods
			distance_to_base = (h_distance_to_base - c_distance_to_base)*10
			#prong distribution -mobility
			val = distance_to_base*2 + number_of_pods*5 + prong_count/4 + mobility/4
			#ap "val = #{val}"
			return distance_to_base*2 + number_of_pods*5 + prong_count/4 + mobility/4
		end	

		def distance(l, player, distance_to_base)
			if player  == @comp
				1.upto(4) do |i|
					dist = Math.sqrt((l.x-1)**2+(l.y-i)**2)
					if dist < distance_to_base
						distance_to_base = dist
					end
				end
			elsif player  == @human
				1.upto(4) do |i|
					dist = sqrt((l.x-5)**2+(l.y-i)**2)
					if dist < distance_to_base
						distance_to_base = dist #negative
					end
				end
			end	
			return distance_to_base	
		end

		def game_ended?
			if self.end_value != nil
				true
			else
				return false
			end
		end

		def end_value
			#if pod is on enemy base
			@podLocs[@comp.index].each do |pod| 
				@human.bases.each do |base|
					if pod == base
						return 100
					end
				end
			end

			@podLocs[@human.index].each do |pod| 
				@comp.bases.each do |base|
					if pod == base
						return -100
					end
				end
			end

			return nil
			
		end
	end
end