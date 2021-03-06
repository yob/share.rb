require 'share/types/base'

module Share
  module Types
    # The operational transform logic for plain text documents.
    #
    class Text < Base

      INSERT = 'i'
      DELETE = 'd'
      PATH = POSITION = 'p'
      LEFT = 'left'
      RIGHT = 'right'

      class MissingInsertOrDelete < ArgumentError; end
      class DeletedDifferentTextFromSameRegion < StandardError; end
      class DeletedStringDoesNotMatch < StandardError; end

      # Applies <operation> to <snapshot>. Stores no state, just returns
      # the transformed snapshot.
      #
      # snapshot should be a plain old ruby String
      #
      # operation should be an array of hashes that looks something like:
      #
      #     [{'i' => 'foo', 'p' => 0}, {'i' => ' bar', 'p' => 3}]
      #
      def apply(snapshot, operation)
        check_valid_operation operation
        operation.each do |component|
          if component[INSERT]
            snapshot = inject snapshot, component[POSITION], component[INSERT]
          else
            deleted = snapshot[component[POSITION], component[DELETE].length]
            unless component[DELETE] == deleted
              raise DeletedStringDoesNotMatch, "request: #{component} actual: #{deleted}"
            end
            snapshot = snapshot[0, component[POSITION]] + snapshot[component[POSITION] + component[DELETE].length, snapshot.length]
          end
        end
        snapshot
      end

      private

      def _append(new_operation, component)
        return if component[INSERT] == '' || component[DELETE] == ''
        if new_operation.length == 0
          new_operation.push component
        else
          last = new_operation.last
          if last[INSERT] && component[INSERT] && last[POSITION] <= component[PATH] && component[PATH] <= (last[POSITION] + last[INSERT].length)
            new_operation[new_operation.length - 1] = {
              INSERT => inject(last[INSERT], component[POSITION] - last[POSITION], component[INSERT]),
              POSITION => last[POSITION]
            }
          elsif last[DELETE] && component[DELETE] && component[POSITION] <= last[POSITION] && last[POSITION] <= (component[POSITION] + component[DELETE].length)
            new_operation[new_operation.length - 1] = {
              DELETE => inject(component[DELETE], last[POSITION] - component[POSITION], last[DELETE]),
              POSITION => component[POSITION]
            }
          else
            new_operation.push component
          end
        end
      rescue StandardError => e
        raise component.inspect
      end

      def transform_position(position, component, insert_after=false)
        if component[INSERT]
          if component[POSITION] < position || (component[POSITION] == position && insert_after)
            position + component[INSERT].length
          else
            position
          end
        else
          if position <= component[POSITION]
            position
          elsif position <= component[POSITION] + component[DELETE].length
            component[POSITION]
          else
            position - component[DELETE].length
          end
        end
      end

      def transform_component(destination, component, other, side)
        check_valid_operation [component]
        check_valid_operation [other]

        if component[INSERT]
          _append destination, {
            INSERT => component[INSERT],
            POSITION => transform_position(component[POSITION], other, side == RIGHT)
          }
        elsif component[DELETE]
          if other[INSERT] # delete vs insert
            string = component[DELETE]
            if component[POSITION] < other[POSITION]
              _append destination,
                DELETE => string.slice(0, other[POSITION] - component[POSITION]),
                POSITION => component[POSITION]
              string = string.slice(other[POSITION] - component[POSITION])
            end

            if string && string != ''
              _append destination,
                DELETE => string,
                POSITION => component[POSITION] + other[INSERT].length
            end
          else # delete vs delete
            if component[POSITION] >= other[POSITION] + other[DELETE].length
              _append destination, {
                DELETE => component[DELETE],
                POSITION => component[POSITION] - other[DELETE].length
              }
            elsif component[POSITION] + component[DELETE].length <= other[POSITION]
              _append destination, component
            else
              # They overlap somewhere.
              new_component = {DELETE => '', POSITION => component[POSITION]}
              if component[POSITION] < other[POSITION]
                new_component[DELETE] = component[DELETE][0, other[POSITION] - component[POSITION]]
              end

              if component[POSITION] + component[DELETE].length > other[POSITION] + other[DELETE].length
                new_component[DELETE] += component[DELETE].slice(other[POSITION] + other[DELETE].length - component[POSITION], component[DELETE].length)
              end

              # This is entirely optional - just for a check that the deleted
              # text in the two ops matches
              intersect_start = [component[POSITION], other[POSITION]].max
              intersect_end = [component[POSITION] + component[DELETE].length, other[POSITION] + other[DELETE].length].min

              # puts [component, other].inspect
              # puts ["intersect range", intersect_start, intersect_end].inspect
              # puts [component[DELETE], intersect_start - component[POSITION], intersect_end - component[POSITION]].inspect
              # puts [other[DELETE], intersect_start - other[POSITION], intersect_end - other[POSITION]].inspect

              intersect = component[DELETE].slice(intersect_start - component[POSITION], intersect_end - component[POSITION])
              other_intersect = other[DELETE].slice(intersect_start - other[POSITION], intersect_end - other[POSITION])
              # puts ["intersects", intersect, other_intersect].inspect
              # raise DeletedDifferentTextFromSameRegion.new([intersect, other_intersect].inspect) unless intersect == other_intersect
              # puts ["new_component", new_component].inspect
              if new_component != ''
                # This could be rewritten similarly to insert v delete, above.
                new_component[POSITION] = transform_position new_component[POSITION], other
                _append destination, new_component
              end
            end
          end

          # puts ["destination", destination].inspect
          destination
        end
      end


      def invert_component(component)
        if component[INSERT]
          {DELETE => component[INSERT], POSITION => component[POSITION]}
        else
          {INSERT => component[DELETE], POSITION => component[POSITION]}
        end
      end


      def inject(left, position, right)
        left[0, position] + right + left[position, left.length]
      end

      def check_valid_component(component)
        raise MissingPositionField.new(component) unless component[POSITION].is_a?(Fixnum)
        insert_type = component[INSERT].class
        delete_type = component[DELETE].class

        raise MissingInsertOrDelete.new(component) unless component[INSERT] || component[DELETE]
        raise NegativePositionError.new(component) unless component[POSITION] >= 0
      end

      def check_valid_operation(operation)
        operation.each { |component| check_valid_component(component) }
        true
      end

      def invert(operation)
        operation.reverse.each { |component| invert_component component }
      end

      def transform_component_x(left, right, dest_left, dest_right)
        transform_component dest_left, left, right, 'left'
        transform_component dest_right, right, left, 'right'
        nil
      end

    end

  end
end
