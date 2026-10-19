/*
:name: test_config_library_binding_format
:description: The %l format prints the library and cell that the module instance containing the call is bound to, including a binding changed by a config (IEEE 1800-2023 Section 33.7)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.7 33.4.1.6 21.2.1.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_library_binding_format.expected
*/
// IEEE 1800-2023 §33.7: %l prints the library.cell binding of the module
// instance that contains the display, much as %m prints its hierarchical name
// (21.2.1.5). Every cell here is in the library work. The config binds u2, an
// instance of cfg_lib_a, to cfg_lib_b, so its task prints work.cfg_lib_b; %m in
// a task prints the name of the task. Icarus Verilog 13.0 skips config
// declarations. Verilator 5.052 gives this output only when --top-module names
// this module.

module cfg_lib_a;
  task show();
    $display("%m: %l");
  endtask
endmodule

module cfg_lib_b;
  task show();
    $display("%m: %l");
  endtask
endmodule

module test_config_library_binding_format;
  cfg_lib_a u1();
  cfg_lib_a u2();

  initial begin
    $display("%m: %l");
    u1.show();
    u2.show();
  end
endmodule

config cfg;
  design work.test_config_library_binding_format;
  instance test_config_library_binding_format.u2 use work.cfg_lib_b;
endconfig
