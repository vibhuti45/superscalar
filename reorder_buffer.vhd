library ieee;
use std.textio.all; 
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.iitb_risc_lib.all;

entity reorder_buffer is
    port (
        -- clock reset
        clock : in std_logic;
        reset : in std_logic;

        -- from exicution unit 
        valid : in bit_array(total_no_pipelines - 1 downto 0);
        PC    : in word_array(total_no_pipelines - 1 downto 0);
        value : in word_array(total_no_pipelines - 1 downto 0);
        address: in word_array(total_no_pipelines - 1 downto 0);
        mem_reg: in bit_array(total_no_pipelines - 1 downto 0);

        -- from RF
        pc_in : in word_array(rs_input_size - 1 downto 0);
        pc_in_valid : in bit_array(rs_input_size - 1 downto 0);

        valid_op : out std_logic;
        data     : out std_logic_vector(15 downto 0);
        address_op : out std_logic_vector(15 downto 0);
        mem_reg_op : out std_logic
        
    );
end reorder_buffer;

architecture behavorial of reorder_buffer is
    type rob_entry is record
        valid : std_logic;
        PC    : std_logic_vector(15 downto 0);
        value : std_logic_vector(15 downto 0);
        address : std_logic_vector(15 downto 0);
        mem_reg : std_logic; -- '0' address | '1' tag 
        ready : std_logic;
    end record;

    type rob_array is array (0 to rob_size - 1) of rob_entry;

    signal reorder_buffer : rob_array:=(others =>(valid => '0', PC => X"0000", value => x"0000", address => x"0000", mem_reg => '0', ready => '0'));
    signal head : integer := 0;
    signal tail : integer := 0;

begin
    rob_process:process(clock)
    begin
        if reset = '1' then
            reset_loop: for i in 0 to rob_size - 1 loop
                reorder_buffer(i).valid <= '0';
                reorder_buffer(i).PC <= x"0000";
                reorder_buffer(i).value <= x"0000";
                reorder_buffer(i).address <= x"0000";
                reorder_buffer(i).mem_reg <= '0';
                reorder_buffer(i).ready <= '0';
            end loop;
        else
            if falling_edge(clock) then
                pc_load_loop: for i in 0 to rs_input_size - 1 loop
                    if pc_in_valid(i) = '1' and reorder_buffer((head + i) mod rob_size).valid = '0' then
                        reorder_buffer((head + i) mod rob_size).PC <= pc_in(i);
                        reorder_buffer((head + i) mod rob_size).valid <= '1';
                        reorder_buffer((head + i) mod rob_size).ready <= '0';
                        head <= (head + i + 1) mod rob_size;
                    end if;
                end loop;

                load_value_loop: for i in 0 to total_no_pipelines - 1 loop
                    for j in 0 to rob_size - 1 loop
                        if reorder_buffer(j).PC = PC(i) and valid(i) = '1' and reorder_buffer(j).valid = '1' then
                            reorder_buffer(j).value <= value(i);
                            reorder_buffer(j).address <= address(i);
                            reorder_buffer(j).mem_reg <= mem_reg(i);
                            reorder_buffer(j).ready <= '1';
                        end if;
                    end loop;
                end loop;

                if reorder_buffer(tail).ready = '1' and reorder_buffer(tail).valid = '1' then
                    valid_op <= '1';
                    data     <= reorder_buffer(tail).value;
                    address_op <= reorder_buffer(tail).address;
                    mem_reg_op <= reorder_buffer(tail).mem_reg;
                    reorder_buffer(tail).valid <= '0';
                    reorder_buffer(tail).ready <= '0';
                    tail <= (tail + 1) mod rob_size;
                else
                    valid_op <= '0';
                    data     <= x"0000";
                    address_op <= x"0000";
                    mem_reg_op <= '0';
                end if;
            end if;
        end if;
    end process rob_process;

    -- sim_process:process(clock)
    -- variable out_line :line;
    -- variable cycle_count: integer:= 0;
    -- file output_file : text open write_mode is "../../sim/reorder_buffer.txt";
    -- begin
    --     if falling_edge(clock) then
    --         cycle_count := cycle_count + 1; 
    --         writeline(output_file, out_line);
    --         write(output_file, "Cycle : "); 
    --         write(output_file, integer'image(cycle_count));  
    --         writeline(output_file, out_line);
    --         write(output_file, "ROB  |  PC  | addr | value | MR | R | V "); 
    --         writeline(output_file, out_line);
    --         for i in 0 to rob_size - 1 loop
    --             write(output_file, integer'image(i));
    --             write(output_file, "    |  "); 
    --             write(output_file, integer'image(to_integer(unsigned(reorder_buffer(i).PC))));
    --             write(output_file, "   |  "); 
    --             write(output_file, integer'image(to_integer(unsigned(reorder_buffer(i).address))));
    --             write(output_file, "  |  "); 
    --             write(output_file, integer'image(to_integer(unsigned(reorder_buffer(i).value))));
    --             write(output_file, "   |   "); 
    --             write(output_file, to_string_std_logic(reorder_buffer(i).mem_reg));
    --             write(output_file, "  |   "); 
    --             write(output_file, to_string_std_logic(reorder_buffer(i).ready));
    --             write(output_file, "   |  "); 
    --             write(output_file, to_string_std_logic(reorder_buffer(i).valid));
    --             writeline(output_file, out_line);
    --         end loop;
    --         write(out_line, LF); 
    --     end if;
    -- end process sim_process;

end architecture behavorial;