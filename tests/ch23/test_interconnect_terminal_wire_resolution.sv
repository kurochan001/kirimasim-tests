/*
:name: test_interconnect_terminal_wire_resolution
:description: An interconnect net connected to gate and UDP terminals is treated as a scalar wire, so conflicting gate and UDP outputs on it resolve to x, a UDP output alone drives it, and gate and UDP inputs read it (IEEE 1800-2023 Section 23.3.3.7.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7.2 6.6.8 6.6.1 29.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_interconnect_terminal_wire_resolution.expected
*/
// IEEE 1800-2023 §23.3.3.7.2: an interconnect net connected to a terminal
// of a primitive or of a UDP is treated as though the terminal were
// connected to a scalar wire. §6.6.1: a wire with two drivers of equal
// strength and opposite values is x.
//   t1: the output of a buf gate drives 1 and the output of a UDP drives 0;
//       as a wire, t1 is x (a wand would be 0, a wor 1);
//   t2: only the output of the UDP drives it, with 1;
//   t3: a module output port drives 0 onto it, and it is the input of a
//       not gate and of the UDP, whose outputs y3 and y4 are 1 and 0.
// t1 and t2 are read through a wire input port of a reader module, whose
// net merges with the interconnect net (23.3.3.7.1). Neither Icarus Verilog
// 13.0 nor Verilator 5.052 supports interconnect nets, so this expected
// output follows the standard alone.

primitive interconnect_terminal_wire_resolution_id(output y, input a);
  table
    0 : 0;
    1 : 1;
  endtable
endprimitive

module interconnect_terminal_wire_resolution_reader(input wire logic i);
endmodule

module interconnect_terminal_wire_resolution_src0(output wire o);
  assign o = 1'b0;
endmodule

module test_interconnect_terminal_wire_resolution;
  interconnect t1, t2, t3;
  wire y3, y4;

  buf g1(t1, 1'b1);
  interconnect_terminal_wire_resolution_id p1(t1, 1'b0);
  interconnect_terminal_wire_resolution_reader r1(t1);

  interconnect_terminal_wire_resolution_id p2(t2, 1'b1);
  interconnect_terminal_wire_resolution_reader r2(t2);

  interconnect_terminal_wire_resolution_src0 s3(t3);
  not g3(y3, t3);
  interconnect_terminal_wire_resolution_id p3(y4, t3);

  initial begin
    #1;
    $display("t1 (buf 1, UDP 0): %b", r1.i);
    $display("t2 (UDP 1): %b", r2.i);
    $display("t3 (port 0): not gives %b, UDP gives %b", y3, y4);
  end
endmodule
