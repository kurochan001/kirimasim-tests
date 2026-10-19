/*
:name: test_enum_xz_member_methods
:description: Enumeration methods of a 4-state enumeration that has a member with an x bit (IEEE 1800-2023 Section 6.19.5)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5 6.19
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_enum_xz_member_methods.expected
*/
// IEEE 1800-2023 §6.19: an enumeration with an explicit 4-state base type may
// give a member a value with x or z bits. §6.19.5: its methods still work on the
// other members: first() is the first member declared, num() counts every
// member, the one with x included, and next() steps in declaration order.

module test_enum_xz_member_methods;
  typedef enum logic [1:0] { A = 2'b00, B = 2'b01, X = 2'b1x } e_t;
  e_t e;
  int fails = 0;

  initial begin
    e = e.first();
    if (e !== A)         begin $display("FAIL first()=%b expected 00", e); fails++; end
    if (e.name() != "A") begin $display("FAIL name=%s expected A", e.name()); fails++; end

    if (e.num() != 3) begin $display("FAIL num()=%0d expected 3", e.num()); fails++; end

    e = e.first();
    e = e.next();
    if (e !== B)         begin $display("FAIL next()=%b expected 01", e); fails++; end
    if (e.name() != "B") begin $display("FAIL next name=%s expected B", e.name()); fails++; end

    if (fails == 0)
      $display("TEST PASSED: methods of an enumeration with an x member");
    else
      $display("TEST FAILED: %0d check(s) failed", fails);
    $finish;
  end
endmodule
