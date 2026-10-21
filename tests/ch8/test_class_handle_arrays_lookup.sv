/*
:name: test_class_handle_arrays_lookup
:description: Objects kept in fixed-size arrays of class handles by two containers are shared, not copied, can be found by comparing a string property, and a method of one container changes them for the other (IEEE 1800-2023 Sections 8.4, 8.7)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.7 7.4 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_handle_arrays_lookup.expected
*/
// IEEE 1800-2023 §8.4: a class variable holds a handle, so storing it in an
// array element or passing it to a method shares the object instead of
// copying it, and an unset handle is null. §8.7: new runs the constructor,
// whose arguments have defaults. §7.4: the containers keep their handles in
// fixed-size arrays. §6.16: the lookups compare string properties with ==.
// A group and a layout both hold the same entry objects; the layout gives
// each an offset from its base, and a cell is found in either by its
// label. After a cell is written through its own handle, restore_all() of
// the group sets it back to its start value, which the variable that made
// the cell then reads. The methods print what they do, and each step
// prints PASS with the values it read.

module test_class_handle_arrays_lookup;

  class entry;
    string label;
    int unsigned width;
    logic [63:0] value;
    logic [63:0] copy;
    logic [63:0] start;

    function new(string label = "entry", int unsigned width = 32);
      this.label = label;
      this.width = width;
      value = 0;
      copy = 0;
      start = 0;
    endfunction

    function string get_label();
      return label;
    endfunction

    function int unsigned get_width();
      return width;
    endfunction

    function void set_start(logic [63:0] v);
      start = v;
      value = v;
      copy = v;
    endfunction

    function logic [63:0] read();
      return value;
    endfunction

    function void write(logic [63:0] v);
      value = v;
    endfunction

    function void restore();
      value = start;
      copy = start;
    endfunction
  endclass

  class store;
    string label;
    int unsigned depth;
    int unsigned width;
    logic [31:0] words[256];

    function new(string label = "store", int unsigned depth = 256, int unsigned width = 32);
      this.label = label;
      this.depth = depth;
      this.width = width;
    endfunction

    function string get_label();
      return label;
    endfunction

    function void clear();
      for (int i = 0; i < 256; i++) begin
        words[i] = 0;
      end
    endfunction
  endclass

  class layout;
    string label;
    logic [63:0] base;
    int unsigned unit;
    entry cells[8];
    logic [63:0] cell_offsets[8];
    int n_cells;
    store stores[4];
    logic [63:0] store_offsets[4];
    int n_stores;

    function new(string label = "layout");
      this.label = label;
      base = 0;
      unit = 4;
      n_cells = 0;
      n_stores = 0;
    endfunction

    function void setup(logic [63:0] b, int unsigned u);
      base = b;
      unit = u;
      $display("LAYOUT: set up %s, base=0x%08h, unit=%0d", label, b, u);
    endfunction

    function logic [63:0] get_base();
      return base;
    endfunction

    function void place_cell(entry c, logic [63:0] offset);
      if (c != null && n_cells < 8) begin
        cells[n_cells] = c;
        cell_offsets[n_cells] = offset;
        n_cells = n_cells + 1;
        $display("LAYOUT: cell %s at offset 0x%04h", c.get_label(), offset);
      end
    endfunction

    function void place_store(store s, logic [63:0] offset);
      if (s != null && n_stores < 4) begin
        stores[n_stores] = s;
        store_offsets[n_stores] = offset;
        n_stores = n_stores + 1;
        $display("LAYOUT: store %s at offset 0x%04h", s.get_label(), offset);
      end
    endfunction

    function logic [63:0] address_of(string name);
      for (int i = 0; i < n_cells && i < 8; i++) begin
        if (cells[i].get_label() == name) begin
          return base + cell_offsets[i];
        end
      end
      return 0;
    endfunction

    function int cell_count();
      return n_cells;
    endfunction
  endclass

  class unit_group;
    string label;
    entry cells[8];
    int n_cells;
    store stores[4];
    int n_stores;
    layout main_layout;
    bit frozen;

    function new(string label = "group");
      this.label = label;
      n_cells = 0;
      n_stores = 0;
      main_layout = null;
      frozen = 0;
    endfunction

    function string get_label();
      return label;
    endfunction

    function layout new_layout(string name, logic [63:0] b, int unsigned u);
      layout lay;
      lay = new(name);
      lay.setup(b, u);
      if (main_layout == null) begin
        main_layout = lay;
      end
      $display("GROUP: made layout %s", name);
      return lay;
    endfunction

    function void add_cell(entry c);
      if (c != null && n_cells < 8) begin
        cells[n_cells] = c;
        n_cells = n_cells + 1;
        $display("GROUP: add cell %s", c.get_label());
      end
    endfunction

    function void add_store(store s);
      if (s != null && n_stores < 4) begin
        stores[n_stores] = s;
        n_stores = n_stores + 1;
        $display("GROUP: add store %s", s.get_label());
      end
    endfunction

    function int cell_count();
      return n_cells;
    endfunction

    function int store_count();
      return n_stores;
    endfunction

    function entry find_cell(string name);
      for (int i = 0; i < n_cells && i < 8; i++) begin
        if (cells[i].get_label() == name) begin
          return cells[i];
        end
      end
      return null;
    endfunction

    function void freeze();
      frozen = 1;
      $display("GROUP: frozen");
    endfunction

    function bit is_frozen();
      return frozen;
    endfunction

    function void restore_all();
      for (int i = 0; i < n_cells && i < 8; i++) begin
        cells[i].restore();
      end
      for (int i = 0; i < n_stores && i < 4; i++) begin
        stores[i].clear();
      end
      $display("GROUP: restored every cell and store");
    endfunction
  endclass

  unit_group grp;
  layout lay;
  entry mode_cell, flags_cell, level_cell;
  store fifo_store;
  int test_pass;

  initial begin
    logic [63:0] addr;
    entry found;
    test_pass = 1;

    $display("=== group of cells ===");

    grp = new("top");
    $display("made group %s", grp.get_label());

    // Step 1: a layout made by the group
    $display("--- Step 1: layout ---");
    lay = grp.new_layout("main", 64'h2400_0000, 4);
    if (lay != null && lay.get_base() == 64'h2400_0000 && grp.main_layout == lay) begin
      $display("PASS: layout base 0x%08h is the main layout", lay.get_base());
    end else begin
      $display("FAIL: layout");
      test_pass = 0;
    end

    // Step 2: cells added to the group
    $display("--- Step 2: cells in the group ---");
    mode_cell = new("mode", 32);
    mode_cell.set_start(32'h0000_0005);
    flags_cell = new("flags");
    flags_cell.set_start(32'h0000_0000);
    level_cell = new("level", 16);
    level_cell.set_start(16'h0000);

    grp.add_cell(mode_cell);
    grp.add_cell(flags_cell);
    grp.add_cell(level_cell);

    if (grp.cell_count() == 3 && flags_cell.get_width() == 32) begin
      $display("PASS: group has %0d cells", grp.cell_count());
    end else begin
      $display("FAIL: expected 3 cells, got %0d", grp.cell_count());
      test_pass = 0;
    end

    // Step 3: the same cells placed in the layout
    $display("--- Step 3: cells in the layout ---");
    lay.place_cell(mode_cell, 64'h0000);
    lay.place_cell(flags_cell, 64'h0008);
    lay.place_cell(level_cell, 64'h0010);

    if (lay.cell_count() == 3 && lay.cells[1] == grp.cells[1]) begin
      $display("PASS: layout has %0d cells, the same objects", lay.cell_count());
    end else begin
      $display("FAIL: expected the 3 cells of the group in the layout");
      test_pass = 0;
    end

    // Step 4: an address found by label
    $display("--- Step 4: address by label ---");
    addr = lay.address_of("flags");
    if (addr == 64'h2400_0008) begin
      $display("PASS: flags at 0x%08h", addr);
    end else begin
      $display("FAIL: expected 0x24000008, got 0x%08h", addr);
      test_pass = 0;
    end

    // Step 5: a store
    $display("--- Step 5: store ---");
    fifo_store = new("fifo", 64, 32);
    grp.add_store(fifo_store);
    lay.place_store(fifo_store, 64'h0800);

    if (grp.store_count() == 1 && grp.stores[1] == null) begin
      $display("PASS: group has %0d store, the next slot is null", grp.store_count());
    end else begin
      $display("FAIL: expected 1 store, got %0d", grp.store_count());
      test_pass = 0;
    end

    // Step 6: a cell found by label
    $display("--- Step 6: cell by label ---");
    found = grp.find_cell("level");
    if (found == level_cell && grp.find_cell("none") == null) begin
      $display("PASS: found cell '%s', width %0d", found.get_label(), found.get_width());
    end else begin
      $display("FAIL: cell 'level' not found");
      test_pass = 0;
    end

    // Step 7: a bit property set by a method
    $display("--- Step 7: freeze ---");
    grp.freeze();
    if (grp.is_frozen()) begin
      $display("PASS: group is frozen");
    end else begin
      $display("FAIL: group should be frozen");
      test_pass = 0;
    end

    // Step 8: restore through the group, read through the variable
    $display("--- Step 8: restore ---");
    mode_cell.write(32'h0000_ABCD);
    grp.restore_all();
    if (mode_cell.read() == 32'h0000_0005 && lay.cells[0].read() == 32'h0000_0005) begin
      $display("PASS: mode back to 0x%08h", mode_cell.read());
    end else begin
      $display("FAIL: expected 0x00000005, got 0x%08h", mode_cell.read());
      test_pass = 0;
    end

    $display("=== done ===");
    if (test_pass) begin
      $display("TEST PASSED");
    end else begin
      $display("TEST FAILED");
    end

    $finish;
  end
endmodule
