/*
:name: test_bound_constant_output_overrides_pull_driver
:description: A constant-driven output of a bound module overrides either pull default in the enclosing target
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11 23.3.3 6.6.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bound_constant_output_overrides_pull_driver.expected
*/
module bound_constant_driver(output wire [7:0] drive);
  assign drive = 8'h29;
endmodule

module bound_constant_target;
  tri0 [7:0] bound_down, direct_down;
  tri1 [7:0] bound_up, direct_up;
  wire [7:0] bound_plain, direct_plain;
  bound_constant_driver local_plain(direct_plain);
  bound_constant_driver local_down(direct_down);
  bound_constant_driver local_up(direct_up);
endmodule

module test_bound_constant_output_overrides_pull_driver;
  bound_constant_target dut();
  bind bound_constant_target bound_constant_driver constant_plain(bound_plain);
  bind bound_constant_target bound_constant_driver constant_down(bound_down);
  bind bound_constant_target bound_constant_driver constant_up(bound_up);

  initial #1 begin
    $display("bound plain=%h pull0=%h pull1=%h", dut.bound_plain, dut.bound_down, dut.bound_up);
    $display("local plain=%h pull0=%h pull1=%h", dut.direct_plain, dut.direct_down, dut.direct_up);
    $finish(0);
  end
endmodule
