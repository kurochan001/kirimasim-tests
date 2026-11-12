/*
:name: test_bitstream_cast_dynamic_array_size_mismatch_runtime_error
:description: A bit-stream cast of a dynamic array to int is legal while the array holds 32 bits and is an error, reported at run time, once the array has 40 bits (IEEE 1800-2023 Section 6.24.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitstream_cast_dynamic_array_size_mismatch_runtime_error.expected
:expected_stderr_regex: (?i:\berror\b)
*/
// IEEE 1800-2023 §6.24.3: when the source or the destination type of a
// bit-stream cast contains dynamically sized types, a difference in their
// sizes gives an error at compile time or at run time, as soon as the
// mismatch can be determined. The source here is a dynamic array of bytes
// whose size comes from the variable n, so the mismatch can be determined
// only when the cast is evaluated. With four bytes the array has the 32
// bits of int and the cast is legal; the item at index 0 takes the most
// significant bits, so the value is 01020304. Resized to five bytes the
// array has 40 bits, and the same cast shall give an error. The standard
// does not say what the cast returns then or whether the run goes on, so
// nothing is printed after it; the messages of the run are checked for an
// error, whose form the standard leaves to the tool. An implementation that
// truncates or pads the 40 bits reports no error and fails that check; one
// that rejects every cast of a dynamic array to int does not print the
// first line.
// Icarus Verilog 13.0 prints both lines and reports the error, but its run
// then stops and does not end; Verilator 5.052 does not support the cast.

module test_bitstream_cast_dynamic_array_size_mismatch_runtime_error;
  byte d[];
  int v, n;

  initial begin
    n = 2 + 2;
    d = new[n];
    for (int i = 0; i < n; i++) d[i] = byte'(i + 1);
    v = int'(d);
    $display("%0d bytes: %h", d.size(), v);
    n = n + 1;
    d = new[n](d);
    $display("casting a dynamic array of %0d bytes to int", d.size());
    v = int'(d);
  end
endmodule
