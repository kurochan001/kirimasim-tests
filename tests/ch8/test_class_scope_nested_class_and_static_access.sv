/*
:name: test_class_scope_nested_class_and_static_access
:description: the class scope operator reads and writes static properties, calls static methods, names enum constants, typedefs, nested classes and parameters, and triggers static events from outside a class, and a nested class uses the static members of its outer class without qualification and its local members through a handle (IEEE 1800-2023 Section 8.23)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.23
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_scope_nested_class_and_static_access.expected
*/
// IEEE 1800-2023 §8.23: class_type::name selects static properties and
// methods, typedefs, enum constants, parameters, local parameters and nested
// classes of a class; such expressions can be read, written and used in event
// controls. A nested class has the access rights of a method of its outer
// class, so it can use local and protected members through a handle, and it
// sees the static properties and methods and the parameters of the outer
// class without qualification.
// The module uses outer_c:: for a static property, a static method, an enum
// constant, a struct typedef, a local parameter, the nested class and a static
// event. inner_c::peek changes the static properties sprop and slprop (local)
// unqualified and reads prop and the local lprop through a handle.
// Icarus Verilog 13.0 does not support nested classes.

class outer_c;
  int prop = 1;
  local int lprop = 2;
  static int sprop = 3;
  static local int slprop = 4;
  localparam int LP = 5;
  typedef enum {A0, A1, A2} e_t;
  typedef struct packed {
    logic [3:0] hi;
    logic [3:0] lo;
  } pair_t;
  static event ev;
  static function int sfun();
    return 6;
  endfunction
  function int get_slprop();
    return slprop;
  endfunction
  class inner_c;
    function int peek(outer_c h);
      sprop = sprop + 10;
      slprop = slprop + 10;
      return h.prop + h.lprop + LP + sfun();
    endfunction
  endclass
endclass

module test_class_scope_nested_class_and_static_access;
  outer_c o;
  outer_c::inner_c in;
  outer_c::pair_t pr;
  int got;

  initial begin
    o = new;
    in = new;
    got = in.peek(o);
    $display("nested: peek=%0d sprop=%0d slprop=%0d", got, outer_c::sprop, o.get_slprop());
    outer_c::sprop = 30;
    pr = '{hi: 4'ha, lo: 4'h5};
    $display("scope: sprop=%0d sfun=%0d A2=%0d LP=%0d pair=%h bits=%0d", outer_c::sprop,
             outer_c::sfun(), outer_c::A2, outer_c::LP, pr, $bits(outer_c::pair_t));
    fork
      begin
        @(outer_c::ev);
        $display("event through the class scope");
      end
      #1 -> outer_c::ev;
    join
  end
endmodule
