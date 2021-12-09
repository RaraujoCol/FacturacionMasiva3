-- Se borra los archivos temporales 
IF OBJECT_ID(N'dbo.tmp_ventas', N'U') IS NOT NULL  drop table  tmp_ventas
IF OBJECT_ID(N'dbo.tmp_ventas2', N'U') IS NOT NULL  drop table  tmp_ventas2

Select * into tmp_ventas2  from  
(
SELECT   DETALLE.GL_NUMERO'Consecutivo cegid'
,DETALLE.GP_SOUCHE'Centro de costo'
,DETALLE.GP_CAISSE'Caja'
--,SUM(convert (bigint, DETALLE.GL_TOTALHTDEV))'Base impuesto DEV'
,MAX(convert (bigint, DETALLE.GP_TOTALHT))'Base impuesto'
,SUM(CONVERT (bigint,GL_TOTALTAXE1))'IVA'
,MAX(convert (bigint, PAGO.GP_TOTALTTCDEV))'Total Neto a Pagar'
,MP_LIBELLE 'Medio de pago'
,PAGO.GPE_MODEPAIE AS Codigo_pago
,SUM (convert (bigint, PAGO.GPE_MONTANTECHE))'Total Medio de pago'
,CONVERT (INT ,GL_TOTALTTC) AS 'Total Unidad IVA inc'
,convert (bigint,GL_REMISELIBRE2)'Total condi comercial'
,GL_NATUREPIECEG AS TipoFAC
,PAGO.GP_TYPECOMPTA AS TipoConta
,TIENDAS.ET_LIBREET6 AS Marca
,TIENDAS.ET_LIBREET1 AS Zona
,CONVERT (INT ,GL_QTEFACT) Cantidad
,DETALLE.GL_NUMLIGNE 'Codigo linea'
,GL_CODEARTICLE 'Referencia'
,GA_LIBELLE'Nombre del articulo'
,GL_REFARTBARRE AS Plu
,GP_VENTEEXPORT 'Venta sin IVA (X)'
,GL_TYPEREMISE'Tipo Descuento Linea cod'
,GL_TOTREMLIGNE'Total Desc Com Linea'
,CONVERT (VARCHAR, DETALLE.GL_DATEPIECE ,111 ) AS Fecha
,Clientes.T_PRENOM,Clientes.T_LIBELLE  , Clientes.T_PASSEPORT, 
 GL_DATECREATION AS 'Fecha-Hora'
,GL_MOTIFMVT AS Motivo
,PAGO.GP_TICKETANNULE AS Anulado
,GL_REMISELIGNE 'Descuento % Linea'
FROM [172.16.1.2,1433].Y2_C4_PROD.DBO.GCREGLEMENTFO PAGO
 left  JOIN [172.16.1.2,1433].Y2_C4_PROD.DBO.GCLIGNEARTDIM DETALLE ON PAGO.GP_NUMERO = DETALLE.GL_NUMERO AND PAGO.GP_SOUCHE = DETALLE.GL_SOUCHE
 left  JOIN [172.16.1.2,1433].Y2_C4_PROD.DBO.ETABLISS TIENDAS ON DETALLE.GL_SOUCHE =TIENDAS.ET_ETABLISSEMENT 
 left  JOIN [172.16.1.2,1433].Y2_C4_PROD.DBO.TIERS Clientes on Clientes.T_TIERS = detalle.GP_TIERS
Where GL_DATEPIECE >='2021-12-03' AND GL_DATEPIECE <='2021-12-03' and DETALLE.GP_SOUCHE <> '999' and
 DETALLE.GP_SOUCHE <> '998' 
   AND PAGO.GPE_MODEPAIE NOT IN ('150','61','177','158') AND PAGO.GP_TYPECOMPTA ='TIC' AND GL_NATUREPIECEG='FFO' and PAGO.GP_TYPECOMPTA ='TIC' 
 and GP_VENTEEXPORT = 'x'   AND PAGO.GP_TICKETANNULE <> 'X'
--where GL_DATEPIECE='2020-11-21' and GL_NATUREPIECEG='FFO'
GROUP BY DETALLE.[GL_NUMERO], DETALLE.[GL_SOUCHE], DETALLE.[GL_DATEPIECE], PAGO.[GPE_NUMERO], DETALLE.[GP_SOUCHE], DETALLE.[GP_CAISSE], PAGO.[MP_LIBELLE], PAGO.[GPE_MODEPAIE],GL_NATUREPIECEG,TIENDAS.ET_LIBREET6,TIENDAS.ET_LIBREET1,PAGO.GP_TYPECOMPTA
,GL_TOTREMLIGNE ,GL_TYPEREMISE ,GL_QTEFACT,GL_FAMILLENIV2, GL_CODEARTICLE ,GA_LIBELLE, GL_REFARTBARRE ,GP_VENTEEXPORT, GL_NUMLIGNE, GL_TOTALTTC, GL_REMISELIBRE2 ,Clientes.T_PRENOM,Clientes.T_LIBELLE  , Clientes.T_PASSEPORT,
GL_MOTIFMVT, PAGO.GP_TICKETANNULE, GL_DATECREATION, GL_REMISELIGNE
--   order by [Centro de costo] ASC
) t

-- Se genera la tabla temporal con la información de las facturas y los productos 
Select * into tmp_ventas  from (
SELECT  [Consecutivo cegid] as Consecutivo
      ,[Centro de costo] as CentroCos
      ,[Caja]
      ,[Base impuesto]
      ,[IVA]
      ,[Total Neto a Pagar]
      ,[Total Unidad IVA inc]
      ,[Total condi comercial]
      ,[TipoFAC]
      ,[TipoConta]
      ,[Marca] as Establecimiento
      ,[Zona]
      ,[Cantidad]
      ,[Codigo linea]
      ,[Referencia]
      ,[Nombre del articulo]
      ,[Plu]
      ,[Venta sin IVA (X)]
      ,[Tipo Descuento Linea cod]
      ,[Total Desc Com Linea]
      ,[Fecha]
      ,CONCAT([T_PRENOM], ' ',[T_LIBELLE]) AS [Nombre Cliente]
      ,[T_PASSEPORT] as cedula,
      [Descuento % Linea],
      [Fecha-Hora]
  FROM [BDSTOP].[dbo].[tmp_ventas2]
  group by [Consecutivo cegid]
      ,[Centro de costo]
      ,[Caja]
      ,[Base impuesto]
      ,[IVA]
      ,[Total Neto a Pagar]
      ,[Total Unidad IVA inc]
      ,[Total condi comercial]
      ,[TipoFAC]
      ,[TipoConta]
      ,[Marca]
      ,[Zona]
      ,[Cantidad]
      ,[Codigo linea]
      ,[Referencia]
      ,[Nombre del articulo]
      ,[Plu]
      ,[Venta sin IVA (X)]
      ,[Tipo Descuento Linea cod]
      ,[Total Desc Com Linea]
      ,[Fecha]
      ,CONCAT([T_PRENOM], ' ',[T_LIBELLE])
      ,[T_PASSEPORT], [Descuento % Linea], [Fecha-Hora]
) t

-- Corrección del valor de las bolsas
    Update  tmp_ventas
    set [Total Desc Com Linea] = 0 ,
      [Total Unidad IVA inc]= 0, 
      [Total condi Comercial] = 51
    where  PLU like '%BOL%' 
        AND [Total Desc Com Linea] = 0 
                and [Total Unidad IVA inc]= -51
                and [Total condi Comercial] = 0

-- Corección del valor de las bolsas 
    Update  tmp_ventas
    set [Total Desc Com Linea] = 0 ,
      [Total Unidad IVA inc]= 0, 
      [Total condi Comercial] = 51
    where  PLU like '%BOL%' 
        AND [Total Desc Com Linea] = 51 
                and [Total Unidad IVA inc]= 0
                and [Total condi Comercial] = 0

-- Corrección de los archiculos en blanco 
   Delete from tmp_ventas where plu  = '' and [Total Unidad IVA inc] = 0
--

--Select top 1000 * from tmp_ventas

--Select [Consecutivo cegid], [Centro de costo],[Fecha] from tmp_ventas2   
--  where  Fecha = '2021/11/19'
--  group by
--[Consecutivo cegid], [Centro de costo],[Fecha]


--Select [Consecutivo cegid], [Centro de costo],[Fecha] from tmp_ventas2   
--  where  Fecha = '2021/11/20'
--  group by
--[Consecutivo cegid], [Centro de costo],[Fecha]


Update tmp_ventas 
 set fecha = replace(fecha,'/','-')

 
UPDATE tmp_ventas
   SET cedula = LTRIM(RTRIM(cedula))


UPDATE tmp_ventas
   SET [Nombre Cliente] = LTRIM(RTRIM([Nombre Cliente]))


UPDATE tmp_ventas
   SET cedula = REPLACE(cedula,'.','')

Update tmp_ventas
  set cedula = cast( cast(cedula as bigint) as nvarchar (30))
  where isnumeric(cedula) = 1


-- Query para identificar que los encabezados que no concuerden con los detalles 


Select *  from (
Select Enc.[centrocos], Enc.[Consecutivo], 
    Enc.[Total Neto a Pagar] as TotalEncabezado, sum(Det.[Total Unidad IVA inc]) as TotalDetalle  from
  (
     Select [Consecutivo], [CentroCos] , [Total Neto a Pagar]from 
     tmp_ventas group by [Consecutivo], [CentroCos], [Total Neto a Pagar] 
  ) as Enc
   left join tmp_ventas Det on Enc.[Consecutivo] = Det.[Consecutivo] 
     and Enc.[CentroCos] = Det.[CentroCos]  


     group by Enc.[CentroCos], Enc.[Consecutivo], Enc.[Total Neto a Pagar]
) as Tabla where tabla.TotalDetalle <> Tabla.TotalEncabezado 
 order by TotalEncabezado asc 



-- Corregir los encabezados

Update tmp_ventas
 set [Total Neto a Pagar] = T1.TotalDetalle
 from tmp_ventas INNER join 
 (
Select [Centrocos], [Consecutivo], TotalDetalle  from (
Select Enc.[Centrocos], Enc.[Consecutivo], 
    Enc.[Total Neto a Pagar] as TotalEncabezado, sum(Det.[Total Unidad IVA inc]) as TotalDetalle  from
  (
     Select [Consecutivo], [Centrocos] , [Total Neto a Pagar]from 
     tmp_ventas group by [Consecutivo], [Centrocos], [Total Neto a Pagar] 
  ) as Enc
   left join tmp_ventas Det on Enc.[Consecutivo] = Det.[Consecutivo] 
     and Enc.[Centrocos] = Det.[Centrocos]  
     group by Enc.[Centrocos], Enc.[Consecutivo], Enc.[Total Neto a Pagar]
) as Tabla where tabla.TotalDetalle <> Tabla.TotalEncabezado 

)  T1 on tmp_ventas.[Centrocos] = t1.[Centrocos] 
    and tmp_ventas.[Consecutivo] = t1.[Consecutivo] 



Select 
[Fecha],[Total Neto a Pagar],[Centrocos],[Consecutivo]
 from tmp_ventas 
  group by  [Fecha],[Total Neto a Pagar],[Centrocos],[Consecutivo]
order by [Total Neto a Pagar] asc



--  Validacion de que ningun producto de error de division por 0

      Select  CentroCos, Consecutivo,
      plu ,[nombre del articulo] as NombreArticulo,  [Descuento % Linea] as DescuentoLinea,
      [Total Unidad IVA inc] as TotalLinea  , Cantidad , 
      [Fecha-Hora] as FechaHora,
      [Total condi comercial]  +   [Total Unidad IVA inc] as ValorBase,
      cast ([Total condi comercial] / (  ( [Total condi comercial]  +   [Total Unidad IVA inc])   *1.0) *100  as decimal (18,0)) as DescuentoPorcentaje ,
      [Total condi comercial] as Descuento

    from tmp_ventas 
    order by CentroCos asc , Consecutivo asc 


-- ---------------------------------------------------------------



BOL458
418559
421005

402605
BOL459
416407
417302
419125
