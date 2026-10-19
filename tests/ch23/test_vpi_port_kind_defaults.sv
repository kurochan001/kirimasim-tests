/*
:name: test_vpi_port_kind_defaults
:description: Ports declared without a port kind are nets when they are inputs or inouts, or outputs with no data type or an implicit one, and variables when they are outputs with an explicit data type or are declared var, as VPI shows by the object types (IEEE 1800-2023 Section 23.2.2.3)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2.3 37.16 37.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_port_kind_defaults.c
:expected_stdout: @test_vpi_port_kind_defaults.expected
*/
// IEEE 1800-2023 §23.2.2.3: in an ANSI port list, an input or inout port
// without a port kind is a net of the default net type, whatever its data
// type; an output port without a port kind is a net if its data type is
// omitted or implicit (only signing or packed dimensions) and a variable if it
// has an explicit data type; var makes any port a variable. The application
// looks up the object of each port inside the instance and prints its kind
// from the VPI object type: vpiNet for logic nets, vpiIntNet for an int net
// (37.16), and vpiReg and vpiIntegerVar for variables (37.17).

module pk_sub(input logic in_logic, input int in_int, input var logic in_var,
              inout [1:0] io, output out_plain, output signed [3:0] out_signed,
              output logic out_logic, output integer out_integer);
  assign out_plain = in_logic;
  assign out_signed = 4'sd0;
  initial begin
    out_logic = in_var;
    out_integer = in_int;
  end
endmodule

module test_vpi_port_kind_defaults;
  logic a = 1'b0, c = 1'b1;
  int n = 3;
  wire [1:0] w;
  wire p;
  wire signed [3:0] s;
  logic l;
  integer i;

  pk_sub u(.in_logic(a), .in_int(n), .in_var(c), .io(w), .out_plain(p), .out_signed(s),
           .out_logic(l), .out_integer(i));

  initial #1 $vt_kinds;
endmodule
