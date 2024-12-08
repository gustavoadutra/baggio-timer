library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity contador is
    Port(
        clock : in STD_LOGIC;
        saida : out STD_LOGIC_VECTOR (6 downto 0) := "0000001"; -- Saída para o display
        selector : out STD_LOGIC_VECTOR(3 downto 0) := "1110";  -- Controla quais displays são ativados
        botaoA : in STD_LOGIC;                                  -- Botão A
        botaoB : in STD_LOGIC;                                  -- Botão B
        botaoC : in STD_LOGIC;                                  -- Botão C
        botaoD : in STD_LOGIC;                                  -- Botão D
        botaoE : in STD_LOGIC;                                  -- Botão E
        led : out STD_LOGIC                                     -- LED de controle
    );
end contador;

--100Mhz

architecture Behavioral of contador is

	signal contador : integer range 0 to 100e4 := 0;             --Contador que conta até 100e4, 1 centésimo
	signal segundo1 : integer range 0 to 0 := 0;                 --Conta as dezenas de segundos
	signal segundo0 : integer range 0 to 12 := 0;                --Conta as unidades de segundos
	signal decimo : integer range 0 to 9 := 0;                   --Conta os décimos de segundos
	signal centesimo : integer range 0 to 9 := 0;                --Conta os centésimos de segundos
	signal conta_ate4 : integer range 0 to 4 := 0;               --Conta até 4 para demultiplexar os displays
	signal entrada : integer range 0 to 9 := 0;                  --Sinal que recebe que número deve ser exibido no display
	signal clk50Khz : STD_LOGIC := '0';                          --Clock de 50KHz
	signal contA : integer range 0 to 100e6;                     --Conta até 1 segundo para o botão A
	signal flagA : STD_LOGIC;                                    --Flag de quando A foi pressionado
	signal flagC : STD_LOGIC;                                    --Flag de quando C foi pressionado
	signal btA   : STD_LOGIC;                                    --Saída do debouce para o botão A
	signal btB   : STD_LOGIC;                                    --Saída do debouce para o botão B
	signal btC   : STD_LOGIC;                                    --Saída do debouce para o botão C
	signal btD   : STD_LOGIC;                                    --Saída do debouce para o botão D
	signal btE   : STD_LOGIC;                                    --Saída do debouce para o botão E 

	component debounce is
		generic (max : integer := 10e6); -- 1 milh�o = 10ms em clock de 100Mhz
		Port ( 
			clk : in  STD_LOGIC;
			botao : in  STD_LOGIC;
			result : out  STD_LOGIC
		);
		end component;

	component display is
		Port(
			e : in integer range 0 to 15;
			d : out STD_LOGIC_VECTOR(6 downto 0)
		);
	end component;

begin

	u1 : display port map(entrada, saida);
	dA : debounce port map(clk, botaoA, btA);
	dB : debounce port map(clk, botaoB, btB);
	dC : debounce port map(clk, botaoC, btC);
	dD : debounce port map(clk, botaoD, btD);
	dE : debounce port map(clk, botaoE, btE);

	process(clock)
	begin
		if rising_edge(clock) then

			if btB = '0' then                             --0 - Testa se o botão B está pressionado, se NÃO:

				if contador>=100e4 then                      --A - Testa se o contador contou 1 centésimo
					contador <= 0;                            --A - Se contou, zera o contador para recomeçar
				
					if centesimo=9 then                       --B - Testa se os centésimos estão em 9
						centesimo <= 0;                         --B - Se sim, zera os centésimos

						if decimo=9 then                        --C - Testa se os décimos estão em 9
							decimo <= 0;                          --C - Se sim, zera os décimos

							if segundo0=9 then                    --D - Testa se o 1º segundos estão em 9
								segundo0 <= 0;                      --D - Se sim, zera o 1º segundos

								if segundo1=9 then                  --E - Testa se o 2º segundos estão em 9
									segundo1 <= 0;                    --E - Se sim, zera o 2º segundos
								else
									segundo1 <= segundo1 + 1;         --E - Soma o 2º segundos se não estiver em 9
								end if;

							else
								segundo0 <= segundo0 + 1;           --D - Soma o 1º segundos se não estiver em 9
							end if;

						else
							decimo <= decimo+1;                   --C - Soma os décimos se não estiver em 9
						end if;

					else
						centesimo <= centesimo+1;               --B - Soma os centésimos se não estiver em 9
					end if;

				else
					contador <= contador + 1;                 --A - Soma o contador se não estiver em 100e4
				end if;

			else
				contador <= 0;                              --Se o botão B está pressionado, zera o contador
			end if; 

		end if;
	end process;


	process(clock)                 --Produz um clock de 50KHz
	begin
		if rising_edge(clock) then

			if cont = 10e3 then
				cont <= 0;
				clk50Khz <= not clk50Khz;
			else
				cont <= cont +1;
			end if;

		end if;
	end process;


	--DIGITS
	-- __ __   __ __   __ __   __ __
	-- |___|   |___|   |___|   |___|
	-- |___|   |___|   |___|   |___|
	--   3       2       1       0



	process(clk50Khz)
	begin
		if rising_edge(clk50Khz) then

			if btB = '0' then               --Verifica se o botão B está pressionado

				if conta_ate4=4 then          --Verifica se o sinal está em 4, se SIM:
					conta_ate4 <= 0;            --zera o sinal
					selector <= "0111";         --ativa o dígito 3
					entrada <= segundo1;        --envia ao dígito o 2º segundos
				else                          --,se NÃO

					if conta_ate4=3 then	        --Verifica se o sinal está em 3, se SIM:
						selector <= "1011";         --ativa o dígito 2
						entrada <= segundo0;        --envia ao dígito o 1º segundos

					elsif conta_ate4=2 then       --Se NÃO, testa se o sinal está em 2, se SIM:
						selector <= "1101";         --ativa o dígito 1
						entrada <= decimo;          --envia ao dígito os décimos

					else                          --, se NÃO:
						selector <= "1110";         --ativa o dígito 0
						entrada <= centesimo;       --envia ao dígito os centésimos
					end if;

				conta_ate4 <= conta_ate4 + 1;  --em todos os casos a não ser sinal=4 somará 1 ao sinal
				end if;
			
			else
				selector <="1111";             --Se o botão B está pressionado, apaga todos os displays
			end if;

		end if;
	end process;




	

	process (btA)                      --Quando o botão A for pressionado o contA é zerado
	begin
		if rising_edge(btA) then
			contA <= 0;
		end if;
	end process;

	process (btC)                      --Quando o botão C for pressionado o contC é zerado
	begin
		if rising_edge(btC) then
			contC <= 0;
		end if;
	end process;

	process (btD)                       --Quando o botão D for pressionado é decrementado 1 às
	begin                               --unidades de segundos
		if rising_edge(btD) then
				segundo0 <= segundo0 - 1;
		end if;
	end process;

	process (btE)                       --Quando o botão E for pressionado é somado 1 às
	begin                               --unidades de segundos
		if rising_edge(btE) then
				segundo0 <= segundo0 + 1;
		end if;
	end process;





	process(clk)
	begin
			if rising_edge(clk) then

				if contA = 100e6 then              --A - Teste se contA contou 1 segundo, se SIM:

					if btA = '1' then								 --B - Testa se o botão A está pressionado, se SIM:
						segundo0 <= segundo0 + 3;      --Soma 3 unidades às unidades de segundos
					end if;
				
				else                               --Se não contou um segundo,
					contA <= contA + 1;              --Soma um ao contA
				end if;



				if contC = 100e6 then              --A - Teste se contC contou 1 segundo, se SIM:

					if btC = '1' then								 --B - Testa se o botão C está pressionado, se SIM:

						if segundo1 = 0 then           --C - Testa se as dezenas de segundo são 0, se SIM:
							segundo0 = 0;                     --zera as unidades de segundos
							decimo = 0;                       --zera os décimos de segundos
							centesimo =0;                     --zera os centésimos de segundos
						
						else                           --C - se NÃO:
							segundo1 <= segundo1 - 1;      		--Decremente 1 das dezenas de segundos

						end if;

					end if;
				
				else                               --Se não contou um segundo,
					contC <= contC + 1;              --Soma um ao contC
				end if;
				

			end if;
	end process;

end Behavioral;
