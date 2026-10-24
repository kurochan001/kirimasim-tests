/*
:name: test_illegal_procedural_assign_concatenation_with_net
:description: the left-hand side of a procedural assignment can be a variable, a select of one, a memory word, an array, an element or slice of it, or a concatenation of these, but a concatenation that contains a net is not (IEEE 1800-2023 Section 10.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the procedural assignment writes the concatenation {p, n}, which contains the net n
:expected_stderr_regex: test_illegal_procedural_assign_concatenation_with_net\.sv:41:
*/
// IEEE 1800-2023 §10.2, Table 10-1: the left-hand side of a procedural
// assignment is a variable, a bit-select or part-select of a packed variable,
// a memory word, an array, an array element select, an array slice, or a
// concatenation or nested concatenation of these. The initial procedure uses
// each of these forms; the last assignment puts the net n into the
// concatenation.
// Icarus Verilog 13.0 also rejects the legal assignments of the array brr and
// of the slice brr[0:1], so its error does not count.

module test_illegal_procedural_assign_concatenation_with_net;
  logic v;
  logic [7:0] pv;
  logic [7:0] mem [4];
  int arr [3];
  int brr [3];
  logic [3:0] p, q;
  wire n;

  initial begin
    v = 1'b1;
    pv[2] = 1'b1;
    pv[7:4] = 4'hc;
    mem[1] = 8'h5a;
    arr = brr;
    arr[0] = 3;
    arr[1:2] = brr[0:1];
    {p, {q, v}} = 9'h1ff;
    {p, n} = 5'h1f;   // illegal: n is a net
    $display("%h %h %0d", pv, mem[1], arr[0]);
  end
endmodule
