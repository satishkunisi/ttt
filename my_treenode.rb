module Searchable

  def dfs(target = nil, &blk)
    if blk.nil?
      return self if self.value == target
    else
      return self if blk.call(self.value)
    end

    self.children.each do |child|
      next if child.nil?

      result = child.dfs(target, &blk)
      return result unless result.nil?
    end

    nil
  end

  def bfs(target = nil, &blk)

    if blk.nil?
      block = Proc.new { |value| value == target }
    else
      block = blk
    end

    stack = []
    stack << self

    until stack.empty?
      current_node = stack.shift
      if block.call(current_node.value, target)
        return current_node
      else
        current_node.children.each do |child|
          stack << child unless child.nil?
        end
      end
    end
  end

end

class PolyTreeNode
  include Searchable

  attr_reader :children, :parent
  attr_accessor :value

  def initialize(parent = nil, children = [], value = nil)
    @parent = parent
    @children = children
    @value = value
  end

  def add_child(new_child)
    new_child.parent = self
    @children << new_child
  end

  def remove_child(old_child)
    old_child.parent = nil
    @children.delete(old_child)
  end

  protected
  attr_writer :parent

end



root = PolyTreeNode.new(nil, [], "root")
node2 = PolyTreeNode.new(nil, [], "A")
node3 = PolyTreeNode.new(nil, [], "B")
node4 = PolyTreeNode.new(nil, [], "C")
node5 = PolyTreeNode.new(nil, [], "D")

root.add_child(node2)
node2.add_child(node3)
node2.add_child(node4)
node4.add_child(node5)

p root.bfs("D") { |value, target| value == target }