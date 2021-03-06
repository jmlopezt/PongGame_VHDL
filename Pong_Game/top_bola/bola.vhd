

-- Descripci�n de una bola cuadrada que se mueve hacia arriba y hacia abajo, 
-- respetando los m�rgenes superior e inferior de la pantalla.
--
-- Basado en ejemplo de Hamblen, J.O., Hall T.S., Furman, M.D.:
-- Rapid Prototyping of Digital Systems : SOPC Edition, Springer 2008.
-- (Cap�tulo 10) 


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;

ENTITY bola IS
	PORT(
		Red,Green,Blue  		: OUT std_logic;
	    vs 						: IN std_logic;
	    up					   	: IN std_logic;
	    down				   	: IN std_logic;
	    up_R					: IN std_logic;  -- Sube la pala derecha
	    down_R				   	: IN std_logic;  -- Baja la pala derecha 
		pixel_Y, pixel_X 		: IN std_logic_vector(9 downto 0)
		);
END bola;

architecture funcional of bola is
	-- BOLA
	SIGNAL Bola_on 			: std_logic;
	SIGNAL Desplaza_Bola_Y	: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL Bola_Y  			: std_logic_vector(9 DOWNTO 0);
	SIGNAL Desplaza_Bola_X	: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL Bola_X  			: std_logic_vector(9 DOWNTO 0);
	CONSTANT Size			: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(8,10);
	
	-- PALA IZQUIERDA
	SIGNAL   Pala_on 		: std_logic;
	SIGNAL 	Desplaza_Pala_Y	: std_logic_vector(9 DOWNTO 0);
	SIGNAL 	 Pala_Y  		: std_logic_vector(9 DOWNTO 0):=CONV_STD_LOGIC_VECTOR(200,10);
	CONSTANT Pala_X			: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(10,10);
	CONSTANT Size_Pala_X	: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(8,10);
	CONSTANT Size_Pala_Y	: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(100,10);
	
	--PALA DERECHA
	SIGNAL   Pala_R_on 			: std_logic;
	SIGNAL 	Desplaza_Pala_R_Y	: std_logic_vector(9 DOWNTO 0);
	SIGNAL 	 Pala_R_Y  			: std_logic_vector(9 DOWNTO 0):=CONV_STD_LOGIC_VECTOR(200,10);
	CONSTANT Pala_R_X			: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(629,10);
	CONSTANT Size_Pala_R_X		: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(6,10);
	CONSTANT Size_Pala_R_Y		: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(15,10);
	
BEGIN

Red		<= Bola_on or Pala_R_on;    -- Pala derecha ROJA
Green	<= Bola_on or Pala_on ;    --Pala izquierda azul
Blue	<= Bola_on or Pala_on ;     -- Bola blanca


Dibujar_Bola: Process (Bola_Y,Bola_X, pixel_X, pixel_Y)
BEGIN
	-- Chequear coordenadas X e Y para identificar el area de la bola
	-- Poner Bola_on a '1' para visualizar la bola
	IF  (Bola_X <= pixel_X + Size) AND
		(Bola_X + Size >= pixel_X) AND
		(Bola_Y <= pixel_Y + Size) AND
		(Bola_Y + Size >= pixel_Y ) THEN
		
		Bola_on <= '1';
	ELSE
		Bola_on <= '0';
	END IF;
END process Dibujar_Bola;

Dibujar_Pala: Process (Pala_Y, pixel_X, pixel_Y)
BEGIN
	-- ESTE PROCESO SOLO DIBUJA LA PALA IZQUIERDA
	-- Chequear coordenadas X e Y para identificar el area de la PALA IZQUIERDA
	-- Poner Pala_on a '1' para visualizar la pala
	IF  (Pala_X <= pixel_X + Size_Pala_X) AND
		(Pala_X + Size_Pala_X >= pixel_X) AND
		(Pala_Y <= pixel_Y + Size_Pala_Y) AND
		(Pala_Y + Size_Pala_Y >= pixel_Y ) THEN
		
		Pala_on <= '1';
	ELSE
		Pala_on <= '0';
	END IF;
END process Dibujar_Pala;

Dibujar_Pala_R: Process (Pala_R_Y, pixel_X, pixel_Y)
BEGIN
	-- ESTE PROCESO SOLO DIBUJA LA PALA DERECHA
	-- Chequear coordenadas X e Y para identificar el area de la PALA DERECHA
	-- Poner Pala_on a '1' para visualizar la PALA DERECHA
	IF  (Pala_R_X <= pixel_X + Size_Pala_R_X) AND
		(Pala_R_X + Size_Pala_R_X >= pixel_X) AND
		(Pala_R_Y <= pixel_Y + Size_Pala_R_Y) AND
		(Pala_R_Y + Size_Pala_R_Y >= pixel_Y ) THEN
		
		Pala_R_on <= '1';
	ELSE
		Pala_R_on <= '0';
	END IF;
END process Dibujar_Pala_R;

Mover_Bola: PROCESS (vs)
BEGIN
	-- Actualizar la posici�n de la bola en cada refresco de pantalla
	IF vs'event and vs = '1' THEN
		-- Detectar los bordes superior e inferior de la pantalla
			IF Bola_Y  >= CONV_STD_LOGIC_VECTOR(479,10) - Size THEN
				Desplaza_Bola_Y <= CONV_STD_LOGIC_VECTOR(-5,10);
			ELSIF  Bola_Y <= Size  THEN
				Desplaza_Bola_Y <= CONV_STD_LOGIC_VECTOR(5,10);
			END IF;
			-- Calcular la siguiente posicion de la bola
			Bola_Y 	  	<= Bola_Y + Desplaza_Bola_Y;
	
	-- Detectar los bordes laterales de la pantalla
	--		IF Bola_X  >= CONV_STD_LOGIC_VECTOR(639,10) - Size THEN
	--			Desplaza_Bola_X <= CONV_STD_LOGIC_VECTOR(-5,10);
				
	--		ELSIF  Bola_X <= Size  THEN
	--			Desplaza_Bola_X <= CONV_STD_LOGIC_VECTOR(5,10);
				
				
	--		END IF;
			-- Calcular la siguiente posicion de la bola
			-- NO quiero detectar los bordes laterales para saber quien gana
			Bola_X 	  	<= Bola_X + Desplaza_Bola_X;
			
	END IF;
	
		-- Rebote con la pala Izquierda
	
		IF vs'event and vs = '1' THEN
		IF (Bola_X <= Pala_X + Size_Pala_X + Size) AND
			(Bola_Y + Size + Size_Pala_Y >= Pala_Y ) AND
			(Bola_Y <= Pala_Y + Size_Pala_Y + Size ) THEN
			
			Desplaza_Bola_X <= CONV_STD_LOGIC_VECTOR(5,10);
		END IF;
		
				-- Rebote con la PALA DERECHA
		
		IF (Bola_X + Size + Size_Pala_R_X >= Pala_R_X) AND
			(Bola_Y + Size + Size_Pala_R_Y >= Pala_R_Y) AND
			(Bola_Y  <= Pala_R_Y + Size_Pala_R_Y + Size ) THEN
			
			Desplaza_Bola_X <= CONV_STD_LOGIC_VECTOR(-5,10);
		END IF;
		
	END IF;

	
END process Mover_Bola;

Mover_Pala: PROCESS (vs)
BEGIN
	-- Actualizar la posici�n de la PALA IZQUIERDA en cada refresco de pantalla
	IF vs'event and vs = '1' THEN
		-- Mover la Pala Izquierda
			IF Pala_Y  >  Size_Pala_Y and up='0' THEN
				Desplaza_Pala_Y <= CONV_STD_LOGIC_VECTOR(-1,10);
			ELSIF  Pala_Y < CONV_STD_LOGIC_VECTOR(479,10) - Size_Pala_Y and down='0'  THEN
				Desplaza_Pala_Y <= CONV_STD_LOGIC_VECTOR(1,10);
			else
				Desplaza_Pala_Y <= CONV_STD_LOGIC_VECTOR(0,10);
			END IF;
			-- Calcular la siguiente posicion de la PALA IZQUIERDA
			Pala_Y 	  	<= Pala_Y + Desplaza_Pala_Y;
	END IF;
	
END process Mover_Pala;

Mover_Pala_R: PROCESS (vs)
BEGIN
	-- Actualizar la posici�n de la PALA DERECHA en cada refresco de pantalla
	IF vs'event and vs = '1' THEN
		-- Mover la Pala DERECHA
			IF Pala_R_Y  >  Size_Pala_R_Y and up_R='0' THEN
				Desplaza_Pala_R_Y <= CONV_STD_LOGIC_VECTOR(-7,10);
			ELSIF  Pala_R_Y < CONV_STD_LOGIC_VECTOR(479,10) - Size_Pala_R_Y and down_R='0'  THEN
				Desplaza_Pala_R_Y <= CONV_STD_LOGIC_VECTOR(7,10);
			else
				Desplaza_Pala_R_Y <= CONV_STD_LOGIC_VECTOR(0,10);
			END IF;
			-- Calcular la siguiente posicion de la PALA DERECHA
			Pala_R_Y 	  	<= Pala_R_Y + Desplaza_Pala_R_Y;
	END IF;
	
END process Mover_Pala_R;


-- DOS PALAS DISTINTO TAMA�O Y VELOCIDAD

END funcional;
