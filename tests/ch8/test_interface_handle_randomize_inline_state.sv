/*
:name: test_interface_handle_randomize_inline_state
:description: randomize() called through an interface class handle randomizes the object it refers to under the object's constraints, and an inline constraint on such a call, which can only name state variables, makes the call fail when it is false and succeed when it is true (IEEE 1800-2023 Section 8.26.9)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26.9 18.7 18.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_handle_randomize_inline_state.expected
*/
// IEEE 1800-2023 §8.26.9: randomize() may be called with an interface class
// handle, and so may randomize() with an inline constraint; an interface
// class has no data members, so the inline constraint can only state
// conditions on state variables. §18.7: names in the inline constraint that
// are not members of the class of the handle are looked up in the scope of
// the call. §18.6.3: randomize() returns 1 when it succeeds and 0 when the
// constraints cannot be met, and then the random variables keep their
// values.
//
// gen_c implements gen_if and has rand x with x inside [10:20]. Through the
// gen_if handle g, randomize() with { mode > 0; } fails while the module
// variable mode is 0 (x keeps 99) and succeeds when mode is 2; a plain
// randomize() through g also randomizes x within [10:20]. Only whether x is
// in the range is printed, not its random value.
//
// The 5.052 release of Verilator rejects the randomize() calls on the
// interface class handle (it adds randomization members to gen_if and then
// reports them as not pure virtual); Icarus Verilog 13.0 does not support
// interface classes.

module test_interface_handle_randomize_inline_state;
  interface class gen_if;
    pure virtual function int value();
  endclass

  class gen_c implements gen_if;
    rand int x;
    constraint c_range { x inside {[10:20]}; }
    virtual function int value();
      return x;
    endfunction
  endclass

  int mode;
  gen_c obj;
  gen_if g;
  int ok;

  initial begin
    obj = new;
    obj.x = 99;
    g = obj;
    mode = 0;
    ok = g.randomize() with { mode > 0; };
    $display("mode=0: randomize=%0d, x kept 99: %0d", ok, obj.x == 99);
    mode = 2;
    ok = g.randomize() with { mode > 0; };
    $display("mode=2: randomize=%0d, x in [10:20]: %0d", ok, obj.x inside {[10:20]});
    obj.x = 99;
    ok = g.randomize();
    $display("no inline constraint: randomize=%0d, x in [10:20]: %0d", ok,
             g.value() inside {[10:20]});
  end
endmodule
