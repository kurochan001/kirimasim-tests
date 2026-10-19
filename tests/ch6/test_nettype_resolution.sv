/*
:name: test_nettype_resolution
:description: a net of a user-defined nettype takes the value its resolution function computes from all its drivers, including an output port, again whenever a driver changes; a second nettype name shares the resolution, and force and release override and restore the resolved value (IEEE 1800-2023 Section 6.6.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.7 10.3 10.6.2 23.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nettype_resolution.expected
*/
// IEEE 1800-2023 §6.6.7: nettype T name with f declares a net type whose
// value is computed by the resolution function f, called with a dynamic array
// of the values of all drivers whenever one of them changes; nettype name1
// name2 gives another name to the same net type. A force on such a net
// overrides it, and after release it has the resolved value again (§10.6.2).
// The drivers here are continuous assignments (§10.3); m_max is also
// connected to an output port whose net has the same nettype, so the two are
// merged into one net (§23.3.3) and the assignment in the instance is one
// more driver. r_sum sums its real drivers, m_max takes the largest of its int
// drivers, and n_count counts its drivers.

package nettypes_pkg;
  function automatic real sum_res(input real d[]);
    sum_res = 0.0;
    foreach (d[i]) sum_res += d[i];
  endfunction

  function automatic int max_res(input int d[]);
    max_res = 0;
    foreach (d[i]) if (i == 0 || d[i] > max_res) max_res = d[i];
  endfunction

  function automatic int count_res(input int d[]);
    return d.size();
  endfunction

  nettype real sum_t with sum_res;
  nettype sum_t sum_alias_t;
  nettype int max_t with max_res;
  nettype int count_t with count_res;
endpackage

module drive_int
  import nettypes_pkg::*;
  (output max_t o);
  assign o = 6;
endmodule

module test_nettype_resolution;
  import nettypes_pkg::*;

  real a = 1.5, b = 2.25;
  int x = 3, y = 7;
  sum_t r_sum;
  sum_alias_t r_alias;
  max_t m_max;
  count_t n_count;

  assign r_sum = a;
  assign r_sum = b;
  assign r_alias = a;
  assign r_alias = 4.0;
  assign m_max = x;
  assign m_max = y;
  drive_int u(m_max);
  assign n_count = x;
  assign n_count = y;
  assign n_count = 0;

  task automatic show(string when);
    $display("%s: r_sum=%.2f r_alias=%.2f m_max=%0d n_count=%0d", when, r_sum, r_alias,
             m_max, n_count);
  endtask

  initial begin
    #1 show("start");
    a = 10.0;
    y = 1;
    #1 show("a=10, y=1");
    force r_sum = 0.5;
    #1 show("forced");
    a = 20.0;
    #1 show("a=20 while forced");
    release r_sum;
    #1 show("released");
  end
endmodule
