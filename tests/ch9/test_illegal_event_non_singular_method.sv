/*
:name: test_illegal_event_non_singular_method
:description: a nonvirtual object method whose return type is not singular cannot be used in an event control
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the event expression calls a method that returns a fixed unpacked array, which is not a singular value
:expected_stderr_regex: test_illegal_event_non_singular_method\.sv:38:
*/
// IEEE 1800-2023 9.4.2: event expressions shall return singular values, and a
// nonvirtual method of an object may appear in an event control only when it
// is a function whose return value is singular. vals returns arr_t, a fixed
// unpacked array of two ints, so @(obj.vals()) is illegal. Verilator 5.052
// accepts the design and Icarus Verilog 13.0 stops at the array return type
// before the event control; the expected result follows the clause.

typedef int arr_t[2];

module test_illegal_event_non_singular_method;
  class C;
    int v;

    function arr_t vals();
      arr_t a;
      a[0] = v;
      a[1] = v + 1;
      return a;
    endfunction
  endclass

  C obj = new;

  initial begin
    @(obj.vals());   // illegal: the method does not return a singular value
    $display("woke");
  end

  initial #5 $finish;
endmodule
