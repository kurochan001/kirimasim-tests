/*
:name: test_dpi_vpi_callback_selects_export_scope
:description: A VPI callback selects the scope of each DPI export call
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_dpi_vpi_callback_selects_export_scope
:files: dpi_vpi_export_scope/host.cpp
:expected_stdout: @test_dpi_vpi_callback_selects_export_scope.expected
*/
module dpi_vpi_scoped_token #(parameter int TOKEN = 0);
  export "DPI-C" function read_scope_token;

  function int read_scope_token();
    return TOKEN;
  endfunction
endmodule

module test_dpi_vpi_callback_selects_export_scope;
  dpi_vpi_scoped_token #(.TOKEN(37)) first();
  dpi_vpi_scoped_token #(.TOKEN(91)) second();

  initial begin
    $display("same instances=%0d,%0d", first.read_scope_token(), second.read_scope_token());
    $finish(0);
  end
endmodule
