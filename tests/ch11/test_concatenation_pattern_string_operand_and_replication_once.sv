/*
:name: test_concatenation_pattern_string_operand_and_replication_once
:description: a concatenation joins bits while an assignment pattern with an apostrophe fills elements, a string operand makes a concatenation a string with string literal operands converted to strings and integral values cast to string, and the operand of a replication is evaluated once, also for a zero multiplier (IEEE 1800-2023 Section 11.4.12)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 11.4.12.1 11.4.12.2 6.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concatenation_pattern_string_operand_and_replication_once.expected
*/
// IEEE 1800-2023 §11.4.12: a concatenation, written in braces without an
// apostrophe, joins the bits of its operands into one vector; it is not an
// assignment pattern, written '{...}, which gives each element of the target
// its own value. For logic [1:0][7:0] pv, {4'ha, 4'hb} is the 8-bit 8'hab,
// zero-extended to 00ab, while '{4'ha, 4'hb} sets the two elements to 0a and
// 0b; {2{4'ha}} is aa, '{2{4'ha}} gives 0a0a.
// §11.4.12.2: when an operand is a string, the concatenation is a string and
// the other operands are converted to strings as in §6.16. An integral value
// cast to string is zero-filled to whole bytes, each byte is a character and
// NUL bytes are dropped: {s, string'(12'h041)} is "abA" and
// {s, string'(24'h004300)} is "abC". A literal "\0" adds nothing; without a
// string operand {"ab", "\0"} keeps its 24 bits.
// The integral operands carry a cast because the text differs: §11.4.12.2
// converts every other operand implicitly, while the concatenation row of
// Table 6-9 (§6.16) lists only string literals and string expressions as
// operands and §6.16 requires a cast from an integral value to a string.
// With the casts the design is legal under both readings and the strings are
// the same.
// §11.4.12.1: the operands of a replication are evaluated exactly once, even
// with a zero multiplier: next() returns how often it was called, so
// {3{next()}} is 111 after one call, and a zero replication of next() still
// counts one call.
// Icarus Verilog 13.0 does not parse a replication inside an assignment
// pattern, '{2{4'ha}}. Verilator 5.052 does not call next() in the zero
// replication (calls=0).

module test_concatenation_pattern_string_operand_and_replication_once;
  localparam int Z = 0;
  logic [1:0][7:0] pv;
  logic [23:0] v24;
  logic [11:0] r12;
  logic [3:0] r4;
  string s = "ab", t;
  int calls;

  function automatic logic [3:0] next();
    calls++;
    return calls;
  endfunction

  initial begin
    pv = {4'ha, 4'hb};
    $write("concatenation and pattern: %h", pv);
    pv = '{4'ha, 4'hb};
    $write(" %h", pv);
    pv = {2{4'ha}};
    $write(" %h", pv);
    pv = '{2{4'ha}};
    $display(" %h", pv);
    t = {s, string'(12'h041)};
    $write("string operand: %s %0d", t, t.len());
    t = {s, string'(24'h004300)};
    $write(" %s %0d", t, t.len());
    t = {s, "\0"};
    $write(" %s %0d", t, t.len());
    t = {"x", s, string'(16'h4344)};
    $display(" %s %0d", t, t.len());
    v24 = {"ab", "\0"};
    $display("bit concatenation: %h", v24);
    calls = 0;
    r12 = {3{next()}};
    $write("replication: %h calls=%0d", r12, calls);
    calls = 0;
    r4 = {{Z{next()}}, 4'hf};
    $display(", zero: %h calls=%0d", r4, calls);
  end
endmodule
