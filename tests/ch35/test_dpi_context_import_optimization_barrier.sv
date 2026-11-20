/*
:name: test_dpi_context_import_optimization_barrier
:description: A context import that reads and writes a module variable through exported functions sees the value written just before its call, and SystemVerilog code sees its write right after the call, also in a loop, while a noncontext import affects only its output and inout actual arguments (IEEE 1800-2023 Section 35.5.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 35.7
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_context_import_optimization_barrier.c
:expected_stdout: @test_dpi_context_import_optimization_barrier.expected
*/
// IEEE 1800-2023 §35.5.3: a call of an import that is not context can read
// or write only its actual arguments, so it is no barrier to optimization;
// a context import may read and write any SystemVerilog data, by VPI or by
// calling exported subroutines (35.7), so its call is a barrier. Code around
// a context call can therefore neither keep a variable in a copy across the
// call nor move a write of it past the call.
//
// around_call writes x, calls the context import c_swap_x, which reads x
// with the export sv_get_x and writes it with sv_set_x, and then reads x.
// The import has to see the value written just before the call, 3, and the
// code after the call the value the import wrote, 103. In the loop, the
// context import c_bump_x adds 5 to x through the exports on each pass, so
// the sum of the values of x read at the start of each pass is 10+15+20.
// Code that kept x across the calls would print 3, 30 or a final x of 10.
// The noncontext import c_args_only writes its output and inout arguments,
// the only data it may affect: they take the values it wrote, and x keeps
// the value it had. Icarus Verilog 13.0 has no DPI.

module test_dpi_context_import_optimization_barrier;
  import "DPI-C" context function int c_swap_x(input int v);
  import "DPI-C" context function void c_bump_x();
  import "DPI-C" function void c_args_only(input int a, output int o, inout int io);
  export "DPI-C" function sv_get_x;
  export "DPI-C" function sv_set_x;

  int x;

  function int sv_get_x();
    return x;
  endfunction

  function void sv_set_x(input int v);
    x = v;
  endfunction

  function automatic int around_call(input int a);
    int seen;
    x = a;
    seen = c_swap_x(a + 100);
    return seen * 1000 + x;
  endfunction

  function automatic int sum_over_calls(input int n);
    int s = 0;
    for (int i = 0; i < n; i++) begin
      s += x;
      c_bump_x();
    end
    return s;
  endfunction

  initial begin
    int r, s, o, io;
    x = 0;
    r = around_call(3);
    $display("context call: the import saw x=%0d, x after the call=%0d", r / 1000, r % 1000);
    x = 10;
    s = sum_over_calls(3);
    $display("context calls in a loop: sum=%0d, x=%0d", s, x);
    o = -1;
    io = 5;
    c_args_only(7, o, io);
    $display("noncontext call: o=%0d io=%0d x=%0d", o, io, x);
  end
endmodule
