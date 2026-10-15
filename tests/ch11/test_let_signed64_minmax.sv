/*
:name: test_let_signed64_minmax
:description: let declarations: 64-bit signed min and max
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12 11.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_signed64_minmax.expected
*/
// IEEE 1800-2023 let declarations: 64-bit signed min and max
module test_let_signed64_minmax;
  let max64(x, y) = ($signed(x) > $signed(y)) ? x : y;
  let min64(x, y) = ($signed(x) < $signed(y)) ? x : y;

  logic signed [63:0] a = -64'sd123456789;
  logic signed [63:0] b =  64'sd98765432;
  logic signed [63:0] c = -64'sd2;

  initial begin
    if (max64(a, b) != b)
      $fatal(1, "FAIL: max64 expected %0d", b);
    if (min64(a, b) != a)
      $fatal(1, "FAIL: min64 expected %0d", a);
    if (min64(b, c) != c)
      $fatal(1, "FAIL: min64 second case");
    $display("PASS: let signed64 minmax");
  end
endmodule
