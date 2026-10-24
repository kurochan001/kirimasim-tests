/*
:name: test_string_substr_types_negative_start
:description: substr(i, j) takes two int indices, returns a string, and returns the empty string when i is negative (IEEE 1800-2023 Section 6.16.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.8 20.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_substr_types_negative_start.expected
*/
// IEEE 1800-2023 §6.16.8: string substr(int i, int j) returns characters i
// through j, and the empty string when i < 0 (also when j < i or j is not
// below len()). A negative start gives "" even when j is in range, while the
// same j with a start of 0 gives characters. The indices 64'h1_0000_0002 and
// 64'h1_0000_0004 are converted to the ints 2 and 4. $typename (§20.6.1)
// shows the type of the call. Icarus Verilog 13.0 has no $typename
// (unsupported construct).

module test_string_substr_types_negative_start;
  string s = "abcdef";
  string r;
  int i;

  initial begin
    $display("type: %s", $typename(s.substr(0, 1)));
    r = s.substr(0, 2);
    $display("(0,2)=\"%s\" len=%0d", r, r.len());
    i = -1;
    r = s.substr(i, 2);
    $display("(-1,2)=\"%s\" len=%0d", r, r.len());
    i = -3;
    r = s.substr(i, 5);
    $display("(-3,5)=\"%s\" len=%0d", r, r.len());
    r = s.substr(i, -1);
    $display("(-3,-1)=\"%s\" len=%0d", r, r.len());
    r = s.substr(1, 1);
    $display("(1,1)=\"%s\" len=%0d", r, r.len());
    r = s.substr(64'h1_0000_0002, 64'h1_0000_0004);
    $display("(64'h1_0000_0002,64'h1_0000_0004)=\"%s\"", r);
    $display("receiver=\"%s\"", s);
  end
endmodule
