
alter PROCEDURE kkCiroPaket @baslangicTarih date, @bitisTarih date
AS
declare @maksFiyatTarih date;

set @maksFiyatTarih= DATEADD(month, 2, @bitisTarih);

with altFiyat as (SELECT STOKKODU,FIYAT1,FIYATDOVIZTIPI,BASTAR,ROW_NUMBER() OVER (PARTITION BY STOKKODU ORDER BY BASTAR DESC) AS DuplicateCount FROM TBLSTOKFIAT where BASTAR<@maksFiyatTarih),
dolarKur as (SELECT SIRA,TARIH,DOV_ALIS as USDTRY FROM [NETSIS].dbo.[DOVIZ] WHERE SIRA=1), 
euroKur as (SELECT SIRA,TARIH,DOV_ALIS AS EURTRY FROM [NETSIS].dbo.[DOVIZ] WHERE SIRA=2), 
toplamPaket as (select distinct count(ham_kodu) as Toplam_Paket_Adedi,isemrino,mamul_kodu from tblisemrirec where ham_kodu like 'P%' group by isemrino,mamul_kodu) 
--CARI ISIM SADELESTIR
SELECT distinct CASE WHEN f.CARI_ISIM='VITA BIANCA MOB.TEKS.INS.ITH.IHR.PAZ.SAN.VE TIC.LTD.STI. (TL)' THEN 'MAGAZA'
WHEN f.CARI_ISIM='SAFAT HOME GENERAL TRADÝNG & CONTRACTÝNG CO. SPC' THEN 'SAFAT'
WHEN f.CARI_ISIM='PAN EMIRATES HOME FURNISHINGS LLC' THEN 'PAN'
WHEN f.CARI_ISIM='PAN EMIRATES TRADING' THEN 'PAN'
WHEN f.CARI_ISIM='PAN EMIRATES FURNITURE' THEN 'PAN'
WHEN f.CARI_ISIM='PAN EMIRATES FURNITURE W.L.L' THEN 'PAN'
WHEN f.CARI_ISIM='WHITE BUTTERFLY COMPANY' THEN 'LIBYA'
WHEN f.CARI_ISIM='VERANDA INTERNI LLC.' THEN 'VERANDA'
WHEN f.CARI_ISIM='D.HAUS S.P.C' THEN 'D.HAUS'
WHEN f.CARI_ISIM LIKE 'VÝTA BÝANCA AHÞAP%' THEN 'AHSAP'
WHEN f.CARI_ISIM LIKE 'EÝCHHOLTZ B.V.' THEN 'EICHHOLTZ'
WHEN f.CARI_ISIM LIKE 'CENTRO FURNÝTURE' THEN 'CENTRO'
WHEN f.CARI_ISIM LIKE 'CÝDDÝ HOME CENTER LTD.' THEN 'CIDDI HOME'
ELSE f.CARI_ISIM
END AS MUSTERI,TEPESIPNO AS SIPNO,TEPESIPKONT AS SIRA,
--FABRIKA BUL
case when SUBSTRING(b.TEPEMAM,1,2)= 'MD' then 'DOSEMELI' 
when SUBSTRING(b.TEPEMAM,1,2)= 'MM' AND i.stok_adi not like '%simon%sehpa%' and i.stok_adi not like '%carmen%konsol%' and i.stok_adi not like '%joey%sehpa%' and i.stok_adi not like '%bernard%' and i.stok_adi not like '%elanor%' and i.stok_adi not like '%c
adiz%' and i.stok_adi not like '%elenor%' then 'MODULER' 
when SUBSTRING(b.TEPEMAM,1,2)= 'MM' AND (i.stok_adi like '%simon%sehpa%' or i.stok_adi like '%carmen%konsol%' or i.stok_adi like '%joey%sehpa%' or i.stok_adi like '%bernard%' or i.stok_adi like '%elanor%' or i.stok_adi like '%cadiz%' or 
i.stok_adi not like '%elanor%') then 'AHSAP' 
WHEN SUBSTRING(b.TEPEMAM,1,2)= 'SS' then 'SSH' 
WHEN SUBSTRING(b.TEPEMAM,1,2)= 'MP' then 'ARGE'
ELSE 'HATA' END AS FABRIKA, 
TEPEMAM AS URUN, i.STOK_ADI AS [URUN ADI],
--iskontolu fiyat uygula, siparişte fiyat yok ise tblstokfiattan çek
CASE WHEN e.STHAR_BF <>0 AND e.STHAR_DOVTIP=0 AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(e.STOK_KODU,1,2)= 'MD' then cast ((e.STHAR_BF/c.USDTRY)*0.8*0.90 as float)
	WHEN e.STHAR_BF <>0 AND STHAR_DOVFIAT<>0 AND STHAR_DOVFIAT<>1 AND e.STHAR_DOVTIP=1 AND e.STHAR_CARIKOD = '120AA10002' and SUBSTRING(e.STOK_KODU,1,2)= 'MD' then cast ((e.STHAR_DOVFIAT*0.8*0.90) as float)
	WHEN e.STHAR_BF <>0 AND STHAR_DOVFIAT<>0 AND STHAR_DOVFIAT<>1 AND e.STHAR_DOVTIP=2 AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(e.STOK_KODU,1,2)= 'MD' then cast ((e.STHAR_DOVFIAT*(g.EURTRY/c.USDTRY))*0.8*0.90 as float)
	WHEN e.STHAR_BF <>0 AND e.STHAR_DOVTIP=0 AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(e.STOK_KODU,1,2)= 'MM'then cast (((e.STHAR_BF/c.USDTRY)*0.85*0.95) as float)
	WHEN e.STHAR_BF <>0 AND STHAR_DOVFIAT<>0 AND STHAR_DOVFIAT<>1 AND e.STHAR_DOVTIP=1 AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(e.STOK_KODU,1,2)= 'MM'then cast ((e.STHAR_DOVFIAT*0.85*0.95) as float)
	WHEN e.STHAR_BF <>0 AND STHAR_DOVFIAT<>0 AND STHAR_DOVFIAT<>1 AND e.STHAR_DOVTIP=2 AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(e.STOK_KODU,1,2)= 'MM'then cast (((e.STHAR_DOVFIAT*(g.EURTRY/c.USDTRY))*0.85*0.95) as float)
	WHEN e.STHAR_BF <>0 and e.STHAR_DOVTIP=0 AND e.STHAR_CARIKOD<>'120AA10002' then cast ((e.STHAR_BF/c.USDTRY) as float)
	WHEN e.STHAR_BF <>0 AND STHAR_DOVFIAT<>0 AND STHAR_DOVFIAT<>1 AND e.STHAR_DOVTIP=1 AND e.STHAR_CARIKOD<>'120AA10002' then cast (e.STHAR_DOVFIAT as float)
	WHEN e.STHAR_BF <>0 AND STHAR_DOVFIAT<>0 AND STHAR_DOVFIAT<>1 AND e.STHAR_DOVTIP=2 AND e.STHAR_CARIKOD<>'120AA10002' then cast ((e.STHAR_DOVFIAT*(g.EURTRY/c.USDTRY)) as float)
	--STOKFIAT-ISKONTO-
	when (e.STHAR_BF =0) AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(d.STOKKODU,1,2)= 'MD' and FIYATDOVIZTIPI=0 and DuplicateCount=1 THEN cast(((FIYAT1/c.USDTRY)*0.8*0.95) as float)
	when (e.STHAR_BF =0 OR e.STHAR_DOVFIAT=1 OR e.STHAR_DOVFIAT=0) AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(d.STOKKODU,1,2)= 'MD' and FIYATDOVIZTIPI=1 and DuplicateCount=1 THEN cast((FIYAT1*0.8*0.95) as float)
	when (e.STHAR_BF =0 OR e.STHAR_DOVFIAT=1 OR e.STHAR_DOVFIAT=0) AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(d.STOKKODU,1,2)= 'MD' and FIYATDOVIZTIPI=2 and DuplicateCount=1 THEN cast((FIYAT1*(g.EURTRY/c.USDTRY))*0.8*0.95 as float)
	when (e.STHAR_BF =0) AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(d.STOKKODU,1,2)= 'MM' and FIYATDOVIZTIPI=0 and DuplicateCount=1 THEN cast(((FIYAT1/c.USDTRY)*0.85*0.95) as float)
	when (e.STHAR_BF =0 OR e.STHAR_DOVFIAT=1 OR e.STHAR_DOVFIAT=0) AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(d.STOKKODU,1,2)= 'MM' and FIYATDOVIZTIPI=1 and DuplicateCount=1 THEN cast((FIYAT1*0.85*0.95) as float)
	when (e.STHAR_BF =0 OR e.STHAR_DOVFIAT=1 OR e.STHAR_DOVFIAT=0) AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(d.STOKKODU,1,2)= 'MM' and FIYATDOVIZTIPI=2 and DuplicateCount=1 THEN cast((FIYAT1*(g.EURTRY/c.USDTRY))*0.85*0.95 as float)
	--STOKFIAT ISKONTOSUZ
	when (e.STHAR_BF =0) AND e.STHAR_CARIKOD<>'120AA10002' and FIYATDOVIZTIPI=0 and DuplicateCount=1 THEN cast((FIYAT1/c.USDTRY) as float)
	when (e.STHAR_BF =0 OR e.STHAR_DOVFIAT=1 OR e.STHAR_DOVFIAT=0) AND e.STHAR_CARIKOD<>'120AA10002' and FIYATDOVIZTIPI=1 and DuplicateCount=1 THEN cast(FIYAT1 as float)
	when (e.STHAR_BF =0 OR e.STHAR_DOVFIAT=1 OR e.STHAR_DOVFIAT=0) AND e.STHAR_CARIKOD<>'120AA10002' and FIYATDOVIZTIPI=2 and DuplicateCount=1 THEN cast((FIYAT1*(g.EURTRY/c.USDTRY)) as float)
	else 0 
	end as FIYAT,		

URETSON_MAMUL AS PAKET,CAST (URETSON_MIKTAR AS INT) AS PAKET_MIKTAR,URETSON_TARIH,Toplam_Paket_Adedi,
--toplam fiyat bul
isnull(cast((CASE WHEN e.STHAR_BF <>0 AND e.STHAR_DOVTIP=0 AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(e.STOK_KODU,1,2)= 'MD' then cast ((e.STHAR_BF/c.USDTRY)*0.8*0.90 as float)
	WHEN e.STHAR_BF <>0 AND STHAR_DOVFIAT<>0 AND STHAR_DOVFIAT<>1 AND e.STHAR_DOVTIP=1 AND e.STHAR_CARIKOD = '120AA10002' and SUBSTRING(e.STOK_KODU,1,2)= 'MD' then cast ((e.STHAR_DOVFIAT*0.8*0.90) as float)
	WHEN e.STHAR_BF <>0 AND STHAR_DOVFIAT<>0 AND STHAR_DOVFIAT<>1 AND e.STHAR_DOVTIP=2 AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(e.STOK_KODU,1,2)= 'MD' then cast ((e.STHAR_DOVFIAT*(g.EURTRY/c.USDTRY))*0.8*0.90 as float)
	WHEN e.STHAR_BF <>0 AND e.STHAR_DOVTIP=0 AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(e.STOK_KODU,1,2)= 'MM'then cast (((e.STHAR_BF/c.USDTRY)*0.85*0.95) as float)
	WHEN e.STHAR_BF <>0 AND STHAR_DOVFIAT<>0 AND STHAR_DOVFIAT<>1 AND e.STHAR_DOVTIP=1 AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(e.STOK_KODU,1,2)= 'MM'then cast ((e.STHAR_DOVFIAT*0.85*0.95) as float)
	WHEN e.STHAR_BF <>0 AND STHAR_DOVFIAT<>0 AND STHAR_DOVFIAT<>1 AND e.STHAR_DOVTIP=2 AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(e.STOK_KODU,1,2)= 'MM'then cast (((e.STHAR_DOVFIAT*(g.EURTRY/c.USDTRY))*0.85*0.95) as float)
	WHEN e.STHAR_BF <>0 and e.STHAR_DOVTIP=0 AND e.STHAR_CARIKOD<>'120AA10002' then cast ((e.STHAR_BF/c.USDTRY) as float)
	WHEN e.STHAR_BF <>0 AND STHAR_DOVFIAT<>0 AND STHAR_DOVFIAT<>1 AND e.STHAR_DOVTIP=1 AND e.STHAR_CARIKOD<>'120AA10002' then cast (e.STHAR_DOVFIAT as float)
	WHEN e.STHAR_BF <>0 AND STHAR_DOVFIAT<>0 AND STHAR_DOVFIAT<>1 AND e.STHAR_DOVTIP=2 AND e.STHAR_CARIKOD<>'120AA10002' then cast ((e.STHAR_DOVFIAT*(g.EURTRY/c.USDTRY)) as float)
	--STOKFIAT-ISKONTO-
	when (e.STHAR_BF =0) AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(d.STOKKODU,1,2)= 'MD' and FIYATDOVIZTIPI=0 and DuplicateCount=1 THEN cast(((FIYAT1/c.USDTRY)*0.8*0.95) as float)
	when (e.STHAR_BF =0 OR e.STHAR_DOVFIAT=1 OR e.STHAR_DOVFIAT=0) AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(d.STOKKODU,1,2)= 'MD' and FIYATDOVIZTIPI=1 and DuplicateCount=1 THEN cast((FIYAT1*0.8*0.95) as float)
	when (e.STHAR_BF =0 OR e.STHAR_DOVFIAT=1 OR e.STHAR_DOVFIAT=0) AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(d.STOKKODU,1,2)= 'MD' and FIYATDOVIZTIPI=2 and DuplicateCount=1 THEN cast((FIYAT1*(g.EURTRY/c.USDTRY))*0.8*0.95 as float)
	when (e.STHAR_BF =0) AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(d.STOKKODU,1,2)= 'MM' and FIYATDOVIZTIPI=0 and DuplicateCount=1 THEN cast(((FIYAT1/c.USDTRY)*0.85*0.95) as float)
	when (e.STHAR_BF =0 OR e.STHAR_DOVFIAT=1 OR e.STHAR_DOVFIAT=0) AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(d.STOKKODU,1,2)= 'MM' and FIYATDOVIZTIPI=1 and DuplicateCount=1 THEN cast((FIYAT1*0.85*0.95) as float)
	when (e.STHAR_BF =0 OR e.STHAR_DOVFIAT=1 OR e.STHAR_DOVFIAT=0) AND e.STHAR_CARIKOD='120AA10002' and SUBSTRING(d.STOKKODU,1,2)= 'MM' and FIYATDOVIZTIPI=2 and DuplicateCount=1 THEN cast((FIYAT1*(g.EURTRY/c.USDTRY))*0.85*0.95 as float)
	--STOKFIAT ISKONTOSUZ
	when (e.STHAR_BF =0) AND e.STHAR_CARIKOD<>'120AA10002' and FIYATDOVIZTIPI=0 and DuplicateCount=1 THEN cast((FIYAT1/c.USDTRY) as float)
	when (e.STHAR_BF =0 OR e.STHAR_DOVFIAT=1 OR e.STHAR_DOVFIAT=0) AND e.STHAR_CARIKOD<>'120AA10002' and FIYATDOVIZTIPI=1 and DuplicateCount=1 THEN cast(FIYAT1 as float)
	when (e.STHAR_BF =0 OR e.STHAR_DOVFIAT=1 OR e.STHAR_DOVFIAT=0) AND e.STHAR_CARIKOD<>'120AA10002' and FIYATDOVIZTIPI=2 and DuplicateCount=1 THEN cast((FIYAT1*(g.EURTRY/c.USDTRY)) as float)
	else 0 
	end *
	isnull(cast(uretson_miktar as int),1)) / isnull(cast(toplam_paket_adedi as int),1) as float),0) as Toplam_Fiyat,
	CASE WHEN SUBSTRING(CAST (URETSON_TARIH AS NVARCHAR(MAX)),1,3) = 'Mar' and SUBSTRING(SUBSTRING(CAST (URETSON_TARIH AS NVARCHAR(MAX)),1,11),8,4) = '2023' THEN 282 else 250 end AS HEDEF_PAKET_MODULER, 
	100 AS HEDEF_PAKET_DOSEMELI

 FROM TBLSTOKURS a

LEFT JOIN TBLISEMRI b ON a.URETSON_SIPNO=b.ISEMRINO AND a.URETSON_MAMUL=b.STOK_KODU 
LEFT JOIN dolarKur c on a.URETSON_TARIH=c.TARIH 
LEFT JOIN euroKur g on a.URETSON_TARIH=c.TARIH 
left JOIN altFiyat d ON b.TEPEMAM=d.STOKKODU
LEFT JOIN TBLSIPATRA e ON b.TEPESIPNO=e.FISNO AND b.TEPESIPKONT=e.stra_sipkont AND b.TEPEMAM=e.STOK_KODU
LEFT JOIN TBLCASABIT f ON e.STHAR_CARIKOD=f.CARI_KOD
LEFT JOIN toplamPaket h on b.tepemam=h.mamul_kodu and b.refisemrino=h.isemrino
LEFT JOIN TBLSTSABIT i on b.tepemam=i.stok_kodu
LEFT JOIN TBLSTSABITEK j on i.stok_kodu=j.stok_kodu
WHERE URETSON_MAMUL LIKE 'P%' and URETSON_TARIH>=@baslangicTarih and URETSON_TARIH<@bitisTarih
