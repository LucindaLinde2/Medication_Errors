select count(*)
from BB_HACK_SYMPTOMS -- 454
where DRG_TYPE like '%APR%' -- 221

select SUBJECT_ID, count(*)
from BB_HACK_SYMPTOMS -- 454
where DRG_TYPE like '%APR%' -- 221
group by SUBJECT_ID
order by count(*) desc -- it is not at the patient level


select HADM_ID, count(*)
from BB_HACK_SYMPTOMS -- 454
where DRG_TYPE like '%APR%' -- 221
group by HADM_ID
order by count(*) desc -- it is at the admissions level

symptoms as (
  select b.ID,
    b.SUBJECT_ID,
    b.HADM_ID,
    b.DRG_TYPE,
    b.DRG_CODE,
    b.DESCRIPTION,
    b.DRG_SEVERITY,
    b.DRG_MORTALITY
  from BB_HACK_SYMPTOMS b -- 454
  where b.DRG_TYPE like '%APR%' -- 221
)


select * from BB_HACK_SYMPTOMS 

where SUBJECT_ID = 10020740


create table bb_hack_adm_pat_sym_ser compress nologging as
with
admission_count as (
  select SUBJECT_ID, count(*) as admission_count
  from BB_HACK_ADMISSIONS
  group by SUBJECT_ID
  having count(*) <= 1
  order by count(*) desc
),
subject_52_admission as (
  select *
  from BB_HACK_ADMISSIONS
  where SUBJECT_ID in (select SUBJECT_ID from admission_count)
),
patient_admission_join as (
  select a.*, p.GENDER, p.ANCHOR_AGE, p.ANCHOR_YEAR, p.ANCHOR_YEAR_GROUP, p.DOD
  from subject_52_admission a
  left join bb_hack_patients p
  on a.SUBJECT_ID = p.SUBJECT_ID
),
symptoms as (
  select b.ID,
    b.SUBJECT_ID,
    b.HADM_ID,
    b.DRG_TYPE,
    b.DRG_CODE,
    b.DESCRIPTION,
    b.DRG_SEVERITY,
    b.DRG_MORTALITY
  from BB_HACK_SYMPTOMS b -- 454
  where b.DRG_TYPE like '%APR%' -- 221
),
adm_patient_symptoms as (
  select a.ID
  , a.SUBJECT_ID
  , a.HADM_ID
  , a.ADMITTIME
  , a.DISCHTIME
  , a.DEATHTIME
  , a.ADMISSION_TYPE
  , a.ADMIT_PROVIDER_ID
  , a.ADMISSION_LOCATION
  , a.DISCHARGE_LOCATION
  , a.INSURANCE
  , a.LANGUAGE
  , a.MARITAL_STATUS
  , a.RACE
  , a.EDREGTIME
  , a.EDOUTTIME
  , a.HOSPITAL_EXPIRE_FLAG
  , a.GENDER
  , a.ANCHOR_AGE
  , a.ANCHOR_YEAR
  , a.ANCHOR_YEAR_GROUP
  , a.DOD
  , b.DRG_TYPE
  , b.DRG_CODE
  , b.DESCRIPTION
  , b.DRG_SEVERITY
  , b.DRG_MORTALITY
  from patient_admission_join a
  left join symptoms b
  on a.SUBJECT_ID = b.SUBJECT_ID
    and a.HADM_ID = b.HADM_ID
),
services_count as (
  select SUBJECT_ID, HADM_ID, count(*) as count
  from BB_HACK_SERVICES
  group by SUBJECT_ID, HADM_ID
  having COUNT(*) <= 1
),
subject_240_1services as (
  select *
  from BB_HACK_SERVICES
  where SUBJECT_ID || '_' || HADM_ID in (select SUBJECT_ID || '_' || HADM_ID from services_count)
),
adm_patient_symptoms_services as (
    select a.ID
    , a.SUBJECT_ID
    , a.HADM_ID
    , a.ADMITTIME
    , a.DISCHTIME
    , a.DEATHTIME
    , a.ADMISSION_TYPE
    , a.ADMIT_PROVIDER_ID
    , a.ADMISSION_LOCATION
    , a.DISCHARGE_LOCATION
    , a.INSURANCE
    , a.LANGUAGE
    , a.MARITAL_STATUS
    , a.RACE
    , a.EDREGTIME
    , a.EDOUTTIME
    , a.HOSPITAL_EXPIRE_FLAG
    , a.GENDER
    , a.ANCHOR_AGE
    , a.ANCHOR_YEAR
    , a.ANCHOR_YEAR_GROUP
    , a.DOD
    , a.DRG_TYPE
    , a.DRG_CODE
    , a.DESCRIPTION
    , a.DRG_SEVERITY
    , a.DRG_MORTALITY
    , c.TRANSFERTIME
    , c.PREV_SERVICE
    , c.CURR_SERVICE
  from subject_240_1services c
  inner join adm_patient_symptoms a
  on c.SUBJECT_ID = a.SUBJECT_ID
    and c.HADM_ID = a.HADM_ID
)
select *
from adm_patient_symptoms_services -- 44 



create table bb_hack_pres
with 
patients as (
  select SUBJECT_ID, GENDER, ANCHOR_AGE, ANCHOR_YEAR, ANCHOR_YEAR_GROUP, DOD
  from bb_hack_patients
),
pres as (
  select ID
      ,SUBJECT_ID
      ,HADM_ID
      ,PHARMACY_ID
      ,POE_ID
      ,POE_SEQ
      ,ORDER_PROVIDER_ID
      ,STARTTIME
      ,STOPTIME
      ,DRUG_TYPE
      ,DRUG
      ,FORMULARY_DRUG_CD
      ,GSN
      ,NDC
      ,PROD_STRENGTH
      ,FORM_RX
      ,DOSE_VAL_RX
      ,DOSE_UNIT_RX
      ,FORM_VAL_DISP
      ,FORM_UNIT_DISP
      ,DOSES_PER_24_HRS
      ,ROUTE
  from BB_HACK_PRESCRIPTION
  where NDC is not null -- 17065
    --and GSN is not null -- 14635
    and drug_type is not null 
    and drug is not null 
    and FORMULARY_DRUG_CD is not null -- 17,065
    and PROD_STRENGTH is not null -- 17065
    and DOSE_VAL_RX is not null and DOSE_VAL_RX > 0 -- 17065 and 16637
    and DOSE_UNIT_RX is not null -- 16637
    and FORM_VAL_DISP is not null and FORM_VAL_DISP > 0  -- 16637
    and FORM_UNIT_DISP is not null -- 16637
    and DOSES_PER_24_HRS is not null -- 10526 ------ 24 hour doses is bring it down a lot
    and ROUTE is not null -- 10526 ------ 10526
),
output as (
  select p.ID
  ,p.SUBJECT_ID
  ,a.GENDER 
  ,a.ANCHOR_AGE
  ,p.HADM_ID
  ,p.PHARMACY_ID
  ,p.POE_ID
  ,p.POE_SEQ
  ,p.ORDER_PROVIDER_ID
  ,p.STARTTIME
  ,p.STOPTIME
  ,p.DRUG_TYPE
  ,p.DRUG
  ,p.FORMULARY_DRUG_CD
  ,p.GSN
  ,p.NDC
  ,p.PROD_STRENGTH
  ,p.DOSE_VAL_RX
  ,p.DOSE_UNIT_RX
  ,p.FORM_VAL_DISP
  ,p.FORM_UNIT_DISP
  ,p.DOSES_PER_24_HRS
  ,p.ROUTE
  from pres p
  left join patients a
  on p.SUBJECT_ID = a.SUBJECT_ID
)
select *
from output


----------


with 
patients as (
  select SUBJECT_ID, GENDER, ANCHOR_AGE, ANCHOR_YEAR, ANCHOR_YEAR_GROUP, DOD
  from bb_hack_patients
),
pres as (
  select ID
      ,SUBJECT_ID
      ,HADM_ID
      ,PHARMACY_ID
      ,POE_ID
      ,POE_SEQ
      ,ORDER_PROVIDER_ID
      ,STARTTIME
      ,STOPTIME
      ,DRUG_TYPE
      ,DRUG
      ,FORMULARY_DRUG_CD
      ,GSN
      ,NDC
      ,PROD_STRENGTH
      ,FORM_RX
      ,DOSE_VAL_RX
      ,DOSE_UNIT_RX
      ,FORM_VAL_DISP
      ,FORM_UNIT_DISP
      ,DOSES_PER_24_HRS
      ,ROUTE
  from BB_HACK_PRESCRIPTION
  where NDC is not null -- 17065
    --and GSN is not null -- 14635
    and drug_type is not null 
    and drug is not null 
    and FORMULARY_DRUG_CD is not null -- 17,065
    and PROD_STRENGTH is not null -- 17065
    and DOSE_VAL_RX is not null and DOSE_VAL_RX > 0 -- 17065 and 16637
    and DOSE_UNIT_RX is not null -- 16637
    and FORM_VAL_DISP is not null and FORM_VAL_DISP > 0  -- 16637
    and FORM_UNIT_DISP is not null -- 16637
    and DOSES_PER_24_HRS is not null -- 10526 ------ 24 hour doses is bring it down a lot
    and ROUTE is not null -- 10526 ------ 10526
),
output as (
  select p.ID
  ,p.SUBJECT_ID
  ,a.GENDER 
  ,a.ANCHOR_AGE
  ,p.HADM_ID
  ,p.PHARMACY_ID
  ,p.POE_ID
  ,p.POE_SEQ
  ,p.ORDER_PROVIDER_ID
  ,p.STARTTIME
  ,p.STOPTIME
  ,p.DRUG_TYPE
  ,p.DRUG
  ,p.FORMULARY_DRUG_CD
  ,p.GSN
  ,p.NDC
  ,p.PROD_STRENGTH
  ,p.DOSE_VAL_RX
  ,p.DOSE_UNIT_RX
  ,p.FORM_VAL_DISP
  ,p.FORM_UNIT_DISP
  ,p.DOSES_PER_24_HRS
  ,p.ROUTE
  from pres p
  left join patients a
  on p.SUBJECT_ID = a.SUBJECT_ID
)
select *
from output

--------

with
admission_count as (
  select SUBJECT_ID, count(*) as admission_count
  from BB_HACK_ADMISSIONS
  group by SUBJECT_ID
  order by count(*) desc
),
subject_52_admission as (
  select *
  from BB_HACK_ADMISSIONS
  where SUBJECT_ID in (select SUBJECT_ID from admission_count where admission_count <=1)
),
patient_admission_join as (
  select a.*, p.GENDER, p.ANCHOR_AGE, p.ANCHOR_YEAR, p.ANCHOR_YEAR_GROUP, p.DOD
  from subject_52_admission a
  left join bb_hack_patients p
  on a.SUBJECT_ID = p.SUBJECT_ID
),
symptoms as (
  select b.ID,
    b.SUBJECT_ID,
    b.HADM_ID,
    b.DRG_TYPE,
    b.DRG_CODE,
    b.DESCRIPTION,
    b.DRG_SEVERITY,
    b.DRG_MORTALITY
  from BB_HACK_SYMPTOMS b -- 454
  where b.DRG_TYPE like '%APR%' -- 221
)
select a.ID
, a.SUBJECT_ID
, a.HADM_ID
, a.ADMITTIME
, a.DISCHTIME
, a.DEATHTIME
, a.ADMISSION_TYPE
, a.ADMIT_PROVIDER_ID
, a.ADMISSION_LOCATION
, a.DISCHARGE_LOCATION
, a.INSURANCE
, a.LANGUAGE
, a.MARITAL_STATUS
, a.RACE
, a.EDREGTIME
, a.EDOUTTIME
, a.HOSPITAL_EXPIRE_FLAG
, a.GENDER
, a.ANCHOR_AGE
, a.ANCHOR_YEAR
, a.ANCHOR_YEAR_GROUP
, a.DOD
, b.DRG_TYPE
, b.DRG_CODE
, b.DESCRIPTION
, b.DRG_SEVERITY
, b.DRG_MORTALITY
from patient_admission_join a
left join symptoms b
on a.SUBJECT_ID = b.SUBJECT_ID
  and a.HADM_ID = b.HADM_ID
-----




with
admission_count as (
  select SUBJECT_ID, count(*) as admission_count
  from BB_HACK_ADMISSIONS
  group by SUBJECT_ID
  order by count(*) desc
),
subject_52_admission as (
  select *
  from BB_HACK_ADMISSIONS
  where SUBJECT_ID in (select SUBJECT_ID from admission_count where admission_count <=1)
),
patient_admission_join as (
  select a.*, p.GENDER, p.ANCHOR_AGE, p.ANCHOR_YEAR, p.ANCHOR_YEAR_GROUP, p.DOD
  from subject_52_admission a
  left join bb_hack_patients p
  on a.SUBJECT_ID = p.SUBJECT_ID
),
symptoms as (
  select b.ID,
    b.SUBJECT_ID,
    b.HADM_ID,
    b.DRG_TYPE,
    b.DRG_CODE,
    b.DESCRIPTION,
    b.DRG_SEVERITY,
    b.DRG_MORTALITY
  from BB_HACK_SYMPTOMS b -- 454
  where b.DRG_TYPE like '%APR%' -- 221
),
adm_patient_symptoms as (
  select a.ID
  , a.SUBJECT_ID
  , a.HADM_ID
  , a.ADMITTIME
  , a.DISCHTIME
  , a.DEATHTIME
  , a.ADMISSION_TYPE
  , a.ADMIT_PROVIDER_ID
  , a.ADMISSION_LOCATION
  , a.DISCHARGE_LOCATION
  , a.INSURANCE
  , a.LANGUAGE
  , a.MARITAL_STATUS
  , a.RACE
  , a.EDREGTIME
  , a.EDOUTTIME
  , a.HOSPITAL_EXPIRE_FLAG
  , a.GENDER
  , a.ANCHOR_AGE
  , a.ANCHOR_YEAR
  , a.ANCHOR_YEAR_GROUP
  , a.DOD
  , b.DRG_TYPE
  , b.DRG_CODE
  , b.DESCRIPTION
  , b.DRG_SEVERITY
  , b.DRG_MORTALITY
  from patient_admission_join a
  left join symptoms b
  on a.SUBJECT_ID = b.SUBJECT_ID
    and a.HADM_ID = b.HADM_ID
)
select count(*) from adm_patient_symptoms -- 52 




select *
from bb_hack_adm_pat_sym_ser
order by DRG_SEVERITY asc, DRG_MORTALITY asc  

SELECT * FROM bb_hack_adm_pat_sym_ser

with
pres as (
  select ID
      ,SUBJECT_ID
      ,HADM_ID
      ,PHARMACY_ID
      ,POE_ID
      ,POE_SEQ
      ,ORDER_PROVIDER_ID
      ,STARTTIME
      ,STOPTIME
      ,DRUG_TYPE
      ,DRUG
      ,FORMULARY_DRUG_CD
      ,GSN
      ,NDC
      ,PROD_STRENGTH
      ,FORM_RX
      ,DOSE_VAL_RX
      ,DOSE_UNIT_RX
      ,FORM_VAL_DISP
      ,FORM_UNIT_DISP
      ,DOSES_PER_24_HRS
      ,ROUTE
  from BB_HACK_PRESCRIPTION
)
select *
from pres
where SUBJECT_ID || '_' || HADM_ID in (select SUBJECT_ID || '_' || HADM_ID from bb_hack_adm_pat_sym_ser) -- 3, 570


with
pres as (
  select *
  from BB_HACK_PRESCRIPTION
  where NDC is not null -- 17065
    and drug_type is not null 
    and drug is not null 
    and FORMULARY_DRUG_CD is not null -- 17,065
    and PROD_STRENGTH is not null -- 17065
    and DOSE_VAL_RX is not null and DOSE_VAL_RX > 0 -- 17065 and 16637
    and DOSE_UNIT_RX is not null -- 16637
    and FORM_VAL_DISP is not null and FORM_VAL_DISP > 0  -- 16637
    and FORM_UNIT_DISP is not null -- 16637
    and DOSES_PER_24_HRS is not null -- 10526 ------ 24 hour doses is bring it down a lot
    and ROUTE is not null -- 10526 ------ 10526
),
PRES_FILTER AS (
  select *
  from pres
  where SUBJECT_ID || '_' || HADM_ID in (select SUBJECT_ID || '_' || HADM_ID from bb_hack_adm_pat_sym_ser) -- 1,983
),
PRES_CUST_ADD_SERVICE AS (
  SELECT A.*
        ,b.ADMITTIME
        ,b.DISCHTIME
        ,b.DEATHTIME
        ,b.ADMISSION_TYPE
        ,b.ADMIT_PROVIDER_ID
        ,b.ADMISSION_LOCATION
        ,b.DISCHARGE_LOCATION
        ,b.INSURANCE
        ,b.LANGUAGE
        ,b.MARITAL_STATUS
        ,b.RACE
        ,b.EDREGTIME
        ,b.EDOUTTIME
        ,b.HOSPITAL_EXPIRE_FLAG
        ,b.GENDER
        ,b.ANCHOR_AGE
        ,b.ANCHOR_YEAR
        ,b.ANCHOR_YEAR_GROUP
        ,b.DOD
        ,b.DRG_TYPE
        ,b.DRG_CODE
        ,b.DESCRIPTION
        ,b.DRG_SEVERITY
        ,b.DRG_MORTALITY
        ,b.TRANSFERTIME
        ,b.PREV_SERVICE
        ,b.CURR_SERVICE
  FROM PRES_FILTER A 
  LEFT JOIN bb_hack_adm_pat_sym_ser B
  ON A.SUBJECT_ID = B.SUBJECT_ID 
    AND A.HADM_ID = B.HADM_ID
)
select distinct DRUG, DESCRIPTION
from PRES_CUST_ADD_SERVICE

SELECT count(distinct SUBJECT_ID), count(distinct HADM_ID), count(distinct DRUG), count(distinct DESCRIPTION)
FROM PRES_CUST_ADD_SERVICE

COUNT(DISTINCTSUBJECT_ID) COUNT(DISTINCTHADM_ID)  COUNT(DISTINCTDRUG) COUNT(DISTINCTDESCRIPTION)
44                        44                      271                 27





