/*
:name: test_nettype_initial_value_before_procedures
:description: A net of a user-defined nettype has its initial value, with the struct member initializers, already when the first statements of initial and always procedures read it at time 0, and the guaranteed time-zero resolver call comes after that initialization, so its result stays (IEEE 1800-2023 Section 6.7.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nettype_initial_value_before_procedures.expected
*/
// IEEE 1800-2023 §6.7.3: the initial value of a net of a user-defined
// nettype is set before any initial or always procedure starts and before the
// resolution function is activated at time 0. That value is the default of
// the data type, with the initializers of the members of a struct applied;
// the resolver of a resolved nettype runs at time 0 at least once, also when
// the net has no driver, and it may run before or after the procedures.
// supply_t has the member initializers level = 7 and volt = 1.5.
// - p, of the nettype plain_net without a resolver and without drivers, keeps
//   its initial value. The first statements of an initial procedure and of an
//   always procedure read it at time 0 and see level 7 and volt 1.50; a net
//   that got its value only later would show the 0 and 0.0 of the members
//   without their initializers.
// - r, of the nettype resolved_net, has no driver; its resolver pick returns
//   level 100 for an empty array of drivers. At time 0 the initial procedure
//   sees either the initial value 7 or the resolved 100, as the order of the
//   resolver call and the procedures is not fixed, so the test prints only
//   whether it is one of them. At time 1 level is 100: the initialization
//   came before the resolver call and did not overwrite its result.
// Oracle checks: Icarus Verilog 13.0 does not support unpacked structures,
// and the 5.054 release of Verilator does not support nettype declarations,
// so the expected output follows the cited clause alone.

module test_nettype_initial_value_before_procedures;
  typedef struct {
    int level = 7;
    real volt = 1.5;
  } supply_t;

  function automatic supply_t pick(input supply_t d[]);
    supply_t t;
    t.level = 100 + d.size();
    return t;
  endfunction

  nettype supply_t plain_net;
  nettype supply_t resolved_net with pick;

  plain_net p;
  resolved_net r;
  int init_level, always_level, r_level0;
  real init_volt, always_volt;

  always begin
    always_level = p.level;
    always_volt = p.volt;
    wait (1'b0);
  end

  initial begin
    init_level = p.level;
    init_volt = p.volt;
    r_level0 = r.level;
    #1;
    $display("initial at 0: p.level=%0d p.volt=%0.2f", init_level, init_volt);
    $display("always at 0: p.level=%0d p.volt=%0.2f", always_level, always_volt);
    $display("initial at 0: r.level is 7 or 100: %0d", r_level0 == 7 || r_level0 == 100);
    $display("at 1: r.level=%0d", r.level);
  end
endmodule
