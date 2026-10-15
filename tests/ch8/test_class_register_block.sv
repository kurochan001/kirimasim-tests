/*
:name: test_class_register_block
:description: A class that models a block of registers, with reads, writes and reset
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.5 12.5
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_register_block.expected
*/
// A class that models a block of registers, with reads, writes and reset

module test_class_register_block;

  // Simple register block class
  class my_reg_block;
    string name;
    int base_addr;

    // Storage
    logic [31:0] ctrl_reg;
    logic [31:0] status_reg;
    logic [31:0] data_reg;

    function new(string n = "my_reg_block");
      name = n;
      base_addr = 0;
      ctrl_reg = 32'h0000_0001;  // Reset value
      status_reg = 32'h0000_0000;
      data_reg = 32'h0000_0000;
    endfunction

    function void configure(int addr);
      base_addr = addr;
    endfunction

    function void write_reg(string reg_name, logic [31:0] value);
      case (reg_name)
        "ctrl":   ctrl_reg = value;
        "status": status_reg = value;
        "data":   data_reg = value;
        default:  $display("ERROR: Unknown register %s", reg_name);
      endcase
      $display("REG: Write %s.%s = 0x%08h", name, reg_name, value);
    endfunction

    function logic [31:0] read_reg(string reg_name);
      logic [31:0] value;
      case (reg_name)
        "ctrl":   value = ctrl_reg;
        "status": value = status_reg;
        "data":   value = data_reg;
        default: begin
          $display("ERROR: Unknown register %s", reg_name);
          value = 0;
        end
      endcase
      $display("REG: Read %s.%s = 0x%08h", name, reg_name, value);
      return value;
    endfunction

    function void reset();
      ctrl_reg = 32'h0000_0001;
      status_reg = 32'h0000_0000;
      data_reg = 32'h0000_0000;
      $display("REG: Reset %s", name);
    endfunction
  endclass

  // Simple memory class
  class my_mem;
    string name;
    int size;
    logic [31:0] storage[256];

    function new(string n = "my_mem", int s = 256);
      name = n;
      size = s;
    endfunction

    function void write(int offset, logic [31:0] value);
      if (offset >= 0 && offset < size) begin
        storage[offset] = value;
        $display("MEM: Write %s[%0d] = 0x%08h", name, offset, value);
      end else begin
        $display("MEM: ERROR - Write out of bounds %s[%0d]", name, offset);
      end
    endfunction

    function logic [31:0] read(int offset);
      if (offset >= 0 && offset < size) begin
        $display("MEM: Read %s[%0d] = 0x%08h", name, offset, storage[offset]);
        return storage[offset];
      end else begin
        $display("MEM: ERROR - Read out of bounds %s[%0d]", name, offset);
        return 0;
      end
    endfunction

    function void reset();
      int i;
      i = 0;
      while (i < size) begin
        storage[i] = 0;
        i = i + 1;
      end
      $display("MEM: Reset %s", name);
    endfunction
  endclass

  my_reg_block regs;
  my_mem mem;
  int test_pass;

  initial begin
    logic [31:0] value;
    test_pass = 1;

    $display("=== Starting Register Block Test ===");

    // Create register block
    regs = new("dut_regs");
    regs.configure(32'h1000_0000);
    $display("Created register block at 0x%08h", regs.base_addr);

    // Create memory
    mem = new("dut_mem", 256);
    $display("Created memory with %0d entries", mem.size);

    // Test 1: Read reset values
    $display("\n--- Test 1: Read reset values ---");
    value = regs.read_reg("ctrl");
    if (value == 32'h0000_0001) begin
      $display("PASS: ctrl reset value correct");
    end else begin
      $display("FAIL: Expected 0x00000001, got 0x%08h", value);
      test_pass = 0;
    end

    // Test 2: Write and read back
    $display("\n--- Test 2: Write and read back ---");
    regs.write_reg("data", 32'hDEAD_BEEF);
    value = regs.read_reg("data");
    if (value == 32'hDEAD_BEEF) begin
      $display("PASS: Write/read data correct");
    end else begin
      $display("FAIL: Expected 0xDEADBEEF, got 0x%08h", value);
      test_pass = 0;
    end

    // Test 3: Memory write/read
    $display("\n--- Test 3: Memory operations ---");
    mem.write(0, 32'h1111_1111);
    mem.write(1, 32'h2222_2222);
    mem.write(2, 32'h3333_3333);

    value = mem.read(1);
    if (value == 32'h2222_2222) begin
      $display("PASS: Memory read correct");
    end else begin
      $display("FAIL: Expected 0x22222222, got 0x%08h", value);
      test_pass = 0;
    end

    // Test 4: Reset
    $display("\n--- Test 4: Reset functionality ---");
    regs.reset();
    value = regs.read_reg("data");
    if (value == 32'h0000_0000) begin
      $display("PASS: Reset cleared data register");
    end else begin
      $display("FAIL: Expected 0x00000000, got 0x%08h", value);
      test_pass = 0;
    end

    value = regs.read_reg("ctrl");
    if (value == 32'h0000_0001) begin
      $display("PASS: Reset restored ctrl to default");
    end else begin
      $display("FAIL: Expected 0x00000001, got 0x%08h", value);
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
