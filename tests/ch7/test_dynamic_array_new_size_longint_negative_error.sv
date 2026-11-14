/*
:name: test_dynamic_array_new_size_longint_negative_error
:description: the size operand of new[] has the signed type longint, so a 64-bit value with its top bit set is a negative size and an error, although its low 32 bits are a small positive number (IEEE 1800-2023 Section 7.5.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_array_new_size_longint_negative_error.expected
:expected_stderr_regex: (?i:\berror\b)
*/
// IEEE 1800-2023 §7.5.1: the type of the size operand of new[] is longint,
// a signed 64-bit integer (6.11), and it shall be an error if the value of
// the operand is negative. The operand here is the unsigned 64-bit variable
// big. With the value 2 the constructor makes an array of two elements.
// Then big becomes 'hFFFF_FFFF_0000_0002: as a longint this is the negative
// value -4294967294, so the same constructor shall give an error. The same
// bits taken as a 32-bit int are the size 2, which gives no error, and taken
// as an unsigned number they are a size of about 1.8e19 elements, which is
// not negative. The standard does not say what the array holds after the
// error or whether the run goes on, so nothing is printed after the call;
// the messages of the run are checked for an error, whose form the standard
// leaves to the tool.
// Icarus Verilog 13.0 ends with a crash at the second call, without a
// message of its own, and the 5.054 release of Verilator runs the call
// without an error.

module test_dynamic_array_new_size_longint_negative_error;
  int d[];
  bit [63:0] big;

  initial begin
    big = 64'h0000_0000_0000_0002;
    d = new[big];
    $display("new[%0d]: size=%0d", big, d.size());
    big = 64'hFFFF_FFFF_0000_0002;
    $display("calling new with the longint value %0d", longint'(big));
    d = new[big];
  end
endmodule
