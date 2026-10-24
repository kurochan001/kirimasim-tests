/*
:name: test_dpi_caller_info
:description: svGetCallerInfo either returns true and gives the file and line of the call of the context import, or returns false and leaves both outputs unchanged (IEEE 1800-2023 Section 35.5.3, H.9.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 H.9.3 22.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_caller_info.c
:expected_stdout: @test_dpi_caller_info.expected
*/
// IEEE 1800-2023 §35.5.3: svGetCallerInfo is one of the functions for context
// imports. H.9.3: whether it can give the place of the call is up to the
// implementation. If it can, it returns true and sets the file name and the
// line number of the SystemVerilog call of the import; if it cannot, it
// returns false and changes neither output. The file name belongs to the
// simulator and lasts only until the next call into SystemVerilog, so C copies
// what it needs at once.
//
// The design calls c_where from two lines and passes the number of each line
// with `__LINE__ (22.13). c_where sets both outputs to known values first. It
// prints 1 when the result is one of the two allowed ones: true with a file
// name that ends in test_dpi_caller_info.sv and the line passed in, or false
// with both outputs unchanged. The test does not print which one it is, as
// that is up to the implementation.

module test_dpi_caller_info;
  import "DPI-C" context function int c_where(input int line);

  initial begin
    $display("first call: caller information is consistent: %0d", c_where(`__LINE__));
    #1 $display("second call: caller information is consistent: %0d", c_where(`__LINE__));
  end
endmodule
