/*
:name: test_modport_use
:description: Test modport usage (IEEE 1800-2023 Section 25.5)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modport_use.expected
*/
// Test modport usage (IEEE 1800-2023 Section 25.5)

interface data_if;
  logic [7:0] data;
  logic valid;
  logic ready;

  modport producer (output data, valid, input ready);
  modport consumer (input data, valid, output ready);
endinterface

module sender (data_if.producer port);
  initial begin
    port.data = 8'hAB;
    port.valid = 1;
  end
endmodule

module receiver (data_if.consumer port);
  initial begin
    port.ready = 1;
  end
endmodule

module test_modport_use;
  data_if intf();
  int pass_count;

  sender s (.port(intf));
  receiver r (.port(intf));

  initial begin
    pass_count = 0;
    #1;

    // Test 1: Producer output
    if (intf.data == 8'hAB) pass_count++;

    // Test 2: Valid signal
    if (intf.valid == 1) pass_count++;

    // Test 3: Consumer output
    if (intf.ready == 1) pass_count++;

    // Test 4: Direct access
    intf.data = 8'hCD;
    #1;
    if (intf.data == 8'hCD) pass_count++;

    $display("Modport use tests: %0d/4 passed", pass_count);
    if (pass_count == 4) begin
      $display("PASS: Modport use tests");
    end else begin
      $display("FAIL: Some modport tests failed");
    end
  end
endmodule
