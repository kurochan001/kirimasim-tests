/*
:name: test_enum_first_last_num
:description: first() and last() return the first and last members of an enumeration in declaration order, whatever their values, and num() the number of members (IEEE 1800-2023 Section 6.19.5.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5.1 6.19.5.2 6.19.5.5 6.19.5.7 6.19.5.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_first_last_num.expected
*/
// IEEE 1800-2023 §6.19.5.1, §6.19.5.2, §6.19.5.5: first() returns the first
// member of the enumeration, last() the last one and num() how many there are.
// The members here are not in the order of their values, so first() is S_A
// (3), not the smallest value, and last() is S_C (6). §6.19.5.7: the members
// can be listed from first() with next() (6.19.5.3) until last().

module test_enum_first_last_num;
  typedef enum logic [2:0] {S_A = 3, S_B = 1, S_C = 6} state_t;

  state_t s, f, l;

  initial begin
    f = s.first();
    l = s.last();
    $display("first=%s(%0d) last=%s(%0d) num=%0d", f.name(), f, l.name(), l,
             s.num());
    s = s.first();
    forever begin
      $display("%s=%0d", s.name(), s);
      if (s == s.last()) break;
      s = s.next();
    end
  end
endmodule
