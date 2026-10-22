/*
:name: test_assoc_default_and_delete_silent
:description: Defaults and deleting missing keys produce no warning and no new entries (IEEE 1800-2023 Sections 7.8.6, 7.9.2 and 7.9.11)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.6 7.9.11 7.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_default_and_delete_silent.expected
:expected_stderr_regex: \A(?![\s\S]*(?i:warn(?:ing)?))[\s\S]*\Z
*/
// Check the entire raw runtime message stream, including messages removed
// from the normalized stdout by the runner.

module test_assoc_default_and_delete_silent;
  int a[string] = '{default:17};
  int missing_value;
  initial begin
    a["live"] = 9;
    missing_value = a["missing"];
    $display("default=%0d size=%0d missing=%0d live=%0d",
             missing_value, a.num(), a.exists("missing"), a["live"]);
    a.delete("missing");
    $display("delete missing: size=%0d live=%0d", a.num(), a["live"]);
    a.delete("live");
    $display("delete present: size=%0d exists=%0d", a.num(), a.exists("live"));
    a.delete("still_missing");
    $display("delete empty: size=%0d", a.num());
  end
endmodule
