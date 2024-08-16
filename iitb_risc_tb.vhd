library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.iitb_risc_lib.all;

entity iitb_risc_tb is
end iitb_risc_tb;

architecture sim of iitb_risc_tb is
    
    signal number_of_cycles : integer := 10; 
    
    signal clock : std_logic := '0';
    signal reset : std_logic := '0';

begin
    inst_iitb_risc: entity work.iitb_risc 
    port map (
        -- clock and reset
        clock => clock,
        reset => reset
    );

    -- Clock generation process
    process
    begin
        while now < number_of_cycles*10 ns loop
            clock <= '0';
            wait for 5 ns;
            clock <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    process
    begin
        while now < number_of_cycles*10 ns loop
            reset <= '0';
            wait for 10 ns;
        end loop;
        wait;
    end process;
end sim;