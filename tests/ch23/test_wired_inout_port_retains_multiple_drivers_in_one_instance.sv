/*
:name: test_wired_inout_port_retains_multiple_drivers_in_one_instance
:description: Wired AND and OR inout ports resolve their two local drivers the same way as equivalent nets driven within one scope
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 23.3.3.1 6.6.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:files: wired_inout_local_drivers.sv
:expected_stdout: @test_wired_inout_port_retains_multiple_drivers_in_one_instance.expected
*/
module test_wired_inout_port_retains_multiple_drivers_in_one_instance;
  logic a, b;
  logic states[4] = '{1'b0, 1'b1, 1'bx, 1'bz};
  wand tested_and, direct_and;
  wor tested_or, direct_or;
  wire internal_and, internal_or, external_and, external_or;

  assign direct_and = a;
  assign direct_and = b;
  assign direct_or = a;
  assign direct_or = b;
  local_and_drivers u_and(a, b, tested_and, internal_and);
  local_or_drivers u_or(a, b, tested_or, internal_or);
  remote_and_reader read_and(tested_and, external_and);
  remote_or_reader read_or(tested_or, external_or);

  task automatic sample(input logic value_a, value_b);
    a = value_a;
    b = value_b;
    #1;
    $display("a=%b b=%b direct=%b%b inout-local=%b%b remote=%b%b",
             a, b, direct_and, direct_or, internal_and, internal_or, external_and, external_or);
  endtask

  initial begin
    foreach (states[i])
      foreach (states[j]) sample(states[i], states[j]);
  end
endmodule
