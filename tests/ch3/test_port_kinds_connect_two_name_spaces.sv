/*
:name: test_port_kinds_connect_two_name_spaces
:description: the ports of a module, an interface, a program and a primitive connect an object of the instantiating scope to the port of the instance whatever names the two sides use; input and output ports carry a value one way, inout and ref ports both ways, and a primitive has output and input ports (IEEE 1800-2023 Section 3.13)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.13 23.3.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_kinds_connect_two_name_spaces.expected
*/
// IEEE 1800-2023 §3.13 g): modules, interfaces, primitives and programs
// introduce a port name space, which connects two objects that are in
// different name spaces. A connection is one way (input or output) or both
// ways (inout or ref). §23.3.3: an input or output port is a continuous
// assignment from the source to the sink, an inout port joins the nets on
// its two sides, and a ref port refers to the variable connected to it.
// §29.3: a primitive has one output port and input ports.
// The top module declares a, q, b and r, the names of the ports of the
// instances, as its own variables (200, 201, 202 and 900), and connects
// other objects to the ports. The module pk_mod, the interface pk_if and the
// program pk_prog have the same four ports: input a, output q = a + k
// (k = 1, 2, 3), inout net b and ref int r. Each uses its own window that
// starts at B (0, 10 and 20):
//   B+1  the top writes 5, 6 or 7 to the variable on r;
//   B+2  the instance prints a (the top's value), b (the top's drive) and r
//        (the value the top wrote);
//   B+3  the top stops driving b and the instance drives it; the instance
//        adds 100, 200 or 300 to r;
//   B+4  the top prints q, the net on b and the variable on r.
// The primitive pk_and has the ports q (output), a and b (inputs); the top
// connects y, en1 and en2, sets both inputs to 1 at 24 and en2 to 0 at 31,
// and prints y at 31 and 33.
// At 35 the top prints its own a, q, b and r, which no port has changed.
// The program waits until 40, so the simulation ends after that (§24.3).
// Icarus Verilog 13.0 does not support ref ports ("sorry"). The 5.054
// release of the Verilator tool matches the expected output (in 5.052 the
// ref port of the interface did not see the value written to the variable
// connected to it); the test uses x and z, so it lists no Verilator oracle.

primitive pk_and(output q, input a, input b);
  table
  // a b : q
     1 1 : 1;
     0 ? : 0;
     ? 0 : 0;
  endtable
endprimitive

module pk_mod(input logic [7:0] a, output logic [7:0] q, inout wire [7:0] b, ref int r);
  logic drive = 1'b0;
  assign q = a + 8'd1;
  assign b = drive ? 8'h5a : 8'hzz;
  initial begin
    #2 $display("module inside: a=%0d b=%h r=%0d", a, b, r);
    #1 drive = 1'b1;
    r = r + 100;
  end
endmodule

interface pk_if(input logic [7:0] a, output logic [7:0] q, inout wire [7:0] b, ref int r);
  logic drive = 1'b0;
  assign q = a + 8'd2;
  assign b = drive ? 8'h6b : 8'hzz;
  initial begin
    #12 $display("interface inside: a=%0d b=%h r=%0d", a, b, r);
    #1 drive = 1'b1;
    r = r + 200;
  end
endinterface

program pk_prog(input logic [7:0] a, output logic [7:0] q, inout wire [7:0] b, ref int r);
  logic drive = 1'b0;
  assign q = a + 8'd3;
  assign b = drive ? 8'h7c : 8'hzz;
  initial begin
    #22 $display("program inside: a=%0d b=%h r=%0d", a, b, r);
    #1 drive = 1'b1;
    r = r + 300;
    #17;
  end
endprogram

module test_port_kinds_connect_two_name_spaces;
  logic [7:0] a = 8'd200, q = 8'd201, b = 8'd202;
  int r = 900;

  logic [7:0] m_in = 8'd10, i_in = 8'd20, p_in = 8'd30;
  logic [7:0] m_out, i_out, p_out;
  logic m_drive = 1'b1, i_drive = 1'b1, p_drive = 1'b1;
  wire [7:0] m_bus, i_bus, p_bus;
  int m_ref = 1, i_ref = 2, p_ref = 3;
  logic en1 = 1'b0, en2 = 1'b0;
  wire y;

  assign m_bus = m_drive ? 8'h11 : 8'hzz;
  assign i_bus = i_drive ? 8'h22 : 8'hzz;
  assign p_bus = p_drive ? 8'h33 : 8'hzz;

  pk_mod u_mod(.a(m_in), .q(m_out), .b(m_bus), .r(m_ref));
  pk_if u_if(i_in, i_out, i_bus, i_ref);
  pk_prog u_prog(.r(p_ref), .b(p_bus), .q(p_out), .a(p_in));
  pk_and u_and(y, en1, en2);

  initial begin
    #1 m_ref = 5;
    #2 m_drive = 1'b0;
    #1 $display("module outside: q=%0d b=%h r=%0d", m_out, m_bus, m_ref);
    #7 i_ref = 6;
    #2 i_drive = 1'b0;
    #1 $display("interface outside: q=%0d b=%h r=%0d", i_out, i_bus, i_ref);
    #7 p_ref = 7;
    #2 p_drive = 1'b0;
    #1 $display("program outside: q=%0d b=%h r=%0d", p_out, p_bus, p_ref);
    en1 = 1'b1;
    en2 = 1'b1;
    #7 $display("primitive: y=%b", y);
    en2 = 1'b0;
    #2 $display("primitive: y=%b", y);
    #2 $display("top's own: a=%0d q=%0d b=%0d r=%0d", a, q, b, r);
  end
endmodule
