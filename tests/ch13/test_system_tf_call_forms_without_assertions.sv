/*
:name: test_system_tf_call_forms_without_assertions
:description: A system function call is a system name with no parentheses, a system name with an argument list of expressions, or a system name with a data type; the calls give the width of the data type, the width of an expression and the time, and $sformatf takes an expression list (IEEE 1800-2023 Sections 13.5.4 and 20.6)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.4 20.2 20.6 20.8 A.8.2
:spec_check: ai
:oracle: spec iverilog@13.0 verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_tf_call_forms_without_assertions.expected
*/
// IEEE 1800-2023 A.8.2: a system tf call is a system tf identifier with an
// optional parenthesized list of arguments, a system tf identifier with a
// data type and an optional expression, or a system tf identifier with an
// expression, further expressions of which any may be left empty, and an
// optional clocking event. §20.6: $bits gives the number of bits of a data
// type or of an expression; §20.8: $clog2 rounds the logarithm up; §20.2
// and the system function $time give the current time.
//
// The first line takes the data type form of $bits with logic [7:0] and int,
// which are 8 and 32 bits. The second line takes the expression form with
// v = 4'hA, so v is 4 bits wide and v + 1 is an int, 32 bits, and
// $clog2(16) is 4. The third line calls $time without parentheses after #1,
// and $sformatf forms the string 3-4 from an expression list.
//
// Icarus Verilog 13.0 and Verilator 5.052 produce this output.

module test_system_tf_call_forms_without_assertions;
  logic [3:0] v = 4'hA;

  initial begin
    #1;
    $display("type %0d %0d", $bits(logic [7:0]), $bits(int));
    $display("expr %0d %0d %0d", $bits(v), $bits(v + 1), $clog2(16));
    $display("noparen %0d", $time);
    $display("args %s", $sformatf("%0d-%0d", 3, 4));
  end
endmodule
