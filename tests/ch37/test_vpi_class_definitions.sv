/*
:name: test_vpi_class_definitions
:description: a module gives its class definitions with their name and virtual flag, their properties, methods, constraints in declaration order and parameters with their local flag; a base class gives its derived classes and a derived class its extends relation to the base class typespec (IEEE 1800-2023 Sections 37.31, 37.32)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.31 37.32 37.28 8.13 8.21 8.25 18.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_class_definitions.c
:expected_stdout: @test_vpi_class_definitions.expected
*/
// IEEE 1800-2023 §37.31: vpi_iterate(vpiClassDefn, module) gives the class
// definitions of a module, with vpiName and vpiVirtual (§8.21); vpiVariables
// and vpiMethods give their properties and methods (detail 1), vpiConstraint
// their constraints in declaration order (detail 4, §18.5), and vpiParameter
// their parameters, with vpiLocalParam true for one declared in the class
// body (detail 7, §37.28, §8.25). vpiDerivedClasses gives the classes derived
// from a class (detail 5); vpiExtends gives the extends object of a derived
// class, and from it the class typespec of the base class (detail 6, §37.32,
// §8.13). Lists other than constraints are sorted.

`timescale 1ns/1ns

module test_vpi_class_definitions;
  class base #(int W = 4);
    localparam int K = 2;
    rand int x;
    int y;
    constraint c_low { x > 0; }
    constraint c_high { x < W * K; }
    function int f();
      return y;
    endfunction
    task t();
    endtask
  endclass

  virtual class shape;
    pure virtual function int area();
  endclass

  class square extends shape;
    int side;
    virtual function int area();
      return side * side;
    endfunction
  endclass

  initial #1 $vt_classes;
endmodule
