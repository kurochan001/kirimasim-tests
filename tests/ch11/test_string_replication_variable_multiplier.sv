/*
:name: test_string_replication_variable_multiplier
:description: A replication whose result is of type string can have a multiplier that is not a constant expression, such as a loop variable or a function call, and a zero multiplier gives the empty string; a vector replication uses a constant multiplier (IEEE 1800-2023 Section 11.4.12.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12.2 6.16 11.4.12.1 A.8.1 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_replication_variable_multiplier.expected
*/
// IEEE 1800-2023 §11.4.12.2, §6.16 and footnote 39 of A.10 (on
// multiple_concatenation, A.8.1): the multiplier of a replication has to be
// a constant expression unless the concatenation is of type string. For a
// string replication the multiplier can be any non-negative integral
// expression; the result is that many copies of the inner concatenation,
// and a multiplier of zero gives the empty string (6.16).
//
// The loop variable n, 0 to 3, is the multiplier of a replication of the
// string variable s = "ab". A non-constant multiplier also makes a
// replication of string literals a string (6.16): {k{"xy", "-"}} with k = 2.
// The value returned by the function twice is the multiplier of a third
// replication. As a contrast, the vector replication {4{2'b10}} has the
// constant multiplier 4 and gives 8'b10101010.
//
// Icarus Verilog 13.0 rejects the variables n and k as multipliers, saying
// that they are not allowed in a constant expression. The 5.052 release
// of Verilator gives the lines of n and k but rejects twice(k) as a
// multiplier, which it tries to evaluate as a constant.

module test_string_replication_variable_multiplier;
  string s = "ab";
  string r;
  int k = 2;
  logic [7:0] v;

  function automatic int twice(int x);
    return 2 * x;
  endfunction

  initial begin
    for (int n = 0; n <= 3; n++) begin
      r = {n{s}};
      $display("n=%0d r=\"%s\" len=%0d", n, r, r.len());
    end
    r = {k{"xy", "-"}};
    $display("k=%0d r=\"%s\" len=%0d", k, r, r.len());
    r = {twice(k){s, "."}};
    $display("twice(k)=%0d r=\"%s\" len=%0d", twice(k), r, r.len());
    v = {4{2'b10}};
    $display("v=%b", v);
  end
endmodule
