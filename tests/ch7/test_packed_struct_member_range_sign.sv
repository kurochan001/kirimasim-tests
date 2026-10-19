/*
:name: test_packed_struct_member_range_sign
:description: A member of a packed structure keeps its declared range and signedness when it is selected (IEEE 1800-2023 Section 7.2.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2.1 6.9.1 6.24.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_struct_member_range_sign.expected
*/
// IEEE 1800-2023 §7.2.1: a member selected from a packed structure has the type
// it was declared with. A member declared logic [0:7] keeps its ascending range,
// so index 0 is its most significant bit (6.9.1); a member declared
// logic signed [7:0] stays signed, so int'() of it sign-extends (6.24.1).

module test_packed_struct_member_range_sign;
  typedef struct packed {
    logic [0:7] data;            // ascending: data[0] is the MSB
  } asc_s_t;

  typedef struct packed {
    logic [26:0]       rest;
    logic signed [7:0] low;      // signed member
  } sp_t;

  typedef struct packed {
    logic [7:0]       a;         // descending (control)
    logic [7:0]       b;
  } desc_s_t;

  asc_s_t  ai;
  sp_t     si;
  desc_s_t di;
  int errs = 0;

  task automatic chk_i(string what, int got, int exp);
    if (got === exp) $display("  ok   %s = %0d", what, got);
    else begin errs++; $display("  FAIL %s = %0d (exp %0d)", what, got, exp); end
  endtask
  task automatic chk_b(string what, logic got, logic exp);
    if (got === exp) $display("  ok   %s = %b", what, got);
    else begin errs++; $display("  FAIL %s = %b (exp %b)", what, got, exp); end
  endtask

  initial begin
    // ascending member
    ai.data = 8'h1d;             // 0001_1101: data[0] = 0, data[3] = 1
    chk_b("asc data[0]", ai.data[0], 1'b0);
    chk_b("asc data[3]", ai.data[3], 1'b1);
    chk_b("asc data[7]", ai.data[7], 1'b1); // LSB
    chk_i("asc part [2:5]", int'(ai.data[2:5]), 4'b0111);

    // signed member
    si.low = 8'hc8;              // -56
    chk_i("int'(signed low)", int'(si.low), -56);
    chk_i("$signed(low)", $signed(si.low), -56);

    // controls: descending and unsigned
    di.a = 8'hC3; di.b = 8'h5A;
    chk_b("desc a[7]", di.a[7], 1'b1);
    chk_b("desc a[0]", di.a[0], 1'b1);
    di.a[0] = 1'b0;
    chk_i("desc write a", int'(di.a), 8'hC2);

    if (errs == 0) $display("TEST PASSED");
    else $display("TEST FAILED: %0d errors", errs);
  end
endmodule
