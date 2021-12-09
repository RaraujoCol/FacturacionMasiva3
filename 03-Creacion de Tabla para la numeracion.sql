

   IF OBJECT_ID(N'dbo.tmp_ventas_numeracion', N'U') IS NOT NULL  drop table  dbo.tmp_ventas_numeracion

-- Esta pendiende lo de la devolucion porque esta duplicando los encabezados

Select * into tmp_ventas_numeracion  from  ( 
Select    
        ventas.cedula,  ventas.[Nombre cliente] as nombreCliente, ventas.consecutivo , 
        ventas.centrocos,   ltrim(rtrim(rt.Formulario)) Resolucion,   rt.Fecha_I as FechaInicio, rt.fechavto as FechaFin ,
        rt.Prefijo + ' '+Desde as ResolucionInicio, rt.Prefijo + ' '+Hasta as ResolucionFin,
        rt.Prefijo, Consecutivo as Consecutivo1, Fecha, [Total Neto a Pagar] as TotalFactura ,
        iif(charindex('STOP',Establecimiento)> 0,'STOP','YOYO') as NombreEmpresa ,
        m.ciudad, m.codigo_municipio, m.departamento , 0 as numeracion, 
        'xxxxxxxxxxxxxxx' as formulario , 'xxxxxxxxxxxxxxx' as RInicio, 'xxxxxxxxxxxxxxx' as RFin , 
        'xxxxxxxxxxxxxxx' as FInicio    , 'xxxxxxxxxxxxxxx' as FFin ,   'xxxxxxxxxxxxxxx' as NPrefijo,
        max(ventas.devolucion) as devolucion,     0 as Generado ,
        ISNUMERIC(cedula) as validacionCedula 
      
from  tmp_ventas  ventas left join tmp_resolucionesTienda rt on  ventas.CentroCos = rt.c_c
      left join DATAWH.dbo.tblTiendas t on ventas.CentroCos = t.CostoPOS
      left join tmp_Municipio m on ventas.CentroCos = m.almacen 

 group by 
        ventas.cedula, ventas.[Nombre cliente] , ventas.consecutivo , ventas.centrocos , 
        rt.Formulario, rt.Fecha_I , rt.fechavto, rt.Prefijo + ' '+Desde, rt.Prefijo + ' '+Hasta,
        rt.Prefijo, Consecutivo , Fecha , [Total Neto a Pagar], 
        iif(charindex('STOP',Establecimiento)> 0,'STOP','YOYO'),m.ciudad, m.codigo_municipio , m.departamento ,
         ISNUMERIC(cedula)  

) t

        ALTER TABLE dbo.tmp_ventas_numeracion ADD Id INT IDENTITY(1,1)
        ALTER TABLE dbo.tmp_ventas_numeracion ADD Num INT
        ALTER TABLE dbo.tmp_ventas_numeracion ADD Dev INT


        Update tmp_ventas_numeracion
        set 
                formulario = '18764021794086',
                RInicio = '1',
                RFin = '50000',
                FInicio='2021-11-25',
                FFin = '2022-11-25' ,
                NPrefijo = 'RCS'
        where NombreEmpresa = 'STOP'


        Update tmp_ventas_numeracion
        set 
                formulario = '18764021795464',
                RInicio = '1',
                RFin = '50000',
                FInicio='2021-11-26',
                FFin = '2022-11-26' ,
                NPrefijo = 'RCY'
        where NombreEmpresa = 'YOYO'
