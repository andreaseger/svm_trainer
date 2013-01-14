require "spec_helper"
require 'trainer/doe_pattern'

describe Trainer::DoePattern do
  let(:dummy_class) do
    Class.new do
      extend(Trainer::DoePattern)
    end
  end

  let(:center) { [0,0] }
  let(:resolution) { [1,1] }
  context "#pattern_for_center" do
    context "plain" do
      let(:pattern3d) { [[-1,1],[0,1],[1,1],[-1,0],[0,0],[1,0],[-1,-1],[0,-1],[1,-1]] }
      let(:pattern2d) { [[-0.5,0.5],[0.5,0.5],[-0.5,-0.5],[0.5,-0.5]] }
      before(:each) do
        @pattern,_ = dummy_class.pattern_for_center(center, resolution)
      end
      it "should contain 13 points" do
        @pattern.should have(13).things
      end
      it "should contain the 3^d pattern" do
        @pattern.first(9).should =~ pattern3d
      end
      it "should contain the 2^d pattern" do
        @pattern.last(4).should =~ pattern2d
      end
    end
    context "adjust pattern" do
      let(:resolution) { [1,1] }
      let(:x_range) { -2..2 }
      let(:y_range) { -2..2 }
      def test_adjust center, goal3d, goal2d
        p,_ = dummy_class.pattern_for_center(center, resolution, [x_range, y_range])
        p.first(9).should =~ goal3d
        p.last(4).should =~ goal2d
      end
      it "should move the pattern right" do
        goal3d = [[-2,0],[-2,1],[-2,2],[-1,0],[-1,1],[-1,2],[0,0],[0,1],[0,2]]
        goal2d = [[-1.5,0.5],[-1.5,1.5],[-0.5,0.5],[-0.5,1.5]]
        test_adjust [-2,1], goal3d, goal2d
      end
      it "should move the pattern left" do
        goal3d = [[0,0],[0,1],[0,2],[1,0],[1,1],[1,2],[2,0],[2,1],[2,2]]
        goal2d = [[1.5,0.5],[1.5,1.5],[0.5,0.5],[0.5,1.5]]
        test_adjust [2,1], goal3d, goal2d
      end
      it "should move the pattern down" do
        goal3d = [[0,0],[0,1],[0,2],[1,0],[1,1],[1,2],[2,0],[2,1],[2,2]]
        goal2d = [[1.5,0.5],[1.5,1.5],[0.5,0.5],[0.5,1.5]]
        test_adjust [1,2], goal3d, goal2d
      end
      it "should move the pattern in both direction at once" do
        goal3d = [[0,0],[0,1],[0,2],[1,0],[1,1],[1,2],[2,0],[2,1],[2,2]]
        goal2d = [[0.5,0.5],[0.5,1.5],[1.5,0.5],[1.5,1.5]]
        test_adjust [2,2],goal3d, goal2d
      end
      it "should move the pattern up" do
        goal3d = [[0,0],[0,-1],[0,-2],[1,0],[1,-1],[1,-2],[2,0],[2,-1],[2,-2]]
        goal2d = [[1.5,-0.5],[1.5,-1.5],[0.5,-0.5],[0.5,-1.5]]
        test_adjust [1,-2], goal3d, goal2d
      end
    end
  end

  context "#pattern_for_range" do
    let(:x_range) { -1..1 }
    let(:y_range) { -1..1 }
    it "should calculate the center & resolution and call pattern_for_center" do
      dummy_class.expects(:pattern_for_center).with(center, resolution)
      dummy_class.pattern_for_range(x_range, y_range)
    end
  end
  context "#pattern_for_limits" do
    let(:x_limits) { [-1,1] }
    let(:y_limits) { [-1,1] }
    it "should calculate the center & resolution and call pattern_for_center" do
      dummy_class.expects(:pattern_for_center).with(center, resolution)
      dummy_class.pattern_for_limits(x_limits, y_limits)
    end
  end

end