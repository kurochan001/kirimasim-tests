/*
:name: test_tlm2_generic_payload
:description: A TLM 2.0 style generic payload written with plain classes and enumerated types
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.5 8.6 6.19 7.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_tlm2_generic_payload.expected
*/
// A TLM 2.0 style generic payload written with plain classes (no UVM):
// enumerated types (6.19), class properties and methods (8.4-8.6) and
// fixed-size arrays of bytes (7.4).

module test_tlm2_generic_payload;

  // TLM 2.0 command types
  typedef enum {
    TLM_READ_COMMAND,
    TLM_WRITE_COMMAND,
    TLM_IGNORE_COMMAND
  } tlm_command_e;

  // TLM 2.0 response status
  typedef enum int {
    TLM_OK_RESPONSE = 1,
    TLM_INCOMPLETE_RESPONSE = 0,
    TLM_GENERIC_ERROR_RESPONSE = -1,
    TLM_ADDRESS_ERROR_RESPONSE = -2,
    TLM_COMMAND_ERROR_RESPONSE = -3,
    TLM_BURST_ERROR_RESPONSE = -4,
    TLM_BYTE_ENABLE_ERROR_RESPONSE = -5
  } tlm_response_status_e;

  // Simplified generic payload class
  class simple_generic_payload;
    tlm_command_e m_command;
    logic [63:0] m_address;
    byte unsigned m_data[16];
    int m_data_length;
    tlm_response_status_e m_response_status;
    bit m_dmi_allowed;
    byte unsigned m_byte_enable[16];
    int m_byte_enable_length;
    int m_streaming_width;

    function new();
      m_command = TLM_READ_COMMAND;
      m_address = 0;
      m_data_length = 0;
      m_response_status = TLM_INCOMPLETE_RESPONSE;
      m_dmi_allowed = 0;
      m_byte_enable_length = 0;
      m_streaming_width = 0;
    endfunction

    // Command accessors
    function void set_command(tlm_command_e cmd);
      m_command = cmd;
    endfunction

    function tlm_command_e get_command();
      return m_command;
    endfunction

    function bit is_read();
      return (m_command == TLM_READ_COMMAND);
    endfunction

    function bit is_write();
      return (m_command == TLM_WRITE_COMMAND);
    endfunction

    // Address accessors
    function void set_address(logic [63:0] addr);
      m_address = addr;
    endfunction

    function logic [63:0] get_address();
      return m_address;
    endfunction

    // Data accessors
    function void set_data_byte(int idx, byte unsigned value);
      if (idx >= 0 && idx < 16) begin
        m_data[idx] = value;
      end
    endfunction

    function byte unsigned get_data_byte(int idx);
      if (idx >= 0 && idx < 16) begin
        return m_data[idx];
      end
      return 0;
    endfunction

    function void set_data_length(int length);
      m_data_length = length;
    endfunction

    function int get_data_length();
      return m_data_length;
    endfunction

    // Response status accessors
    function void set_response_status(tlm_response_status_e status);
      m_response_status = status;
    endfunction

    function tlm_response_status_e get_response_status();
      return m_response_status;
    endfunction

    function bit is_response_ok();
      return (m_response_status == TLM_OK_RESPONSE);
    endfunction

    function bit is_response_error();
      return (int'(m_response_status) < 0);
    endfunction

    function string get_response_string();
      case (m_response_status)
        TLM_OK_RESPONSE:               return "OK";
        TLM_INCOMPLETE_RESPONSE:       return "INCOMPLETE";
        TLM_GENERIC_ERROR_RESPONSE:    return "GENERIC_ERROR";
        TLM_ADDRESS_ERROR_RESPONSE:    return "ADDRESS_ERROR";
        TLM_COMMAND_ERROR_RESPONSE:    return "COMMAND_ERROR";
        TLM_BURST_ERROR_RESPONSE:      return "BURST_ERROR";
        TLM_BYTE_ENABLE_ERROR_RESPONSE: return "BYTE_ENABLE_ERROR";
        default:                       return "UNKNOWN";
      endcase
    endfunction

    // DMI accessors
    function void set_dmi_allowed(bit allowed);
      m_dmi_allowed = allowed;
    endfunction

    function bit is_dmi_allowed();
      return m_dmi_allowed;
    endfunction

    // Streaming width accessors
    function void set_streaming_width(int width);
      m_streaming_width = width;
    endfunction

    function int get_streaming_width();
      return m_streaming_width;
    endfunction
  endclass

  simple_generic_payload gp;
  int test_pass;

  initial begin
    byte unsigned data_val;
    test_pass = 1;

    $display("=== Starting TLM 2.0 Generic Payload Test ===");

    // Create payload
    gp = new();

    // Test 1: Default values
    $display("\n--- Test 1: Default values ---");
    if (gp.is_read() && gp.get_address() == 0 &&
        gp.get_response_status() == TLM_INCOMPLETE_RESPONSE) begin
      $display("PASS: Default values correct");
    end else begin
      $display("FAIL: Default values incorrect");
      test_pass = 0;
    end

    // Test 2: Set command
    $display("\n--- Test 2: Set command ---");
    gp.set_command(TLM_WRITE_COMMAND);
    if (gp.is_write() && !gp.is_read()) begin
      $display("PASS: Command set to WRITE");
    end else begin
      $display("FAIL: Command not set correctly");
      test_pass = 0;
    end

    // Test 3: Set address
    $display("\n--- Test 3: Set address ---");
    gp.set_address(64'h0000_1000_DEAD_BEEF);
    if (gp.get_address() == 64'h0000_1000_DEAD_BEEF) begin
      $display("PASS: Address = 0x%016h", gp.get_address());
    end else begin
      $display("FAIL: Address incorrect");
      test_pass = 0;
    end

    // Test 4: Set data
    $display("\n--- Test 4: Set data ---");
    gp.set_data_byte(0, 8'hAA);
    gp.set_data_byte(1, 8'hBB);
    gp.set_data_byte(2, 8'hCC);
    gp.set_data_byte(3, 8'hDD);
    gp.set_data_length(4);

    data_val = gp.get_data_byte(2);
    if (data_val == 8'hCC && gp.get_data_length() == 4) begin
      $display("PASS: Data[2] = 0x%02h, length = %0d", data_val, gp.get_data_length());
    end else begin
      $display("FAIL: Data incorrect");
      test_pass = 0;
    end

    // Test 5: Response status
    $display("\n--- Test 5: Response status ---");
    gp.set_response_status(TLM_OK_RESPONSE);
    if (gp.is_response_ok() && !gp.is_response_error()) begin
      $display("PASS: Response = %s", gp.get_response_string());
    end else begin
      $display("FAIL: Response status incorrect");
      test_pass = 0;
    end

    // Test 6: Error response
    $display("\n--- Test 6: Error response ---");
    gp.set_response_status(TLM_ADDRESS_ERROR_RESPONSE);
    if (!gp.is_response_ok() && gp.is_response_error()) begin
      $display("PASS: Error response = %s", gp.get_response_string());
    end else begin
      $display("FAIL: Error response incorrect");
      test_pass = 0;
    end

    // Test 7: DMI allowed
    $display("\n--- Test 7: DMI allowed ---");
    gp.set_dmi_allowed(1);
    if (gp.is_dmi_allowed()) begin
      $display("PASS: DMI allowed = %0d", gp.is_dmi_allowed());
    end else begin
      $display("FAIL: DMI should be allowed");
      test_pass = 0;
    end

    // Test 8: Streaming width
    $display("\n--- Test 8: Streaming width ---");
    gp.set_streaming_width(64);
    if (gp.get_streaming_width() == 64) begin
      $display("PASS: Streaming width = %0d", gp.get_streaming_width());
    end else begin
      $display("FAIL: Streaming width incorrect");
      test_pass = 0;
    end

    // Report results
    $display("\n=== Test Complete ===");
    if (test_pass) begin
      $display("TEST PASSED");
    end else begin
      $display("TEST FAILED");
    end

    $finish;
  end
endmodule
