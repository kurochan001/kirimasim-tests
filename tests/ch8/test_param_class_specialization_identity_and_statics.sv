/*
:name: test_param_class_specialization_identity_and_statics
:description: class parameters are overridden by position or by name, parameter sets with matching types and equal values select the same specialization, the unadorned class name is the default specialization, each specialization has its own static variables while a non-parameterized base class shares one, and a type parameter takes any type, also a struct or a class (IEEE 1800-2023 Section 8.25)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25 6.22.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_class_specialization_identity_and_statics.expected
*/
// IEEE 1800-2023 §8.25: a class is parameterized with the parameter mechanism
// and its parameters are overridden as for modules, by position or by name.
// Two parameter sets give the same specialization only when every type
// parameter is a matching type and every value parameter has a matching type
// and the same value; matching specializations are the same type. The name of
// a parameterized class alone denotes its default specialization, C#().
// Each specialization has its own static variables; a variable shared by all
// of them belongs in a non-parameterized base class. A type parameter can be
// any type, including a structure or a class.
// cnt_c#(4), cnt_c#(.W(4)), cnt_c#(4, int), cnt_c#(4'd4) and cnt_c are all the
// specialization W = 4, T = int: the value 4'd4 becomes the int value 4 of W,
// and the default T is int. Their constructor calls share one static count,
// while cnt_c#(5) and cnt_c#(4, shortint) count separately. shared_c adds to
// the static total of its non-parameterized base for every specialization.
// Handles of the matching specializations are assigned to each other.
// Icarus Verilog 13.0 does not support parameterized classes.

typedef struct packed {
  logic [3:0] hi;
  logic [3:0] lo;
} pair_t;

class item_c;
  int id = 3;
endclass

class cnt_c #(int W = 4, type T = int);
  static int count = 0;
  T payload;
  bit [W-1:0] bits;
  function new();
    count++;
  endfunction
endclass

class total_c;
  static int total = 0;
endclass

class shared_c #(int W = 1) extends total_c;
  static int own = 0;
  function new();
    total++;
    own++;
  endfunction
endclass

module test_param_class_specialization_identity_and_statics;
  cnt_c #(4) a1;
  cnt_c #(.W(4)) a2;
  cnt_c #(4, int) a3;
  cnt_c #(4'd4) a4;
  cnt_c a5;
  cnt_c #(5) b1;
  cnt_c #(4, shortint) c1;
  cnt_c #(8, pair_t) s1;
  cnt_c #(2, item_c) h1;
  shared_c #(1) x1;
  shared_c #(2) x2, x3;

  initial begin
    a1 = new;
    a2 = new;
    a3 = new;
    a4 = new;
    a5 = new;
    b1 = new;
    c1 = new;
    $display("counts: W=4,T=int: %0d, W=5: %0d, T=shortint: %0d", a1.count, b1.count,
             c1.count);
    a1 = a2;
    a2 = a3;
    a3 = a4;
    a4 = a5;
    a5 = a1;
    $display("same type: a5==a1=%0d, bits of a5.bits=%0d, of b1.bits=%0d", a5 == a1,
             $bits(a5.bits), $bits(b1.bits));
    s1 = new;
    s1.payload = '{hi: 4'hc, lo: 4'h3};
    h1 = new;
    h1.payload = new;
    $display("type parameters: struct payload=%h hi=%h, class payload id=%0d", s1.payload,
             s1.payload.hi, h1.payload.id);
    x1 = new;
    x2 = new;
    x3 = new;
    $display("statics: shared total=%0d, own #(1)=%0d, own #(2)=%0d", total_c::total, x1.own,
             x2.own);
  end
endmodule
