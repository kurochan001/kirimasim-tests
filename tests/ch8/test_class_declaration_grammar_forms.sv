/*
:name: test_class_declaration_grammar_forms
:description: the class syntax admits virtual and final classes with parameters, extends with constructor arguments, an implements list and an end label, the class items of each kind with their qualifiers, constructors declared in the class or out of it with declarations before the statements, and the :initial, :extends and :final specifiers of methods and prototypes (IEEE 1800-2023 Section 8.3)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.3 8.17 8.20 8.24 8.26
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_declaration_grammar_forms.expected
*/
// IEEE 1800-2023 §8.3 (Syntax 8-1): a class declaration is [virtual] class
// [:final] name [parameters] [extends class_type [(arguments)]] [implements
// interface classes] ; items endclass [: name]. Its items are properties
// (with static, local, protected, rand, randc or const), methods (with
// virtual, pure virtual, extern and the qualifiers), constraints, nested
// classes and interface classes, covergroups, parameter and localparam
// declarations, all optionally with attributes, and empty items. A
// constructor is function new without a return type: in the class, or as an
// extern prototype with its body declared out of the class, with
// declarations before its statements. A method or prototype may have the
// specifiers :initial or :extends, then :final, after function or task. A
// parameter declared as a class item is a local parameter.
// base_c is virtual and parameterized; leaf_c is final, extends base_c #(8)
// with the constructor argument H, implements two interface classes, and
// declares an item of each kind. The printed values show that the items
// declared in these forms work.
// Icarus Verilog 13.0 does not support interface classes.

interface class named_if;
  pure virtual function string name();
endclass

interface class sized_if;
  pure virtual function int size();
endclass

virtual class base_c #(int W = 4);
  int w;
  function new(int w0 = W);
    w = w0;
  endfunction
  pure virtual function int area();
  virtual function int scale();
    return 1;
  endfunction
  virtual task :initial tick(output int t);
    t = 5;
  endtask
endclass : base_c

class :final leaf_c #(int H = 3) extends base_c #(8) (H) implements named_if, sized_if;
  (* note = "attribute" *) int attr_prop = 2;
  rand bit [3:0] r;
  randc bit [1:0] rc;
  static local int count = 0;
  protected const int pc = 6;
  localparam int LPV = 11;
  parameter int PV = 12;
  ;
  constraint c_r { r < 10; }
  class node_c;
    int v = 9;
  endclass
  interface class inner_if;
    pure virtual function int k();
  endclass
  covergroup cg;
    coverpoint r;
  endgroup
  extern function new(int extra);
  virtual function :extends int area();
    return w * H;
  endfunction
  function :extends :final int scale();
    return 2 + pc - 6;
  endfunction
  extern virtual function :final string name();
  extern function int size();
  static function int made();
    return count;
  endfunction
endclass : leaf_c

function leaf_c::new(int extra);
  int tmp;
  tmp = extra + 1;
  count = count + tmp;
  cg = new;
endfunction : new

function string leaf_c::name();
  return "leaf";
endfunction

function int leaf_c::size();
  return w;
endfunction

module test_class_declaration_grammar_forms;
  leaf_c #(3) l;
  base_c #(8) b;
  named_if ni;
  sized_if si;
  leaf_c#(3)::node_c n;
  int t, ok;

  initial begin
    l = new(4);
    b = l;
    ni = l;
    si = l;
    n = new;
    l.tick(t);
    ok = l.randomize();
    $display("area=%0d scale=%0d base scale=%0d tick=%0d", l.area(), l.scale(), b.scale(), t);
    $display("name=%s size=%0d made=%0d", ni.name(), si.size(), leaf_c#(3)::made());
    $display("attr_prop=%0d LPV=%0d PV=%0d scoped PV=%0d node v=%0d", l.attr_prop, l.LPV,
             l.PV, leaf_c#(3)::PV, n.v);
    $display("randomize ok=%0d r<10=%0d", ok, l.r < 10);
  end
endmodule
