class Board

  attr_reader :rows

  def self.make_board
    Array.new(3) { Array.new(3, nil) }
  end

  def initialize
    @rows = self.class.make_board
  end

  def [](pos)
    x, y = pos
    @rows[x][y]
  end

  def []=(pos = [], mark)
    x, y = pos[0], pos[1]
    @rows[x][y] = mark
  end

  def cols
    cols = Array.new(3) { [] }
    @rows.each do |row|
      row.each_with_index do |mark, col|
        cols[col] << mark
      end
    end

    cols
  end

  def diags
    up_diag = [[0, 0], [1, 1], [2, 2]]
    down_diag = [2, 0], [1, 1], [0, 2]

    [up_diag, down_diag].map do |diag|
      diag.map do |x, y|
        @rows[x][y]
      end
    end

  end

  def winner
    [self.cols + self.diags + self.rows].each do |combos|
      combos.each do |combo|
        return :x if combo == [:x, :x, :x]
        return :o if combo == [:o, :o, :o]
      end
    end

    nil
  end

  def tied?
    @rows.all? { |row| row.none? { |el| el.nil? } }
  end

  def won?
    !winner.nil?
  end

  def over?
    won? || tied?
  end

  def empty?(pos)
    x, y = pos[0], pos[1]
    @rows[x][y].nil?
  end


  def dup
    duped_board = @rows.map { |row| row.dup }
  end
end

class TicTacToe

  attr_reader :board

  def initialize(player1, player2)
    @board = Board.new
    @players = {:x => player1, :o => player2 }
    @turn = :x
  end

  def play
    until board.over?
      self.show
      pos = current_player.take_turn(@board, @turn)
      self.mark_board(pos, @turn)
      switch_turn
    end

    puts "Game over! #{@players[@board.winner].name} won!"
  end

  def show
    self.board.rows.each { |row| p row }
  end

  def current_player
    @players[@turn]
  end

  def mark_board(pos, mark)
    @board[pos] = mark
  end

  def switch_turn
    @turn == :x ? @turn = :o : @turn = :x
  end

  def current_player
    @players[@turn]
  end

end

class HumanPlayer
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def take_turn(board, turn)
    while true
      print "#{@name}, enter your move: (ex: 0,1): "
      pos = gets.chomp.split(",").map {|el| el.to_i }

      if valid_move?(pos, board)
        return pos
      else
        puts "Invalid move!"
      end
    end
  end

  def valid_move?(pos, board)
    pos.all? { |el| (0..2).include?(el) } && board.empty?(pos)
  end
end


class


player1 = HumanPlayer.new("Me")
player2 = HumanPlayer.new("Them")

ttt = TicTacToe.new(player1, player2)

ttt.play


