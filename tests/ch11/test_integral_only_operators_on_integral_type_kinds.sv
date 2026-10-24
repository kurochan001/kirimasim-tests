/*
:name: test_integral_only_operators_on_integral_type_kinds
:description: the operators that Table 11-1 allows for integral operands only (bitwise, reduction, shift, modulus, their assignment forms, wildcard equality, concatenation and replication) work on every kind of integral type, and concatenation also on strings and unpacked arrays (IEEE 1800-2023 Section 11.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_integral_only_operators_on_integral_type_kinds.expected
*/
// IEEE 1800-2023 §11.3, Table 11-1: binary & | ^ ^~ ~^, &= |= ^=, the unary
// reductions, >> <<, >>= <<=, >>>= <<<=, % and %=, ==? !=?, concatenation and
// replication take integral operands. Integral types are the 2-state and
// 4-state vectors, the integer atom types, packed structures and packed
// arrays, and enumerations (§6.11.1). Concatenation of strings (§11.4.12.2)
// and of unpacked arrays (§10.10) follow their own rules and are allowed too.
// The operands are a 4-state vector lv, a 2-state vector bv, a byte sb, a
// packed structure ps, an enumeration en and a packed array pa, each holding a
// different 8-bit value, and every result is printed. The signed byte shows
// that >>= shifts in zeros and >>>= copies the sign, and that % keeps the
// sign of its first operand; the unsigned lv shows that >>>= shifts in zeros
// there.

module test_integral_only_operators_on_integral_type_kinds;
  typedef struct packed { logic [3:0] hi, lo; } ps_t;
  typedef enum logic [7:0] { E0 = 8'h0f, E1 = 8'hf0 } en_t;
  logic [7:0] lv = 8'hca;
  bit [7:0] bv = 8'h56;
  byte sb = -8'sd6;
  ps_t ps = 8'h3c;
  en_t en = E1;
  logic [1:0][3:0] pa = 8'h96;
  bit [3:0] b4 = 4'hf;
  logic [7:0] x;
  ps_t px;
  byte sx;
  string str;
  int ua [];

  initial begin
    $display("bitwise: %h %h %h %h %h", lv & bv, lv | ps, ps ^ en, pa ^~ bv, en ~^ sb);
    x = lv; x &= bv; $write("&= |= ^=: %h", x);
    x |= ps; $write(" %h", x);
    x ^= en; $display(" %h", x);
    $display("reduction: %b %b %b %b %b %b %b %b", &b4, &bv, |ps, ^en, ~&lv, ~|pa, ~^sb, ^~ps);
    $display("shifts: %h %h %h %h %h", lv >> 3, bv << 2, ps >> 2, pa << 1, sb >> 1);
    px = ps; px >>= 1; $write(">>= <<=: %h", px);
    px <<= 3; $display(" %h", px);
    sx = sb; sx >>= 1; $write(">>= >>>= <<<= on byte: %0d", sx);
    sx = sb; sx >>>= 1; $write(" %0d", sx);
    sx <<<= 2; $display(" %0d", sx);
    x = lv; x >>>= 2; $display(">>>= on logic: %h", x);
    $display("%%: %0d %0d %0d %0d %0d %0d", lv % 7, ps % 7, sb % 4, en % 9, pa % 11, bv % 3);
    x = lv; x %= 9; sx = -8'sd7; sx %= 3; $display("%%=: %0d %0d", x, sx);
    $display("==? !=?: %b %b %b %b %b %b", lv ==? 8'b1100_xxxx, ps ==? 8'b0011_11??,
             en !=? 8'b1111_zzzz, pa ==? 8'b1001_011x, bv ==? 8'b0101_x111, sb ==? 8'b1111_1x10);
    $display("concat: %h %h %h", {ps, en}, {2{pa[1]}}, {sb, lv[3:0]});
    str = {"ab", "cd"};
    ua = {1, 2, 3};
    $display("string and array concat: %s %0d %0d", str, ua.size(), ua[2]);
  end
endmodule
