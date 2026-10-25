/*
:name: test_this_and_super_in_out_of_block_methods
:description: this, super and this.super used inside a class declaration and inside out-of-block method declarations (a constructor and two functions) select the property of the current object or of its base class instead of a same-named argument or the derived property (IEEE 1800-2023 Sections 8.11, 8.15 and 8.24)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.11 8.15 8.24 A.8.4 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_this_and_super_in_out_of_block_methods.expected
*/
// IEEE 1800-2023 §8.11, §8.15, §8.24 with footnote 46 of A.10: this and the
// implicit class handles (this, super, this.super) appear only within a class
// declaration or an out-of-block method declaration. In both places this.val
// is the property of the current object even when an argument has the same
// name, and super.val (or this.super.val) the property of the base class that
// the derived class hides.
//
// Der hides Base::val (1) with its own val, set to 20 by the out-of-block
// constructor through this.val although the argument is also named val.
//   inline_this() = this.val + super.val            = 20 + 1       = 21
//   sum(5)        = val + this.val + super.val      = 5 + 20 + 1   = 26
//   base_get()    = this.super.val * 100 + super.get() = 100 + 1   = 101
//
// Icarus Verilog 13.0 does not support the out-of-block constructor
// ("External constructors are not yet supported").

class Base;
  int val = 1;

  function int get();
    return val;
  endfunction
endclass

class Der extends Base;
  int val;

  extern function new(int val);
  extern function int sum(int val);
  extern function int base_get();

  function int inline_this();
    return this.val + super.val;
  endfunction
endclass

function Der::new(int val);
  this.val = val;
endfunction

function int Der::sum(int val);
  return val + this.val + super.val;
endfunction

function int Der::base_get();
  return this.super.val * 100 + super.get();
endfunction

module test_this_and_super_in_out_of_block_methods;
  initial begin
    Der d;
    d = new(20);
    $display("val=%0d inline_this=%0d", d.val, d.inline_this());
    $display("sum=%0d base_get=%0d", d.sum(5), d.base_get());
  end
endmodule
