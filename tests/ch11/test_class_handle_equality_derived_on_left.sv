/*
:name: test_class_handle_equality_derived_on_left
:description: Logical and case equality compare object identity with the derived class handle on the left
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5 8.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: class_handle_equality/handle_pairs.svh
:expected_stdout: @test_class_handle_equality_derived_on_left.expected
*/
// The child handle is assignment compatible with the parent handle.
// Equality in either order tests identity, including when both are null.
// Icarus Verilog 13.0 reports that handle comparison is unimplemented.
module test_class_handle_equality_derived_on_left;
  `include "handle_pairs.svh"

  task automatic show(input string state);
    $display("%s ==%b !=%b ===%b !==%b", state,
             child_handle == parent_handle, child_handle != parent_handle,
             child_handle === parent_handle, child_handle !== parent_handle);
  endtask
endmodule
