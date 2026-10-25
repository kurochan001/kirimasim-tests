/*
:name: test_syntax_class_and_interface_class_headers
:description: A class header with the final specifier, a parameter port list, extends with constructor arguments and an implements list, and an interface class header with a parameter port list, an extends list of interface class types, a typedef, localparam, parameter, empty and attributed pure virtual items (IEEE 1800-2023 Sections 8.3, 8.13 and 8.26.1)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.3 8.13 8.26.1 A.1.2 A.1.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_class_and_interface_class_headers.expected
*/
// IEEE 1800-2023 A.1.2: a class declaration is an optional virtual, class,
// an optional final specifier, an identifier, an optional parameter port
// list, an optional extends with a class type and optional constructor
// arguments, an optional implements with one or more interface class types,
// a semicolon, class items, endclass and an optional name. An interface
// class declaration is interface class, an identifier, an optional parameter
// port list, an optional extends with one or more interface class types, a
// semicolon, interface class items, endclass and an optional name.
//   - c_plain has a constructor and a virtual method, and c_top is a final
//     class that extends it with the constructor argument 5, so the implicit
//     constructor of c_top calls c_plain's constructor with 5,
//   - ic_base has a parameter port list, a typedef of a vector of its
//     parameter, a localparam, a parameter, an empty item, and an attributed
//     pure virtual function whose argument and return type are the typedef
//     and a pure virtual task,
//   - ic_chain extends two interface classes, one of them parameterized,
//   - c_impl implements the parameterized interface class and ic_extra, so
//     it defines f, t and g; f of a 2-bit type returns x + 1.
// The printed numbers: v = 5, w = 6, id = 5, f(2) = 3, g = 9, count = 4.
//
// Icarus Verilog 13.0 does not compile this design. Verilator 5.052 does not
// accept every header or interface class item here.

interface class ic_extra;
  pure virtual function int g();
endclass

interface class ic_base #(parameter int W = 2);
  typedef logic [W-1:0] T;
  localparam int K = 3;
  parameter int M = 4;
  ;
  (* attr *) pure virtual function T f(input T x);
  (* attr *) pure virtual task t(input int n);
endclass : ic_base

interface class ic_chain extends ic_base#(3), ic_extra;
  pure virtual function int h();
endclass

class c_plain;
  int v;

  function new(int a);
    v = a;
  endfunction

  virtual function int id();
    return v;
  endfunction
endclass

class :final c_top extends c_plain(5);
  int w = 6;
endclass

class c_impl implements ic_base#(2), ic_extra;
  int count;

  virtual function ic_base#(2)::T f(input ic_base#(2)::T x);
    return x + 1;
  endfunction

  virtual task t(input int n);
    count = count + n;
  endtask

  virtual function int g();
    return 9;
  endfunction
endclass

module test_syntax_class_and_interface_class_headers;
  c_top o;
  c_impl i;
  int r;

  initial begin
    o = new();
    i = new();
    r = i.f(2);
    i.t(4);
    #1 $display("top v=%0d w=%0d id=%0d impl f=%0d g=%0d count=%0d",
                o.v, o.w, o.id(), r, i.g(), i.count);
  end
endmodule
