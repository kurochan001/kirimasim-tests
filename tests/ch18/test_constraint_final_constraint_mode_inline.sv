/*
:name: test_constraint_final_constraint_mode_inline
:description: A constraint declared :initial :final takes part in randomize() like any other and can be switched off with constraint_mode(0), since final only forbids replacing it, while a constraint replaced with :extends in the subclass is the one that inline constraints meet (IEEE 1800-2023 Sections 18.5.2, 18.9, 18.7)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.2 18.9 18.7 18.6.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_final_constraint_mode_inline.expected
*/
// IEEE 1800-2023 §18.5.2: :final forbids a subclass to replace a constraint;
// it says nothing about whether the constraint is active. :extends marks a
// replacement, which then takes the place of the inherited constraint.
// §18.9: constraint_mode(0) makes a constraint inactive and constraint_mode()
// returns its current mode. §18.7: randomize() with adds inline constraints.
// §18.6.3: a failed randomize() returns 0 and leaves the variables unchanged.
//
// cm_c has c_lock :initial :final (x == 7) and c_range (x in 1 to 9);
// cm_sub_c replaces c_range with :extends (x in 5 to 9). With c_lock active,
// randomize() gives 7 and randomize() with { x > 8; } fails, keeping 7. With
// c_lock off, x > 8 gives 9, the only value left, and x < 5 fails because
// the replacement allows only 5 to 9, keeping 9.
// Icarus Verilog 13.0 does not support override specifiers and stops with a
// syntax error.

class cm_c;
  rand int unsigned x;
  constraint :initial :final c_lock { x == 7; }
  constraint c_range { x inside {[1:9]}; }
endclass

class cm_sub_c extends cm_c;
  constraint :extends c_range { x inside {[5:9]}; }
endclass

module test_constraint_final_constraint_mode_inline;
  cm_sub_c s;
  int ok;

  initial begin
    s = new;
    ok = s.randomize();
    $display("lock on: ok=%0d x=%0d", ok, s.x);
    ok = s.randomize() with { x > 8; };
    $display("lock on, x > 8: ok=%0d x=%0d", ok, s.x);
    s.c_lock.constraint_mode(0);
    ok = s.randomize() with { x > 8; };
    $display("lock off, x > 8: ok=%0d x=%0d mode=%0d", ok, s.x, s.c_lock.constraint_mode());
    ok = s.randomize() with { x < 5; };
    $display("lock off, x < 5: ok=%0d x=%0d", ok, s.x);
  end
endmodule
