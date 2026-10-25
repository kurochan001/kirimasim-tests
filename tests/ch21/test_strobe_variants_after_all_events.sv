/*
:name: test_strobe_variants_after_all_events
:description: $strobe, $strobeb, $strobeo and $strobeh take the arguments, escapes and formats of $display and print at the end of the time step, after the nonblocking update and the events it causes (IEEE 1800-2023 Section 21.2.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.2 21.2.1.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_strobe_variants_after_all_events.expected
*/
// IEEE 1800-2023 §21.2.2: $strobe and its b, o and h variants take their
// arguments like $display, with the same escape sequences and formats, and
// an argument without a format is shown in decimal, binary, octal or
// hexadecimal like $display, $displayb, $displayo and $displayh
// (§21.2.1.1). The output is made at the end of the current time step, when
// all of its events have occurred, just before time advances.
// In each of the time steps 1 to 4 the initial procedure sets v to 10, calls
// one strobe task, prints v with $display at once and schedules v <= 100.
// The nonblocking update wakes the always procedure, which then sets v to
// 200 in the same time step. Each strobe line therefore shows 200 (11001000,
// 310 or c8), after the $display line of its time step showing 10, and
// before the line of the next time step. Only one strobe task is called per
// time step, so the order of their lines is fixed.

module test_strobe_variants_after_all_events;
  logic [7:0] v = 8'd0;

  always @(v) if (v == 8'd100) v = 8'd200;

  initial begin
    #1;
    v = 8'd10;
    $strobe("strobe\tv=%0d %h", v, v);
    $display("t1 v=%0d", v);
    v <= 8'd100;
    #1;
    v = 8'd10;
    $strobeb("b ", v);
    $display("t2 v=%0d", v);
    v <= 8'd100;
    #1;
    v = 8'd10;
    $strobeo("o ", v);
    $display("t3 v=%0d", v);
    v <= 8'd100;
    #1;
    v = 8'd10;
    $strobeh("h ", v, " %0d", v);
    $display("t4 v=%0d", v);
    v <= 8'd100;
    #1;
    $display("t5 v=%0d", v);
  end
endmodule
