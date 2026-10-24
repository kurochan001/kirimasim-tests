/*
:name: test_logic_reg_same_type
:description: reg and logic denote the same data type, so type references of reg and logic declarations with the same signing and range compare equal, while bit and a different signing do not (IEEE 1800-2023 Section 6.11.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11.2 6.23 6.22.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logic_reg_same_type.expected
*/
// IEEE 1800-2023 §6.11.2: logic and reg denote the same type; the keyword
// reg does not make anything a hardware register. §6.23: type references can
// be compared with == and !=, which is true when the types match (6.22.1).
// Variables and typedefs declared with reg and with logic, scalar, with a
// range and signed, are compared; bit, which is 2-state, and the same range
// with a different signing are the controls that do not match.

module test_logic_reg_same_type;
  reg r1;
  logic l1;
  reg [3:0] r4;
  logic [3:0] l4;
  bit [3:0] b4;
  reg signed [3:0] rs4;
  logic signed [3:0] ls4;
  typedef reg [7:0] reg_byte_t;
  typedef logic [7:0] logic_byte_t;

  initial begin
    $display("reg == logic: %0d", type(r1) == type(l1));
    $display("reg [3:0] == logic [3:0]: %0d", type(r4) == type(l4));
    $display("reg signed [3:0] == logic signed [3:0]: %0d", type(rs4) == type(ls4));
    $display("typedefs: %0d", type(reg_byte_t) == type(logic_byte_t));
    $display("data types: %0d", type(reg [5:0]) == type(logic [5:0]));
    $display("reg [3:0] == bit [3:0]: %0d", type(r4) == type(b4));
    $display("reg [3:0] == logic signed [3:0]: %0d", type(r4) == type(ls4));
    $display("reg [3:0] != logic [3:0]: %0d", type(r4) != type(l4));
  end
endmodule
