module Trainer
  module DoePattern
    # 1=max, -1=min, 0=center, resolution=|0->1|
    #     3^d pattern         #      2^d pattern
    #   |                     #   |
    #  1| O   O   O           #  1|
    #   |                     #   |   O   O
    #  0| O   O   O           #  0|
    #   |                     #   |   O   O
    # -1| O   O   O           # -1|
    #   +------------         #   +------------
    #    -1   0   1           #    -1   0   1

    #
    # create a list of 13 points aligned in the DOE 2^d and 3^d pattern in the given window
    # @param  center [x,y] center of the pattern window
    # @param  resolution [double,double] margin between center and the edges in x and y direction
    # @param  adjust [x,y] unless false move the pattern inside the edges of bigger window
    #
    # @return [Array] list of 13 points
    def pattern_for_center center, resolution, adjust=false
      x3d,y3d = center.map.with_index{|e,i|
        [ e-resolution[i],  #-1
          e,                # 0
          e+resolution[i]]  # 1
      }
      if adjust
        # move pattern into search window
        x, y = adjust
        if x3d[0] < x.min
          t=x3d[0]
          x3d.map! { |e| e + (t.abs - x.min.abs).abs }
        elsif x3d[2] > x.max
          t=x3d[2]
          x3d.map! { |e| e - (t.abs - x.max.abs).abs }
        end

        if y3d[0] < y.min
          t=y3d[0]
          y3d.map! { |e| e + (t.abs - y.min.abs).abs }
        elsif y3d[2] > y.max
          t=y3d[2]
          y3d.map! { |e| e - (t.abs - y.max.abs).abs }
        end
        center = [x3d[1],y3d[1]]
      end

      x2d,y2d = center.map.with_index{|e,i|
        [ e-0.5*resolution[i],  #-0.5
          e+0.5*resolution[i]]  # 0.5
      }

      return x3d.product(y3d).concat(x2d.product(y2d)), resolution
    end
    def pattern_for_range x, y
      resolution = [x,y].map { |e| (e.min.abs+e.max.abs)/2.0 }
      center = [x,y].map.with_index { |e,i| e.min+resolution[i] }
      pattern_for_center(center, resolution)
    end
    def pattern_for_limits x,y
      pattern_for_range x[0]..x[1], y[0]..y[1]
    end
  end
end
