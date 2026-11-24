/*
:name: test_dpi_scope_switch_and_restore_across_instances
:description: Context imports use their own instance scope and explicit scope changes control export dispatch
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 I.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_scope_switch_and_restore_across_instances.c
:expected_stdout: @test_dpi_scope_switch_and_restore_across_instances.expected
*/
// Each call enters through a different instance of one module type.
module scope_owner #(parameter int ID = 0);
  import "DPI-C" context function int c_probe_scope(input bit save);
  export "DPI-C" function instance_id;
  function int instance_id();
    return ID;
  endfunction
endmodule

module test_dpi_scope_switch_and_restore_across_instances;
  scope_owner #(.ID(1)) first();
  scope_owner #(.ID(2)) second();

  initial begin
    $display("first=%0d", first.c_probe_scope(1));
    $display("second=%0d", second.c_probe_scope(0));
    $display("first_again=%0d", first.c_probe_scope(1));
  end
endmodule
