/*
:name: test_tagged_union_read_wrong_tag_runtime_error
:description: Reading a member of a tagged union with dot notation while the current tag names another member gives a run-time error (IEEE 1800-2023 Section 11.9)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.9 7.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_tagged_union_read_wrong_tag_runtime_error.expected
:expected_stderr_regex: (?i:\berror\b)
*/
// IEEE 1800-2023 §11.9: a member of a tagged union is read or assigned with
// dot notation, and the access shall be consistent with the current tag,
// which in general needs a check in the run. An attempt to read or assign a
// value whose type is inconsistent with the tag results in a run-time error.
// The tag here is set by a tagged union expression under a condition that
// only the run knows. While the tag is Int, t.Int is read and gives 5. Then
// the tag becomes Byte, t.Byte gives a5, and the read of t.Int that follows
// shall give the error. The standard does not say what the access does
// after the error or whether the run goes on, so nothing is printed after
// it; the messages of the run are checked for an error, whose form the
// standard leaves to the tool. An implementation that
// reads the bits of the Byte member as Int reports no error and fails
// that check.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports tagged unions.

module test_tagged_union_read_wrong_tag_runtime_error;
  typedef union tagged {
    int Int;
    bit [7:0] Byte;
  } tu_t;

  tu_t t;
  int k, x;

  initial begin
    k = 1 + 1;
    t = tagged Int 5;
    $display("tag Int: Int=%0d", t.Int);
    if (k == 2) t = tagged Byte 8'hA5;
    $display("tag Byte: Byte=%h", t.Byte);
    $display("reading Int while the tag is Byte");
    x = t.Int;
  end
endmodule
