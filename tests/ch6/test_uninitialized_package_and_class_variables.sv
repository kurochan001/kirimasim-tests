/*
:name: test_uninitialized_package_and_class_variables
:description: 4-state variables in a package and class properties without an initializer start as x, and 2-state ones as 0 (IEEE 1800-2023 Section 6.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8 26.2 8.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_uninitialized_package_and_class_variables.expected
*/
// IEEE 1800-2023 §6.8, Table 6-7: a variable without an initializer starts
// with the default of its type, x for a 4-state integral type and 0 for a
// 2-state one. This is the same for a variable declared in a package (26.2),
// for a property of a class object (8.7) and for a static class property as
// for a variable of a module.

package pk;
  logic [15:0] v;
  int i;
endpackage

class holder;
  logic [15:0] inst;
  static logic [15:0] stat;
  bit [3:0] two;
endclass

module test_uninitialized_package_and_class_variables;
  logic [15:0] m;
  holder obj;

  initial begin
    obj = new;
    #1;
    $display("package: v=%h i=%0d", pk::v, pk::i);
    $display("class: inst=%h stat=%h two=%b", obj.inst, obj.stat, obj.two);
    $display("module: m=%h", m);
  end
endmodule
