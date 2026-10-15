/*
:name: test_let_signed_addsub
:description: let declarations: chained signed addition and subtraction, with an unsigned operand cast by $signed
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12 11.7
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_signed_addsub.expected
*/
// IEEE 1800-2023 let declarations: chained signed addition and subtraction, with an unsigned operand cast by $signed
module test_let_signed_addsub;
  let sum3(a, b, c) = $signed(a) + $signed(b) + $signed(c);
  let diff2(a, b)   = $signed(a) - $signed(b);

  logic signed [15:0] a = -16'sd12;
  logic signed [15:0] b =  16'sd25;
  logic        [7:0]  c =  8'd5;

  initial begin
    if (sum3(a, b, c) != 16'sd18)
      $fatal(1, "FAIL: sum3 result");
    if (diff2(b, a)   != 16'sd37)
      $fatal(1, "FAIL: diff2 result");
    if (diff2(a, c)   != -16'sd17)
      $fatal(1, "FAIL: diff2 mixed");

    $display("PASS: let add/sub signed mix");
  end
endmodule
