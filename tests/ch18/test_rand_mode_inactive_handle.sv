/*
:name: test_rand_mode_inactive_handle
:description: rand_mode(0) makes a variable behave as a nonrandom one, and on an object handle it changes only the mode of the handle (IEEE 1800-2023 Section 18.8)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.8 18.3 18.5.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_mode_inactive_handle.expected
*/
// IEEE 1800-2023 §18.3, §18.8: rand_mode(0) makes a random variable inactive,
// and it then behaves exactly like a variable not declared rand: randomize()
// leaves it alone and the solver uses its value as a state variable. So x,
// turned off and set to 50, keeps 50 and makes y 49 by x == y + 1, just as the
// nonrandom z = 70 makes w 71 by w == z + 1; turned on again, x follows y.
// For a rand object handle, rand_mode changes only the mode of the handle and
// not that of the variables of the object: with h off, h.v.rand_mode() still
// returns 1; o.randomize() does not randomize the object of h (18.5.8), so
// h.v keeps 99, outside the [10:20] of its constraint, while h.randomize()
// called on the object itself randomizes v into [10:20].
// Icarus Verilog 13.0 does not compile classes with constraints. Verilator
// 5.052 randomizes the object of h in o.randomize() although h is inactive.

class rmi_inner;
  rand bit [7:0] v;
  constraint c_v { v inside {[10:20]}; }
endclass

class rmi_obj;
  rand bit [7:0] x, y, w;
  bit [7:0] z;
  rand rmi_inner h;
  constraint c_xy { x == y + 8'd1; }
  constraint c_wz { w == z + 8'd1; }
  function new();
    h = new;
  endfunction
endclass

module test_rand_mode_inactive_handle;
  rmi_obj o;
  int ok;

  initial begin
    o = new;
    o.x.rand_mode(0);
    o.x = 8'd50;
    o.z = 8'd70;
    ok = o.randomize();
    $display("x off: ok=%0d x=%0d y=%0d, nonrandom z: w=%0d", ok, o.x, o.y, o.w);
    o.x.rand_mode(1);
    ok = o.randomize() with { y == 8'd5; };
    $display("x on again: ok=%0d x=%0d", ok, o.x);

    o.h.rand_mode(0);
    o.h.v = 8'd99;
    $display("h off: h=%0d h.v=%0d", o.h.rand_mode(), o.h.v.rand_mode());
    ok = o.randomize();
    $display("o.randomize() with h off: ok=%0d h.v=%0d", ok, o.h.v);
    ok = o.h.randomize();
    $display("h.randomize(): ok=%0d h.v in [10:20]=%0d", ok, o.h.v inside {[10:20]});
    o.h.rand_mode(1);
    o.h.v = 8'd99;
    ok = o.randomize();
    $display("h on again: ok=%0d h.v in [10:20]=%0d", ok, o.h.v inside {[10:20]});
  end
endmodule
