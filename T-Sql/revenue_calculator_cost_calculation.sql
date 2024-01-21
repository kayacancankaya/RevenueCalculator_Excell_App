  
  
alter view kkvCiroMaliyetHesapla as   
with stokFiyat as (select STOKKODU,FIYAT1,FIYATDOVIZTIPI,BASTAR,ROW_NUMBER() OVER (PARTITION BY STOKKODU ORDER BY BASTAR DESC) AS sirala from TBLSTOKFIAT WHERE FIYAT1<>0 ),  
stharFiyat AS ( select stok_kodu,sthar_dovfiat,STHAR_NF,STHAR_DOVTIP,STHAR_TARIH,ROW_NUMBER() OVER (PARTITION BY STOK_KODU ORDER BY STHAR_TARIH DESC) AS siralatHar FROM TBLSTHAR WHERE sthar_gckod='G' and sthar_nf<>0 and sthar_htur='j' ),  
dolarKur as (SELECT SIRA,TARIH,DOV_ALIS as USDTRY FROM [NETSIS].dbo.[DOVIZ] WHERE SIRA=1),   
euroKur as (SELECT SIRA,TARIH,DOV_ALIS AS EURTRY FROM [NETSIS].dbo.[DOVIZ] WHERE SIRA=2)   
   
--CARI ISIM SADELESTIR  
SELECT distinct CASE WHEN s.CARI_ISIM='VITA BIANCA MOB.TEKS.INS.ITH.IHR.PAZ.SAN.VE TIC.LTD.STI. (TL)' THEN 'MAGAZA'  
WHEN s.CARI_ISIM='SAFAT HOME GENERAL TRADÝNG & CONTRACTÝNG CO. SPC' THEN 'SAFAT'  
WHEN s.CARI_ISIM='PAN EMIRATES HOME FURNISHINGS LLC' THEN 'PAN'  
WHEN s.CARI_ISIM='PAN EMIRATES TRADING' THEN 'PAN'  
WHEN s.CARI_ISIM='PAN EMIRATES FURNITURE' THEN 'PAN'  
WHEN s.CARI_ISIM='PAN EMIRATES FURNITURE W.L.L' THEN 'PAN'  
WHEN s.CARI_ISIM='WHITE BUTTERFLY COMPANY' THEN 'LIBYA'  
WHEN s.CARI_ISIM='VERANDA INTERNI LLC.' THEN 'VERANDA'  
WHEN s.CARI_ISIM='D.HAUS S.P.C' THEN 'D.HAUS'  
WHEN s.CARI_ISIM LIKE 'VÝTA BÝANCA AHÞAP%' THEN 'AHSAP'  
WHEN s.CARI_ISIM LIKE 'EÝCHHOLTZ B.V.' THEN 'EICHHOLTZ'  
WHEN s.CARI_ISIM LIKE 'CENTRO FURNÝTURE' THEN 'CENTRO'  
WHEN s.CARI_ISIM LIKE 'CÝDDÝ HOME CENTER LTD.' THEN 'CIDDI HOME'  
ELSE s.CARI_ISIM  
END AS MUSTERI,yz.TEPESIPNO,yz.TEPESIPKONT,  
--FABRIKA BUL  
case when SUBSTRING(yz.TEPEMAM,1,2)= 'MD' then 'DOSEMELI'   
when SUBSTRING(yz.TEPEMAM,1,2)= 'MM' AND u.stok_adi not like '%simon%sehpa%' and u.stok_adi not like '%carmen%konsol%' and u.stok_adi not like '%joey%sehpa%' and u.stok_adi not like '%bernard%' and u.stok_adi not like '%elanor%' and u.stok_adi not like '%
  
cadiz%' then 'MODULER'   
when SUBSTRING(yz.TEPEMAM,1,2)= 'MM' AND (u.stok_adi like '%simon%sehpa%' or u.stok_adi like '%carmen%konsol%' or u.stok_adi like '%joey%sehpa%' or u.stok_adi like '%bernard%' or u.stok_adi like '%elanor%' or u.stok_adi like '%cadiz%') then 'AHSAP'   
WHEN SUBSTRING(yz.TEPEMAM,1,2)= 'SS' then 'SSH' ELSE 'HATA' END AS FABRIKA,   
yz.TEPEMAM AS URUN, u.STOK_ADI AS [URUN ADI],  
  
zz.uretson_tarih as uretim_tarihi,b.stok_kodu as mamul_kodu,a.ham_kodu,t.kod_1,  
   
  
--üretilen miktarın iş emri miktarına oranı  
cast(cast (zz.uretson_miktar/b.miktar as float) *   
--reçete miktarı ile iş emri miktar çarpımı  
cast (a.miktar as float) *  cast (b.miktar as float) *    
case when 
  
--STOKFIATTAKİ FİYAT 0 dan büyük ise stokfiat  
ISNULL(CAST(  
CASE WHEN FIYATDOVIZTIPI=0 THEN  FIYAT1/USDTRY  
WHEN FIYATDOVIZTIPI=1 THEN FIYAT1  
WHEN FIYATDOVIZTIPI=2 THEN FIYAT1*(EURTRY/USDTRY)  
END AS FLOAT),0) > 0 
THEN
--STOKFIYATI AL
ISNULL(CAST(  
CASE WHEN FIYATDOVIZTIPI=0 THEN  FIYAT1/USDTRY  
WHEN FIYATDOVIZTIPI=1 THEN FIYAT1  
WHEN FIYATDOVIZTIPI=2 THEN FIYAT1*(EURTRY/USDTRY)  
END AS FLOAT),0)

WHEN
--STHARDAKİ FİYAT 0DAN BÜYÜK İSE  STHARI AL
ISNULL(CASE WHEN n.STHAR_DOVFIAT=0 THEN n.STHAR_NF/USDTRY   
WHEN n.STHAR_DOVFIAT=1 THEN n.STHAR_DOVFIAT   
WHEN n.STHAR_DOVFIAT=2 THEN n.STHAR_DOVFIAT*(EURTRY/USDTRY)  
END,0) > 0 THEN

ISNULL(CASE WHEN n.STHAR_DOVFIAT=0 THEN n.STHAR_NF/USDTRY   
WHEN n.STHAR_DOVFIAT=1 THEN n.STHAR_DOVFIAT   
WHEN n.STHAR_DOVFIAT=2 THEN n.STHAR_DOVFIAT*(EURTRY/USDTRY)  
END,0)

else
0 
END as float) as toplamFiyat,

----STHARDA VEYA STOKFİYATTA FİYAT YOK İSE STSABİT FİYATINI AL   
--ELSE   

--ISNULL(CAST(  
--CASE WHEN t.ALIS_DOV_TIP=0 THEN  t.ALIS_FIAT1/USDTRY  
--WHEN t.ALIS_DOV_TIP=1 THEN t.DOV_ALIS_FIAT  
--WHEN t.ALIS_DOV_TIP=2 THEN t.DOV_ALIS_FIAT*(EURTRY/USDTRY)  
--END AS FLOAT),0)   
--END as float) as toplamFiyat,  

bastar as stokFiatTarih,n.sthar_tarih   
from tblstokurs zz   
left join tblisemri yz on zz.uretson_mamul=yz.stok_kodu and zz.uretson_sipno=yz.isemrino  
left join tblisemrirec a on yz.isemrino=a.isemrino and yz.stok_kodu=a.mamul_kodu  
left join tblisemri b on a.isemrino=b.isemrino and a.mamul_kodu = b.stok_kodu   
left join stokFiyat m on ham_kodu = m.STOKKODU  
left join stharFiyat n on ham_kodu = n.STOK_KODU  
LEFT JOIN dolarKur o on zz.URETSON_TARIH=o.TARIH   
LEFT JOIN euroKur p on zz.URETSON_TARIH=p.TARIH    
LEFT JOIN tblsipatra r ON b.tepesipno=r.fisno and b.tepesipkont=r.stra_sipkont and b.tepemam=r.stok_kodu  
left join tblcasabit s on r.STHAR_CARIKOD=s.CARI_KOD  
left join tblstsabit t on a.ham_kodu=t.stok_kodu  
left join tblstsabit u on yz.tepemam=u.stok_kodu  
where a.ham_kodu like 'hm%'     
AND (sirala =1 or sirala is null)  
AND (siralatHar= 1 or siralatHar is null)   
  
  
--kkCiroMaliyetHesapla @bastar='2023-01-01', @bittar= '2023-02-01', @maks_fiyat_tarih='2023-12-01'  
  
  