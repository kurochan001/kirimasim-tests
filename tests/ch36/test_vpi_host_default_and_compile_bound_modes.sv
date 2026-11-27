/*
:name: test_vpi_host_default_and_compile_bound_modes
:description: One VPI default applies to unbound applications alongside compile bound modes
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.2 36.12.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: vpi_host_default/dispatcher.c
:vpi_c: @vpi_host_default/application.c
:expected_stdout: @test_vpi_host_default_and_compile_bound_modes.expected
*/
module test_vpi_host_default_and_compile_bound_modes;
  reg [7:0] storage [0:2];
  reg [7:0] standalone;
  integer counter;

  initial begin
    storage[1] = 8'd47;
    standalone = 8'd59;
    counter = 61;
    #1 $finish(0);
  end
endmodule
