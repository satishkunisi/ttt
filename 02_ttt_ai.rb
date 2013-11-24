require './tree_node'
require './tic_tac_toe'

class TicTacToeNode < PolyTreeNode
  # One limitation of this class is that it only looks for winning
  # moves; it will not look for potential losing moves.

  attr_reader :evaluating_player

  # Create a node representing a TTT board; for simplicity, we record
  # the player who would play next. We will evaluate the position from
  # the persepective of the evaluating player; we'll try to find moves
  # that will help the evaluating player win.
  def initialize(board, next_player, evaluating_player)
    super({
      :board => board,
      :next_player => next_player
    })

    @evaluating_player = evaluating_player
    # A winning node is one where we have either (1) already won the
    # game, or (2) can force a win no matter what the opponent
    # does. To start, we don't know if this is a winning node.
    @winning_node = nil
  end

  def board
    value[:board]
  end

  def next_player
    value[:next_player]
  end

  def winning_node?
    @winning_node
  end

  def evaluate_position
    if board.over?
      # game is over; did we win?
      @winning_node = (board.winner == evaluating_player)
      return self
    end

    self.class.open_positions(board).each do |pos|
      # We're going to try each move. Here we create a new node to
      # represent a potential move.
      next_board = board.dup
      next_board[pos] = next_player
      next_next_player = (next_player == :x) ? :o : :x
      child = TicTacToeNode.new(next_board, next_next_player, evaluating_player)
      self.add_child(child)

      # Evaluate the outcome of this position.
      child.evaluate_position

      if ((next_player != evaluating_player) && (not child.winning_node?))
        # The opponent can force a non winning position! Do not bother
        # evaluating further; we can't force a victory.
        @winning_node = false
        return self
      elsif ((next_player == evaluating_player) && (child.winning_node?))
        # We can choose a winning move; we can stop early, since we
        # know we can force a victory.
        @winning_node = true
        return self
      end
    end

    # The block didn't cause a hard return, so we have to deal with remaining cases.

    # If next_player == evaluating_player, that means _none_ of my children were winning nodes
    # since line 63 would have caught any child node that was winning. Thus I am not a winning
    # node.

    # If next_player != evaluating_player, that means all of my children were
    # winning nodes, since line 58 would have caught any child node that was not winning. Thus
    # I am a winning node. So our condition is simply:

    @winning_node = (next_player != evaluating_player)
    return self
  end

  def self.open_positions(board)
    open_positions = []
    (0..2).each do |row|
      (0..2).each do |col|
        pos = [row, col]
        open_positions << pos if board.empty?(pos)
      end
    end

    open_positions
  end
end

class TicTacToeAI
  def self.choose_move(board, player)
    node = TicTacToeNode.new(board, player, player)
    node.evaluate_position

    node
  end
end
