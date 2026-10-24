/*
:name: test_macromodule_keyword_defines_module
:description: A module definition is enclosed between module and endmodule and named by the identifier after the keyword, and macromodule can be used in place of module: a macromodule is instantiated, connected and named in the hierarchy like a module (IEEE 1800-2023 Section 23.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2 23.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macromodule_keyword_defines_module.expected
*/
// IEEE 1800-2023 §23.2: a module definition is enclosed between the keywords
// module and endmodule, the identifier after the keyword is the name of the
// module, and the keyword macromodule can be used interchangeably with module
// (an implementation may treat such definitions differently, for example in
// how it optimizes them, but they define modules). macromodule_adder and
// macromodule_wrapper are defined with macromodule, the second instantiating
// the first, and plain_scaler with module; the end labels repeat the names.
// The top module instantiates each by its name, connects their ports, and
// calls a task of each instance in turn, which prints its hierarchical name
// with %m, so the macromodule instances are part of the hierarchy like the
// module instance. The sums are printed at time 1.

macromodule macromodule_adder(input logic [3:0] a, input logic [3:0] b,
                              output logic [4:0] s);
  assign s = a + b;
  task show();
    $display("%m");
  endtask
endmodule : macromodule_adder

macromodule macromodule_wrapper(input logic [3:0] x, output logic [4:0] y);
  macromodule_adder inner(.a(x), .b(4'd5), .s(y));
endmodule : macromodule_wrapper

module plain_scaler(input logic [3:0] x, output logic [5:0] y);
  assign y = x * 3;
  task show();
    $display("%m");
  endtask
endmodule : plain_scaler

module test_macromodule_keyword_defines_module;
  logic [3:0] p = 4'd9, q = 4'd8;
  wire [4:0] s1, s2;
  wire [5:0] s3;

  macromodule_adder add(.a(p), .b(q), .s(s1));
  macromodule_wrapper wrap(.x(p), .y(s2));
  plain_scaler scale(.x(q), .y(s3));

  initial begin
    #1;
    $display("add: %0d + %0d = %0d", p, q, s1);
    $display("wrap: %0d + 5 = %0d", p, s2);
    $display("scale: %0d * 3 = %0d", q, s3);
    add.show();
    wrap.inner.show();
    scale.show();
  end
endmodule
