SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[sp_generarReporteDianYoyo] 
AS
Begin 

DECLARE 
   @NuevaNumeracion int, 
   @InicioBloque int ,
   @FinBloque int, 

    @Id_Factura int, 

    @NombreCliente  nvarchar(255),
	@CedulaCliente nvarchar(20),
	@consecutivo nvarchar(30),
	@centrocosto nvarchar(20),
    @TotalFactura NVARCHAR(200),
    @ciudad NVARCHAR(200),
    @Codigo_Municipio NVARCHAR(200),
    @Departamento NVARCHAR(100),

    @PLUProducto nvarchar(100),
    @NombreProducto NVARCHAR(255),
    @DescuentoLinea NVARCHAR(20),
    @Formulario NVARCHAR(40),
    @FechaInicio as NVARCHAR(20),
    @FechaFin as NVARCHAR(20),
    @ResolucionInicio as NVARCHAR(20),
    @ResolucionFin as NVARCHAR(20),
    @Prefijo as NVARCHAR(20),
    @TotalLinea as NVARCHAR(20),
    @TotalNetoFactura as NVARCHAR(20),
    @Cantidad as NVARCHAR(20),
    @FechaFactura as NVARCHAR(20),
    @FechaHoraFactura as NVARCHAR(20),

    @ContProductos int = 1,

    @ValorBase as DECIMAL(18,2),
    @DescuentoPorcentaje as DECIMAL(18,2),
    @Descuento as DECIMAL(18,2),

    @TotalProductosFactura int = 0,
    @NombreEmpresa  as NVARCHAR(30);



DECLARE cursor_Factura CURSOR
FOR  
Select    TOP 1000
        ventas.cedula,      ventas.[Nombre cliente] as nombreCliente,   ventas.Consecutivo  , 
        ventas.centrocos,   ltrim(rtrim(vn.Formulario)), 
        vn.FInicio  as FechaInicio,  vn.FFin as FechaFin ,
        vn.NPrefijo + ' '+vn.Rinicio as ResolucionInicio, vn.NPrefijo + ' '+vn.RFin as ResolucionFin,
        vn.NPrefijo, ventas.Fecha, [Total Neto a Pagar] as TotalFactura ,
        iif(charindex('STOP',Establecimiento)> 0,'STOP','YOYO') as NombreEmpresa ,
        m.ciudad, m.codigo_municipio, m.departamento, vn.Num
        

from  tmp_ventas  ventas left join tmp_resolucionesTienda rt on  ventas.CentroCos = rt.c_c
      left join DATAWH.dbo.tblTiendas t on ventas.CentroCos = t.CostoPOS
      left join tmp_Municipio m on ventas.CentroCos = m.almacen 
      left join tmp_ventas_numeracion vn on vn.CentroCos = ventas.CentroCos and vn.Consecutivo = ventas.Consecutivo
      -- where vn.NombreEmpresa = 'YOYO'  and dev is null  and  validacionCedula = 1 and  generado = 0
      -- where NombreEmpresa = 'STOP' and num in (33,101,144,167) 
      -- where Generado =      0  and NombreEmpresa = 'STOP'
      -- where NUM =8454  and NombreEmpresa = 'STOP'
      where Generado =  0  and NombreEmpresa = 'YOYO'

 group by
        ventas.cedula, ventas.[Nombre cliente] , ventas.Consecutivo , 
        ventas.centrocos , vn.Formulario, vn.FInicio , vn.FFin, vn.NPrefijo + ' '+vn.RFin, vn.NPrefijo + ' '+vn.Rinicio,
        vn.NPrefijo , ventas.Fecha , [Total Neto a Pagar], 
        iif(charindex('STOP',Establecimiento)> 0,'STOP','YOYO'),m.ciudad, m.codigo_municipio , m.departamento, 
        vn.num
    order by num asc 
      
OPEN cursor_Factura;
FETCH NEXT FROM cursor_Factura INTO 
    @CedulaCliente,
    @NombreCliente,
	@consecutivo,
	@centrocosto,
    @Formulario,
    @FechaInicio,
    @FechaFin,
    @ResolucionInicio,
    @ResolucionFin,
    @Prefijo,
    @FechaFactura,
    @TotalNetoFactura,
    @NombreEmpresa,
    @ciudad,
    @Codigo_Municipio,
    @Departamento,
    @NuevaNumeracion

WHILE @@FETCH_STATUS = 0
    BEGIN

    delete from tmp_reporteDian

    insert into  tmp_reporteDian
        (linea)
        Select 'InIcIo'

    insert into  tmp_reporteDian (linea)
    Select 'InicioFactura'

    SET @InicioBloque = SCOPE_IDENTITY()

 If @NombreEmpresa = 'STOP'
  Begin 
    insert into  tmp_reporteDian (linea)
    Select '@COMEN STOP S.A.S'

	insert into  tmp_reporteDian (linea)
    Select '@COMEN 890911898'
 End 
  else 
  BEGIN
    insert into  tmp_reporteDian (linea)
    Select '@COMEN YOYO S.A.S'

	insert into  tmp_reporteDian (linea)
    Select '@COMEN 900486370'

  End 

	insert into  tmp_reporteDian (linea)
    Select '@COMEN CR 59 A 14 95'

	insert into  tmp_reporteDian (linea)
    Select '@COMEN impuestosstop@stop.com.co'

	insert into  tmp_reporteDian (linea)
    Select '@USERS jgarces'

	insert into  tmp_reporteDian (linea)
    Select '@DOPDF SI'

	insert into  tmp_reporteDian (linea)
    Select '@TIPOD FACTURA-FAC'

	insert into  tmp_reporteDian (linea)
    Select '@DOPDF NO'

	insert into  tmp_reporteDian (linea)
    Select '@COPIA 1'

	insert into  tmp_reporteDian (linea)
    Select '@RESOL RESOLUCIÓN AUTORIZACIÓN FACTURACIÓN ELECTRÓNICA '+ isnull(@Formulario,'Falta')

    insert into  tmp_reporteDian (linea)
    Select '@RESOL DEL '+@FechaInicio+' HASTA '+@FechaFin+' DEL NÚMERO '+@ResolucionInicio+' AL '+@ResolucionFin

    insert into  tmp_reporteDian (linea)
    Select '@FAB05 '+ isnull(@Formulario,'Falta')

    insert into  tmp_reporteDian (linea)
    Select '@FAB07 '+ @FechaInicio

    insert into  tmp_reporteDian (linea)
    Select '@FAB08 '+ @FechaFin

    insert into  tmp_reporteDian (linea)
    Select '@FAB10 '+ @Prefijo 

    insert into  tmp_reporteDian (linea)
    Select '@FAB11 '+ substring( @ResolucionInicio ,  charindex ( ' ' , @ResolucionInicio ) + 1,100)
    
    insert into  tmp_reporteDian (linea)
    Select '@FAB12 '+ substring( @ResolucionFin ,  charindex ( ' ' , @ResolucionFin ) + 1,100)

    insert into  tmp_reporteDian (linea)
    Select '@P0000 '

    insert into tmp_reporteDian (linea)
    Select '@P0002 '

    insert into tmp_reporteDian (linea)
    Select '@P0029 '

    insert into tmp_reporteDian (linea)
    Select '@P0030 '

    insert into tmp_reporteDian (linea)
    Select '@P0100 '

    insert into tmp_reporteDian (linea)
    Select '@P0101 '

    insert into tmp_reporteDian (linea)
    Select '@P0102 '

    insert into tmp_reporteDian (linea)
    Select '@P0103 '

    insert into tmp_reporteDian (linea)
    Select '@P0104 '

    insert into tmp_reporteDian (linea)
    Select '@P0105 '

    insert into tmp_reporteDian (linea)
    Select '@P0106 '

    insert into tmp_reporteDian (linea)
    Select '@P0107 '

    insert into tmp_reporteDian (linea)
    Select '@P0108 '

    insert into tmp_reporteDian (linea)
    Select '@P0003 Juan Diego Garces'

    insert into tmp_reporteDian (linea)
    Select ''

    Select @TotalProductosFactura = count(*) from tmp_ventas where Consecutivo = @consecutivo

    --        insert into  tmp_reporteDian (linea)
    --        Select '@P0015 ' + [dbo].[spf_facturacion_CantidadenLetras](@TotalFactura) 

        set @ContProductos = 1;
        DECLARE cursor_Detalles_Factura CURSOR
            FOR 
                Select  
                plu ,[nombre del articulo] as NombreArticulo,  [Descuento % Linea] as DescuentoLinea,
                [Total Unidad IVA inc] as TotalLinea  , Cantidad , 
                [Fecha-Hora] as FechaHora,
                [Total condi comercial]  +   [Total Unidad IVA inc] as ValorBase,
                cast ([Total condi comercial] / (  ( [Total condi comercial]  +   [Total Unidad IVA inc])   *1.0) *100  as decimal (18,0)) as DescuentoPorcentaje ,
                [Total condi comercial] as Descuento
                from tmp_ventas  where consecutivo =  @consecutivo   AND CentroCos = @centrocosto and Devolucion = 0
         
            OPEN cursor_Detalles_Factura;
                FETCH NEXT FROM cursor_Detalles_Factura INTO 
                    @PLUProducto,
                    @NombreProducto,
                    @DescuentoLinea,
                    @TotalLinea,
                    @Cantidad,
                    @FechaHoraFactura,
                    @ValorBase,
                    @DescuentoPorcentaje,
                    @Descuento
                   
                    WHILE @@FETCH_STATUS = 0
                        BEGIN
                            Declare @TotalDescuentoFactura as int = 0;
                            Select   @TotalDescuentoFactura = sum([Total condi comercial] )  from  
                                  tmp_ventas  where consecutivo =  @consecutivo  AND CentroCos = @centrocosto AND Devolucion = 0

                            -- Contador de producto
                            insert into tmp_reporteDian (linea)
                             Select '@FAV02 '+ CAST( @ContProductos AS NVARCHAR(20))

                            -- Cantidad por producto 
                            insert into tmp_reporteDian (linea)
                            Select '@FAV04 '+ @Cantidad

                            -- Unidad de medida del producto 
                            insert into tmp_reporteDian (linea)
                            Select '@FAV05 94'

                            --  Valor total de la linea 
                            insert into tmp_reporteDian (linea)
                            Select '@FAV06 ' + @TotalLinea

                            -- Valor articulo servicio    
                            insert into tmp_reporteDian (linea)
                            Select '@FAW03 '+ cast( @ValorBase as nvarchar(20))

                            insert into tmp_reporteDian (linea)
                            Select '@FAW04 COP'

                            insert into tmp_reporteDian (linea)
                            Select '@FAW05 01'
                            -- 
                            insert into tmp_reporteDian (linea)
                            Select '@FBE02 '+ CAST( @NuevaNumeracion AS nvarchar(50))


--                            IF @DescuentoPorcentaje <> 0
--                                BEGIN                        
--                                    insert into tmp_reporteDian (linea)
--                                    Select '@FBE03 false'
--                                END
--                            ELSE
--                                BEGIN
--                                    insert into tmp_reporteDian (linea)
--                                    Select '@FBE03 true'
--                            End 


                        insert into tmp_reporteDian (linea)
                        Select '@FBE03 false'


                        insert into tmp_reporteDian (linea)
                        Select '@FBE04 '

                        insert into tmp_reporteDian (linea)
                        Select '@FBE05 '+  cast(  @DescuentoPorcentaje as nvarchar(20))

                        insert into tmp_reporteDian (linea)
                        Select '@FBE06 '+    cast(  @Descuento as nvarchar(20))

                        insert into tmp_reporteDian (linea)
                        Select '@FBE08 ' + cast(  @ValorBase as nvarchar(20))
        
                        insert into tmp_reporteDian (linea)
                        Select '@FAX02 0 '

                        insert into tmp_reporteDian (linea)
                        Select '@FAX05 ' +   cast(  @ValorBase as nvarchar(20)) 

                        insert into tmp_reporteDian (linea)
                        Select '@FAX07 0'

                        insert into tmp_reporteDian (linea)
                        Select '@FAX14 0'

                        insert into tmp_reporteDian (linea)
                        Select '@FAX16 01'

                        insert into tmp_reporteDian (linea)
                        Select '@FAX17 IVA'

                        insert into tmp_reporteDian (linea)
                        Select '@FAZ02 ' + @NombreProducto

                        insert into tmp_reporteDian (linea)
                        Select '@FAZ03 '+ @Cantidad

                        insert into tmp_reporteDian (linea)
                        Select '@FAZ04 ' + @NombreProducto

                        insert into tmp_reporteDian (linea)
                        Select '@FAZ05 ' + @NombreProducto

                        insert into  tmp_reporteDian (linea)
                        Select '@FAZ10 ' +  @PLUProducto
        
                        insert into  tmp_reporteDian (linea)
                        Select '@FAZ12 ' 

                        insert into  tmp_reporteDian (linea)
                        Select '@FBB02 ' + cast(  @ValorBase as nvarchar(20))

                        insert into  tmp_reporteDian (linea)
                        Select '@FBB04 ' + @Cantidad

                        insert into  tmp_reporteDian (linea)
                        Select '@FBB05 94'
                               
                        FETCH NEXT FROM cursor_Detalles_Factura INTO 
                        @PLUProducto, 
                        @NombreProducto,
                        @DescuentoLinea,
                        @TotalLinea,
                        @Cantidad,
                        @FechaHoraFactura,
                        @ValorBase,
                        @DescuentoPorcentaje,
                        @Descuento
                  
                        Set @ContProductos = @ContProductos +1
                    END;

                        insert into tmp_reporteDian (linea)
                        Select '@P0028 '

                        insert into tmp_reporteDian (linea)
                        Select '@FBA06 195'

                        insert into tmp_reporteDian (linea)
                        Select '@FBA08 '

                        insert into tmp_reporteDian (linea)
                        Select '@FAD02 10'

                        insert into tmp_reporteDian (linea)
                        Select '@FAD04 '

                        insert into tmp_reporteDian (linea)
                        Select '@FAD05 '+@Prefijo + cast( @NuevaNumeracion as nvarchar(20))

                        insert into tmp_reporteDian (linea)
                        Select '@FAD07 1'

                        insert into tmp_reporteDian (linea)
                        Select '@FAD09 '+@FechaFactura

                        insert into tmp_reporteDian (linea)
                        Select '@FAD10 '+  cast(  FORMAT ( DATEADD(HOUR, 2, @FechaHoraFactura  ), 'yyyy-MM-dd HH:mm:ss' )   as nvarchar(50))
                                       
                        insert into tmp_reporteDian (linea)
                        Select '@FAD11 '+@FechaFactura

                        insert into tmp_reporteDian (linea)
                        Select '@FAD12 03'
                        
                        insert into tmp_reporteDian (linea)
                        Select '@FAD15 COP'

                        insert into tmp_reporteDian (linea)
                        Select '@FAD16 '+ cast( @TotalProductosFactura as nvarchar(30))

                        insert into tmp_reporteDian (linea)
                        Select '@FAF02 '

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ02 1'

                        IF @NombreEmpresa = 'STOP'
                          Begin
                                insert into tmp_reporteDian (linea)
                                Select '@FAJ06 STOP S.A.S'
                          END
                          ELSE
                          Begin
                                insert into tmp_reporteDian (linea)
                                Select '@FAJ06 YOYO S.A.S'
                          END

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ09 '+@Codigo_Municipio

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ10 '+@ciudad

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ73 '

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ11 '+@Departamento

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ12 '+ SUBSTRING(@Codigo_Municipio,1,2)

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ14 CR 59 A 14 95'

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ16 CO'

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ17 COLOMBIA'

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ18 es'

                        IF @NombreEmpresa = 'STOP'
                          Begin
                            insert into tmp_reporteDian (linea)
                            Select '@FAJ20 STOP S.A.S'

                            insert into tmp_reporteDian (linea)
                            Select '@FAJ21 890911898'

                            insert into tmp_reporteDian (linea)
                            Select '@FAJ24 5'

                        END
                         ELSE
                         BEGIN
                            insert into tmp_reporteDian (linea)
                            Select '@FAJ20 YOYO S.A.S'

                            insert into tmp_reporteDian (linea)
                            Select '@FAJ21 900486370'


                            insert into tmp_reporteDian (linea)
                            Select '@FAJ24 0'
                         End 

                        

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ25 31'

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ26 R-99-PN'

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ29 '+@Codigo_Municipio

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ30 '+ @ciudad

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ67 50024'

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ31 '+@Departamento

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ32 '+SUBSTRING(@Codigo_Municipio,1,2)

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ36 CO'

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ37 COLOMBIA'

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ38 es'

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ34 CR 59 A 14 95'

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ40 1'

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ41 IVA'

                        If @NombreEmpresa = 'STOP'
                             Begin 
                                insert into tmp_reporteDian (linea)
                                Select '@FAJ43 STOP S.A.S'

                                insert into tmp_reporteDian (linea)
                                Select '@FAJ44 890911898'
                            End 
                        else
                            BEGIN
                                insert into tmp_reporteDian (linea)
                                Select '@FAJ43 YOYO S.A.S'

                                insert into tmp_reporteDian (linea)
                                Select '@FAJ44 900486370'
                            end


                        insert into tmp_reporteDian (linea)
                        Select '@FAJ47 5'

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ48 31'

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ50 '+ @Prefijo

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ51 '

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ69 6090200'

                        insert into tmp_reporteDian (linea)
                        Select '@FAJ71 impuestosstop@stop.com.co'

                        insert into tmp_reporteDian (linea)
                        Select '@FAK02 1'

                        insert into tmp_reporteDian (linea)
                        Select '@FAK04 '+ @CedulaCliente

                       insert into tmp_reporteDian (linea)
                       Select '@FAK06 '+ @NombreCliente

                     --   insert into tmp_reporteDian (linea)
                    --   Select '@FAK09 '+@Codigo_Municipio

                    --    insert into tmp_reporteDian (linea)
                    --    Select '@FAK10 '+@ciudad

                    --    insert into tmp_reporteDian (linea)
                    --    Select '@FAK57 '

                    --    insert into tmp_reporteDian (linea)
                    --    Select '@FAK11 '+@Departamento

                    --    insert into tmp_reporteDian (linea)
                    --    Select '@FAK12 '+SUBSTRING(@Codigo_Municipio,1,2)

                    --    insert into tmp_reporteDian (linea)
                    --    Select '@FAK14 '

                    --    insert into tmp_reporteDian (linea)
                    --    Select '@FAK16 CO'

                    --    insert into tmp_reporteDian (linea)
                    --    Select '@FAK17 Colombia'

                    --    insert into tmp_reporteDian (linea)
                    --    Select '@FAK18 es'

                        insert into tmp_reporteDian (linea)
                        Select '@FAK20 ' +@NombreCliente

                        insert into tmp_reporteDian (linea)
                        Select '@FAK21 ' +@CedulaCliente

                        insert into tmp_reporteDian (linea)
                        Select '@FAK25 '

                        insert into tmp_reporteDian (linea)
                        Select '@FAK26 R-99-PN'

                        insert into tmp_reporteDian (linea)
                        Select '@FAK30 '+@ciudad

                        insert into tmp_reporteDian (linea)
                        Select '@FAK40 1'

                        insert into tmp_reporteDian (linea)
                        Select '@FAK41 IVA'

                        insert into tmp_reporteDian (linea)
                        Select '@FAK43 '+ @NombreCliente

                        insert into tmp_reporteDian (linea)
                        Select '@FAK44 '+ @CedulaCliente

                        insert into tmp_reporteDian (linea)
                        Select '@FAK47 '

                        insert into tmp_reporteDian (linea)
                        Select '@FAK48 13'

                        insert into tmp_reporteDian (linea)
                        Select '@FAK53 '

                        insert into tmp_reporteDian (linea)
                        Select '@FAK55 '

                        insert into tmp_reporteDian (linea)
                        Select '@FAK60 '

                        insert into tmp_reporteDian (linea)
                        Select '@FAK62 '+@CedulaCliente

                        insert into tmp_reporteDian (linea)
                        Select '@FAK63 '

                        insert into tmp_reporteDian (linea)
                        Select '@FAN02 1'

                        insert into tmp_reporteDian (linea)
                        Select '@FAN03 10'

                        insert into tmp_reporteDian (linea)
                        Select '@FAN04 '+@FechaFactura

                        insert into tmp_reporteDian (linea)
                        Select '@FAS02 0'

                        insert into tmp_reporteDian (linea)
                        Select '@FAS05 ' +   CAST(  @TotalNetoFactura   AS nvarchar(50)  ) 

                        insert into tmp_reporteDian (linea)
                        Select '@FAS07 0'

                        insert into tmp_reporteDian (linea)
                        Select '@FAS14 0'

                        insert into tmp_reporteDian (linea)
                        Select '@FAS16 01'

                        insert into tmp_reporteDian (linea)
                        Select '@FAS17 IVA'

                        insert into tmp_reporteDian (linea)
                        -- Select '@FAU02 '+  CAST(  @TotalNetoFactura + @TotalDescuentoFactura  AS nvarchar(50)  ) 
                        Select '@FAU02 '+  CAST(  @TotalNetoFactura   AS nvarchar(50)  ) 

                        insert into tmp_reporteDian (linea)
                        Select '@FAU04 ' +  CAST(  @TotalNetoFactura + @TotalDescuentoFactura  AS nvarchar(50)  ) 

                        insert into tmp_reporteDian (linea)
                        Select '@FAU06 '+@TotalNetoFactura

                        insert into tmp_reporteDian (linea)
                        Select '@FAU14 '+@TotalNetoFactura

                        insert into tmp_reporteDian (linea)
                        Select '@FAI02 '+ CAST( @NuevaNumeracion AS nvarchar(50))


                CLOSE cursor_Detalles_Factura;
            DEALLOCATE cursor_Detalles_Factura;

    insert into  tmp_reporteDian
    (linea)
    Select 'FinFactura'
    SET @FinBloque = SCOPE_IDENTITY()

    Update tmp_reporteDian 
      Set Empresa = @NombreEmpresa
    where id BETWEEN @InicioBloque and @FinBloque

    insert into  tmp_reporteDian
  (linea)
  Select 'FinDeDocumento'

    DECLARE @cmd VARCHAR(8000)

    print 'Fin documento'
    print  cast( @FechaFactura as NVARCHAR(25))
    IF @NombreEmpresa = 'STOP'
        Begin
            SET @cmd = 'bcp "Select Linea from  BDSTOP.dbo.tmp_reporteDian where Empresa= '+CHAR(39)+'STOP'+CHAR(39)+' OR Empresa is null order by id asc" queryout "\\stopnet\ftp\Carpetas\reporteDian\FacturacionDiaSinIva2\Stop_devolucion\Stop-'+CAST(@NuevaNumeracion AS nvarchar(50))+'-'+@centrocosto +'-'+ @consecutivo+'-'+cast( @FechaFactura as NVARCHAR(25))+'.txt"  -U sa -P aSeBeQar81$   -S 172.16.1.22\bi    -t -c  -C 0x0c0a /t"|" /T'
            Exec xp_cmdshell @cmd   
            print @cmd
        END
    ELSE
        BEGIN
            SET @cmd = 'bcp "Select Linea from  BDSTOP.dbo.tmp_reporteDian where Empresa= '+CHAR(39)+'YOYO'+CHAR(39)+' OR Empresa is null order by id asc" queryout "\\stopnet\ftp\Carpetas\reporteDian\FacturacionDiaSinIva2\Yoyo_devolucion\Yoyo-'+CAST(@NuevaNumeracion AS nvarchar(50))+'-'+@centrocosto+ +'-'+ @consecutivo+'-'+cast( @FechaFactura as NVARCHAR(25))+'.txt"  -U sa -P aSeBeQar81$   -S 172.16.1.22\bi    -t -c  -C 0x0c0a /t"|" /T'
            Exec xp_cmdshell @cmd 
        End 

    Update tmp_ventas_numeracion 
      set generado = 1 where num = @NuevaNumeracion and NombreEmpresa = @NombreEmpresa

        FETCH NEXT FROM cursor_Factura INTO 
			@CedulaCliente,
            @NombreCliente,
			@consecutivo,
			@centrocosto,
            @Formulario,
            @FechaInicio,
            @FechaFin,
            @ResolucionInicio,
            @ResolucionFin,
            @Prefijo,
            @FechaFactura,
            @TotalNetoFactura,
            @NombreEmpresa,
            @ciudad,
            @Codigo_Municipio,
            @Departamento,
            @NuevaNumeracion
    END;

CLOSE cursor_Factura;

DEALLOCATE cursor_Factura;
 	
End
GO
