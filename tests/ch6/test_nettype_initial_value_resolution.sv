/*
:name: test_nettype_initial_value_resolution
:description: A net of a user-defined nettype starts with the default value of its data type, struct member initializers included, logic being x rather than z, and a resolved nettype resolves at time zero even without drivers (IEEE 1800-2023 Section 6.7.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7.3 6.7.2 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_nettype_initial_value_resolution.expected
*/
// IEEE 1800-2023 §6.7.3: a net of a user-defined nettype (6.7.2) starts with
// the default value of its data type, with the initializers of struct members
// applied; for logic that default is x, not the z of other nets. The
// resolution function of a resolved nettype (6.6.7) runs at time zero at
// least once, also without drivers, and then gets an empty array of driver
// values. None of these nets has a driver: s has the struct's initializer for
// level, n is x, and r is what with_bias returns for no drivers, 0.25, rather
// than the 0.0 that a real starts with. The resolution function has no side
// effects, as 6.6.7 requires, so its result is the only trace of the call.

module test_nettype_initial_value_resolution;
  typedef struct {
    int level = 7;
    real volt;
  } supply_t;
  typedef logic [3:0] nibble_t;

  function automatic real with_bias(input real drivers[]);
    real total = 0.25;
    foreach (drivers[i]) total += drivers[i];
    return total;
  endfunction

  nettype supply_t supply_net;
  nettype nibble_t nibble_net;
  nettype real bias_net with with_bias;

  supply_net s;
  nibble_net n;
  bias_net r;
  wire [3:0] w;

  initial
    #1 $display("s.level=%0d s.volt=%0.1f n=%b w=%b r=%0.2f", s.level, s.volt, n, w,
                r);
endmodule
