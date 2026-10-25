/*
:name: test_syntax_enable_gates
:description: bufif0, bufif1, notif0 and notif1 declared with and without drive strength and three delays, with several named and unnamed instances that list output, data input and control input (IEEE 1800-2023 Section 28.6)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.6 28.3 28.3.2 28.3.4 A.3.1 A.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_syntax_enable_gates.expected
*/
// IEEE 1800-2023 §28.6, A.3.1, A.3.4: the keywords bufif0, bufif1, notif0
// and notif1 take an optional drive strength and up to three delays, then
// one or more instances separated by commas. An instance has an optional
// name and three terminals: output, data input, control input. bufif0 and
// notif0 drive when the control is 0, bufif1 and notif1 when it is 1, the
// notif gates invert the data, and a gate that does not drive outputs z.
// With three delays the first is the rise delay, the second the fall delay
// and the third the delay of transitions to z; a z to 1 change is a rise.
//
// The logic part applies all four data and control combinations to the four
// gate types. The timed part drives a bufif1 declaration with
// (pull0, strong1) and #(2, 4, 6) and prints its two instances with %v
// between the delays of a fall, a rise, a turn-off and a turn-on.

`timescale 1ns/1ns

module test_syntax_enable_gates;
  reg d, en, td, te;
  wire b0, b1, n0, n1, n1b;
  wire t1, t2;

  bufif0 g_b0 (b0, d, en);
  bufif1 (b1, d, en);
  notif0 g_n0 (n0, d, en);
  notif1 g_n1 (n1, d, en), (n1b, d, en);

  bufif1 (pull0, strong1) #(2, 4, 6) g_t1 (t1, td, te), (t2, td, te);

  task show;
    $display("d=%b en=%b bufif0=%b bufif1=%b notif0=%b notif1=%b%b",
             d, en, b0, b1, n0, n1, n1b);
  endtask

  task timed;
    $display("t=%0t t1=%v t2=%v", $time, t1, t2);
  endtask

  initial begin
    d = 0; en = 0; td = 0; te = 1;
    #1 show;
    d = 1;
    #1 show;
    d = 0; en = 1;
    #1 show;
    d = 1;
    #1 show;
    #6 timed;     // t=10
    td = 1;       // rise at 12
    #1 timed;     // t=11
    #2 timed;     // t=13
    te = 0;       // to z at 19
    #5 timed;     // t=18
    #2 timed;     // t=20
    te = 1;       // z to 1 at 22
    #1 timed;     // t=21
    #2 timed;     // t=23
    td = 0;       // fall at 27
    #3 timed;     // t=26
    #2 timed;     // t=28
  end
endmodule
