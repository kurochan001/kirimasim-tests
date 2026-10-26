/*
:name: test_dpi_export_caller_allocated_arguments
:description: C code calls an exported SystemVerilog function with actual arguments it allocates itself as canonical svBitVecVal arrays, which the export writes in the layout of the SystemVerilog type and reads back, through the C prototype that the same formal list would have in an import (IEEE 1800-2023 Sections H.8.2 and H.8.5)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 H.8.2 H.8.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_export_caller_allocated_arguments.c
:expected_stdout: @test_dpi_export_caller_allocated_arguments.expected
*/
// IEEE 1800-2023 §H.8.2: an exported SystemVerilog subroutine has the same C
// header as an imported function with the same result type and formal list,
// and for arguments passed by reference the C caller allocates the actual
// argument with the layout SystemVerilog uses for that type. §H.8.5: the
// caller owns that allocation, and a packed array needs an array of the
// canonical type, svBitVecVal or svLogicVecVal, allocated and, for an input,
// initialized before the call.
//
// The export sv_fill has an output bit [63:0], an output int and an input
// bit [7:0], so its C parameters are svBitVecVal *, int * and const
// svBitVecVal *. The C code allocates the two words of the 64-bit output and
// the one word of the input, gives the input a value, and calls the export,
// which builds a value that names each byte of its result. The C code then
// prints the two words of the output and the int, so the word order of the
// canonical representation and the value written through the pointer are both
// visible. The export sv_sum shows a result and small input formal arguments
// passed by value.

module test_dpi_export_caller_allocated_arguments;
  export "DPI-C" function sv_fill;
  export "DPI-C" function sv_sum;
  import "DPI-C" context function void c_call_exports();

  function void sv_fill(output bit [63:0] w, output int n,
                        input bit [7:0] p);
    w = {p, 8'h01, 8'h23, 8'h45, 8'h67, 8'h89, 8'hab, 8'hcd};
    n = 42;
  endfunction

  function int sv_sum(input int a, input int b);
    return a + b;
  endfunction

  initial c_call_exports();
endmodule
