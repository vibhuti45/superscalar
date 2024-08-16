library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bit16_adder is
    port (
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);

        Sum : out std_logic_vector(15 downto 0)
    );
end bit16_adder;

architecture behavorial of bit16_adder is
begin
    Sum <= A + B;
end architecture behavorial;
