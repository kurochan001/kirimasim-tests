/*
:name: test_root_hierarchical_write
:description: A hierarchical name that starts with $root can be written as well as read (IEEE 1800-2023 Section 23.3.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.1 23.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_root_hierarchical_write.expected
*/
// IEEE 1800-2023 §23.3.1: $root names the top of the instance hierarchy, so
// $root.test_root_hierarchical_write.u.data is the variable data of instance
// u. Like any hierarchical name (23.6), it can be the target of an
// assignment: the value written through $root is read back through $root
// and through the relative name u.data.

module data_holder;
  logic [15:0] data = 16'h0000;
endmodule

module test_root_hierarchical_write;
  data_holder u ();

  initial begin
    #1 $root.test_root_hierarchical_write.u.data = 16'hcafe;
    #1 $display("$root read: %h, relative read: %h", $root.test_root_hierarchical_write.u.data,
                u.data);
    u.data = 16'hbeef;
    $display("after a relative write, $root read: %h", $root.test_root_hierarchical_write.u.data);
  end
endmodule
