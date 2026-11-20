/*
:name: test_monitorh_monitoro_time_is_not_a_change
:description: $monitorh and $monitoro show arguments without a format in hexadecimal or octal with four-state digits, print once when two arguments change in one time step, and do not print when only $time in their list advances (IEEE 1800-2023 Section 21.2.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.3 21.2.1.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_monitorh_monitoro_time_is_not_a_change.expected
*/
// IEEE 1800-2023 §21.2.3: $monitorh and $monitoro take their arguments like
// $display; an argument without a format is shown in hexadecimal or octal.
// The list is printed at the end of each time step in which an argument
// changes, except that $time, $stime and $realtime do not count as changes,
// and only once when several arguments change in the same step. A new call
// replaces the list. §21.2.1.3: a hexadecimal or octal digit whose bits are
// all x is x, one with some x bits is X, and one with some z bits and no x
// bit is Z.
// Each call is made in a time step that then changes one of its arguments.
// $time is in both lists, but nothing else changes at 5 and 25, so no line
// shows those times. At 10 w becomes 4'bx01z: X in hexadecimal and xZ in
// octal. At 30 v and w change in the same step and one line is printed.

`timescale 1ns/1ns

module test_monitorh_monitoro_time_is_not_a_change;
  logic [5:0] v = 6'd0;
  logic [3:0] w = 4'd0;

  initial begin
    $monitorh("h t=%0d v=", $time, v, " w=", w);
    v = 6'h2a;
    #5;
    #5 w = 4'bx01z;
    #5 $monitoro("o t=%0d v=", $time, v, " w=", w);
    v = 6'o17;
    #5 w = 4'b1111;
    #5;
    #5 v = 6'o40;
    w = 4'b0101;
    #5 $finish;
  end
endmodule
