/*
:name: test_always_latch_comb_in_interface
:description: always_latch and always_comb procedures in an interface run as they do in a module (IEEE 1800-2023 Section 9.2.2.3)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.3 9.2.2.2 25.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_latch_comb_in_interface.expected
*/
// IEEE 1800-2023 §25.3: an interface can contain procedures, which behave as
// they would in a module. An always_latch procedure (9.2.2.3) and an
// always_comb procedure (9.2.2.2) in an interface run once at time 0 and then
// whenever a variable they read changes. The latch output follows d while
// en is 1 and holds its value while en is 0; the combinational output is
// d + 1 while en is 1 and 0 otherwise.

interface latch_if (input logic en, input logic [3:0] d);
  logic [3:0] q, c;

  always_latch
    if (en) q <= d;

  always_comb
    if (en) c = d + 4'd1;
    else c = 4'd0;
endinterface

module test_always_latch_comb_in_interface;
  logic en = 0;
  logic [3:0] d = 4'd0;
  latch_if u_if (.en(en), .d(d));

  initial begin
    #1 $display("en=0: c=%0d", u_if.c);
    en = 1;
    d = 4'd5;
    #1 $display("en=1 d=5: q=%0d c=%0d", u_if.q, u_if.c);
    d = 4'd7;
    #1 $display("en=1 d=7: q=%0d c=%0d", u_if.q, u_if.c);
    en = 0;
    d = 4'd9;
    #1 $display("en=0 d=9: q=%0d c=%0d", u_if.q, u_if.c);
  end
endmodule
