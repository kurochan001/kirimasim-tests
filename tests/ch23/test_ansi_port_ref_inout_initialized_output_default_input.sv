/*
:name: test_ansi_port_ref_inout_initialized_output_default_input
:description: In an ANSI port list a ref port is a variable shared with the connected variable, an inout port is a net resolved with the drivers outside, a variable output port can have an initial value, and an input port can have a default value used when it is not connected (IEEE 1800-2023 Section 23.2.2.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2.2 23.2.2.4 23.3.3 A.1.3 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ansi_port_ref_inout_initialized_output_default_input.expected
*/
// IEEE 1800-2023 §23.2.2.2 with footnote 2 of A.10 (on
// list_of_port_declarations, A.1.3): a ref port is of a variable type and an
// inout port is not; only a variable output port can be initialized, and
// only an input port can have a default value (23.2.2.4). The module
// port_kinds has one port of each kind, used in those legal ways:
//   ref int r            writes and reads go to the connected variable
//                        itself (23.3.3)
//   inout wor [3:0] io   a net; the module drives 4'h5 on it, and outside
//                        the parent drives 4'hA, so both see 4'hF, and 4'h5
//                        once the parent drives 0
//   output int count = 7 the variable starts at 7, which the port gives to
//                        the connected variable before the module writes it
//   input var int step = 10  u1 leaves step out and gets 10; u2 connects 20
//
// Times: at 1 each instance adds 100 through r; at 2 the parent prints a, b,
// c1, c2 and bus1; at 3 it sets a to 9 and stops driving bus1; at 4 u1
// stores what it sees through r and io; at 5 each instance adds step to
// count; at 6 the parent prints the rest. No two prints, nor a write and a
// read of the same object, happen at the same time.
//
// Icarus Verilog 13.0 does not support ref ports.

module port_kinds (
  ref int r,
  inout wor [3:0] io,
  output int count = 7,
  input var int step = 10
);
  int seen_r;
  logic [3:0] seen_io;

  assign io = 4'h5;

  initial begin
    #1 r = r + 100;
    #3 seen_r = r;
    seen_io = io;
    #1 count = count + step;
  end
endmodule

module test_ansi_port_ref_inout_initialized_output_default_input;
  int a = 1, b = 50;
  int c1, c2;
  logic [3:0] pdrive = 4'hA;
  wor [3:0] bus1, bus2;

  assign bus1 = pdrive;

  port_kinds u1 (.r(a), .io(bus1), .count(c1));
  port_kinds u2 (.r(b), .io(bus2), .count(c2), .step(20));

  initial begin
    #2 $display("t2: a=%0d b=%0d c1=%0d c2=%0d bus1=%h", a, b, c1, c2, bus1);
    #1 a = 9;
    pdrive = 4'h0;
    #3 $display("t6: u1 saw r=%0d io=%h, bus1=%h c1=%0d c2=%0d", u1.seen_r, u1.seen_io, bus1,
                c1, c2);
  end
endmodule
