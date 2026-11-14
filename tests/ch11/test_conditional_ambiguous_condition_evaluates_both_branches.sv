/*
:name: test_conditional_ambiguous_condition_evaluates_both_branches
:description: with an x or z condition, both branches of ?: are evaluated and compared with logical equality; an equal pair returns that value, and otherwise the result depends on the type (IEEE 1800-2023 Section 11.4.11)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_conditional_ambiguous_condition_evaluates_both_branches.expected
*/
// IEEE 1800-2023 §11.4.11: a true condition evaluates only the first branch
// and a false one only the second. An x or z condition evaluates both, then
// compares them for logical equivalence as == does (§11.4.5). If that
// comparison gives 1, either branch is the result; otherwise the result
// depends on the types: integral branches are combined bit by bit with
// Table 11-20, and a real result is 0.0 (Table 7-1).
// fa and fb count their calls, so the first four lines show which branches
// each condition evaluates. Equal real, string and class handle branches
// return their common value, which the type rule alone would not give: two
// unequal reals give 0.0, as the next line shows. For identical integral
// branches with a z bit, == gives x rather than 1, so the branches are
// combined and the z bit becomes x; a pair without x or z bits is returned
// as it is, and an unequal known pair is combined.
// Icarus Verilog 13.0 stops with an internal error on the conditionals
// with string and class handle branches.

class item_c;
  int v;
  function new(int v0);
    v = v0;
  endfunction
endclass

module test_conditional_ambiguous_condition_evaluates_both_branches;
  logic c1 = 1'b1;
  logic c0 = 1'b0;
  logic cx = 1'bx;
  logic cz = 1'bz;
  int na, nb, r;
  real ra = 2.5, rb = 2.5, rc = 4.0, rr;
  string sa = "ab", sb = "ab", sr;
  item_c h1, hr;
  logic [3:0] r4;

  function automatic int fa();
    na++;
    return 6;
  endfunction

  function automatic int fb();
    nb++;
    return 6;
  endfunction

  initial begin
    h1 = new(7);
    r = c1 ? fa() : fb();
    $display("true: r=%0d na=%0d nb=%0d", r, na, nb);
    r = c0 ? fa() : fb();
    $display("false: r=%0d na=%0d nb=%0d", r, na, nb);
    r = cx ? fa() : fb();
    $display("x: r=%0d na=%0d nb=%0d", r, na, nb);
    r = cz ? fa() : fb();
    $display("z: r=%0d na=%0d nb=%0d", r, na, nb);
    rr = cx ? ra : rb;
    $display("equal reals: %.2f", rr);
    rr = cx ? ra : rc;
    $display("unequal reals: %.2f", rr);
    sr = cx ? sa : sb;
    $display("equal strings: \"%s\"", sr);
    hr = cx ? h1 : h1;
    $display("equal handles: same=%0d v=%0d", hr == h1, hr.v);
    r4 = cx ? 4'b1z01 : 4'b1z01;
    $display("identical with z: %b", r4);
    r4 = cx ? 4'b1001 : 4'b1001;
    $display("identical known: %b", r4);
    r4 = cx ? 4'b1001 : 4'b1100;
    $display("unequal known: %b", r4);
  end
endmodule
