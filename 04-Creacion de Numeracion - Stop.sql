
-- UPDATE tmp_ventas_numeracion  SET Numeracion  = 0 

Declare @id as int;
Declare @contador as int = 1;

DECLARE db_cursor CURSOR FOR 

SELECT Id  from tmp_ventas_numeracion  
    where Generado =      0  and NombreEmpresa = 'STOP'
  order by   fecha asc,  centrocos  asc , consecutivo asc 
OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @id  

WHILE @@FETCH_STATUS = 0  
BEGIN  

    print @id 
	  print @contador
	      
	  Update tmp_ventas_numeracion 
	     set numeracion = @contador , NUM =@contador    where id = @id 

       set @contador = @contador + 1

	   FETCH NEXT FROM db_cursor INTO @id
END

CLOSE db_cursor  
DEALLOCATE db_cursor 
