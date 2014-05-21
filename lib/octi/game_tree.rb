module Octi
	class GameTree

		attr_accessor :comp, :human, :positions, :comp_pos, :board, :inserts,:pod
		
		def initialize(board_position)

		end

		# def generate
		# 	initial_game_state = GameState.new(@comp = Player.new(0),@human = Player.new(1), @board = Board.new(6,7))			
		# end


### MINIMAX ALGO ###
		def minimax (position, player, depth)
			return maxmove(position, player, depth)
		end

		def maxmove (position, player, depth)
			if position.game_ended?(player) || depth == 0
				return evaluate_end(position)
			else
				best_move = nil #+infinity?
				moves = position.legal_moves(player) #children
				for move in moves
					new_move = minmove(move.execute_move(position), @human, depth-1)
					if value(move) > value(best_move)
						best_move = move
					end
				end
				return best_move
			end
		end

		def minmove(position, player, depth)
			best_move = nil #-infinity?
			moves = position.legal_moves(player)
			for move in moves
				new_move = maxmove(move.execute_move(position), @comp, depth)
				if value(move) > value(best_move)
					best_move = move
				end 
			end
			return best_move
		end

		#heuristic evaluation function
		def value(position, player)
			
			#distance to base
			pods = position.pods #are scores player specific or do they take opponent into account
			podlocs = position.podLocs

			#x number of pods
			#prongs in reserve 
			player.prongs_in_reserve
			#prongs on board
			number_of_pods = 0
			distance_to_base = 100
			prongs_on_board =0
			mobility_arr = position.hops
			for l in podlocs[player.index]
				if pods[l.x][l.y].is_a?(Pod)
					number_of_pods++
					distance_to_base = distance(l, player, distance_to_base)
					pod.prongs.each do |peg|
						peg ? prongs_on_board++
					end
				end
			end
			prong_count = prongs_in_reserve - prongs_on_board
			mobility = mobility_arr.length
			#prong distribution -mobility

			return distance_to_base + number_of_pods + prong_count + mobility
			#				
		end	

		def distance(l, player, distance_to_base)
			if player  == @comp
				1.upto(4) do |i|
					dist = sqrt((l.x-1)**2+(l.y-i)**2)
					if dist < distance_to_base
						distance_to_base = dist
					end
				end
			elsif player  == @comp
				1.upto(4) do |i|
					dist = sqrt((l.x-5)**2+(l.y-i)**2)
					if dist < distance_to_base
						distance_to_base = dist
					end
				end
			end	

			return distance_to_base	
		end
	end
end

