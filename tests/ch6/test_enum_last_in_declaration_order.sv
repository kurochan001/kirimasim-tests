/*
:name: test_enum_last_in_declaration_order
:description: last() returns the member declared last, not the largest or smallest value, and first() the member declared first (IEEE 1800-2023 Section 6.19.5.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5.2 6.19.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_last_in_declaration_order.expected
*/
// IEEE 1800-2023 §6.19.5.2: last() returns the value of the last member of
// the enumeration, the one declared last; §6.19.5.1: first() returns the
// member declared first. The values are not in numeric order, so a method
// that takes the largest or smallest value gives another member: for d_t
// the largest is M9 and the smallest M1, while the last is M3. For s_t, a
// signed base, the last member N_MIN holds the smallest value.

module test_enum_last_in_declaration_order;
  typedef enum {M5 = 5, M1 = 1, M9 = 9, M3 = 3} d_t;
  typedef enum bit signed [3:0] {N2 = 2, N_MAX = 7, N_MIN = -8} s_t;
  d_t d, df, dl;
  s_t s, sf, sl;

  initial begin
    df = d.first();
    dl = d.last();
    sf = s.first();
    sl = s.last();
    $display("d_t: first=%s(%0d) last=%s(%0d)", df.name(), df, dl.name(), dl);
    $display("s_t: first=%s(%0d) last=%s(%0d)", sf.name(), sf, sl.name(), sl);
  end
endmodule
