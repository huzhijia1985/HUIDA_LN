 select a.t$ctyp,a.产品类型,a.t$csel,a.t$dsca,nvl(t1.期初结存数量,0) 期初结存数量,nvl(t2.成品入库数量,0) 成品入库数量,nvl(t3.采购入库数量,0) 采购入库数量,
                   nvl(t8.完工数量,0) 完工数量,
                   nvl(t5.调拨入库数量,0) 调拨入库,nvl(t6.销售退货入库数量,0) 销售退货,nvl(t7.销售出库数量,0) 销售出库,
                   nvl(t9.调拨出库数量,0) 调拨出库,
                   nvl(t2.成品入库数量,0)+ nvl(t3.采购入库数量,0)+nvl(t8.完工数量,0)+nvl(t5.调拨入库数量,0) 成品总计入库数量,
                   nvl(t7.销售出库数量,0)- nvl(t6.销售退货入库数量,0) 成品总计出库,
                   nvl(t1.期初结存数量,0)+（(nvl(t2.成品入库数量,0)+ nvl(t3.采购入库数量,0)+nvl(t8.完工数量,0)+nvl(t5.调拨入库数量,0)-nvl(t9.调拨出库数量,0))
                   - (nvl(t7.销售出库数量,0)+ nvl(t6.销售退货入库数量,0))
                   ) 期末结存
                   from (  select distinct d.t$csel,d.t$dsca,c.t$ctyp,g.t$dsca 产品类型  from twhinr110150 a
                   left join twhina112150 b on a.t$cwar = b.t$cwar and a.t$item = b.t$item
                   left join ttcibd001150 c on a.t$item = c.t$item
                   left join ttcmcs022150 d on c.t$csel = d.t$csel 
                   left join ttccus029150  e on e.t$item = a.t$item
                   left join ttccus027150  f on e.t$xsqd = f.t$xsqd
                   left join ttcmcs015150  g on c.t$ctyp = g.t$ctyp
                   where d.t$csel <> ' ' AND c.t$ctyp <> ' ' 
                   and e.t$xsqd  in (select regexp_substr('Q04', '[^,]+', 1, level) orgid  from dual  
                                            connect by level <= regexp_count('Q04','[^,]+') )
                    order by t$csel asc ) a

             left join ( select a.t$csel,a.t$ctyp,sum(t$qhnd) 期初结存数量 from
                          (select A.*
                            from  (select a.t$item,a.t$cwar,a.t$seqn,c.t$ctyp,d.t$csel,a.t$qhnd,a.t$trdt  from twhinr110150 a
                             left join ttcibd001150 c on a.t$item = c.t$item
                             left join ttcmcs022150 d on c.t$csel = d.t$csel
                              left join ttccus029150  e on e.t$item = a.t$item

                             where d.t$csel <> ' ' AND c.t$ctyp <> ' '  
                             and e.t$xsqd  in (select regexp_substr('Q04', '[^,]+', 1, level) orgid  from dual
                              connect by level <= regexp_count('Q04','[^,]+') )
                             and a.t$cwar in (select regexp_substr('101001', '[^,]+', 1, level) orgid  from dual 
                                                     connect by level <= regexp_count('101001','[^,]+'))
                             and  to_date(NEW_TIME(a.t$trdt,'PST','GMT')) <to_date('2019-09-01','yyyy-mm-dd')
                             and  a.t$phtr = 1 
                             order by a.t$item asc ,a.t$cwar asc , d.t$csel asc ,a.t$trdt  asc) A,
                     (select * from 
                     ( select a.*, row_number()over(partition by t$item,t$cwar order by t$trdt desc, t$seqn desc) rn 
                     from (select a.t$item,a.t$cwar,a.t$seqn ,a.t$phtr,d.t$csel,c.t$ctyp,a.t$qhnd,a.t$trdt  from twhinr110150 a
                     left join ttcibd001150 c on a.t$item = c.t$item
                     left join ttcmcs022150 d on c.t$csel = d.t$csel
                     left join ttccus029150  e on e.t$item = a.t$item
                     where d.t$csel <> ' ' AND c.t$ctyp <> ' '  
                     and e.t$xsqd  in (select regexp_substr('Q04', '[^,]+', 1, level) orgid  from dual
                       connect by level <= regexp_count('Q04','[^,]+') )
                     and a.t$cwar in (select regexp_substr('101001', '[^,]+', 1, level) orgid  from dual 
                     connect by level <= regexp_count('101001','[^,]+'))
                             and  to_date(NEW_TIME(a.t$trdt,'PST','GMT')) <to_date('2019-09-01','yyyy-mm-dd')
                             and  a.t$phtr = 1 )a)a
                     where a.rn = 1) B
                          where A.t$item = B.t$item and a.t$cwar = b.t$cwar and A.t$trdt = B.t$trdt and a.t$seqn = b.t$seqn order by A.t$item ) a  group by a.t$csel,a.t$ctyp

                       ) t1 on a.t$csel = t1.t$csel and a.t$ctyp = t1.t$ctyp

             left join (select d.t$csel,c.t$ctyp,sum(a.t$qstk) 成品入库数量 from twhinr110150 a

                           left join ttcibd001150 c on a.t$item = c.t$item
                           left join ttcmcs022150 d on c.t$csel = d.t$csel
                           left join twhinh200150 e on a.t$orno = e.t$orno and a.t$cwar = e.t$stco
                           left join ttccus029150  f on f.t$item = a.t$item
                           where d.t$csel <>  ' ' AND c.t$ctyp <> ' '
                            and f.t$xsqd in (select regexp_substr('Q04', '[^,]+', 1, level) orgid
                                      from dual
                       connect by level <= regexp_count('Q04','[^,]+') )
                           and a.t$cwar in (select regexp_substr('101001', '[^,]+', 1, level) orgid
                            from dual connect by level <= regexp_count('101001','[^,]+'))
                            and ( to_date(NEW_TIME(a.t$trdt,'PST','GMT')) >= to_date('2019-09-01','yyyy-mm-dd')
                                  and  to_date(NEW_TIME(a.t$trdt,'PST','GMT')) <= to_date('2019-09-02','yyyy-mm-dd'))
                           and e.t$seri in   ('M01','M03','M06','T22','M07','M08','M11','M13','M15','M16','M18')
                           and a.t$koor in (36) and a.t$kost in (3)
                           and  a.t$phtr = 1 
                           group by d.t$csel,c.t$ctyp order by  t$csel asc ) t2 on a.t$csel = t2.t$csel  and a.t$ctyp = t2.t$ctyp

              left join (select d.t$csel,c.t$ctyp,sum(a.t$qstk) 采购入库数量 from twhinr110150 a

                           left join ttcibd001150 c on a.t$item = c.t$item
                           left join ttcmcs022150 d on c.t$csel = d.t$csel
                           left join ttccus029150  e on e.t$item = a.t$item
                           where d.t$csel <> ' ' AND c.t$ctyp <> ' ' 
                           and e.t$xsqd  in (select regexp_substr('Q04', '[^,]+', 1, level) orgid
                                      from dual
                       connect by level <= regexp_count('Q04','[^,]+') )
                           and a.t$cwar in (select regexp_substr('101001', '[^,]+', 1, level) orgid
                            from dual connect by level <= regexp_count('101001','[^,]+'))
                            and ( to_date(NEW_TIME(a.t$trdt,'PST','GMT')) >= to_date('2019-09-01','yyyy-mm-dd')
                                  and  to_date(NEW_TIME(a.t$trdt,'PST','GMT')) <= to_date('2019-09-02','yyyy-mm-dd'))
                           and a.t$koor in (2) and a.t$kost in (3)
                           and  a.t$phtr = 1 
                           group by d.t$csel,c.t$ctyp  order by  t$csel asc ) t3 on a.t$csel = t3.t$csel and a.t$ctyp = t3.t$ctyp

              left join (select d.t$csel,c.t$ctyp,sum(a.t$qstk) 完工数量 from twhinr110150 a

                           left join ttcibd001150 c on a.t$item = c.t$item
                           left join ttcmcs022150 d on c.t$csel = d.t$csel
                           left join ttccus029150  e on e.t$item = a.t$item
                           where d.t$csel <> ' ' AND c.t$ctyp <> ' ' 
                           and e.t$xsqd  in (select regexp_substr('Q04', '[^,]+', 1, level) orgid
                                      from dual
                       connect by level <= regexp_count('Q04','[^,]+') )
                           and a.t$cwar in (select regexp_substr('101001', '[^,]+', 1, level) orgid
                            from dual connect by level <= regexp_count('101001','[^,]+'))
                            and ( to_date(NEW_TIME(a.t$trdt,'PST','GMT')) >= to_date('2019-09-01','yyyy-mm-dd')
                                  and  to_date(NEW_TIME(a.t$trdt,'PST','GMT')) <= to_date('2019-09-02','yyyy-mm-dd'))
                           and a.t$koor in (1) and a.t$kost in (3)
                           and  a.t$phtr = 1 
                           group by d.t$csel,c.t$ctyp  order by  t$csel asc ) t8 on a.t$csel = t8.t$csel and a.t$ctyp = t8.t$ctyp

              left join (select d.t$csel,c.t$ctyp,sum(a.t$qstk) 调拨入库数量 from twhinr110150 a

                           left join ttcibd001150 c on a.t$item = c.t$item
                           left join ttcmcs022150 d on c.t$csel = d.t$csel
                           left join twhinh200150 e on a.t$orno = e.t$orno and a.t$cwar = e.t$stco
                           left join ttccus029150  f on f.t$item = a.t$item
                           where d.t$csel <> ' ' AND c.t$ctyp <> ' ' 
                           and f.t$xsqd  in (select regexp_substr('Q04', '[^,]+', 1, level) orgid
                                      from dual
                       connect by level <= regexp_count('Q04','[^,]+') )
                           and a.t$cwar in (select regexp_substr('101001', '[^,]+', 1, level) orgid
                            from dual connect by level <= regexp_count('101001','[^,]+'))
                            and ( to_date(NEW_TIME(a.t$trdt,'PST','GMT')) >= to_date('2019-09-01','yyyy-mm-dd')
                                  and  to_date(NEW_TIME(a.t$trdt,'PST','GMT')) <= to_date('2019-09-02','yyyy-mm-dd'))
                            and e.t$seri not in ('M01','M03','M06','T22','M07','M08','M11','M13','M15','M16','M18')
                           and a.t$koor in (36) and a.t$kost in (3)
                           and  a.t$phtr = 1 
                           group by d.t$csel,c.t$ctyp  order by  t$csel asc )t5  on a.t$csel = t5.t$csel    and a.t$ctyp = t5.t$ctyp

              left join (select d.t$csel,c.t$ctyp,sum(a.t$qstk) 销售退货入库数量 from twhinr110150 a

                           left join ttcibd001150 c on a.t$item = c.t$item
                           left join ttcmcs022150 d on c.t$csel = d.t$csel
                           left join ttccus029150  e on e.t$item = a.t$item
                           where d.t$csel <>  ' ' AND c.t$ctyp <> ' ' 
                           and e.t$xsqd  in (select regexp_substr('Q04', '[^,]+', 1, level) orgid
                                      from dual
                       connect by level <= regexp_count('Q04','[^,]+') )
                           and a.t$cwar in ('102001')
                           and ( to_date(NEW_TIME(a.t$trdt,'PST','GMT')) >= to_date('2019-09-01','yyyy-mm-dd')
                                  and  to_date(NEW_TIME(a.t$trdt,'PST','GMT')) <= to_date('2019-09-02','yyyy-mm-dd'))
                           and a.t$koor in (3) and a.t$kost in (3)
                           and  a.t$phtr = 1 
                           group by d.t$csel,c.t$ctyp  order by  t$csel asc ) t6 on a.t$csel = t6.t$csel     and a.t$ctyp = t6.t$ctyp

             left join (select d.t$csel,c.t$ctyp,sum(a.t$qstk) 销售出库数量 from twhinr110150 a

                           left join ttcibd001150 c on a.t$item = c.t$item
                           left join ttcmcs022150 d on c.t$csel = d.t$csel
                       left join ttccus029150  e on e.t$item = a.t$item
                           where d.t$csel <>  ' ' AND c.t$ctyp <> ' ' 
                           and e.t$xsqd  in (select regexp_substr('Q04', '[^,]+', 1, level) orgid
                                      from dual
                       connect by level <= regexp_count('Q04','[^,]+') )
                           and a.t$cwar in (select regexp_substr('101001', '[^,]+', 1, level) orgid
                            from dual connect by level <= regexp_count('101001','[^,]+'))
                            and ( to_date(NEW_TIME(a.t$trdt,'PST','GMT')) >= to_date('2019-09-01','yyyy-mm-dd')
                                  and  to_date(NEW_TIME(a.t$trdt,'PST','GMT')) <= to_date('2019-09-02','yyyy-mm-dd'))
                           and a.t$koor in (3) and a.t$kost in (5)
                           and  a.t$phtr = 1 
                           group by d.t$csel,c.t$ctyp  order by  t$csel asc )t7 on a.t$csel = t7.t$csel  and a.t$ctyp = t7.t$ctyp
             left join (select c.t$ctyp,d.t$csel,sum(a.t$qstk) 调拨出库数量 from twhinr110150 a

                         left join ttcibd001150 c on a.t$item = c.t$item
                         left join ttcmcs022150 d on c.t$csel = d.t$csel
                         left join twhinh200150 e on a.t$orno = e.t$orno and a.t$cwar = e.t$sfco
                         left join ttccus029150  f on f.t$item = a.t$item
                         where d.t$csel <>  ' ' AND c.t$ctyp <> ' '  
                         and f.t$xsqd  in (select regexp_substr('Q04', '[^,]+', 1, level) orgid
                                      from dual
                       connect by level <= regexp_count('Q04','[^,]+') )
                         and a.t$cwar in (select regexp_substr('101001', '[^,]+', 1, level) orgid
                            from dual connect by level <= regexp_count('101001','[^,]+'))
                         and ( to_date(NEW_TIME(a.t$trdt,'PST','GMT')) >= to_date('2019-09-01','yyyy-mm-dd')
                                  and  to_date(NEW_TIME(a.t$trdt,'PST','GMT')) <= to_date('2019-09-02','yyyy-mm-dd'))
                         /*and e.t$seri not in ('M01','M03','M06','T22','M07','M08','M11','M13','M15','M16','M18')*/
                         and a.t$koor in (36) and a.t$kost in (5)
                         and  a.t$phtr = 1 
                         group by c.t$ctyp,d.t$csel  order by  t$csel asc ) t9 on a.t$csel = t9.t$csel  and a.t$ctyp = t9.t$ctyp
 
