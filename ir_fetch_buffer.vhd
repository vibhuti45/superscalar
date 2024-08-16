library ieee;
use std.textio.all; 
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.iitb_risc_lib.all;

entity ir_fetch_buffer is
    port (
        -- Clock and Reset
        clock  : in std_logic;
        reset  : in std_logic;

        -- Instruction Input
        pc_in           : in word_array(ir_fetch_buffer_size-1 downto 0);
        ir_in           : in word_array(ir_fetch_buffer_size-1 downto 0);

        -- Instruction Output
        ir_op           : out word_array(ir_fetch_buffer_size-1 downto 0);
        pc_op           : out word_array(ir_fetch_buffer_size-1 downto 0)
    );
end ir_fetch_buffer;

architecture behavorial of ir_fetch_buffer is
    type ifb_entry is record
        instruction: std_logic_vector(15 downto 0);
        program_counter : std_logic_vector(15 downto 0);
    end record;

    type ifb_array is array (0 to ir_fetch_buffer_size - 1) of ifb_entry;

    signal ir_fetch_buffer: ifb_array := (others => (instruction => x"A000", program_counter => x"0000"));

begin
    ifb_write_process:process(clock)
    begin
        if reset = '1' then
            reset_loop: for i in 0 to ir_fetch_buffer_size - 1 loop
                ir_fetch_buffer(i).instruction <= x"0000";
                ir_fetch_buffer(i).program_counter <= x"0000";
            end loop reset_loop;
        else
            if falling_edge(clock) then
                write_loop: for i in 0 to ir_fetch_buffer_size - 1 loop
                    ir_fetch_buffer(i).instruction <= ir_in(i);
                    ir_fetch_buffer(i).program_counter <= pc_in(i);
                end loop write_loop;
            end if;
        end if;
    end process ifb_write_process;

    ifb_read_process:process(clock)
    begin
        read_loop: for i in 0 to ir_fetch_buffer_size - 1 loop
            ir_op(i) <= ir_fetch_buffer(i).instruction;
            pc_op(i) <= ir_fetch_buffer(i).program_counter;
        end loop read_loop;
    end process ifb_read_process;
end architecture behavorial;