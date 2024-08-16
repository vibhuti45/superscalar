library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.iitb_risc_lib.all;

entity data_memory is
    port (
        clock : in std_logic;
        
        address_read : in std_logic_vector(15 downto 0);
        data_output  : out std_logic_vector(15 downto 0);

        address_write : in std_logic_vector(15 downto 0);
        data_in       : in std_logic_vector(15 downto 0);
        write_en      : in std_logic
    );
end data_memory;

architecture behavioral of data_memory is
    type memoryType is array (0 to 2**16 - 1) of std_logic_vector(15 downto 0);
    signal data_memory: memoryType:=(others => x"0000");

begin
    memory_read:process(address_read)
    begin
        data_output <= data_memory(to_integer(unsigned(address_read)));
    end process memory_read;

    memory_write: process(clock)
    begin
        if falling_edge(clock) then
            if write_en = '1' then
                data_memory(to_integer(unsigned(address_write))) <= data_in;
            end if;
        end if;
    end process memory_write;
end behavioral;