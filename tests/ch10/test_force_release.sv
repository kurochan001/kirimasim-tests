/*
:name: test_force_release
:description: Procedural continuous assignments
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_release.expected
*/
// IEEE 1800-2023 §10.6 Procedural continuous assignments
// Test force/release statements

module test_force_release;
  logic [7:0] a;
  logic [7:0] b;

  assign b = a + 1;  // Continuous assignment

  initial begin
    // Normal operation
    a = 8'h10;
    #1;
    assert(b == 8'h11) else $fatal(1, "b should be 0x11, got 0x%0h", b);

    // Force overrides continuous assignment
    force b = 8'hFF;
    #1;
    assert(b == 8'hFF) else $fatal(1, "b should be 0xFF (forced), got 0x%0h", b);

    // Change a, but b is still forced
    a = 8'h20;
    #1;
    assert(b == 8'hFF) else $fatal(1, "b should still be 0xFF (forced), got 0x%0h", b);

    // Release restores continuous assignment
    release b;
    #1;
    assert(b == 8'h21) else $fatal(1, "b should be 0x21 (a+1), got 0x%0h", b);

    $display("PASS: Force/release test completed");
    $finish;
  end
endmodule
