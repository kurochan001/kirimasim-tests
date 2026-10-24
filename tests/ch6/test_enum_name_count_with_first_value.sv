/*
:name: test_enum_name_count_with_first_value
:description: name[N] = C gives the first generated name the value C and each following generated name the next value (IEEE 1800-2023 Section 6.19.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.2 6.19.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_name_count_with_first_value.expected
*/
// IEEE 1800-2023 §6.19.2, Table 6-10: name[N] = C generates the N names
// name0 to name(N-1); the first gets the value C and each following one the
// next consecutive value. The constant here is not the next automatic value
// (pre is 2), so a generator that ignores C gives 3, 4, 5. A name after the
// range continues from the last generated value. The names are walked with
// first() and next() (§6.19.5), which follow the declaration order.

module test_enum_name_count_with_first_value;
  typedef enum {pre = 2, r[3] = 20, post, k[2] = 7} e_t;
  e_t v;

  initial begin
    v = v.first();
    for (int i = 0; i < v.num(); i++) begin
      $display("%s=%0d", v.name(), v);
      v = v.next();
    end
    $display("num=%0d", v.num());
  end
endmodule
