/*
:name: test_35_extra_35_5_1_6_cxx_linkage
:description: A foreign function compiled as C++ reaches SystemVerilog through an extern "C" definition, and calls an exported SystemVerilog function through its C linkage, so the C linkage holds at the boundary (IEEE 1800-2023 Section 35.5.1.6)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.6 H.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_35_extra_35_5_1_6_cxx_linkage.c
:expected_stdout: @test_35_extra_35_5_1_6_cxx_linkage.expected
*/
// IEEE 1800-2023 §35.5.1.6: a C++ implementation of DPI must obey C linkage
// at the boundary; an exception that escapes an imported subroutine is
// undefined. H.2: the boundary uses the C function call and linking model in
// both directions.
//
// When the foreign file is compiled as C++ (Verilator compiles it so), its
// helper triple lives in a namespace and has C++ linkage; only the imported
// entry point cxx_chain and the exported sv_plus are extern "C". Compiled as
// C, as the suite allows, every function has C linkage and the chain gives
// the same result, so the expected output is common to both. cxx_chain is a
// context import, so it may call the exported SystemVerilog function sv_plus
// through its C prototype, and returns 3 * 5 + (5 + 1) = 21. The escape of a
// C++ exception is not exercised, because the standard leaves that behavior
// undefined.
module test_35_extra_35_5_1_6_cxx_linkage;
  import "DPI-C" context function int cxx_chain(input int v);
  export "DPI-C" function sv_plus;

  function int sv_plus(input int x);
    return x + 1;
  endfunction

  initial $display("cxx chain %0d", cxx_chain(5));
endmodule
