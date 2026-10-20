/*
:name: test_enum_wider_than_64_bits_name
:description: The name() method of an enum whose base type is wider than 64 bits returns the name of the member (IEEE 1800-2023 Section 6.19.5.6)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5.6 6.19
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_wider_than_64_bits_name.expected
*/
// IEEE 1800-2023 §6.19: the base type of an enumeration can be a vector of
// any width, and §6.19.5.6: name() returns the name of the member whose
// value the variable holds, or "" when no member has that value. With a
// 65-bit base the whole value decides: 65'h1_0000_0000_0000_0001 is HIGH,
// not LOW, whose value has the same low 64 bits.

module test_enum_wider_than_64_bits_name;
  typedef enum bit [64:0] {
    LOW = 65'h1,
    HIGH = 65'h1_0000_0000_0000_0001
  } code_t;
  code_t value;

  initial begin
    value = HIGH;
    $display("$bits=%0d value=%h name=%s", $bits(value), value, value.name());
    value = LOW;
    $display("value=%h name=%s", value, value.name());
    value = code_t'(65'h2);
    $display("value=%h name=\"%s\"", value, value.name());
  end
endmodule
