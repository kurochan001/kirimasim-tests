/*
:name: test_class_static_init_order
:description: The declaration initializers of static class properties and of package variables take effect before any initial procedure starts, so updates made at time 0 build on them instead of being overwritten (IEEE 1800-2023 Section 6.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8 8.9 26.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_static_init_order.expected
*/
// IEEE 1800-2023 §6.8: the initial value given in the declaration of a static
// variable, static class members included, is set before any initial or always
// procedure starts. ci_counter::made is a static class property (8.9) set to
// 10, and ci_pkg::total a package variable (26.2) set to 100. The initial
// procedure creates three objects, whose constructor adds 1 to made, and adds
// 5 to total, so they become 13 and 105; an initializer that ran later would
// have overwritten the updates.

package ci_pkg;
  int total = 100;
endpackage

class ci_counter;
  static int made = 10;
  function new();
    made++;
  endfunction
endclass

module test_class_static_init_order;
  initial begin
    ci_counter c;
    repeat (3) c = new;
    ci_pkg::total += 5;
    $display("made = %0d, total = %0d", ci_counter::made, ci_pkg::total);
  end
endmodule
