/*
:name: test_ref_port_variable_shared_writers
:description: A variable passed to ref ports of two instances is one variable shared across the ports, so procedural writes in either instance or in the parent are seen at once through every port (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.5 23.3.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ref_port_variable_shared_writers.expected
*/
// IEEE 1800-2023 §6.5: a variable cannot be connected to an inout port, and a
// variable connected to an output port can have no other writer; but a
// variable can be shared across ports with ref ports (23.3.3), where no
// continuous assignment is implied and the variable can have several
// procedural writers.
// The parent variable v is connected to the ref port r of two instances, which
// write it at times 1 and 3; the parent writes it at time 4. After each write,
// v and r in both instances read the value just written.

module test_ref_port_variable_shared_writers_child #(parameter logic [7:0] VAL = 8'h00,
                                                     parameter int AT = 0)
  (ref logic [7:0] r);
  initial #AT r = VAL;
endmodule

module test_ref_port_variable_shared_writers;
  logic [7:0] v = 8'h00;

  test_ref_port_variable_shared_writers_child #(.VAL(8'h11), .AT(1)) a(.r(v));
  test_ref_port_variable_shared_writers_child #(.VAL(8'h22), .AT(3)) b(.r(v));

  initial begin
    #2 $display("after a: v=%h a.r=%h b.r=%h", v, a.r, b.r);
    #2 $display("after b: v=%h a.r=%h b.r=%h", v, a.r, b.r);
    v = 8'h33;
    $display("after parent: v=%h a.r=%h b.r=%h", v, a.r, b.r);
  end
endmodule
