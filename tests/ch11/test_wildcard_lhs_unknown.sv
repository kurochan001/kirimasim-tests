/*
:name: test_wildcard_lhs_unknown
:description: A wildcard bit on the right of ==? or !=? matches an x or z bit on the left, while an x or z on the left against a known right bit is unknown unless a known mismatch decides the result (IEEE 1800-2023 Section 11.4.6)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_wildcard_lhs_unknown.expected
*/
// IEEE 1800-2023 §11.4.6 B007: x and z bits of the right operand of ==? and
// !=? are wildcards and match any left bit, including x and z. x and z bits
// of the left operand are not wildcards; against a known right bit they make
// the relation unknown unless a known bit mismatch already makes it false.
// B009 repeats that ==? and !=? may yield x for such a left value. Each line
// below names the relation and prints its one-bit result.

module test_wildcard_lhs_unknown;
  logic [3:0] a, b;

  task automatic chk(string name, logic got, logic want);
    if (got === want)
      $display("ok   %s = %b", name, got);
    else
      $display("BAD  %s got=%b want=%b", name, got, want);
  endtask

  initial begin
    a = 4'bzzzz; b = 4'b0000; chk("zzzz ==? 0000", a ==? b, 1'bx);
    a = 4'bz001; b = 4'b0001; chk("z001 ==? 0001", a ==? b, 1'bx);
    a = 4'bz001; b = 4'b1001; chk("z001 ==? 1001", a ==? b, 1'bx);
    a = 4'bz001; b = 4'b0111; chk("z001 ==? 0111", a ==? b, 1'b0);
    a = 4'b1z0x; b = 4'b1?0?; chk("1z0x ==? 1?0?", a ==? b, 1'b1);
    a = 4'b1z0x; b = 4'b0000; chk("1z0x ==? 0000", a ==? b, 1'b0);
    a = 4'b0z0x; b = 4'b0000; chk("0z0x ==? 0000", a ==? b, 1'bx);
    a = 4'b0z0x; b = 4'b0?0?; chk("0z0x ==? 0?0?", a ==? b, 1'b1);
    a = 4'b01xz; b = 4'b01xz; chk("01xz ==? 01xz", a ==? b, 1'b1);
    a = 4'bz1x0; b = 4'bz1x0; chk("z1x0 !=? z1x0", a !=? b, 1'b0);
    a = 4'bz1x0; b = 4'b01?0; chk("z1x0 !=? 01?0", a !=? b, 1'bx);
    a = 4'b1010; b = 4'b10?0; chk("1010 ==? 10?0", a ==? b, 1'b1);
    a = 4'b0000; b = 4'b????; chk("0000 ==? ????", a ==? b, 1'b1);
    a = 4'b0101; b = 4'b01x1; chk("0101 ==? 01x1", a ==? b, 1'b1);
    a = 4'b1010; b = 4'b10z0; chk("1010 ==? 10z0", a ==? b, 1'b1);
    a = 4'b0000; b = 4'b0?0?; chk("0000 ==? 0?0?", a ==? b, 1'b1);
  end
endmodule
