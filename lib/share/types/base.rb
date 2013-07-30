module Share
  module Types
    # Superclass for the operational transform implementations.
    #
    class Base
      LEFT = 'left'
      RIGHT = 'right'

      # Assume two sets of operations made by different users to the same
      # version of the document. Transforms one of the sets so they apply to
      # the document after the first set.
      #
      # left_operations and right_operations should be arrays of hashes that
      # looks something like:
      #
      #     [{'i' => 'foo', 'p' => 0}, {'i' => ' bar', 'p' => 3}]
      #
      def transform(left_operations, right_operations, type)
        # TODO can this be simplified to always be a left transform? The first
        #      arg can be the ops to be transformed, the second arg could be the
        #      ops that have been applied and the 3 arg could be removed.
        unless [LEFT, RIGHT].include?(type)
          raise ArgumentError.new("type must be 'left' or 'right'")
        end

        if right_operations.length == 0
          left_operations
        elsif right_operations.length == 0
          right_operations
        elsif left_operations.length == 1 && right_operations.length == 1
          transform_component [], left_operations.first, right_operations.first, type
        elsif type == LEFT
          transformation = transform_x(left_operations, right_operations)
          transformation.first
        elsif type == RIGHT
          transformation = transform_x(right_operations, left_operations)
          transformation.last
        else
          raise "This should never happen"
        end
      end

      private

      def transform_x(left, right)
        check_valid_operation(left)
        check_valid_operation(right)

        new_right = []

        right.each do |component|
          # puts "RIGHT EACH"
          new_left = []

          # puts ["left",left].inspect
          left.each_with_index do |left_component, index|
            # puts "LEFT EACH"
            # puts ["index", index].inspect
            next_component = []

            transform_component_x left_component, component, new_left, next_component

            if next_component.length == 1
              component = next_component.first
            elsif next_component.length == 0
              # puts ["next c length is 0", new_left, left.slice(index + 1, left.length)].inspect
              left.slice(index + 1, left.length).each {|_component| _append new_left, _component }
              component = nil
              break
            else
              _left, _right = transform_x left.slice(index + 1, left.length), next_component
              _append new_left, _left
              _append new_right, _right
              component = nil
              break
            end

          end

          _append new_right, component if component
          left = new_left
        end

        [left, new_right]
      end

      def transform_component_x(left, right, dest_left, dest_right)
        transform_component dest_left, left, right, 'left'
        transform_component dest_right, right, left, 'right'
        nil
      end

    end
  end
end
