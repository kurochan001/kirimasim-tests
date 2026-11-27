/*
:name: test_vpi_host_default_reversed_library_order
:description: One VPI host default applies to unbound applications regardless of their load order
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_vpi_host_default_and_compile_bound_modes
:files: vpi_host_default/dispatcher.c
:vpi_c: @vpi_host_default/application.c
:expected_stdout: @test_vpi_host_default_reversed_library_order.expected
*/
// Keep the interface name expected by the unchanged application binaries.
module test_vpi_host_default_and_compile_bound_modes;
  reg [7:0] storage [0:2];
  reg [7:0] standalone;
  integer counter;

  initial begin
    storage[1] = 8'd83;
    standalone = 8'd19;
    counter = 23;
    #1 $finish(0);
  end
endmodule
