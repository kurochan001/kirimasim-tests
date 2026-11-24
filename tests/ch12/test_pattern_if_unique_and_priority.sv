/*
:name: test_pattern_if_unique_and_priority
:description: Unique and priority qualify pattern matching if chains
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.6.2 12.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_pattern_if_unique_and_priority.expected
*/
// The unique patterns do not overlap. Both priority patterns match code
// three, so the earlier pattern must win.
module test_pattern_if_unique_and_priority;
  task automatic check(input bit [2:0] code);
    int u, p;
    unique if (code matches (3'b011)) u = 10;
    else if (code matches (3'b101)) u = 20;
    else u = 30;

    priority if (code matches (3'b011)) p = 1;
    else if (code matches .n &&& (n == 3 || n == 7)) p = 2;
    else p = 3;

    $display("code=%0d unique=%0d priority=%0d", code, u, p);
  endtask
  initial begin
    check(3);
    check(7);
    check(5);
  end
endmodule
