/*
:name: test_if_condition_known_nonzero
:description: An if condition selects its first statement only for a known nonzero value; zero, x and z conditions skip it and run the else statement when there is one (IEEE 1800-2023 Section 12.4)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_if_condition_known_nonzero.expected
*/
// IEEE 1800-2023 §12.4: the first statement of an if runs when the condition
// is true, which means it has a known value that is not zero. A zero
// condition, or one that is x or z, is false: the first statement does not
// run, and the else statement runs if there is one.
//
// The conditions are a multi-bit value with a single 1 that is not bit 0,
// a negative int, a nonzero real, zero values of each kind, x and z of one
// bit, and 4-bit values whose other bits are 0 and one bit is x or z (they
// have no known 1, so they are not known to be nonzero). Each is tested once
// with an else and once without; "taken" counts the first statements that
// ran in the ifs without an else.

module test_if_condition_known_nonzero;
  logic [3:0] w;
  logic s;
  int n;
  real r;
  int taken;

  task automatic show(string what, logic [3:0] v);
    w = v;
    if (w) $display("%s: then", what);
    else $display("%s: else", what);
    if (w) taken++;
  endtask

  initial begin
    taken = 0;
    show("4'b0100", 4'b0100);
    show("4'b1000", 4'b1000);
    show("4'b0000", 4'b0000);
    show("4'b00x0", 4'b00x0);
    show("4'bz000", 4'bz000);
    show("4'b0x0z", 4'b0x0z);
    $display("4-bit ifs without else: taken=%0d", taken);

    taken = 0;
    s = 1'b1;
    if (s) $display("1'b1: then"); else $display("1'b1: else");
    if (s) taken++;
    s = 1'b0;
    if (s) $display("1'b0: then"); else $display("1'b0: else");
    if (s) taken++;
    s = 1'bx;
    if (s) $display("1'bx: then"); else $display("1'bx: else");
    if (s) taken++;
    s = 1'bz;
    if (s) $display("1'bz: then"); else $display("1'bz: else");
    if (s) taken++;
    $display("1-bit ifs without else: taken=%0d", taken);

    taken = 0;
    n = -3;
    if (n) $display("int -3: then"); else $display("int -3: else");
    if (n) taken++;
    n = 0;
    if (n) $display("int 0: then"); else $display("int 0: else");
    if (n) taken++;
    r = 0.25;
    if (r) $display("real 0.25: then"); else $display("real 0.25: else");
    if (r) taken++;
    r = 0.0;
    if (r) $display("real 0.0: then"); else $display("real 0.0: else");
    if (r) taken++;
    $display("int and real ifs without else: taken=%0d", taken);
  end
endmodule
