/*
:name: test_dpi_call_directions_and_context_chain
:description: A C function imported as a function and one imported as a task are called from SystemVerilog, an exported SystemVerilog function is called from C, and a context import calls that export and reads its declaration scope through a C helper, so the call directions and the context call chain work (IEEE 1800-2023 Sections H.2, H.6.5 and H.9, A.2.6)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 35.5.1.6 H.2 H.6.5 H.9 H.9.3 A.2.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_call_directions_and_context_chain.c
:expected_stdout: @test_dpi_call_directions_and_context_chain.expected
*/
// IEEE 1800-2023 H.2: functions implemented in C and given import
// declarations are called from SystemVerilog, tasks implemented in
// SystemVerilog and given export declarations are called from C, and an
// imported C task or function can call an exported task or function. H.6.5:
// only a context import may safely call an exported SystemVerilog routine.
// H.9: a DPI-C context call chain starts with a context import and continues
// in C; svGetScope and svGetNameFromScope give the declaration scope, which
// H.9.1 says is the scope of the import, not of the call site.
//
// The top module imports c_add as a function and c_set as a task and calls
// both. The instance u of wA_dpi_unit declares the context function c_chain
// and the export sv_twice; its initial block calls c_chain, which calls the C
// helper scope_name, not called directly from SystemVerilog but part of the
// chain, and then the exported sv_twice(7), whose result 14 gives 15. The
// printed scope is the instance u, the declaration scope.

`timescale 1ns/1ns

module wA_dpi_unit;
  import "DPI-C" context function int c_chain(input int v);
  export "DPI-C" function sv_twice;

  function int sv_twice(input int x);
    return x * 2;
  endfunction

  initial $display("chain %0d", c_chain(7));
endmodule

module test_dpi_call_directions_and_context_chain;
  import "DPI-C" function int c_add(input int a, input int b);
  import "DPI-C" task c_set(output int o);

  wA_dpi_unit u();
  int o;

  initial begin
    $display("added %0d", c_add(2, 3));
    c_set(o);
    $display("task %0d", o);
  end
endmodule
