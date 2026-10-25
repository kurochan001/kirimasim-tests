/*
:name: test_illegal_virtual_interface_with_interface_port
:description: An interface whose port references another interface cannot be used in the declaration of a virtual interface, while it can be instantiated with that interface connected (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the virtual interface v is declared with vip_wrap_if, which has the interface port base of type vip_base_if
:expected_stderr_regex: test_illegal_virtual_interface_with_interface_port\.sv:36:
*/
// IEEE 1800-2023 §25.9: an interface may have ports that reference other
// interfaces, but it shall be illegal to use an interface with such ports in
// the declaration of a virtual interface. vip_wrap_if has an interface port of
// vip_base_if; the module instantiates it, which is legal, and a virtual
// interface of vip_base_if is legal too. A virtual interface of vip_wrap_if is
// not.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count. The 5.052
// release of Verilator accepts the design.

interface vip_base_if;
  logic d = 1'b0;
endinterface

interface vip_wrap_if(vip_base_if base);
  logic e;
endinterface

module test_illegal_virtual_interface_with_interface_port;
  vip_base_if b ();
  vip_wrap_if w (b);
  virtual vip_base_if vb;
  virtual vip_wrap_if v;   // illegal: vip_wrap_if has a port of another interface
  initial begin
    vb = b;
    $display("%b", vb.d);
  end
endmodule
