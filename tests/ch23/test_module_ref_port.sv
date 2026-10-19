/*
:name: test_module_ref_port
:description: A ref port of a module shares the connected variable, so writes on either side are seen at once on the other (IEEE 1800-2023 Section 23.3.3)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3 23.3.3.2 23.2.2.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_ref_port.expected
*/
// IEEE 1800-2023 §23.3.3: a ref port passes a reference to the variable
// connected to it, so the module and its parent share one variable. A write
// in the child is seen by the parent in the same time step, and a write in
// the parent by the child; nothing is copied through the port. §23.3.3.2: a
// ref port is connected to a variable of an equivalent type.

module ref_child (ref logic [7:0] r);
  initial begin
    #2 r = 8'h55;
    $display("t=%0d child wrote 55, parent's v reads %h", $time, test_module_ref_port.v);
  end
endmodule

module test_module_ref_port;
  logic [7:0] v = 8'h00;
  ref_child u1 (.r(v));

  initial begin
    #1 v = 8'h11;
    $display("t=%0d parent wrote 11, u1.r reads %h", $time, u1.r);
    #2 $display("t=%0d v=%h", $time, v);
    v = 8'ha7;
    $display("t=%0d parent wrote a7, u1.r reads %h", $time, u1.r);
  end
endmodule
