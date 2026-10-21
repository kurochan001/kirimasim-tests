/*
:name: test_rand_real_constraint
:description: A rand real variable gets random values that meet its constraints, and an equality constraint fixes it (IEEE 1800-2023 Section 18.4.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.4.1 18.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_real_constraint.expected
*/
// IEEE 1800-2023 §18.4.1: a variable of type real can be declared rand, and
// gets values uniformly distributed over the range its constraints (§18.5)
// allow. r lies strictly between 1.5 and 1.75 after each of 20 calls, and s,
// constrained to 2.5, is always 2.5. The test counts the calls that break the
// constraints.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports this construct of
// IEEE 1800-2023.

class test_rand_real_constraint_c;
  rand real r;
  rand real s;
  constraint k { r > 1.5; r < 1.75; s == 2.5; }
endclass

module test_rand_real_constraint;
  test_rand_real_constraint_c o = new;
  int bad = 0;
  initial begin
    repeat (20) begin
      if (!o.randomize() || !(o.r > 1.5 && o.r < 1.75) || o.s != 2.5) bad++;
    end
    $display("violations=%0d s=%0.2f", bad, o.s);
  end
endmodule
