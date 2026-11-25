/*
:name: test_dpi_pure_call_optimization
:description: Pure DPI calls may reuse results and omit unused evaluations
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_dpi_pure_call_optimization
:dpi_c: @test_dpi_pure_call_optimization.c
:expected_stdout: @test_dpi_pure_call_optimization.expected
*/
`timescale 1ns/1ns
module test_dpi_pure_call_optimization;
  import "DPI-C" pure function int dpi_pure_lookup(input int seed);
`ifdef OBSERVE_STATIC_LOCAL_AS_PURE
  import "DPI-C" pure function int dpi_local_history(input int seed);
`else
  import "DPI-C" function int dpi_local_history(input int seed);
`endif
`ifdef OBSERVE_GLOBAL_AS_PURE
  import "DPI-C" pure function int dpi_global_history(input int seed);
`else
  import "DPI-C" function int dpi_global_history(input int seed);
`endif

  wire signed [31:0] unused = dpi_pure_lookup(29);
  int a, b, c, d;
  int p, q, r, x, y, z;

  initial begin
    void'(dpi_pure_lookup(19));
    a = dpi_pure_lookup(7);
    b = dpi_pure_lookup(7);
    c = dpi_pure_lookup(11);
    d = dpi_pure_lookup(7);
    $display("pure: %0d,%0d,%0d,%0d", a, b, c, d);

    $display("before history calls");
    p = dpi_local_history(3);
    q = dpi_local_history(3);
    r = dpi_local_history(3);
    x = dpi_global_history(13);
    y = dpi_global_history(13);
    z = dpi_global_history(13);
    $display("local history: %0d,%0d,%0d", p, q, r);
    $display("global history: %0d,%0d,%0d", x, y, z);
`ifdef OBSERVE_NET_VALUE
    #1 $display("visible: %0d", unused);
`endif
    $finish(0);
  end
endmodule
