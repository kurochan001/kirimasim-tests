/*
:name: test_a1_9_constructor_arguments_and_parameter_class_item
:description: A class constructor takes comma-separated tf-port items with a default value, and a parameter declaration in a class is a localparam, so its value sizes and initializes other class items (IEEE 1800-2023 Sections 8.8 and 8.25, A.1.9 and A.10)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.8 8.25 A.1.9 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_a1_9_constructor_arguments_and_parameter_class_item.expected
*/
// IEEE 1800-2023 A.1.9: the argument list of a class constructor is one or
// more comma-separated class constructor arguments, each a tf-port item or the
// keyword default (clarification 9: default appears at most once). The tf-port
// item of A.2.7 gives the name, the dimensions and the default value.
// Clarification 7: in a parameter_declaration that is a class item, parameter
// is a synonym for localparam, so the name is a constant expression in the
// class.
//
// item has the parameters WIDTH and DEPTH and the properties slots, sized by
// WIDTH, and tag, initialized from DEPTH. Its constructor takes a and b, whose
// default is 5, and calls the base constructor. Two calls, one without b and
// one with it, show the default and the given value; slots has WIDTH
// elements, tag is DEPTH, and both names are readable through the class scope.

`timescale 1ns/1ns
module test_a1_9_constructor_arguments_and_parameter_class_item;
  class base;
    int x;
    int y;

    function new(int x = 1, int y = 2);
      this.x = x;
      this.y = y;
    endfunction
  endclass

  class item extends base;
    parameter int WIDTH = 3;
    parameter int DEPTH = WIDTH * 2;
    int slots [WIDTH];
    int tag = DEPTH;
    int a;
    int b;

    function new(int a, int b = 5);
      super.new();
      this.a = a;
      this.b = b;
    endfunction
  endclass

  item i1;
  item i2;

  initial begin
    i1 = new(7);
    i2 = new(7, 8);
    $display("defaults %0d %0d", i1.a, i1.b);
    $display("given %0d %0d", i2.a, i2.b);
    $display("size %0d %0d %0d %0d",
             $size(i1.slots), i1.tag, item::WIDTH, item::DEPTH);
  end
endmodule
