/*
:name: test_constraint_function_order
:description: Functions in constraints order their random arguments before the constraints that use their results, through a chain of two functions and with an argument passed as const ref, and their results act as state variables (IEEE 1800-2023 Section 18.5.11)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_function_order.expected
*/
// IEEE 1800-2023 §18.5.11: a random variable passed to a function in a
// constraint is solved first, with the constraints that use only it and
// variables of higher priority, and the function result is then a state
// variable for the other constraints. y is solved first (y in [2:5]), then
// x == sq(y), then z == inc(x), so in every call x is the square of y and z
// one more (functions called with the values from before the call would
// break this). A function may take a const ref argument: t is ten times w,
// which is solved before it. With randomize() with { y == 4; } the values
// are fixed: x = 16 and z = 17.

class cfo_obj;
  rand bit [3:0] y;
  rand bit [7:0] x, z;
  rand bit [3:0] w;
  rand int t;

  function automatic bit [7:0] sq(bit [3:0] a);
    return a * a;
  endfunction

  function automatic bit [7:0] inc(bit [7:0] a);
    return a + 8'd1;
  endfunction

  function automatic int tenfold(const ref bit [3:0] a);
    return 10 * a;
  endfunction

  constraint c_y { y inside {[2:5]}; }
  constraint c_x { x == sq(y); }
  constraint c_z { z == inc(x); }
  constraint c_w { w inside {[1:3]}; }
  constraint c_t { t == tenfold(w); }
endclass

module test_constraint_function_order;
  cfo_obj o;
  int failed = 0, bad = 0;
  int ok;

  initial begin
    o = new;
    repeat (30) begin
      if (!o.randomize()) failed++;
      if (!(o.y inside {[2:5]}) || o.x != o.y * o.y || o.z != o.x + 1) bad++;
      if (!(o.w inside {[1:3]}) || o.t != 10 * o.w) bad++;
    end
    $display("30 calls: failed=%0d violations=%0d", failed, bad);
    ok = o.randomize() with { y == 4'd4; };
    $display("y==4: ok=%0d x=%0d z=%0d", ok, o.x, o.z);
  end
endmodule
