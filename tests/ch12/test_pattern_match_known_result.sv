/*
:name: test_pattern_match_known_result
:description: A pattern match yields a known one-bit 0 or 1 even with x and z in the value and the constant pattern, a ? in a constant pattern is a z bit and not a wildcard, and a pattern identifier is bound by an ordinary procedural assignment (IEEE 1800-2023 Section 12.6)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.6 12.6.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pattern_match_known_result.expected
*/
// IEEE 1800-2023 §12.6: the result of a pattern match is a determined one-bit
// value, 0 or 1, and cannot be x or z even when the value and the pattern
// contain such bits; a successful match binds each pattern identifier to the
// corresponding part of the value with an ordinary procedural assignment,
// that is, as a copy of the value at that moment. The match of v = 4'b1x0z
// against the same bits succeeds and against 4'b1x01 fails, both as known
// values; 4'b1?0z is 4'b1z0z, so the x in v does not equal its z bit and the
// match fails, because ? is a z digit and not a wildcard here (§12.6.1 gives
// the wildcard comparisons to casez and casex). .n binds n to the whole value
// and changing v afterwards does not change n.

module test_pattern_match_known_result;
  logic [3:0] v;
  logic r;

  initial begin
    v = 4'b1x0z;
    r = (v matches 4'b1x0z);
    $display("same: %b unknown=%b", r, $isunknown(r));
    r = (v matches 4'b1x01);
    $display("diff: %b unknown=%b", r, $isunknown(r));
    r = (v matches 4'b1?0z);
    $display("q is z: %b", r);
    r = (v matches .*);
    $display("wildcard: %b", r);
    v = 4'b10x1;
    if (v matches .n) begin
      v = 4'b0000;
      $display("bound n=%b v=%b", n, v);
    end
  end
endmodule
