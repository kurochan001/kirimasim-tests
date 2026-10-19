/*
:name: test_string_substr_out_of_range
:description: substr returns the empty string when its range is not inside the string (IEEE 1800-2023 Section 6.16.8)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_substr_out_of_range.expected
*/
// IEEE 1800-2023 §6.16.8: str.substr(i, j) returns the characters at positions
// i to j. When i is negative, j is less than i, or j is not less than
// str.len(), it returns the empty string; the range is not cut down to fit.

module test_string_substr_out_of_range;
  string s = "hello";   // length 5
  string r2, r3, r4, r5, r6;
  int fails = 0;

  initial begin
    r2 = s.substr(2, 10);  // j >= len   -> ""
    r3 = s.substr(3, 1);   // j < i      -> ""
    r4 = s.substr(5, 5);   // i >= len   -> ""
    r5 = s.substr(1, 3);   // inside     -> "ell"
    r6 = s.substr(0, 4);   // j == len-1 -> "hello"

    if (r2 != "")      begin $display("FAIL substr(2,10)=[%s] (exp \"\")", r2); fails++; end
    if (r3 != "")      begin $display("FAIL substr(3,1)=[%s] (exp \"\")", r3); fails++; end
    if (r4 != "")      begin $display("FAIL substr(5,5)=[%s] (exp \"\")", r4); fails++; end
    if (r5 != "ell")   begin $display("FAIL substr(1,3)=[%s] (exp ell)", r5); fails++; end
    if (r6 != "hello") begin $display("FAIL substr(0,4)=[%s] (exp hello)", r6); fails++; end

    if (fails == 0)
      $display("TEST PASSED: substr out of range returns the empty string");
    else
      $display("TEST FAILED: %0d check(s) failed", fails);
    $finish;
  end
endmodule
