class Board
  attr_reader :rows
  
  #Creates blank board as a 3 X 3 array
  def self.blank_grid
    (0...3).map { [nil] * 3 } # = Array.new(3) { Array.new(3, nil) }
  end

  #initializes board and assigns to @rows variable; optionally pass in rows
  def initialize(rows = self.class.blank_grid)
    @rows = rows
  end
  
  # 
  def dup
    duped_rows = rows.map(&:dup) #duped_rows = rows.map { |row| row.dup }
    self.class.new(duped_rows) #returning a new, deep dup'd board 
  end
  
  #checks if a position in empty; uses [] getter method
  def empty?(pos)
    self[pos].nil?
  end
  
  #sets an @rows position using [] and mark; ex: board[1,2] = :x @rows[1][2]
  def []=(pos, mark) # pos = contents of brackets & mark = what follows eq sign
    raise "mark already placed there!" unless empty?(pos)
    
    x, y = pos[0], pos[1]
    @rows[x][y] = mark
  end

  #gets @rows element based on two element array passed using []; ex: board[1,1]
  def [](pos)
    x, y = pos[0], pos[1]
    @rows[x][y]
  end
  
  #returns array of arrays. each array holds marks for each column
  def cols
    cols = [[], [], []]
    @rows.each do |row| # row = conents of [0][0], [0][1], [0][2]
      row.each_with_index do |mark, col| #:x, 0 ; :o, 1, :x, 0
                            #ex: [[:x, :o, :x], [:x, nil, :o], [:x, nil, :x]]
        cols[col] << mark   #cols[0] = the three marks in column 0 
      end
    end

    cols
  end
  
  
  # 
  def diagonals
    down_diag = [[0, 0], [1, 1], [2, 2]] #diagonal values of @rows
    up_diag = [[0, 2], [1, 1], [2, 0]]
    
    #equivalent to: down_diag.map { |x, y| rows[x][y] }
    #ex: [[:x, :o, :x], [:x, nil, :o], [:x, nil, :x]]
    
    [down_diag, up_diag].map do |diag|
      # Note the `x, y` inside the block; this unpacks, or
      # "destructures" the argument. Read more here:
      # http://tony.pitluga.com/2011/08/08/destructuring-with-ruby.html
      diag.map { |x, y| @rows[x][y] }
    end
  end
  
  def over?
    # style guide says to use `or`, but I (and many others) prefer to
    # use `||` all the time. We don't like two ways to do something
    # this simple.
    won? || tied?
  end

  def won?
    !winner.nil?
  end

  def tied?
    return false if won?

    # no empty space?
    @rows.all? { |row| row.none? { |el| el.nil? }}
    # do all the rows have no positions that are nil?
    #
    # @rows.all? do |row|   <= returns true if all rows true for condition
    #   row.none? do |el|   <= returns true if all positions false for condition
    #     el.nil?           <= checks if each position in row is nil
    #   end                 <= if it's not nil, there's gotta be a mark
    # end
    
    
  end

  def winner # summing arrays gives array of 8 rows, diags, columns in 
            #[:x, :o, :x] 
    (rows + cols + diagonals).each do |triple|
      return :x if triple == [:x, :x, :x] #checks for consecutive :x & :o's
      return :o if triple == [:o, :o, :o] 
    end

    nil #returns mark of winner; otherwise returns nil
  end
end

class TicTacToe
  class IllegalMoveError < RuntimeError #creates illegal move class
  end

  attr_reader :board #creates board getter

  def initialize(player1, player2)
    @board = Board.new
    @players = { :x => player1, :o => player2 } #uses mark as key fo plyr obj
    @turn = :x #x goes first 
  end

  def show #prints the board
    # not very pretty printing!
    self.board.rows.each { |row| p row }
  end

  def run
    until self.board.over? #board is over when won or tied
      play_turn
    end

    if self.board.won? 
      winning_player = self.players[self.board.winner]
      puts "#{winning_player.name} won the game!"
    else
      puts "No one wins!"
    end
  end

  attr_reader :players, :turn

  def play_turn
    while true
      #sets current player based on turn (which is either :x or :o)
      current_player = self.players[self.turn]
      
      #calls player move method, passing the game and the mark to the player)
      pos = current_player.move(self, self.turn)
      
      #keeps the loop running until player places mark on an empty position
      break if place_mark(pos, self.turn)
    end

    # swap next whose turn it will be next
    @turn = ((self.turn == :x) ? :o : :x)
  end

  def place_mark(pos, mark) #takes in the position  & the mark
    if self.board.empty?(pos)  #checks if position is empty
      self.board[pos] = mark   #if it is, places mark in that position
      true # returns true
    else
      false # if it ain't empty or it's not a valid position, returns false
    end
  end
end

class HumanPlayer
  attr_reader :name #makes the name acessible

  def initialize(name)
    @name = name #initializes the name
  end

  def move(game, mark)
    game.show  #shows the board
    while true
      puts "#{@name}: please select your space" #captures move from user
      x, y = gets.chomp.split(",").map(&:to_i)  # ex: "1,2" => ["1", "2"] =>
                                                # [1, 2]
      if HumanPlayer.valid_coord?(x, y)
        #keeps looping until user inputs valid coords       
        return [x, y]                   
      else
        puts "Invalid coordinate!"
      end
    end
  end

  private
  def self.valid_coord?(x, y)
    #ensures coords are between 0 & 2
    [x, y].all? { |coord| (0..2).include?(coord) } 
  end
end

class ComputerPlayer
  attr_reader :name

  def initialize
    @name = "Tandy 400"
  end

  def move(game, mark)
    winner_move(game, mark) || random_move(game, mark)
  end

  private
  
  # checks all positions to see if there's a winning move
  def winner_move(game, mark) 
    (0..2).each do |x|
      (0..2).each do |y|
        board = game.board.dup #using the board's deep dup method
        pos = [x, y]

        next unless board.empty?(pos) #makes sure current position is empty
        board[pos] = mark #sets the current position on the dup'd board
        
        #returns the position if pos would make computer the winner
        # (remember, mark is set by the game object to track who is who)
        return pos if board.winner == mark 
      end
    end

    # no winning move
    nil
  end

  def random_move(game, mark)
    board = game.board
    while true
      range = (0..2).to_a
      pos = [range.sample, range.sample]

      return pos if board.empty?(pos)
    end
  end
end
