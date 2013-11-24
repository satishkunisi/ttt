# You need to implement #children to use Searchable.
module Searchable
  def dfs(target = nil, &prc)
    if prc.nil?
      return self if value == target
    else
      return self if prc.call(self)
    end

    children.each do |child|
      next if child.nil?

      result = child.dfs(target, &prc)
      return result unless result.nil?
    end

    nil
  end

  def bfs(target = nil,&prc)
    nodes = [self]
    until nodes.empty?
      node = nodes.shift

      if block_given?
        return node if node.value == target
      else
        return node if prc.call(self)
      end

      nodes.concat(node.children)
    end

    nil
  end

  def count
    1 + children.map(&:count).inject(0, :+)
  end
end

class BinaryTreeNode
  include Searchable

  attr_accessor :value
  attr_reader :parent

  def initialize(value = nil)
    @value, @parent, @children = value, nil, [nil, nil]
  end

  def children
    @children.reject { |child| child.nil? }
  end

  def detach
    return unless self.parent

    self.parent.children_[self.pos.position] = nil
    self.parent = nil
    self.pos = nil
  end

  def left_child
    @children[0]
  end

  def right_child
    @children[1]
  end

  def left_child=(child)
    set_child(child, 0)
  end

  def right_child=(child)
    set_child(child, 1)
  end

  protected
  attr_accessor :children_, :position
  attr_writer :parent

  def set_child(new_child, position)
    unless [0, 1].include?(position)
      raise IllegalArgumentError.new("invalid position")
    end

    old_child = @children[position]

    # don't need to do anything if they're equal
    return if old_child == new_child

    new_child && new_child.detach
    old_child && old_child.detach

    @children[position] = new_child
    new_child.parent = self
    new_child.pos = position

    nil
  end
end

class PolyTreeNode
  include Searchable

  attr_accessor :value
  attr_reader :parent

  def initialize(value = nil)
    @value, @parent, @children = value, nil, []
  end

  def children
    # We dup to avoid someone inadvertantly trying to add/remove a
    # child without permission. But it also may make `children`
    # confusing, in that modifications to `node.children` do not
    # actually persist.
    @children.dup
  end

  def add_child(new_child)
    @children << new_child
    new_child.parent = self
  end

  def remove_child(child)
    @children.delete(child)
    child.parent = nil
  end

  protected
  attr_writer :parent
end
