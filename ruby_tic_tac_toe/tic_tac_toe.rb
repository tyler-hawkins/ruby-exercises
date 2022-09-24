class Game
	def initialize()
		puts "Starting new tic-tac-toe game"
		@players=[]; 
		2.times do 
			@players.push(Player.new) 
		end
		@board = Array.new(3) { Array.new(3) }
		puts "Game created!"
		puts show_board
	end

	def show_board
		puts "Board: #{@board}"
	end
end

class Player
	attr_reader :name
	attr_accessor :marker
	attr_accessor :wins	
	@@markers_in_use = []

	def initialize()
		@name = get_name
		@marker = get_marker
		@wins = 0
		puts "New player created: " + info
	end

	def marker=(marker)
		@marker = marker
	end

	def win
		@wins += 1
	end

	private
	def get_name
		print "New player, enter your name: "
		@name = gets.chomp 
		while @name.length == 0 do
			puts "Your name must be at least 1 letter."
			print "Enter your name: "
			@name = gets.chomp
		end
		@name
	end

	def get_marker
		print "#{@name}, enter which symbol you'd like to use (e.g., X, O): "
		@marker = gets.chomp[0] 
		while @@markers_in_use.include?(@marker) do
			puts "That marker is already in use. Please choose another."
			print "Enter which symbol you'd like to use: "
			@marker = gets.chomp[0] 
		end
		@@markers_in_use.push(@marker)
		@marker
	end

	def info
		"#{@name} (#{@marker}) has #{@wins} wins."
	end
end

game = Game.new