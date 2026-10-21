/*
:name: test_rand_enum_solver_finds_solution
:description: A rand enum variable takes only the named values of its type, an enum state variable may hold another value, a string comparison without random variables can appear in a constraint, and the solver finds the only solution of a product constraint (IEEE 1800-2023 Section 18.3)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_enum_solver_finds_solution.expected
*/
// IEEE 1800-2023 §18.3 lists properties of constraints that this test
// observes:
// - an active random variable of an enum type gets only the values of the
//   named constants of the type, here 1, 5 and 9 of a 4-bit type, never 0, 3
//   or another value of its 4 bits; an enum state variable may hold a value
//   that is not named (3) and still allow a solution;
// - a subexpression that has no random variable may have operands that are
//   not integral, such as a comparison of strings, as long as its result is
//   integral;
// - if a solution exists the solver finds it: p * q == 667 with
//   1 < p <= q has only the solution 23 * 29 (the product of two 8-bit
//   values fits in 16 bits, so it cannot wrap).

typedef enum bit [3:0] {RES_LOW = 4'd1, RES_MID = 4'd5, RES_HIGH = 4'd9} res_level_e;

class res_obj;
  rand res_level_e level;
  res_level_e fixed_level;
  rand bit [3:0] w;
  rand bit [3:0] s;
  rand bit [7:0] p, q;
  string tag;
  constraint c_w { w == 4'(fixed_level) + 4'd1; }
  constraint c_s { s > 4'd0; (tag == "small") -> s < 4'd2; }
  constraint c_pq { p > 8'd1; p <= q; 16'(p) * 16'(q) == 16'd667; }
endclass

module test_rand_enum_solver_finds_solution;
  res_obj o;
  int failed = 0;
  int unnamed = 0;
  int ok;

  initial begin
    o = new;
    o.tag = "small";
    o.fixed_level = res_level_e'(4'd3);
    repeat (100) begin
      if (!o.randomize()) failed++;
      if (!(o.level inside {RES_LOW, RES_MID, RES_HIGH})) unnamed++;
    end
    $display("100 calls: failed=%0d level outside the named values=%0d", failed, unnamed);
    $display("enum state variable with the unnamed value 3: w=%0d", o.w);
    $display("tag == \"small\": s=%0d", o.s);
    $display("p * q == 667: p=%0d q=%0d", o.p, o.q);
    o.tag = "large";
    ok = o.randomize() with { s == 4'd12; };
    $display("tag == \"large\": ok=%0d s=%0d", ok, o.s);
  end
endmodule
