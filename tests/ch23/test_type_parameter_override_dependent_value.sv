/*
:name: test_type_parameter_override_dependent_value
:description: A value parameter whose type is a type parameter is evaluated only with the type that the instance gives, so a default type for which the default value would be illegal (a class) or a type parameter without a default does not stop the elaboration (IEEE 1800-2023 Section 23.10.3)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.3 6.20.3 23.10.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_parameter_override_dependent_value.expected
*/
// IEEE 1800-2023 §23.10.3: when an instance overrides a type parameter, a
// parameter whose type depends on it is assigned only with the overridden
// type, never with the default type first. Here T defaults to a class type,
// for which the default 70000 of P would be an illegal value, and T2 has no
// default, so P2 can only be evaluated with the type of an override. Every
// instance overrides both by name (§23.10.2.2), so the design is legal and
// P and P2 take their defaults converted to the given types:
//   a: T int, T2 byte unsigned: P 70000 (32 bits), P2 -1 as 255 (8 bits);
//   b: T shortint, T2 logic [11:0]: P 70000 cut to 16 bits, 4464, and P2
//      4095 (12 bits).

class type_parameter_override_dependent_value_k;
endclass

module type_parameter_override_dependent_value_m
  #(type T = type_parameter_override_dependent_value_k, T P = 70000,
    type T2, T2 P2 = -1);
endmodule

module test_type_parameter_override_dependent_value;
  type_parameter_override_dependent_value_m #(.T(int), .T2(byte unsigned)) a();
  type_parameter_override_dependent_value_m #(.T(shortint), .T2(logic [11:0])) b();

  initial begin
    $display("a: P=%0d/%0d P2=%0d/%0d", a.P, $bits(a.P), a.P2, $bits(a.P2));
    $display("b: P=%0d/%0d P2=%0d/%0d", b.P, $bits(b.P), b.P2, $bits(b.P2));
  end
endmodule
