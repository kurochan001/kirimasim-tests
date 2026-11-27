config precompiled_crossed;
  design work.test_config_precompiled_transitive_cells;
  instance test_config_precompiled_transitive_cells.middle use middleLib.phase_enclosure;
  instance test_config_precompiled_transitive_cells.middle.west use cellsLib.phase_worker;
  instance test_config_precompiled_transitive_cells.middle.east use cellsLib.phase_worker;
  instance test_config_precompiled_transitive_cells.middle.west.implementation use eastLib.phase_leaf;
  instance test_config_precompiled_transitive_cells.middle.east.implementation use westLib.phase_leaf;
endconfig

config precompiled_local;
  design work.test_config_precompiled_transitive_cells;
  instance test_config_precompiled_transitive_cells.middle use middleLib.phase_enclosure;
  instance test_config_precompiled_transitive_cells.middle.west use cellsLib.phase_worker;
  instance test_config_precompiled_transitive_cells.middle.east use cellsLib.phase_worker;
  instance test_config_precompiled_transitive_cells.middle.west.implementation use westLib.phase_leaf;
  instance test_config_precompiled_transitive_cells.middle.east.implementation use eastLib.phase_leaf;
endconfig
