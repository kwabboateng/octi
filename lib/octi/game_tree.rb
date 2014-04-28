module Octi
	class GameTree

		attr_accessor :comp

		def generate
		

			initial_game_state = GameState.new(comp, @board = Board.new(6,7))
			generate_moves(initial_game_state)
			initial_game_state
	end

	def generate_moves(game_state)
		next_player = (game_state.current_player == comp ? human : comp)
		game_state.board.each_index do |x|
			x.each_with_index do |game_state.current_player, position|
			unless player_at_position #base case placeholder

				if game_state.board[x][position] == nil # is this necessary?
					@board.each do |col|
						col.each do |cell|
							if cell.is_a?(Pod)
								pod = cell
								if pod.player == comp
									if pod.can_move?(@board,x,position, col,cell)
										next_board = game_state.board.dup
										next_board[col][cell] = nil
										next_board[x][position] = pod
										next_board = game_state.board.dup
										next_game_state = (GameState.cache.states[next_baord] 
											||= GameState.new(next_player, next_board)))
										game_state.moves << next_game_state
										generate_moves(next_game_state)										
									end
								else
									pod.prongs.each do |prong|
										if !prong 
											prong = true
											next_board = game_state.board.dup
											next_board[x][position] = #game_state.current
											next_board = game_state.board.dup
											next_game_state = (GameState.cache.states[next_baord] 
												||= GameState.new(next_player, next_board)))
											game_state.moves << next_game_state
											generate_moves(next_game_state)	
										end	
									end						
								end
							end
						end
					end
				end
				next_board = game_state.board.dup
				next_game_state = (GameState.cache.states[next_baord] 
					||= GameState.new(next_player, next_board)))
				game_state.moves << next_game_state
				generate_moves(next_game_state)
			end
		end
	end
end