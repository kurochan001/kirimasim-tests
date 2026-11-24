/*
:name: test_user_nettype_active_low_switch_unknown_turnoff_delay
:description: An active-low switch on a user nettype treats unknown controls as an off transition
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.8 6.6.7 4.9.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_user_nettype_active_low_switch_unknown_turnoff_delay.expected
*/
`timescale 1ns/1ns
module test_user_nettype_active_low_switch_unknown_turnoff_delay;
  function automatic int combine(input int drivers[]);
    combine = 0;
    foreach (drivers[i]) combine += drivers[i];
  endfunction
  nettype int original_t with combine;
  original_t left;
  original_t right;
  logic control = 1;
  assign left = 5;
  assign right = 7;
  tranif0 #(2, 5) link(left, right, control);
  string changes = "";
  always @(left) if ($time >= 10)
    changes = {changes, $sformatf(" %0d:%0d", $time, left)};

  task automatic show(string phase);
    $display("%s left=%0d right=%0d", phase, left, right);
  endtask

  initial begin
    #10 show("initial");
    control = 0;
    #1 show("before turn-on");
    #2 show("after turn-on");
    #7 control = 1'bx;
    #3 show("before x turn-off");
    #3 show("after x turn-off");
    #4 control = 0;
    #3 show("after rejoin");
    #7 control = 1'bz;
    #3 show("before z turn-off");
    #3 show("after z turn-off");
    $display("left changes:%s", changes);
  end
endmodule
