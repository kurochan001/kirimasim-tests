/*
:name: test_variable_categories_and_modifiers
:description: variable declarations accept every data-type category, the const, var and lifetime modifiers, and the integral and real categories keep their value rules
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8 6.11.1 6.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_variable_categories_and_modifiers.expected
*/
// IEEE 1800-2023 6.8: a variable can hold an integer vector or atom, a real,
// a struct or union, an enum, a string, a chandle, a virtual interface, a class
// handle, an event, a covergroup or a type reference, and its declaration
// permits const, var and a lifetime modifier. 6.11.1: integral types include
// basic integer types, packed arrays, packed structures, packed unions and
// enums, which all support bit-selects and arithmetic. 6.12: real, shortreal
// and realtime form the real-variable category and hold fractional values.
// The test declares each category, writes a value through it and prints the
// observed value.

interface class iclass;
  pure virtual function int value();
endclass

interface simple_if;
  logic sig;
endinterface

class cobj implements iclass;
  virtual function int value();
    return 7;
  endfunction
endclass

typedef struct packed {logic a; logic b;} pstruct_t;
typedef union packed {logic [1:0] two; logic [1:0] same;} punion_t;

module test_variable_categories_and_modifiers;
  int atom;
  logic [3:0] vec;
  real r;
  shortreal sr;
  realtime rt;
  struct {int n;} ust;
  union {int i; byte b;} uun;
  enum int {EA = 2} en;
  string str;
  chandle ch;
  virtual simple_if vif;
  cobj obj;
  event ev;
  covergroup cg;
    coverpoint atom;
  endgroup
  cg cg_inst = new;
  var logic implied;
  var [7:0] implied_vec;
  const int fixed = 3;
  var type(logic [3:0]) tref;
  pstruct_t ps;
  punion_t pu;
  simple_if u_if();

  task automatic check_lifetime;
    automatic int local_auto = 2;
    static int local_static = 5;
    local_static++;
    $display("auto=%0d static=%0d", local_auto, local_static);
  endtask

  initial begin
    atom = 1;
    vec = 4'hA;
    r = 1.5;
    sr = 2.25;
    rt = 3.75;
    ust.n = 4;
    uun.i = 8;
    en = EA;
    str = "ok";
    ch = null;
    vif = u_if;
    u_if.sig = 1;
    obj = new;

    implied = 1;
    implied_vec = 8'h5A;
    tref = 4'h3;
    ps = 2'b10;
    pu.two = 2'b01;
    cg_inst.sample();
    $display("atom=%0d vec=%h", atom, vec);
    $display("real=%0.2f sum=%0.2f", r, r + sr + rt);
    $display("ust=%0d uun=%0d en=%0d", ust.n, uun.i, en);
    $display("str=%s ch_null=%0d", str, ch == null);
    $display("vif_sig=%0d obj=%0d", vif.sig, obj.value());
    $display("implied=%0d implied_vec=%h", implied, implied_vec);
    $display("fixed=%0d tref=%h", fixed, tref);
    $display("ps=%b pu=%b", ps, pu.two);
    check_lifetime;
    check_lifetime;
  end
endmodule
