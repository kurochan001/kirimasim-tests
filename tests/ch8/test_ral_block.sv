/*
:name: test_ral_block
:description: A register-model block written with plain classes: handles, arrays of handles and lookups by name
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.7 7.4 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ral_block.expected
*/
// A register-model block written with plain classes (no UVM): class
// handles (8.4), constructors (8.7), arrays of handles (7.4) and string
// comparison (6.16).

module test_ral_block;

  // Simplified register class
  class simple_reg;
    string m_name;
    int unsigned m_n_bits;
    logic [63:0] m_value;
    logic [63:0] m_mirrored;
    logic [63:0] m_reset_value;

    function new(string name = "reg", int unsigned n_bits = 32);
      m_name = name;
      m_n_bits = n_bits;
      m_value = 0;
      m_mirrored = 0;
      m_reset_value = 0;
    endfunction

    function string get_name();
      return m_name;
    endfunction

    function int unsigned get_n_bits();
      return m_n_bits;
    endfunction

    function void set_reset(logic [63:0] value);
      m_reset_value = value;
      m_value = value;
      m_mirrored = value;
    endfunction

    function logic [63:0] get();
      return m_value;
    endfunction

    function void set(logic [63:0] value);
      m_value = value;
    endfunction

    function void reset();
      m_value = m_reset_value;
      m_mirrored = m_reset_value;
    endfunction
  endclass

  // Simplified memory class
  class simple_mem;
    string m_name;
    int unsigned m_size;
    int unsigned m_n_bits;
    logic [31:0] m_storage[256];

    function new(string name = "mem", int unsigned size = 256, int unsigned n_bits = 32);
      m_name = name;
      m_size = size;
      m_n_bits = n_bits;
    endfunction

    function string get_name();
      return m_name;
    endfunction

    function int unsigned get_size();
      return m_size;
    endfunction

    function int unsigned get_n_bits();
      return m_n_bits;
    endfunction

    function void write(int unsigned offset, logic [31:0] value);
      if (offset < m_size) begin
        m_storage[offset] = value;
      end
    endfunction

    function logic [31:0] read(int unsigned offset);
      if (offset < m_size) begin
        return m_storage[offset];
      end
      return 0;
    endfunction

    function void reset();
      for (int i = 0; i < 256; i++) begin
        m_storage[i] = 0;
      end
    endfunction
  endclass

  // Simplified register map
  class simple_reg_map;
    string m_name;
    logic [63:0] m_base_addr;
    int unsigned m_n_bytes;
    simple_reg m_regs[8];
    logic [63:0] m_reg_offsets[8];
    int m_reg_count;
    simple_mem m_mems[4];
    logic [63:0] m_mem_offsets[4];
    int m_mem_count;

    function new(string name = "map");
      m_name = name;
      m_base_addr = 0;
      m_n_bytes = 4;
      m_reg_count = 0;
      m_mem_count = 0;
    endfunction

    function string get_name();
      return m_name;
    endfunction

    function void configure(logic [63:0] base_addr, int unsigned n_bytes);
      m_base_addr = base_addr;
      m_n_bytes = n_bytes;
      $display("MAP: Configure %s, base=0x%08h, n_bytes=%0d", m_name, base_addr, n_bytes);
    endfunction

    function logic [63:0] get_base_addr();
      return m_base_addr;
    endfunction

    function void add_reg(simple_reg rg, logic [63:0] offset);
      if (rg != null && m_reg_count < 8) begin
        m_regs[m_reg_count] = rg;
        m_reg_offsets[m_reg_count] = offset;
        m_reg_count = m_reg_count + 1;
        $display("MAP: Add register %s at offset 0x%04h", rg.get_name(), offset);
      end
    endfunction

    function void add_mem(simple_mem mem, logic [63:0] offset);
      if (mem != null && m_mem_count < 4) begin
        m_mems[m_mem_count] = mem;
        m_mem_offsets[m_mem_count] = offset;
        m_mem_count = m_mem_count + 1;
        $display("MAP: Add memory %s at offset 0x%04h", mem.get_name(), offset);
      end
    endfunction

    function logic [63:0] get_reg_addr_by_name(string name);
      for (int i = 0; i < m_reg_count && i < 8; i++) begin
        if (m_regs[i].get_name() == name) begin
          return m_base_addr + m_reg_offsets[i];
        end
      end
      return 0;
    endfunction

    function int get_num_regs();
      return m_reg_count;
    endfunction

    function int get_num_mems();
      return m_mem_count;
    endfunction
  endclass

  // Simplified register block
  class simple_reg_block;
    string m_name;
    simple_reg m_regs[8];
    int m_reg_count;
    simple_mem m_mems[4];
    int m_mem_count;
    simple_reg_map m_default_map;
    bit m_locked;

    function new(string name = "block");
      m_name = name;
      m_reg_count = 0;
      m_mem_count = 0;
      m_default_map = null;
      m_locked = 0;
    endfunction

    function string get_name();
      return m_name;
    endfunction

    function simple_reg_map create_map(string name, logic [63:0] base_addr, int unsigned n_bytes);
      simple_reg_map new_map;
      new_map = new(name);
      new_map.configure(base_addr, n_bytes);
      if (m_default_map == null) begin
        m_default_map = new_map;
      end
      $display("BLOCK: Created map %s", name);
      return new_map;
    endfunction

    function simple_reg_map get_default_map();
      return m_default_map;
    endfunction

    function void add_reg(simple_reg rg);
      if (rg != null && m_reg_count < 8) begin
        m_regs[m_reg_count] = rg;
        m_reg_count = m_reg_count + 1;
        $display("BLOCK: Add register %s", rg.get_name());
      end
    endfunction

    function void add_mem(simple_mem mem);
      if (mem != null && m_mem_count < 4) begin
        m_mems[m_mem_count] = mem;
        m_mem_count = m_mem_count + 1;
        $display("BLOCK: Add memory %s", mem.get_name());
      end
    endfunction

    function int get_num_regs();
      return m_reg_count;
    endfunction

    function int get_num_mems();
      return m_mem_count;
    endfunction

    function simple_reg get_reg_by_name(string name);
      for (int i = 0; i < m_reg_count && i < 8; i++) begin
        if (m_regs[i].get_name() == name) begin
          return m_regs[i];
        end
      end
      return null;
    endfunction

    function void lock_model();
      m_locked = 1;
      $display("BLOCK: Model locked");
    endfunction

    function bit is_locked();
      return m_locked;
    endfunction

    function void reset();
      for (int i = 0; i < m_reg_count && i < 8; i++) begin
        m_regs[i].reset();
      end
      for (int i = 0; i < m_mem_count && i < 4; i++) begin
        m_mems[i].reset();
      end
      $display("BLOCK: Reset all registers and memories");
    endfunction
  endclass

  simple_reg_block dut_block;
  simple_reg_map dut_map;
  simple_reg ctrl_reg, status_reg, data_reg;
  simple_mem buffer_mem;
  int test_pass;

  initial begin
    logic [63:0] addr;
    simple_reg found_reg;
    test_pass = 1;

    $display("=== Starting RAL Block Test ===");

    // Create block
    dut_block = new("dut_block");
    $display("Created register block: %s", dut_block.get_name());

    // Test 1: Create map
    $display("\n--- Test 1: Create register map ---");
    dut_map = dut_block.create_map("default_map", 64'h1000_0000, 4);
    if (dut_map != null && dut_map.get_base_addr() == 64'h1000_0000) begin
      $display("PASS: Created map with base address 0x%08h", dut_map.get_base_addr());
    end else begin
      $display("FAIL: Map creation failed");
      test_pass = 0;
    end

    // Test 2: Create and add registers
    $display("\n--- Test 2: Create and add registers ---");
    ctrl_reg = new("ctrl", 32);
    ctrl_reg.set_reset(32'h0000_0001);
    status_reg = new("status", 32);
    status_reg.set_reset(32'h0000_0000);
    data_reg = new("data", 32);
    data_reg.set_reset(32'h0000_0000);

    dut_block.add_reg(ctrl_reg);
    dut_block.add_reg(status_reg);
    dut_block.add_reg(data_reg);

    if (dut_block.get_num_regs() == 3) begin
      $display("PASS: Block has %0d registers", dut_block.get_num_regs());
    end else begin
      $display("FAIL: Expected 3 registers, got %0d", dut_block.get_num_regs());
      test_pass = 0;
    end

    // Test 3: Add registers to map
    $display("\n--- Test 3: Add registers to map ---");
    dut_map.add_reg(ctrl_reg, 64'h0000);
    dut_map.add_reg(status_reg, 64'h0004);
    dut_map.add_reg(data_reg, 64'h0008);

    if (dut_map.get_num_regs() == 3) begin
      $display("PASS: Map has %0d registers", dut_map.get_num_regs());
    end else begin
      $display("FAIL: Expected 3 registers in map, got %0d", dut_map.get_num_regs());
      test_pass = 0;
    end

    // Test 4: Get register address
    $display("\n--- Test 4: Get register address ---");
    addr = dut_map.get_reg_addr_by_name("status");
    if (addr == 64'h1000_0004) begin
      $display("PASS: status_reg address = 0x%08h", addr);
    end else begin
      $display("FAIL: Expected 0x10000004, got 0x%08h", addr);
      test_pass = 0;
    end

    // Test 5: Create and add memory
    $display("\n--- Test 5: Create and add memory ---");
    buffer_mem = new("buffer", 256, 32);
    dut_block.add_mem(buffer_mem);
    dut_map.add_mem(buffer_mem, 64'h1000);

    if (dut_block.get_num_mems() == 1) begin
      $display("PASS: Block has %0d memory", dut_block.get_num_mems());
    end else begin
      $display("FAIL: Expected 1 memory, got %0d", dut_block.get_num_mems());
      test_pass = 0;
    end

    // Test 6: Get register by name
    $display("\n--- Test 6: Get register by name ---");
    found_reg = dut_block.get_reg_by_name("data");
    if (found_reg != null) begin
      $display("PASS: Found register '%s'", found_reg.get_name());
    end else begin
      $display("FAIL: Register 'data' not found");
      test_pass = 0;
    end

    // Test 7: Lock model
    $display("\n--- Test 7: Lock model ---");
    dut_block.lock_model();
    if (dut_block.is_locked()) begin
      $display("PASS: Model is locked");
    end else begin
      $display("FAIL: Model should be locked");
      test_pass = 0;
    end

    // Test 8: Reset block
    $display("\n--- Test 8: Reset block ---");
    ctrl_reg.set(32'hFFFF_FFFF);
    dut_block.reset();
    if (ctrl_reg.get() == 32'h0000_0001) begin
      $display("PASS: ctrl_reg reset to 0x%08h", ctrl_reg.get());
    end else begin
      $display("FAIL: Expected 0x00000001, got 0x%08h", ctrl_reg.get());
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
