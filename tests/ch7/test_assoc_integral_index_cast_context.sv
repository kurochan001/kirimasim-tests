/*
:name: test_assoc_integral_index_cast_context
:description: Typed indices apply cast width and sign context before arithmetic truncation (IEEE 1800-2023 Section 7.8.4)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_integral_index_cast_context.expected
*/
// The 8-bit index context reaches the addition before four-bit overflow.
// A wider final receiving variable alone would not establish this.

module test_assoc_integral_index_cast_context;
  typedef bit [7:0] key_t;
  typedef bit signed [7:0] signed_key_t;
  int a[key_t], s[signed_key_t];
  initial begin
    a[16'h0101] = 10;
    a[8'h01] = 20;
    a[4'hf + 4'h1] = 31;
    a[-1] = 77;
    s[16'h00ff] = 33; s[-1] = 44;
    $display("unsigned: size=%0d one=%0d sixteen=%0d zero=%0d ff=%0d",
             a.num(), a[1], a[16], a.exists(0), a[8'hff]);
    $display("signed alias: size=%0d minus1=%0d ff=%0d",
             s.num(), s[-1], s[8'hff]);
  end
endmodule
