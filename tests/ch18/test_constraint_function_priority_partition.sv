/*
:name: test_constraint_function_priority_partition
:description: a random function argument is solved before the constraints that use the function result and without them, so randomize() fails when the lower-priority constraints leave one value of it that the first step does not see, and a randc variable of the lower-priority set is solved after the argument and first within its own set, so it keeps its cycle (IEEE 1800-2023 Section 18.5.11)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_function_priority_partition.expected
*/
// IEEE 1800-2023 §18.5.11: a random variable passed to a function in a
// constraint gets a higher priority. The constraints that use only variables
// of higher priority are solved first, without looking at the others at all,
// and then the function results are state variables for the rest; this
// splits the solution space and can make randomize() fail. Within each such
// set the randc variables are solved first.
// - fpp_split: x == idf(y) && x == 0, where idf returns its argument. No
//   constraint uses only y, so y is solved first over all its 1024 values,
//   and then x == y and x == 0 can be met only when y happened to be 0. A
//   call succeeds with probability 1/1024, so at least 28 of 32 calls fail
//   except with negligible probability. Solved together, y = 0 would always
//   work.
// - fpp_joint: the same constraints with y in place of idf(y) have no
//   function, so x and y are solved together and every call gives y == 0.
// - fpp_randc: r is randc and r == idf(y) is a constraint of the lower set,
//   so r is solved after y, when idf(y) is known, and every call succeeds
//   with r == y. If r were solved before y, as the first of all variables,
//   r == idf(y) would hold only when y happened to equal r.
// - fpp_cyc: the randc r and the rand x are both in the lower set, with
//   (r == 0) -> (x == 0) and x <= idf(y). r is solved first in that set,
//   from its permutation (18.4.2), and with any value of r, x == 0 meets
//   both constraints, so every call succeeds and no permutation has to be
//   recomputed: calls 1 to 4, 5 to 8 and so on each give r the values 0 to
//   3 once. If x were solved before r, a nonzero x, which comes in about
//   half of the calls, would rule out r == 0, and those runs of four would
//   not all have 0.
// Icarus Verilog 13.0 does not support constraints. The 5.054 release of
// the Verilator simulator solves x and y of fpp_split together, so none of
// its 32 calls fails and its first line ends with 0; its other three lines
// are as expected.

class fpp_split;
  rand bit [9:0] x, y;
  function int idf(bit [9:0] v);
    return v;
  endfunction
  constraint c { x == idf(y); x == 0; }
endclass

class fpp_joint;
  rand bit [9:0] x, y;
  constraint c { x == y; x == 0; }
endclass

class fpp_randc;
  rand bit [1:0] y;
  randc bit [1:0] r;
  function int idf(bit [1:0] v);
    return v;
  endfunction
  constraint c { r == idf(y); }
endclass

class fpp_cyc;
  rand bit [1:0] y;
  randc bit [1:0] r;
  rand bit [1:0] x;
  function int idf(bit [1:0] v);
    return v;
  endfunction
  constraint c { (r == 0) -> (x == 0); x <= idf(y); }
endclass

module test_constraint_function_priority_partition;
  fpp_split os = new;
  fpp_joint oj = new;
  fpp_randc orc = new;
  fpp_cyc oc = new;
  int sfail, jfail, jbad, rfail, rbad;
  int cfail, cbad, cincomplete;
  bit [3:0] seen;

  initial begin
    repeat (32) if (!os.randomize()) sfail++;
    repeat (32) begin
      if (!oj.randomize()) jfail++;
      else if (oj.y != 0) jbad++;
    end
    repeat (40) begin
      if (!orc.randomize()) rfail++;
      else if (orc.r != orc.y) rbad++;
    end
    seen = 0;
    for (int i = 1; i <= 40; i++) begin
      if (!oc.randomize()) cfail++;
      else begin
        seen[oc.r] = 1;
        if (oc.x > oc.y || (oc.r == 0 && oc.x != 0)) cbad++;
      end
      if (i % 4 == 0) begin
        if (seen != 4'b1111) cincomplete++;
        seen = 0;
      end
    end
    $display("argument solved first: at least 28 of 32 calls fail %0d", sfail >= 28);
    $display("no function: failures %0d, y other than 0 %0d", jfail, jbad);
    $display("randc in the lower set: failures %0d, r other than y %0d", rfail, rbad);
    $display("randc first in its set: failures %0d, constraints broken %0d, %s %0d",
             cfail, cbad, "runs of 4 without all of 0 to 3", cincomplete);
  end
endmodule
