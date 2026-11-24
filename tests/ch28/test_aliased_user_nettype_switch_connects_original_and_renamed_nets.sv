/*
:name: test_aliased_user_nettype_switch_connects_original_and_renamed_nets
:description: A passive switch accepts the original nettype and a second name for the same user nettype
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.8 6.6.7 6.22.6 4.9.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_aliased_user_nettype_switch_connects_original_and_renamed_nets.expected
*/
module test_aliased_user_nettype_switch_connects_original_and_renamed_nets;
  function automatic int total(input int values[]);
    total = 0;
    foreach (values[i]) total += values[i];
  endfunction

  nettype int original_t with total;
  nettype original_t alias_t;
  original_t left, control_left, control_right;
  alias_t right;

  assign left = 5;
  assign right = 7;
  assign control_left = 5;
  assign control_right = 7;
  tran link(left, right);
  tran same_name(control_left, control_right);

  initial #1 $display("alias=%0d/%0d control=%0d/%0d",
                       left, right, control_left, control_right);
endmodule
