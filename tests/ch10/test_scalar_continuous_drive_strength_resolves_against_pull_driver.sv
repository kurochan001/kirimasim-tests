/*
:name: test_scalar_continuous_drive_strength_resolves_against_pull_driver
:description: A scalar continuous assignment with an explicit drive strength resolves against a pull driver
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_scalar_continuous_drive_strength_resolves_against_pull_driver.expected
*/
module test_scalar_continuous_drive_strength_resolves_against_pull_driver;
  logic drive;
  wire weaker, stronger;
  assign (weak0, weak1) weaker = drive;
  assign (strong0, strong1) stronger = drive;
  pulldown (weaker);
  pulldown (stronger);

  initial begin
    drive = 0;
    #1 $display("low weak=%b strong=%b", weaker, stronger);
    drive = 1;
    #1 $display("high weak=%b strong=%b", weaker, stronger);
  end
endmodule
