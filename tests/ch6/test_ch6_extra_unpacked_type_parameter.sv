/*
:name: test_ch6_extra_unpacked_type_parameter
:description: An unpacked array type used as a type parameter value has to be named by a user-defined type identifier (IEEE 1800-2023 Section 6.18)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.18 6.20.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the type parameter T is given the unnamed unpacked array type int [3]
:expected_stderr_regex: test_ch6_extra_unpacked_type_parameter\.sv:26:
*/
// IEEE 1800-2023 §6.18: user-defined data type names need to be used for
// complex data types as type parameter values (§6.20.3) when unpacked array
// types are used. arr_t names int [3] and is a legal default for T in the
// first module. The marked line gives the second module the unpacked array
// type itself, which is not a type identifier, so the declaration is illegal.

typedef int arr_t [3];

module test_ch6_extra_unpacked_type_parameter_ok #(parameter type T = arr_t) ();
  initial $display("ok=%0d", $bits(T));
endmodule

module test_ch6_extra_unpacked_type_parameter #(parameter type T = int [3]) ();
  initial $display("bad=%0d", $bits(T));
endmodule
