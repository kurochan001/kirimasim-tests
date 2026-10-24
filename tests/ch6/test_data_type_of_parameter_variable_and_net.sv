/*
:name: test_data_type_of_parameter_variable_and_net
:description: A parameter, a variable and a net of one 4-bit data type each hold a value of that type, so values outside its range wrap and its addition is 4-bit, while two variables with the same 8 bits read differently because byte is signed and bit [7:0] is not (IEEE 1800-2023 Section 6.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.2 6.18 6.20.2 6.11
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_data_type_of_parameter_variable_and_net.expected
*/
// IEEE 1800-2023 §6.2: a data type is a set of values and the operations on
// them; a data object, such as a parameter, a variable or a net, is a named
// entity with a value and a data type.
// nib_t is logic [3:0] (§6.18), so its values are 0 to 15:
// - the parameter P of type nib_t is given 20 and holds 4 (§6.20.2), the
//   variable v is assigned 29 and holds 13, and the net w is driven with 27
//   and has 11; each has 4 bits;
// - P + v is a 4-bit addition when it is printed by itself, so 4 + 13 = 17
//   wraps to 1, and v15 + 1'b1 for the nib_t variable v15 = 15 is 0.
// The variables sb (byte, signed) and ub (bit [7:0], unsigned) are both
// assigned 8'd200, the same eight bits 11001000; their types make them
// read -56 and 200 (§6.11).

typedef logic [3:0] nib_t;

module test_data_type_of_parameter_variable_and_net;
  parameter nib_t P = 20;
  nib_t v;
  nib_t v15 = 4'd15;
  wire nib_t w;
  byte sb;
  bit [7:0] ub;

  assign w = 5'd27;

  initial begin
    v = 5'd29;
    sb = 8'd200;
    ub = 8'd200;
    #1;
    $display("bits: P=%0d v=%0d w=%0d", $bits(P), $bits(v), $bits(w));
    $display("values: P=%0d v=%0d w=%0d", P, v, w);
    $display("operations: P+v=%0d v15+1=%0d", P + v, v15 + 1'b1);
    $display("same bits: byte=%0d bit[7:0]=%0d pattern=%b %b", sb, ub, sb, ub);
  end
endmodule
