/*
:name: test_config_binding_nested
:description: %l prints the library.cell binding of the module instance that contains the call, also through nested instances and functions, while %m prints the hierarchical name (IEEE 1800-2023 Section 33.7)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.7 21.2.1.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_config_binding_nested
:expected_stdout: @test_config_binding_nested.expected
*/
// IEEE 1800-2023 §33.7: %l prints the library.cell binding of the module
// instance in which the call is made, while %m (21.2.1.5) prints the
// hierarchical name of the call. Every cell here has the default binding to
// library work, so a task of cell_x prints work.cell_x whether it is called
// through w1.x or w2.x, and a function of cell_x called through w2.x.label
// prints work.cell_x as well. The top module prints its own binding.
//
// Icarus Verilog 13.0 does not implement %l; version 5.052 of Verilator
// prints this output when --top-module names the test module, which the
// :top_module: field does.

module cell_x;
  task show();
    $display("x task: %m %l");
  endtask

  function automatic string label();
    return $sformatf("%l");
  endfunction
endmodule

module cell_y;
  task show();
    $display("y task: %m %l");
  endtask
endmodule

module wrap;
  cell_x x();
  cell_y y();
endmodule

module test_config_binding_nested;
  wrap w1();
  wrap w2();

  initial begin
    $display("top: %m %l");
    w1.x.show();
    w2.x.show();
    w1.y.show();
    $display("func through path: %s", w2.x.label());
  end
endmodule
