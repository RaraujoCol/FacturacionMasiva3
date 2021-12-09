        ALTER TABLE dbo.tmp_ventas ADD Devolucion INT 
        Update dbo.tmp_ventas set Devolucion = 0  
        UPDATE dbo.tmp_ventas set Devolucion = 1 WHERE Cantidad <0

    -- ----------------------------------------------------------------------------------------- 
    -- Recalculo de los totales de las facturas con producto devueltos 
    -- -----------------------------------------------------------------------------------------
   
     IF OBJECT_ID(N'dbo.tmp_ventas_TotalesDevolucion', N'U') IS NOT NULL  drop table  tmp_ventas_TotalesDevolucion

        Select * into tmp_ventas_TotalesDevolucion  from  
                (
                Select top 10000000  vn.CentroCos, vn.Consecutivo,  [Total Neto a Pagar] Total,  Dev.TotalDev,  min(vn.cantidad) devolucion 
                        from tmp_ventas vn
                                left join (
                                                Select CentroCos, Consecutivo, sum (  [Total Unidad IVA inc]  ) as TotalDev 
                                                        from tmp_ventas 
                                                                where devolucion = 0
                                                                GROUP by CentroCos, Consecutivo
                                        )  
                Dev on vn.Consecutivo = Dev.Consecutivo and vn.CentroCos = Dev.CentroCos

             --   where vn.dev = -1
            --    order by TotalDevolucion asc 

                  group by  vn.CentroCos, vn.Consecutivo,  [Total Neto a Pagar],  Dev.TotalDev
                ) 
                T

           delete from tmp_ventas_TotalesDevolucion where devolucion =1

           Select * from tmp_ventas_TotalesDevolucion
    

        Update tmp_ventas 
         set [Total Neto a Pagar] = td.TotalDev
         from tmp_ventas vnt inner join  tmp_ventas_TotalesDevolucion td 
          on vnt.CentroCos = td.CentroCos and vnt.Consecutivo = td.Consecutivo

