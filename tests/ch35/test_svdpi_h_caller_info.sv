/*
:name: test_svdpi_h_caller_info
:description: svGetCallerInfo returns 1 and writes the source file and line of the import call when it has that information and 0 without changing the outputs when it has not, so the test accepts either answer and checks the outputs against it (IEEE 1800-2023 Section 35.3.2, I.3, H.9.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3 H.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_caller_info.c
:expected_stdout: @test_svdpi_h_caller_info.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI is the one Annex I lists.
// I.3 and H.9.3: svGetCallerInfo writes the name of the SystemVerilog file
// and the line number of the import call into the two outputs and returns
// true when the implementation keeps that information, and returns false
// without changing the two outputs when it does not; whether it keeps it is
// left to the implementation. The string it gives belongs to the simulator
// and only until the next call of a SystemVerilog routine, so the test reads
// it at once and does not write to it.
//
// c_caller fills the two outputs with a sentinel string and -1 first, calls
// svGetCallerInfo, and prints 1 when the answer is 0 or 1 and 1 when the
// outputs match it: the sentinel values for 0, and for 1 a file name that
// ends in the name of this test's source and the line of the call, which is
// the line c_caller() in the design, 33.

module test_svdpi_h_caller_info;
  import "DPI-C" context function void c_caller();

  initial begin
    c_caller();
  end
endmodule
