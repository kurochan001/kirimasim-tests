/*
:name: test_program_port_connection
:description: A program has ports like any design element, connected by name or in order, and its output ports drive the nets of the module that instantiates it (IEEE 1800-2023 Sections 24.3 and 23.3)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 23.3.2 23.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_port_connection.expected
*/
// IEEE 1800-2023 §24.3: a program is a design element and, like a module, may
// have input and output ports. §23.3.2: the two instances of p_ports connect
// them by name and in order. §23.3.3: an input port carries the value of the
// connected expression into the program, and an output port drives the net
// that the module connects to it. The module changes a at 4 and prints b and
// c at 7, after each program has read a again and written its output. §24.3:
// the simulation would end when every initial procedure of the programs has
// ended, so the initial procedure of p_ports waits once more after 6, and the
// module's $finish at 8 ends the run.

`timescale 1ns/1ns

program p_ports(input logic [3:0] d, output logic [3:0] q);
  initial begin
    #2 q = d + 1;
    #4 q = d + 2;
    #20 q = d + 3;
  end
endprogram

module test_program_port_connection;
  logic [3:0] a = 4'd3;
  wire [3:0] b, c;

  p_ports u1(.d(a), .q(b));
  p_ports u2(a, c);

  initial begin
    #4 a = 4'd5;
    #3 $display("named: b=%0d ordered: c=%0d", b, c);
    #1 $finish;
  end
endmodule
