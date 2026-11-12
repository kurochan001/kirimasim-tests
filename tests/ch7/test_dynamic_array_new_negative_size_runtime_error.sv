/*
:name: test_dynamic_array_new_negative_size_runtime_error
:description: new[] with a size operand whose value is negative at run time is an error (IEEE 1800-2023 Section 7.5.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_array_new_negative_size_runtime_error.expected
:expected_stderr_regex: (?i:\berror\b)
*/
// IEEE 1800-2023 §7.5.1: the operand in the brackets of new[] is the size of
// the dynamic array, and it shall be an error if its value is negative. The
// operand here is the variable n, so only the run knows its value. With
// n = 3 the constructor makes an array of three elements. Then n becomes -1
// and the same constructor shall give an error. The standard does not say
// what the array holds after the error or whether the run goes on, so
// nothing is printed after the call; the messages of the run are checked
// for an error, whose form the standard leaves to the tool. An
// implementation that takes a negative size as zero or as a large unsigned
// number reports no error of the standard and fails that check.
// Icarus Verilog 13.0 ends with a crash at the call, without a message of
// its own, and Verilator 5.052 runs the call without an error.

module test_dynamic_array_new_negative_size_runtime_error;
  int d[];
  int n;

  initial begin
    n = 1 + 2;
    d = new[n];
    $display("new[%0d]: size=%0d", n, d.size());
    n = n - 4;
    $display("calling new[%0d]", n);
    d = new[n];
  end
endmodule
