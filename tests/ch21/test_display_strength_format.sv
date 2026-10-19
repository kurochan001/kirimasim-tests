/*
:name: test_display_strength_format
:description: %v prints the strength and value of scalar nets as a mnemonic and a value character (IEEE 1800-2023 Section 21.2.1.4)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.4 28.12.1 28.15.1 28.15.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_display_strength_format.expected
*/
// IEEE 1800-2023 §21.2.1.4: %v prints three characters for a scalar net: a
// two-letter strength mnemonic (Su, St, Pu, We, Hi, ...) and its value (0, 1,
// X or Z). A net with no driver is HiZ. Two drivers of the same strength and
// different values give X at that strength (28.12.1). tri1 is pulled to 1 at
// pull strength when nothing else drives it (28.15.1), and supply1 has supply
// strength (28.15.3).

module test_display_strength_format;
  wire s1;  assign s1 = 1'b1;
  wire w0;  assign (weak0, weak1) w0 = 1'b0;
  wire hz;
  wire sx;  assign sx = 1'b0; assign sx = 1'b1;
  wire px;  assign (pull0, pull1) px = 1'b0; assign (pull0, pull1) px = 1'b1;
  tri1 t1;
  supply1 vdd;

  initial begin
    #1;
    $display("s1=%v w0=%v hz=%v", s1, w0, hz);
    $display("sx=%v px=%v", sx, px);
    $display("t1=%v vdd=%v", t1, vdd);
  end
endmodule
