/*
:name: test_illegal_virtual_interface_type_parameter_mismatch
:description: The type of an interface instance includes the actual type of its type parameter, so an instance with T = int cannot be assigned to a virtual interface declared with T = byte, while an instance with T = byte can (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: u_int, whose type parameter T keeps its default int, is assigned to the virtual interface vb declared with T = byte
:expected_stderr_regex: test_illegal_virtual_interface_type_parameter_mismatch\.sv:33:
*/
// IEEE 1800-2023 §25.9: the type of an interface includes its actual
// parameters, default or overridden, and the actual values and types of those
// parameters shall match for an interface instance and a virtual interface to
// be of the same type and assignment compatible. u_byte has T = byte and
// matches vb; u_int keeps the default T = int.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count.

interface vtp_if #(parameter type T = int);
  T d;
endinterface

module test_illegal_virtual_interface_type_parameter_mismatch;
  vtp_if #(.T(byte)) u_byte ();
  vtp_if u_int ();
  virtual vtp_if #(.T(byte)) vb;
  initial begin
    vb = u_byte;
    $display("%0d", $bits(vb.d));
    vb = u_int;   // illegal: T is int in u_int and byte in vb
  end
endmodule
