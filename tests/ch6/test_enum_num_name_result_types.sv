/*
:name: test_enum_num_name_result_types
:description: num() takes no arguments and returns int, and name() takes no arguments and returns a string, empty for a value that is not a member (IEEE 1800-2023 Sections 6.19.5.5 and 6.19.5.6)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5.5 6.19.5.6 20.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_num_name_result_types.expected
*/
// IEEE 1800-2023 §6.19.5.5: function int num() returns the number of
// members: an int, so num() - 5 is negative for 3 members, and the count does
// not depend on the base width (3 members of a bit [7:0] enum). §6.19.5.6:
// function string name() returns the name of the value as a string (the
// string methods work on it), and the empty string for a value that is not a
// member. $typename and $bits (§20.6.1) show the type of each call.
// Icarus Verilog 13.0 does not know the string method tolower and has no
// $typename (unsupported constructs). For num(), Verilator 5.052 gives the
// $typename bit[31:0] instead of int.

module test_enum_num_name_result_types;
  typedef enum bit [7:0] {RED = 8'd10, GREEN = 8'd20, BLUE = 8'd30} c_t;
  c_t c = GREEN;
  string s;

  initial begin
    $display("num: %s bits=%0d value=%0d below=%0d", $typename(c.num()), $bits(c.num()),
             c.num(), c.num() - 5 < 0);
    s = c.name();
    $display("name: %s value=%s len=%0d lower=%s", $typename(c.name()), s, s.len(),
             s.tolower());
    c = c_t'(8'd25);
    s = c.name();
    $display("non-member: \"%s\" len=%0d", s, s.len());
  end
endmodule
