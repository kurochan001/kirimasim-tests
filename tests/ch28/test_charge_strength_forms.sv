/*
:name: test_charge_strength_forms
:description: The three charge strengths small, medium and large on trireg nets show as the strengths Sm, Me and La of the value the net keeps after its driver is released (IEEE 1800-2023 Sections 28.15.2 and 21.2.1.4)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.15.2 21.2.1.4 A.2.2.1 A.2.2.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_charge_strength_forms.expected
*/
// IEEE 1800-2023 A.2.2.2: a charge strength is small, medium or large, and
// clarification 16 allows it only with the trireg keyword. 28.15.2: a trireg
// net keeps the value that was last driven on it, and the strength of that
// charge is the charge strength of the declaration. 21.2.1.4 gives the
// mnemonics of the strength levels: Sm is the small, Me the medium and La the
// large capacitor, and %v prints them with the value.
// Each of c1, c2 and c3 is driven with 1 and then released when a becomes z,
// and the display shows the charge that each keeps.
//
// Icarus Verilog 13.0 and Verilator 5.052 do not support trireg nets.

module test_charge_strength_forms;
  logic a;
  trireg (small) c1;
  trireg (medium) c2;
  trireg (large) c3;

  assign c1 = a;
  assign c2 = a;
  assign c3 = a;

  initial begin
    a = 1'b1;
    #1 a = 1'bz;
    #1 $display("held: %v %v %v", c1, c2, c3);
  end
endmodule
