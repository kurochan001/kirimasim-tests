/*
:name: test_syntax_class_item_kinds
:description: Class items with attributes before a property, a method, a constraint, a nested class, an interface class and a covergroup; properties with rand, randc, static, protected, local, const, parameter and localparam; both forms of a constraint; and a constraint prototype completed by an external constraint block (IEEE 1800-2023 Sections 8.5, 8.6, 18.5 and A.1.9)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.5 8.6 8.18 18.5 18.5.1 A.1.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_class_item_kinds.expected
*/
// IEEE 1800-2023 A.1.9: a class item may carry attributes before a class
// property, a class method, a class constraint, a class declaration, an
// interface class declaration or a covergroup declaration. A property is a
// data declaration with optional property qualifiers, or const with optional
// class item qualifiers, a data type, a name and an optional initializer. The
// property qualifiers are rand, randc, static, protected and local; a method
// qualifier is pure virtual or one of those three; parameter and localparam
// declarations and an empty semicolon are class items too. A constraint is a
// constraint prototype or a constraint declaration, and 18.5.1 lets an
// external constraint block complete a prototype.
//   - the property of each qualifier is read through the method total, so
//     its value is in the printed number,
//   - parameter is a synonym for localparam in a class (A.10 note 7),
//   - randomize() with the inline constraint fixing r to 5 and the static
//     constraint fixing rc to 1 makes both values fixed, so the run does not
//     depend on the random seed,
//   - the implicit prototype c_hard and the explicit prototype c_ext are
//     completed by the two external constraint blocks, and the inline
//     constraint c_inline is a constraint declaration.
//
// Icarus Verilog 13.0 does not compile this design; Verilator 5.052 does not
// accept every class item here.

class item_base;
  rand int r;
  randc bit [1:0] rc;
  const static int K = 4;
  const int kk = 5;
  static int s = 6;
  protected int prot = 7;
  local int loc = 8;
  parameter int P = 9;
  localparam int L = 10;
  int plain = 11;
  (* attr *) int attr_prop = 12;

  (* attr *) constraint c_attr { r >= 0; }
  constraint c_hard;
  extern constraint c_ext;
  constraint c_inline { r == 5; }
  static constraint c_static { rc == 2'd1; }

  (* attr *) function int total();
    return s + prot + loc + K + kk + plain + attr_prop + P + L;
  endfunction

  static function int twice(int x);
    return 2 * x;
  endfunction

  protected function int plus_one(int x);
    return x + 1;
  endfunction

  local task note();
    loc = 9;
  endtask

  function int call_prot();
    return plus_one(1);
  endfunction

  (* attr *) class Inner;
    static int v = 13;
  endclass

  (* attr *) interface class IBase;
    pure virtual function int f();
  endclass

  (* attr *) covergroup cg;
    coverpoint r;
  endgroup

  ;
endclass

constraint item_base::c_hard { r >= 1; }
constraint item_base::c_ext { r <= 10; }

module test_syntax_class_item_kinds;
  item_base o;
  int ok;

  initial begin
    o = new();
    ok = o.randomize();
    #1 $display("ok=%0d r=%0d rc=%0d total=%0d inner=%0d twice=%0d plus=%0d",
                ok, o.r, o.rc, o.total(), item_base::Inner::v,
                item_base::twice(2), o.call_prot());
  end
endmodule
