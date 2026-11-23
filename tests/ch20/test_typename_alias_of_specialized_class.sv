/*
:name: test_typename_alias_of_specialized_class
:description: The type name of a specialized class is identical through its typedef (IEEE 1800-2023 Section 20.6.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.1 6.18 8.25
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typename_alias_of_specialized_class.expected
:expected_exit: 0
*/
// Compare the two strings for equality. The oracle does not fix a simulator-
// specific spelling of a specialized type. An empty name cannot pass.

package aliases;
  class box #(type T = int); endclass
  typedef box#(string) text_box;
endpackage

module test_typename_alias_of_specialized_class;
  import aliases::*;
  initial begin
    automatic string name = $typename(text_box);
    $display("CHECK named=%0d same_type=%0d", name.len() != 0,
             name == $typename(box#(string)));
    $finish;
  end
endmodule
