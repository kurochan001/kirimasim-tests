/*
:name: test_cast_dispatch_enum_and_bitstream
:description: a cast of a non-assignment-compatible operand to an enum truncates to the base type and a bit-stream cast of a string follows the byte-array rule
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.24.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_dispatch_enum_and_bitstream.expected
*/
// IEEE 1800-2023 6.24.1: when the operand is not assignment compatible with
// the target, an enum cast follows 6.19.4 and a bit-stream type cast follows
// 6.24.3. The enum e2_t has a 2-bit base type, so casting the non-member 3'd6
// gives its low two bits, 2. 6.24.3 also says a string is a dynamic array of
// bytes for a bit-stream cast, so "AB" becomes 16'h4142 and "A" becomes 8'h41.
// A tool that range-checks the enum cast, or that treats the string as
// characters without their byte encoding, prints other values.

typedef enum logic [1:0] {A0 = 0, A1 = 1, A2 = 2} e2_t;
typedef bit [15:0] b16_t;
typedef bit [7:0] b8_t;

module test_cast_dispatch_enum_and_bitstream;
  e2_t e;
  string s2 = "AB";
  string s1 = "A";

  initial begin
    e = e2_t'(3'd6);
    $display("enum=%0d", e);
    $display("str16=%04x str8=%02x", b16_t'(s2), b8_t'(s1));
  end
endmodule
