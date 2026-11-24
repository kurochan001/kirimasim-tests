/*
:name: test_type_option_goal_defaults_and_shared_targets
:description: Type coverage goals default to 100 and can be set independently for a group, point and cross across instances of the same type
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.7.1 19.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_option_goal_defaults_and_shared_targets.expected
*/
module test_type_option_goal_defaults_and_shared_targets;
  bit a, b;

  covergroup measured;
    point_a: coverpoint a;
    point_b: coverpoint b;
    both: cross point_a, point_b;
  endgroup

  covergroup untouched;
    point_a: coverpoint a;
    point_b: coverpoint b;
    both: cross point_a, point_b;
  endgroup

  measured left_one, right_one;
  untouched other;

  initial begin
    left_one = new;
    right_one = new;
    other = new;
    $display("defaults=%0d %0d %0d", measured::type_option.goal,
             measured::point_a::type_option.goal, measured::both::type_option.goal);

    measured::type_option.goal = 83;
    measured::point_a::type_option.goal = 61;
    measured::both::type_option.goal = 47;
    left_one.option.goal = 23;
    right_one.option.goal = 31;

    $display("type targets=%0d %0d %0d %0d", right_one.type_option.goal,
             measured::point_a::type_option.goal, measured::point_b::type_option.goal,
             measured::both::type_option.goal);
    $display("instance targets=%0d %0d %0d %0d", left_one.option.goal,
             right_one.option.goal, right_one.point_a.option.goal,
             right_one.both.option.goal);
    $display("other type=%0d %0d %0d", other.type_option.goal,
             untouched::point_a::type_option.goal, untouched::both::type_option.goal);

    left_one.type_option.goal = 91;
    $display("shared target=%0d %0d %0d", left_one.type_option.goal,
             right_one.type_option.goal, measured::type_option.goal);
  end
endmodule
