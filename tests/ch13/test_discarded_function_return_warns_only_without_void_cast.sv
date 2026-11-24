/*
:name: test_discarded_function_return_warns_only_without_void_cast
:description: A discarded nonvoid function value warns at the uncast statement and both calls execute
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_discarded_function_return_warns_only_without_void_cast.expected
:expected_stderr_regex: (?ms)\A(?=.*?^(?=[^\n]*test_discarded_function_return_warns_only_without_void_cast\.sv:23:)(?=[^\n]*(?i:warning))(?=[^\n]*(?i:IGNOREDRETURN|ignor(?:ed|ing)[^\n]*\breturn\b|discard(?:ed|ing)?[^\n]*return|function[^\n]*called as a task))[^\n]+)(?!.*?^(?=[^\n]*test_discarded_function_return_warns_only_without_void_cast\.sv:24:)[^\n]*(?i:warning))
*/
module test_discarded_function_return_warns_only_without_void_cast;
  int total;

  function automatic int update_total(input int amount);
    total += amount;
    return total;
  endfunction

  initial begin
    update_total(7);
    void'(update_total(11));
    $display("total=%0d", total);
  end
endmodule
