/*
:name: test_vpi_class_specialization_members
:description: the class typespec of a variable declared with a parameterized class is a specialization that iterates its parameters with their values and local flags, its parameter assignment, its static and automatic properties and methods without built-in methods, its virtual interface variables one element at a time while vpiVariables gives the array whole, its normal constraints in declaration order and its named events and event arrays, each of which leads back to it (IEEE 1800-2023 Section 37.32)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.32 37.33 37.28 8.25 18.5.1 18.7 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_class_specialization_members.c
:expected_stdout: @test_vpi_class_specialization_members.expected
*/
// IEEE 1800-2023 §37.32: the class var b8 is declared outside any class defn
// with base #(8), so its class typespec (37.33 detail 5) has all parameters
// resolved and is a class specialization (detail 1). Its vpiParameter
// iteration gives the port parameter W, 8, and the body parameter K, 2, with
// vpiLocalParam TRUE only for K (detail 12, 37.28); its param assign for W
// has a right-hand side with the value 8 (detail 3). vpiVariables and
// vpiMethods give static and automatic members alike and no built-in method
// such as randomize or new (detail 5): the properties s_cnt, x, vif and vifs,
// the methods get, sget and t. vpiVirtualInterfaceVar gives vif and each of
// the two elements of vifs, while vpiVariables gives vifs once, as a
// vpiArrayVar (detail 11, 25.9). vpiConstraint gives the normal constraints
// in declaration order, the extern c_ext at the place of its prototype, and
// not the inline constraint of randomize() with in never_called (details 7
// and 8, 18.5.1, 18.7). vpiNamedEvent gives ev and vpiNamedEventArray evs.
// Each parameter, method, constraint, event and event array leads back to the
// specialization through vpiClassTypespec. Names are sorted, except the
// constraints, which are printed in iteration order.

interface test_vpi_class_specialization_members_ifc;
  logic s;
endinterface

module test_vpi_class_specialization_members;
  class base #(int W = 4);
    localparam int K = 2;
    static int s_cnt;
    rand int x;
    virtual test_vpi_class_specialization_members_ifc vif;
    virtual test_vpi_class_specialization_members_ifc vifs [2];
    event ev;
    event evs [2];
    constraint c_a { x < W; }
    extern constraint c_ext;
    constraint c_b { x > 0; }

    function int get();
      return x;
    endfunction

    static function int sget();
      return s_cnt;
    endfunction

    task t();
    endtask
  endclass

  constraint base::c_ext { x != 3; }

  base #(8) b8;

  function void never_called();
    void'(b8.randomize() with { x == 5; });
  endfunction

  initial #1 $vt_spec;
endmodule
