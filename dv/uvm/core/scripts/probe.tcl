database -open waves -into waves.shm -default
probe -create rv0_core_tb_top.DUT -depth all -tasks -functions -uvm -packed 4k -unpacked 16k -all -memories -database waves
