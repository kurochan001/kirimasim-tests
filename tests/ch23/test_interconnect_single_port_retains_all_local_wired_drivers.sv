/*
:name: test_interconnect_single_port_retains_all_local_wired_drivers
:description: Several drivers on one typed inout port keep their wired resolution when the enclosing connection is interconnect
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7.1 6.6.8 6.6.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:files: wired_inout_local_drivers.sv
:expected_stdout: @test_interconnect_single_port_retains_all_local_wired_drivers.expected
*/
module test_interconnect_single_port_retains_all_local_wired_drivers;
  bit a = 0, b = 0;
  interconnect merged_and, merged_or;
  wire local_and, local_or, remote_and, remote_or;

  local_and_drivers tested_and(a, b, merged_and, local_and);
  local_or_drivers tested_or(a, b, merged_or, local_or);
  remote_and_reader tested_and_observer(merged_and, remote_and);
  remote_or_reader tested_or_observer(merged_or, remote_or);
  task automatic sample(input bit value_a, value_b);
    a = value_a;
    b = value_b;
    #1;
    $display("a=%b b=%b local=%b%b remote=%b%b", a, b, local_and, local_or, remote_and, remote_or);
  endtask

  initial begin
    sample(0, 0);
    sample(0, 1);
    sample(1, 0);
    sample(1, 1);
  end
endmodule
