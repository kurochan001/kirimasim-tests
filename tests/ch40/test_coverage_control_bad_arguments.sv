/*
:name: test_coverage_control_bad_arguments
:description: Every coverage control, and $coverage_get_max and $coverage_get, gives SV_COV_ERROR for a module definition name that names no module, with either scope (IEEE 1800-2023 Section 40.3.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.3.2.2 40.3.2.3 40.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_control_bad_arguments.expected
*/
// IEEE 1800-2023 §40.3.2.1 (Table 40-1): `SV_COV_ERROR means that the operation
// failed without effect because of bad arguments, such as a module that does
// not exist, and every control can give it: start, stop, reset and check.
// $coverage_get_max and $coverage_get give it as well (40.3.2.2, 40.3.2.3).
// The definition name "no_such_module" names no module of the design, for
// either scope definition. Only whether each call gives the error is printed.

module test_coverage_control_bad_arguments;
  string names[4] = '{"start", "stop", "reset", "check"};
  int controls[4] = '{`SV_COV_START, `SV_COV_STOP, `SV_COV_RESET, `SV_COV_CHECK};
  int scopes[2] = '{`SV_COV_MODULE, `SV_COV_HIER};

  function automatic string is_error(int r);
    return r == `SV_COV_ERROR ? "ERROR" : "not ERROR";
  endfunction

  initial begin
    foreach (scopes[s]) begin
      foreach (controls[c])
        $display("%s, %s: %s", s == 0 ? "module" : "hierarchy", names[c],
                 is_error($coverage_control(controls[c], `SV_COV_TOGGLE, scopes[s],
                                            "no_such_module")));
      $display("%s, maximum: %s", s == 0 ? "module" : "hierarchy",
               is_error($coverage_get_max(`SV_COV_STATEMENT, scopes[s], "no_such_module")));
      $display("%s, current: %s", s == 0 ? "module" : "hierarchy",
               is_error($coverage_get(`SV_COV_STATEMENT, scopes[s], "no_such_module")));
    end
  end
endmodule
