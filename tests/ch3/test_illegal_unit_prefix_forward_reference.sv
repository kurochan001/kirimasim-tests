/*
:name: test_illegal_unit_prefix_forward_reference
:description: A $unit:: reference to a compilation-unit variable that is declared later in the compilation unit is rejected (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the $unit:: prefix does not allow a reference to unit_late, which is declared later in the compilation unit
:expected_stderr_regex: test_illegal_unit_prefix_forward_reference\.sv:30:
*/
// IEEE 1800-2023 §3.12.1: apart from task and function names, references shall
// only be made to names already defined in the compilation unit, and the
// $unit:: prefix only disambiguates; it does not allow references to items
// declared later. $unit::unit_early names a variable declared before the
// module and is legal; $unit::unit_late names one declared after it, so the
// use on the marked line is an error. Icarus Verilog 13.0 and Verilator
// 5.052 both accept the reference and run the design, which the clause does
// not allow.

int unit_early = 2;

module test_illegal_unit_prefix_forward_reference;
  int sum;

  initial begin
    sum = $unit::unit_early;
    sum = sum + $unit::unit_late;   // illegal: $unit:: adds no forward reference
    $display("sum=%0d", sum);
  end
endmodule

int unit_late = 5;
