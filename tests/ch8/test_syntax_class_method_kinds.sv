/*
:name: test_syntax_class_method_kinds
:description: Class methods with method qualifiers before a task, a function and a constructor, a constructor declaration with block item declarations, a super.new call and an end label, a constructor prototype completed outside the class, extern task and function prototypes defined out of block, and pure virtual task and function prototypes implemented in a derived class (IEEE 1800-2023 Sections 8.6, 8.7, 8.14, 8.21 and 8.24)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.6 8.7 8.14 8.21 8.24 A.1.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_class_method_kinds.expected
*/
// IEEE 1800-2023 A.1.9: a class method is optional method qualifiers before
// a task declaration, a function declaration, or a class constructor
// declaration; pure virtual with optional class item qualifiers before a
// method prototype; extern with optional method qualifiers before a method
// prototype, with the constructor prototype as its own production. A method
// prototype is a task prototype or a function prototype (A.2.7, A.2.6).
// 8.7: a constructor may carry block item declarations and call super.new
// first; 8.24: an out-of-block definition names the class scope.
//   - m_base is a virtual class with a pure virtual function f and a pure
//     virtual task t, so it cannot be instantiated,
//   - m_der declares the constructor with a block item declaration, a
//     super.new call and the label : new; it also has the qualified methods
//     protected virtual function pv, local static function ls, local task lt
//     and protected task pt,
//   - h and tk are extern prototypes defined out of block,
//   - m_extern has a constructor prototype completed out of block,
//   - m_local has a local constructor that its static make calls.
// The printed numbers: d.f = 5, d.g = 4, d.h(2) = 6, d.tk(4) then d.t()
// gives q = 9, d.bump_pt() gives q = 10, d.call_pv = 6, d.call_ls = 5,
// e.v = 8, and m_local::make().v = 21.
//
// Icarus Verilog 13.0 does not compile this design; Verilator 5.052 does not
// accept every method form here.

virtual class m_base;
  protected int p;

  function new(int a);
    p = a;
  endfunction

  pure virtual function int f();
  pure virtual task t();

  virtual function int g();
    return p;
  endfunction
endclass

class m_der extends m_base;
  int q;

  function new(int a);
    int tmp;
    super.new(a + 1);
    tmp = a + 1;
    q = tmp;
  endfunction : new

  function int f();
    return p + 1;
  endfunction

  task t();
    q = q + 1;
  endtask

  extern function int h(int x);
  extern task tk(input int x);

  protected virtual function int pv();
    return 6;
  endfunction

  local static function int ls();
    return 5;
  endfunction

  local task lt();
    q = q;
  endtask

  protected task pt();
    q = q + 1;
  endtask

  task bump_pt();
    pt();
  endtask

  function int call_ls();
    return ls();
  endfunction

  function int call_pv();
    return pv();
  endfunction
endclass

function int m_der::h(int x);
  return x + p;
endfunction

task m_der::tk(input int x);
  q = q + x;
endtask

class m_extern;
  int v;

  extern function new(int a);
endclass

function m_extern::new(int a);
  v = a + 1;
endfunction

class m_local;
  int v;

  local function new();
    v = 21;
  endfunction

  static function m_local make();
    make = new();
  endfunction
endclass

module test_syntax_class_method_kinds;
  m_der d;
  m_extern e;
  m_local l;

  initial begin
    d = new(3);
    e = new(7);
    l = m_local::make();
    d.tk(4);
    d.t();
    d.bump_pt();
    #1 $display("f=%0d g=%0d h=%0d q=%0d pv=%0d ls=%0d e=%0d l=%0d",
                d.f(), d.g(), d.h(2), d.q, d.call_pv(), d.call_ls(),
                e.v, l.v);
  end
endmodule
