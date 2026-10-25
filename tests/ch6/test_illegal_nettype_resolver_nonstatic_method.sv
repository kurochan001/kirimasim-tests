/*
:name: test_illegal_nettype_resolver_nonstatic_method
:description: A nettype whose resolution function is a non-static class method is rejected (IEEE 1800-2023 Section 6.6.7)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.7 8.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the resolution function sum_dyn is a class method that is not static
:expected_stderr_regex: test_illegal_nettype_resolver_nonstatic_method\.sv:37:
*/
// IEEE 1800-2023 §6.6.7: a class method may be the resolution function of
// a nettype only if it is a static method (§8.10), since the resolution
// is called without any class object. The static method sum_static is a
// legal resolver of static_t; the nettype dyn_t on the marked line names
// the non-static method sum_dyn, an error.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports nettype
// declarations; both stop at the first of them, so their errors are not
// this rule.

module test_illegal_nettype_resolver_nonstatic_method;
  class resolvers;
    static function int sum_static(input int d[]);
      sum_static = 0;
      foreach (d[i]) sum_static += d[i];
    endfunction

    function int sum_dyn(input int d[]);
      sum_dyn = 0;
      foreach (d[i]) sum_dyn += d[i];
    endfunction
  endclass

  nettype int static_t with resolvers::sum_static;
  nettype int dyn_t with resolvers::sum_dyn;   // illegal: not a static method

  static_t s;
  dyn_t y;

  assign s = 2;
  assign s = 3;
  assign y = 4;
  assign y = 5;

  initial #1 $display("s=%0d y=%0d", s, y);
endmodule
